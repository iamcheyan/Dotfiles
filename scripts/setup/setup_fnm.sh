#!/usr/bin/env zsh
#
# fnm lazy loader.

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"

if [[ -d "$FNM_DIR" ]]; then
    path=("$FNM_DIR" "$FNM_DIR/bin" $path)
    export PATH
fi

__fnm_bin() {
    for candidate in "$FNM_DIR/fnm" "$FNM_DIR/bin/fnm" "$HOME/.local/share/fnm/fnm" "$HOME/.local/bin/fnm"; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    # Homebrew or system-installed fnm: resolve through PATH.
    local via_path
    via_path="$(command -v fnm 2>/dev/null)" && [[ -n "$via_path" ]] && {
        printf '%s\n' "$via_path"
        return 0
    }

    if [[ -n "${commands[fnm]:-}" ]]; then
        printf '%s\n' "${commands[fnm]}"
        return 0
    fi

    return 1
}

__fnm_lazy_load() {
    if [[ "${__FNM_LAZY_LOADED:-0}" == "1" ]]; then
        return 0
    fi

    local fnm_bin
    fnm_bin="$(__fnm_bin)" || {
        echo "Error: fnm not found. Run init.sh or install fnm first." >&2
        return 1
    }

    eval "$("$fnm_bin" env --shell zsh --use-on-cd)"

    if ! "$fnm_bin" use default >/dev/null 2>&1; then
        local latest_local
        latest_local=$("$fnm_bin" list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
        if [[ -n "$latest_local" ]]; then
            "$fnm_bin" use "$latest_local" >/dev/null 2>&1 || true
            "$fnm_bin" default "$latest_local" >/dev/null 2>&1 || true
        fi
    fi

    export __FNM_LAZY_LOADED=1
}

__fnm_lazy_dispatch() {
    local command_name="$1"
    shift

    __fnm_lazy_load || return $?
    unfunction node npm npx corepack 2>/dev/null || true
    hash -r 2>/dev/null || true

    command "$command_name" "$@"
}

fnm() {
    local fnm_bin
    fnm_bin="$(__fnm_bin)" || {
        echo "Error: fnm not found. Run init.sh or install fnm first." >&2
        return 1
    }
    unfunction fnm 2>/dev/null || true
    __fnm_lazy_load || return $?
    command "$fnm_bin" "$@"
}

node() {
    __fnm_lazy_dispatch node "$@"
}

npm() {
    __fnm_lazy_dispatch npm "$@"
}

npx() {
    __fnm_lazy_dispatch npx "$@"
}

corepack() {
    __fnm_lazy_dispatch corepack "$@"
}
