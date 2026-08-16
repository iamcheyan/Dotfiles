#!/usr/bin/env bash
# Save-side guard for tmux-persist: prevents empty snapshots from overwriting
# good ones during shutdown.
#
# Problem:
#   tmux-persist's save-on-exit hooks (client-detached / session-closed) fire
#   when systemd SIGTERMs the tmux server on shutdown. By then the session's
#   panes/windows are already gone, so save.sh writes a 20-byte empty tarball
#   and unconditionally points <session>_last at it (snapshot_create in
#   helpers.sh has no empty guard; skip-unchanged doesn't help because the
#   empty layout hashes differently from the previous good snapshot).
#   On next boot, the session-created hook runs restore.sh, which reads the
#   now-empty last pointer and restores nothing.
#
# Fix:
#   This wrapper intercepts save.sh. For each target session it checks whether
#   the session still has any windows. If a session is empty (or already gone),
#   it is skipped entirely — the existing <session>_last symlink is left
#   pointing at the last good snapshot.
#
# Wired by overriding the client-detached / session-closed hooks AFTER
# `run tpm` in tmux.conf (persist.tmux hardcodes @persist-save-script-path to
# its own save.sh, so the option can't be redirected; the hooks must be
# replaced instead).
#
# Args mirror save.sh: [quiet] [all] | [quiet] <session>
# Exit status is 0 even when every session is skipped, so tmux hooks don't log
# errors.

set -u

REAL_SAVE="$HOME/.tmux/plugins/tmux-persist/scripts/save.sh"

# Reuse the plugin's own persist-dir resolution so we agree on where snapshots
# live. Source variables.sh just for get_tmux_option / persist_dir.
source "$HOME/.tmux/plugins/tmux-persist/scripts/variables.sh" 2>/dev/null
source "$HOME/.tmux/plugins/tmux-persist/scripts/helpers.sh" 2>/dev/null

QUIET=""
SAVE_SESSION=""
SAVE_ALL="false"
for arg in "$@"; do
	case "$arg" in
		quiet) QUIET="quiet" ;;
		all)   SAVE_ALL="true" ;;
		*)     SAVE_SESSION="$arg" ;;
	esac
done

# session_has_windows <name>: 0 if the session exists and has >=1 window.
session_has_windows() {
	local name="$1"
	# has-session alone is not enough: during teardown a session can exist
	# briefly with zero windows. list-windows returns nothing in that case.
	tmux has-session -t "$name" 2>/dev/null || return 1
	[ -n "$(tmux list-windows -t "$name" -F '#{window_index}' 2>/dev/null)" ]
}

# collect_target_sessions: echo the list of session names to consider,
# honouring the all/session argument the same way save.sh does.
collect_target_sessions() {
	if [ "$SAVE_ALL" = "true" ]; then
		tmux list-sessions -F '#{session_name}' 2>/dev/null
	elif [ -n "$SAVE_SESSION" ]; then
		echo "$SAVE_SESSION"
	else
		# No "all" and no explicit session: save.sh would target the current
		# client session. Resolve it the same way.
		tmux display-message -p '#{client_session}' 2>/dev/null
	fi
}

# Decide which sessions are saveable. If none survive, exit 0 without invoking
# save.sh at all (so last pointers stay put).
SAVEABLE=""
SKIP_EMPTY=""
while IFS= read -r sess; do
	[ -n "$sess" ] || continue
	if session_has_windows "$sess"; then
		SAVEABLE="$SAVEABLE"$'\n'"$sess"
	else
		[ -n "$QUIET" ] || echo "persist-save-guard: skipping empty session '$sess'" >&2
		SKIP_EMPTY="$SKIP_EMPTY"$'\n'"$sess"
	fi
done < <(collect_target_sessions)

# If every target session is empty, do nothing — keep the good last pointer.
if [ -z "${SAVEABLE//$'\n'/}" ]; then
	exit 0
fi

# If we were invoked with "all" but some sessions were empty, narrow the call
# to only the non-empty ones so save.sh doesn't re-stomp them. save.sh has no
# multi-session mode other than "all", so when SAVE_ALL is set we either pass
# "all" (if nothing was filtered) or fall back to per-session calls.
if [ "$SAVE_ALL" = "true" ]; then
	if [ -z "$SKIP_EMPTY" ]; then
		exec "$REAL_SAVE" "$@"            # nothing filtered: original call verbatim
	else
		# Call save.sh once per non-empty session. save.sh with a session arg
		# saves only that session.
		while IFS= read -r sess; do
			[ -n "$sess" ] || continue
			"$REAL_SAVE" "$QUIET" "$sess" >/dev/null 2>&1 || true
		done <<< "$SAVEABLE"
		exit 0
	fi
fi

# Single-session (or current-client) path: only invoke if non-empty.
if [ -n "$SAVE_SESSION" ]; then
	# Already filtered above; SAVEABLE holds it iff it had windows.
	exec "$REAL_SAVE" "$@"
fi

# Current-client path with no explicit session: only save if it has windows.
CURRENT_SESS="$(tmux display-message -p '#{client_session}' 2>/dev/null)"
if [ -n "$CURRENT_SESS" ] && session_has_windows "$CURRENT_SESS"; then
	exec "$REAL_SAVE" "$@"
fi
exit 0