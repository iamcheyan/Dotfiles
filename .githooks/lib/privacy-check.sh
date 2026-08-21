#!/usr/bin/env bash

set -euo pipefail

ZERO_SHA="0000000000000000000000000000000000000000"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
USER_HOME="${HOME:-$(getent passwd "$(id -un)" | cut -d: -f6 2>/dev/null || pwd)}"
DOTFILES_DIR="${DOTFILES_DIR:-$REPO_ROOT}"
WIN_HOME_DEFAULT="/mnt/c/Users/${USER:-$(id -un)}"
WIN_HOME="${WIN_HOME:-$WIN_HOME_DEFAULT}"
RIME_DIR="${RIME_DIR:-$WIN_HOME/AppData/Roaming/Rime}"
WIN_HOME_BASENAME="$(basename "$WIN_HOME")"
RIME_SUFFIX="${RIME_DIR#"$WIN_HOME"/}"

regex_escape() {
  printf '%s' "$1" | sed 's/[][(){}.^$+*?|\\/]/\\&/g'
}

HOME_RE="$(regex_escape "$USER_HOME")"
DOTFILES_RE="$(regex_escape "$DOTFILES_DIR")"
WIN_HOME_RE="$(regex_escape "$WIN_HOME")"
RIME_RE="$(regex_escape "$RIME_DIR")"
RIME_SUFFIX_RE="$(regex_escape "$RIME_SUFFIX")"
WIN_HOME_WIN_RE="$(printf '%s' "$WIN_HOME_BASENAME" | sed 's/[][(){}.^$+*?|\\/]/\\&/g')"
export USER_HOME DOTFILES_DIR WIN_HOME RIME_DIR WIN_HOME_BASENAME RIME_SUFFIX

SECRET_REGEX='(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|aws_access_key_id|aws_secret_access_key|authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9._=-]+|token=[A-Za-z0-9._=-]+|client_secret[[:space:]:=]+[^[:space:]]+|password[[:space:]:=]+[^[:space:]]+|passwd[[:space:]:=]+[^[:space:]]+)'
PRIVACY_REGEX="([A-Za-z0-9._%+-]+@(outlook\\.com|gmail\\.com|hotmail\\.com|qq\\.com|icloud\\.com|yahoo\\.com|sbilife\\.co\\.jp)|([0-9]{1,3}\\.){3}[0-9]{1,3}|${DOTFILES_RE}|${HOME_RE}|${RIME_RE}|${WIN_HOME_RE}|${RIME_SUFFIX_RE}|\\\\Users\\\\${WIN_HOME_WIN_RE})"
SAFE_EMAIL_REGEX='(@users[.]noreply[.]github[.]com|@example[.]com|@outlook[.]com)$'
SENSITIVE_PATH_REGEX='(^|/)(private_.*(env|key|secret)|.*[._-](secret|secrets|token|tokens|credential|credentials|passwd|passwords?)([._-].*)?|[.]env([._-].*)?)$'

privacy_tmpdir=

privacy_init_tmpdir() {
  privacy_tmpdir="$(mktemp -d)"
  trap 'rm -rf "$privacy_tmpdir"' EXIT
}

privacy_filter_hits() {
  local input_file="$1"
  local output_file="$2"

  awk '
    BEGIN {
      comment_regex = "^[[:space:]]*(#|//|;|--|/\\*|\\*)"
      doc_path_regex = "[.](md|markdown|mdx|adoc|txt)$"
      example_secret_regex = "(Authorization:\"Bearer (TOKEN|\\$TOKEN)\"|http -a username:password GET https://httpbin\\.org/basic-auth/username/password)"
    }
    {
      if (match($0, /:[0-9]+:/)) {
        line = substr($0, RSTART + RLENGTH)
        before = substr($0, 1, RSTART - 1)
        last_colon = 0
        for (i = 1; i <= length(before); i++) {
          if (substr(before, i, 1) == ":") {
            last_colon = i
          }
        }
        if (last_colon > 0) {
          path = substr(before, last_colon + 1)
        } else {
          path = before
        }
      } else {
        next
      }

      if (path == ".githooks/pre-push") next
      if (path == ".githooks/pre-commit") next
      if (path == ".githooks/lib/privacy-check.sh") next
      if (path == "git.md" && line ~ /(\/home\/[^[:space:]]+\/dotfiles|\\\$HOME\/dotfiles)/) next
      if (path == "doc/git.md" && line ~ /(\/home\/[^[:space:]]+\/dotfiles|\\\$HOME\/dotfiles)/) next
      if (line ~ comment_regex) next
      if (path ~ doc_path_regex && line ~ example_secret_regex) next
      if (line ~ /127[.]0[.]0[.]1/) next
      if (line ~ /0[.]0[.]0[.]0/) next
      print
    }
  ' "$input_file" > "$output_file"
}

privacy_build_path_hints() {
  local input_file="$1"
  local output_file="$2"

  awk '
    BEGIN {
      dotfiles = ENVIRON["DOTFILES_DIR"]
      home = ENVIRON["USER_HOME"]
      win_home = ENVIRON["WIN_HOME"]
      rime_dir = ENVIRON["RIME_DIR"]
      win_home_basename = ENVIRON["WIN_HOME_BASENAME"]
    }
    {
      if (match($0, /:[0-9]+:/)) {
        line = substr($0, RSTART + RLENGTH)
        before = substr($0, 1, RSTART - 1)
        last_colon = 0
        for (i = 1; i <= length(before); i++) {
          if (substr(before, i, 1) == ":") {
            last_colon = i
          }
        }
        if (last_colon > 0) {
          path = substr(before, last_colon + 1)
        } else {
          path = before
        }
      } else {
        next
      }

      if (dotfiles != "" && index(line, dotfiles)) {
        print path ": replace hardcoded dotfiles path with ${DOTFILES_DIR:-$HOME/dotfiles}"
      }
      if (home != "" && index(line, home)) {
        print path ": replace hardcoded home path with $HOME"
      }
      if (rime_dir != "" && index(line, rime_dir)) {
        print path ": replace hardcoded Rime path with ${RIME_DIR}"
      }
      if (win_home != "" && index(line, win_home)) {
        print path ": replace hardcoded Windows home path with ${WIN_HOME}"
      }
      if (ENVIRON["RIME_SUFFIX"] != "" && index(line, ENVIRON["RIME_SUFFIX"])) {
        print path ": replace AppData/Roaming/Rime with ${RIME_DIR}"
      }
      if (win_home_basename != "" && line ~ ("\\\\Users\\\\" win_home_basename)) {
        print path ": replace \\\\Users\\\\" win_home_basename " with ${WIN_HOME_WIN}"
      }
    }
  ' "$input_file" | sort -u > "$output_file"
}

privacy_check_identities() {
  local output_file="$1"

  {
    git var GIT_AUTHOR_IDENT 2>/dev/null || true
    git var GIT_COMMITTER_IDENT 2>/dev/null || true
  } | awk -v safe_email_regex="$SAFE_EMAIL_REGEX" '
    {
      if (match($0, /<[^>]+>/)) {
        email = substr($0, RSTART + 1, RLENGTH - 2)
        name = substr($0, 1, RSTART - 2)
        sub(/[[:space:]]+$/, "", name)
        if (email !~ safe_email_regex) {
          print name "\t" email
        }
      }
    }
  ' | sort -u > "$output_file"
}

privacy_check_paths() {
  local input_file="$1"
  local output_file="$2"

  awk -v sensitive_path_regex="$SENSITIVE_PATH_REGEX" '
    $0 ~ sensitive_path_regex {
      print $0
    }
  ' "$input_file" | sort -u > "$output_file"
}

privacy_report_and_exit() {
  local mode="$1"
  local content_hits="$2"
  local path_hits="$3"

  if [[ ! -s "$content_hits" && ! -s "$path_hits" ]]; then
    return 0
  fi

  echo "${mode}: blocked due to possible secrets." >&2
  echo >&2

  if [[ -s "$content_hits" ]]; then
    echo "Content matches requiring review:" >&2
    sed -n '1,80p' "$content_hits" >&2
    echo >&2
  fi

  if [[ -s "$path_hits" ]]; then
    echo "Sensitive file paths requiring review:" >&2
    sed -n '1,40p' "$path_hits" >&2
    echo >&2
  fi

  echo "Fix the staged files before committing." >&2
  echo "If this is intentional, edit .githooks/pre-commit or .githooks/lib/privacy-check.sh instead of bypassing it." >&2
  exit 1
}

run_pre_commit_check() {
  privacy_init_tmpdir

  local raw_content_hits="$privacy_tmpdir/content_hits_raw.txt"
  local content_hits="$privacy_tmpdir/content_hits.txt"
  local path_hits="$privacy_tmpdir/path_hits.txt"
  local -a staged_paths=()

  while IFS= read -r -d '' path; do
    staged_paths+=("$path")
  done < <(git diff --cached --name-only -z --diff-filter=ACMR)

  if [[ "${#staged_paths[@]}" -eq 0 ]]; then
    exit 0
  fi

  printf '%s\n' "${staged_paths[@]}" | privacy_check_paths /dev/stdin "$path_hits"
  git grep --cached -n -I -E "${SECRET_REGEX}" -- "${staged_paths[@]}" > "$raw_content_hits" || true
  privacy_filter_hits "$raw_content_hits" "$content_hits"
  privacy_report_and_exit "pre-commit" "$content_hits" "$path_hits"
}

run_pre_push_check() {
  # pre-push 不做隐私检查，只在 pre-commit 时检查
  exit 0
}
