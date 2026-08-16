#!/usr/bin/env bash
# Restore-side guard for tmux-persist: don't trust an empty "last" pointer.
#
# Problem:
#   If the save-side guard (or any other path) ever let an empty snapshot
#   become <session>_last, the session-created auto-restore hook would
#   restore nothing. This is a defensive layer: before handing off to the
#   real restore.sh, if the target session's last pointer resolves to an
#   empty snapshot, walk backwards to the most recent NON-empty snapshot for
#   that session and repoint last at it for this restore.
#
# "Empty" = the snapshot's layout has no pane lines. A snapshot produced
# during teardown has either no layout file at all (20-byte tar) or a layout
# with zero `^pane` lines.
#
# Wired by overriding the session-created hook AFTER `run tpm` in tmux.conf.
#
# Args mirror restore.sh: [quiet] <session>
# The real restore.sh reads last via last_session_file("$RESTORE_SESSION"),
# so repointing the symlink before calling it is enough. The repoint is
# permanent: an empty last is never useful, so we keep it pointing at the
# recovered good snapshot.

set -u

REAL_RESTORE="$HOME/.tmux/plugins/tmux-persist/scripts/restore.sh"
PERSIST_DIR="$HOME/.local/share/tmux/resurrect"

# Reuse the plugin's resolution so PERSIST_DIR matches reality.
source "$HOME/.tmux/plugins/tmux-persist/scripts/variables.sh" 2>/dev/null
source "$HOME/.tmux/plugins/tmux-persist/scripts/helpers.sh" 2>/dev/null
# helpers.sh defines persist_dir() and last_session_file(); recompute PERSIST_DIR
# the same way the plugin does (it may differ if @persist-dir is set).
PERSIST_DIR="$(persist_dir 2>/dev/null)" || PERSIST_DIR="$HOME/.local/share/tmux/resurrect"

RESTORE_SESSION=""
for arg in "$@"; do
	case "$arg" in
		quiet) ;;
		*) RESTORE_SESSION="$arg" ;;
	esac
done

# Restore.sh, when called by the auto-restore hook, gets the session name as a
# positional arg. When called manually it may fall back to #{client_session}.
if [ -z "$RESTORE_SESSION" ]; then
	RESTORE_SESSION="$(tmux display-message -p '#{client_session}' 2>/dev/null)"
fi
[ -n "$RESTORE_SESSION" ] || exec "$REAL_RESTORE" "$@"

LAST_LINK="$(last_session_file "$RESTORE_SESSION" 2>/dev/null)"
[ -e "$LAST_LINK" ] || exec "$REAL_RESTORE" "$@"

# snapshot_layout_lines <tgz|txt>: emit the layout content for inspection.
snapshot_layout_lines() {
	local file="$1"
	case "$file" in
		*.tgz) tar xzf "$file" -O ./layout 2>/dev/null ;;
		*.txt) cat "$file" 2>/dev/null ;;
	esac
}

# snapshot_is_empty <file>: 0 if the snapshot has no pane lines.
snapshot_is_empty() {
	local file="$1"
	local layout
	layout="$(snapshot_layout_lines "$file")"
	# Count lines starting with "pane". Empty tar (no layout) → empty → true.
	[ -z "$(printf '%s' "$layout" | grep -c '^pane')" ] && return 0
	# grep -c prints a number (possibly 0); empty only when 0 panes.
	[ "$(printf '%s' "$layout" | grep -c '^pane')" -eq 0 ]
}

CURRENT_TARGET="$(readlink "$LAST_LINK" 2>/dev/null)"
[ -n "$CURRENT_TARGET" ] || exec "$REAL_RESTORE" "$@"
CURRENT_FILE="$PERSIST_DIR/$CURRENT_TARGET"

# If the current last is non-empty, just restore normally.
if ! snapshot_is_empty "$CURRENT_FILE"; then
	exec "$REAL_RESTORE" "$@"
fi

# Current last is empty — search for the newest NON-empty snapshot for this
# session, sorted by mtime (newest first). Snapshots are named
# "<session>_<timestamp>.tgz".
BEST=""
BEST_TARGET=""
while IFS= read -r snap; do
	[ "$snap" != "$CURRENT_FILE" ] || continue
	if ! snapshot_is_empty "$snap"; then
		BEST="$snap"
		BEST_TARGET="$(basename "$snap")"
		break
	fi
done < <(ls -t "$PERSIST_DIR"/"${RESTORE_SESSION}"_*.tgz 2>/dev/null)

# No non-empty snapshot found — fall through to real restore.sh (it will
# restore the empty one, same as today, but at least we tried).
[ -n "$BEST_TARGET" ] || exec "$REAL_RESTORE" "$@"

# Permanently repoint last at the best non-empty snapshot. An empty <session>_last
# is never useful — save-side guard won't overwrite it, and leaving it empty would
# make every future restore fall through to this fallback again. Pointing it at
# the good snapshot makes the next save (skip-unchanged) a no-op until the live
# session actually diverges.
ln -fs "$BEST_TARGET" "$LAST_LINK"
exec "$REAL_RESTORE" "$@"