#!/usr/bin/env bash
# Wrapper: lets tmux-continuum drive tmux-persist's per-session save.
#
# tmux-continuum calls "$@resurrect-save-script-path" "quiet" (one arg).
# tmux-persist's save.sh with just "quiet" saves only the current client
# session — but continuum runs from status-right interpolation where there
# may be no attached client, so #{client_session} is empty and nothing saves.
#
# This wrapper adds "all" so every session gets a periodic snapshot, matching
# the original tmux-resurrect behaviour continuum was designed for.
exec "$HOME/.tmux/plugins/tmux-persist/scripts/save.sh" quiet all