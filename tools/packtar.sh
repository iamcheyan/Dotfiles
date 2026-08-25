#!/usr/bin/env bash
# Package the current directory as tar.gz and place it in the parent directory
# Usage: pack_tar.sh [--day <n>] <filename>

set -euo pipefail

# Validate arguments
DAY_RANGE=1
POSITIONAL_ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --day)
            shift
            if [ $# -eq 0 ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
                echo "Error: --day requires a positive integer" >&2
                exit 1
            fi
            DAY_RANGE="$1"
            shift
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -gt 0 ]; then
    set -- "${POSITIONAL_ARGS[@]}"
fi

if [ $# -eq 0 ]; then
    echo "Error: a filename is required" >&2
    echo "Usage: $0 [--today|-t] <filename>" >&2
    exit 1
fi

FILENAME="$1"

# Get the current directory
CURRENT_DIR="$(pwd)"

# Get the parent directory
PARENT_DIR="$(dirname "$CURRENT_DIR")"

# Output path for the tar.gz file
OUTPUT_FILE="${PARENT_DIR}/${FILENAME}.tar.gz"

# Path to the .tar-exclude file in the current directory
EXCLUDE_FILE="${CURRENT_DIR}/.tar-exclude"
GITIGNORE_FILE="${CURRENT_DIR}/.gitignore"
GITIGNORE_EXCLUDE_FILE=""
GIT_INCLUDE_FILE=""
USE_GIT_FILELIST=0
TAR_SUPPORTS_NULL=0
TODAY_INCLUDE_FILE=""
TODAY_MARKER_FILE=""
CLEANUP_FILES=()

cleanup_tmp() {
    if [ ${#CLEANUP_FILES[@]} -gt 0 ]; then
        rm -f "${CLEANUP_FILES[@]}"
    fi
}
trap cleanup_tmp EXIT

if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi

if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--null"; then
    TAR_SUPPORTS_NULL=1
fi

# Run tar
echo "Creating archive: ${CURRENT_DIR} -> ${OUTPUT_FILE}"

# Build tar arguments (ordering is important)
# Correct order: options -> output -> --exclude -> --exclude-from -> -C -> archive path
TAR_ARGS=(
    czf "${OUTPUT_FILE}"
    --exclude=".git"
    --exclude=".git/*"
)

# Apply additional exclusions from .tar-exclude before -C
if [ -f "$EXCLUDE_FILE" ]; then
    echo "Exclusion file: ${EXCLUDE_FILE}"
    TAR_ARGS+=(--exclude-from="${EXCLUDE_FILE}")
fi

# Apply .gitignore rules when available
if [ -f "$GITIGNORE_FILE" ]; then
    echo "Found: ${GITIGNORE_FILE} (applying gitignore exclusions)"
    if command -v git >/dev/null 2>&1 && [ -d "${CURRENT_DIR}/.git" ]; then
        GITIGNORE_MATCHES="$(git -C "${CURRENT_DIR}" ls-files -i -o --exclude-standard --directory)"
        if [ -n "${GITIGNORE_MATCHES}" ]; then
            echo "Excluded files (from gitignore):"
            echo "${GITIGNORE_MATCHES}"
        else
            echo "Excluded files (from gitignore): none"
        fi
        USE_GIT_FILELIST=1
        GIT_INCLUDE_FILE="$(mktemp)"
        CLEANUP_FILES+=("${GIT_INCLUDE_FILE}")
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | \
                while IFS= read -r -d '' path; do
                    if [ -e "${CURRENT_DIR}/${path}" ]; then
                        printf '%s\0' "${path}"
                    fi
                done > "${GIT_INCLUDE_FILE}"
        else
            echo "Warning: this tar has no --null support; paths containing spaces may be mishandled" >&2
            git -C "${CURRENT_DIR}" ls-files --cached --others --exclude-standard | \
                while IFS= read -r path; do
                    if [ -e "${CURRENT_DIR}/${path}" ]; then
                        printf '%s\n' "${path}"
                    fi
                done > "${GIT_INCLUDE_FILE}"
        fi
        echo "Exclusion rule: generate the file list with git ls-files"
    else
        echo "Warning: git is unavailable, so excluded files cannot be listed" >&2
        if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--exclude-vcs-ignores"; then
            echo "Exclusion rule: use tar --exclude-vcs-ignores"
            TAR_ARGS+=(--exclude-vcs-ignores)
        else
            echo "Warning: .gitignore was found but cannot be applied because tar/git support is insufficient" >&2
        fi
    fi
fi

# Append the directory change and archive path last
if [ "${DAY_RANGE}" -gt 0 ]; then
    TODAY_MARKER_FILE="$(mktemp)"
    CLEANUP_FILES+=("${TODAY_MARKER_FILE}")
    if date -d "now - ${DAY_RANGE} days" >/dev/null 2>&1; then
        touch -d "now - ${DAY_RANGE} days" "${TODAY_MARKER_FILE}"
    elif date -v0H -v0M -v0S >/dev/null 2>&1; then
        touch -t "$(date -v-"${DAY_RANGE}"d '+%Y%m%d%H%M.%S')" "${TODAY_MARKER_FILE}"
    else
        touch "${TODAY_MARKER_FILE}"
    fi

    TODAY_INCLUDE_FILE="$(mktemp)"
    CLEANUP_FILES+=("${TODAY_INCLUDE_FILE}")
    if command -v git >/dev/null 2>&1 && [ -d "${CURRENT_DIR}/.git" ]; then
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | \
                while IFS= read -r -d '' path; do
                    if [ -e "${CURRENT_DIR}/${path}" ] && [ "${CURRENT_DIR}/${path}" -nt "${TODAY_MARKER_FILE}" ]; then
                        printf '%s\0' "${path}"
                    fi
                done > "${TODAY_INCLUDE_FILE}"
        else
            echo "Warning: this tar has no --null support; paths containing spaces may be mishandled" >&2
            git -C "${CURRENT_DIR}" ls-files --cached --others --exclude-standard | \
                while IFS= read -r path; do
                    if [ -e "${CURRENT_DIR}/${path}" ] && [ "${CURRENT_DIR}/${path}" -nt "${TODAY_MARKER_FILE}" ]; then
                        printf '%s\n' "${path}"
                    fi
                done > "${TODAY_INCLUDE_FILE}"
        fi
        echo "Exclusion rule: generate the file list with git ls-files (last ${DAY_RANGE} days)"
    else
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            find . -path "./.git" -prune -o -type f -newer "${TODAY_MARKER_FILE}" -print0 > "${TODAY_INCLUDE_FILE}"
        else
            echo "Warning: this tar has no --null support; paths containing spaces may be mishandled" >&2
            find . -path "./.git" -prune -o -type f -newer "${TODAY_MARKER_FILE}" -print > "${TODAY_INCLUDE_FILE}"
        fi
    fi

    if [ ! -s "${TODAY_INCLUDE_FILE}" ]; then
        echo "Error: no files were updated in the last ${DAY_RANGE} days" >&2
        exit 1
    fi

    TAR_ARGS+=(-C "${CURRENT_DIR}")
    if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
        TAR_ARGS+=(--null -T "${TODAY_INCLUDE_FILE}")
    else
        TAR_ARGS+=(-T "${TODAY_INCLUDE_FILE}")
    fi
elif [ "${USE_GIT_FILELIST}" -eq 1 ]; then
    TAR_ARGS+=(-C "${CURRENT_DIR}")
    if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
        TAR_ARGS+=(--null -T "${GIT_INCLUDE_FILE}")
    else
        TAR_ARGS+=(-T "${GIT_INCLUDE_FILE}")
    fi
else
    TAR_ARGS+=(
        -C "${CURRENT_DIR}" .
    )
fi

tar "${TAR_ARGS[@]}"

# Display archive information
if [ -f "${OUTPUT_FILE}" ]; then
    echo "Complete: ${OUTPUT_FILE}"
    echo ""
    echo "Archive information:"
    echo "  Path: ${OUTPUT_FILE}"
    
    # Size in human-readable form and bytes
    FILE_SIZE_H=$(ls -lh "${OUTPUT_FILE}" | awk '{print $5}')
    FILE_SIZE_B=$(stat -c '%s' "${OUTPUT_FILE}" 2>/dev/null || stat -f '%z' "${OUTPUT_FILE}" 2>/dev/null || ls -l "${OUTPUT_FILE}" | awk '{print $5}')
    echo "  Size: ${FILE_SIZE_H} (${FILE_SIZE_B} bytes)"
    
    # Creation time
    if stat -c '%y' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_DATE=$(stat -c '%y' "${OUTPUT_FILE}" | cut -d'.' -f1 | sed 's/ /  /')
    elif stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_DATE=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${OUTPUT_FILE}")
    else
        # Fallback
        FILE_DATE=$(ls -l --time-style=long-iso "${OUTPUT_FILE}" 2>/dev/null | awk '{print $6, $7}' || date '+%Y-%m-%d %H:%M:%S')
    fi
    echo "  Created: ${FILE_DATE}"
    
    # Permissions
    if stat -c '%a' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_PERM=$(stat -c '%a (%A)' "${OUTPUT_FILE}")
    elif stat -f '%OLp' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_PERM=$(stat -f '%OLp (%Sp)' "${OUTPUT_FILE}")
    else
        FILE_PERM=$(ls -l "${OUTPUT_FILE}" | awk '{print $1}')
    fi
    echo "  Permissions: ${FILE_PERM}"
    
    # Owner
    if stat -c '%U:%G' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_OWNER=$(stat -c '%U:%G' "${OUTPUT_FILE}")
    elif stat -f '%Su:%Sg' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_OWNER=$(stat -f '%Su:%Sg' "${OUTPUT_FILE}")
    else
        FILE_OWNER=$(ls -l "${OUTPUT_FILE}" | awk '{print $3":"$4}')
    fi
    echo "  Owner: ${FILE_OWNER}"
else
    echo "Error: the archive was not created" >&2
    exit 1
fi
