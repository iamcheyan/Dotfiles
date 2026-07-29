#!/usr/bin/env bash
# Pre-restore hook for tmux-persist: rewrites pane full_commands in the
# restore staging layout so that agent CLIs resume their previous session
# instead of starting fresh.
#
# Why a hook instead of strategy files:
# tmux-persist looks up strategy files under <plugin>/strategies/ by
# _just_command (first word of pane_full_command). codex runs as "node
# .../codex" and omp runs as "bun .../omp", so _just_command returns
# "node"/"bun" — we'd need @persist-strategy-node/@persist-strategy-bun
# and strategy files inside the plugin dir, which TPM updates overwrite.
# This hook lives in the dotfiles repo and is update-proof.
#
# Rewrites (only the full_command field, column 11, with leading ":"):
#   If the command already contains a resume/continue flag, pass through unchanged.
#   Otherwise:
#     omp              → omp --continue
#     codex            → codex resume --last
#     pi               → pi --continue
#     grok             → grok --continue
#     mimo             → mimo -c --dangerously-skip-permissions
#     kiro-cli         → kiro-cli chat -r
#
# Wired via: set -g @persist-hook-pre-restore-pane-processes 'path/to/this'

# Don't use set -e: we need to handle missing files gracefully

# Locate the restore staging layout file (same logic as tmux-persist's persist_dir)
if [ -d "$HOME/.tmux/persist" ]; then
    _PERSIST_DIR="$HOME/.tmux/persist"
elif [ -d "$HOME/.tmux/resurrect" ]; then
    _PERSIST_DIR="$HOME/.tmux/resurrect"
elif [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect" ]; then
    _PERSIST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
else
    _PERSIST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/persist"
fi

LAYOUT_FILE="$_PERSIST_DIR/restore/layout"

[ -f "$LAYOUT_FILE" ] || exit 0

# Check if a command string already contains a resume/continue flag.
# Matches: --continue, -c, --resume, -r, resume, fork, --conversation
already_resumes() {
    [[ "$1" =~ (^|[[:space:]])(--continue|-c|--resume|-r|resume|fork|--conversation)([[:space:]]|$) ]]
}

# Rewrite a full_command to add the appropriate resume flag.
# $1 = full_command (without leading ":")
# Echoes the rewritten command.
rewrite_command() {
    local cmd="$1"

    # Already has a resume/continue flag → pass through unchanged
    if already_resumes "$cmd"; then
        echo "$cmd"
        return
    fi

    # omp (bun-wrapped): "bun .../omp" or "omp ..."
    if [[ "$cmd" =~ omp ]]; then
        echo "omp --continue"
        return
    fi

    # codex (node-wrapped): "node .../codex" or "codex ..."
    if [[ "$cmd" =~ codex ]]; then
        echo "codex resume --last"
        return
    fi

    # pi (node-wrapped): "node .../pi-coding-agent..." or "pi ..."
    # Match "pi-coding-agent" (the npm package path) or standalone "pi" word
    if [[ "$cmd" =~ pi-coding-agent ]] || [[ "$cmd" =~ (^|[[:space:]/])pi([[:space:]]|$) ]]; then
        echo "pi --continue"
        return
    fi

    # grok (native binary): "grok ..."
    if [[ "$cmd" =~ (^|[[:space:]])grok([[:space:]]|$) ]]; then
        echo "grok --continue"
        return
    fi

    # mimo (native ELF): "mimo ..."
    if [[ "$cmd" =~ (^|[[:space:]])mimo([[:space:]]|$) ]]; then
        echo "mimo -c --dangerously-skip-permissions"
        return
    fi

    # kiro-cli (native ELF): "kiro-cli ..."
    if [[ "$cmd" =~ (^|[[:space:]])kiro-cli([[:space:]]|$) ]]; then
        echo "kiro-cli chat -r"
        return
    fi

    # No match → pass through unchanged
    echo "$cmd"
}

# Read all lines, rewrite pane full_commands, write back.
# Layout format (tab-delimited):
#   pane  session  win  win_active  win_flags  pane_idx  pane_title  :dir  pane_active  pane_command  :full_command
# Column 11 is :full_command (leading ":" means empty).
tmp=$(mktemp)
while IFS= read -r line; do
    if [[ $line == pane* ]]; then
        # Split into fields by tab
        IFS=$'\t' read -r f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 <<< "$line"
        # f11 is ":<full_command>" or just ":"
        cmd="${f11#:}"  # strip leading ":"

        if [ -n "$cmd" ]; then
            new_cmd="$(rewrite_command "$cmd")"
            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8" "$f9" "$f10" ":$new_cmd" >> "$tmp"
        else
            printf '%s\n' "$line" >> "$tmp"
        fi
    else
        printf '%s\n' "$line" >> "$tmp"
    fi
done < "$LAYOUT_FILE"
mv "$tmp" "$LAYOUT_FILE"