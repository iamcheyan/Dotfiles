#!/usr/bin/env bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  vssh
  vssh <ssh-host>
  vssh <ssh-host> -p <port>
  vssh <ssh-host> -d <remote-path>
  vssh <ssh-host> -p <port> -d <remote-path>
EOF
}

list_ssh_config_hosts() {
	local files=()

	[ -f "$HOME/.ssh/config" ] && files+=("$HOME/.ssh/config")
	[ -d "$HOME/.ssh/conf.d" ] && files+=("$HOME"/.ssh/conf.d/*)
	[ -d "$HOME/.ssh/config.d" ] && files+=("$HOME"/.ssh/config.d/*)

	[ "${#files[@]}" -gt 0 ] || return 0

	awk '
		tolower($1) == "host" {
			for (i = 2; i <= NF; i++) {
				if ($i !~ /[*?!]/) {
					print $i
				}
			}
		}
	' "${files[@]}" 2>/dev/null | sort -u
}

choose_ssh_host() {
	local hosts selected

	hosts="$(list_ssh_config_hosts)"
	if [ -z "$hosts" ]; then
		echo "[ERROR] No ssh hosts found in ~/.ssh/config" >&2
		exit 1
	fi

	if command -v fzf >/dev/null 2>&1; then
		selected="$(
			printf '%s\n' "$hosts" |
				FZF_DEFAULT_OPTS= \
					fzf \
					--height=30% \
					--layout=reverse \
					--border \
					--preview '
        ssh -G {} 2>/dev/null | grep -E "user|hostname|port"
        echo "----"
        ssh -o ConnectTimeout=1 {} "uptime" 2>/dev/null
      ' ||
				true
		)"
	else
		PS3="ssh host> "
		select selected in $hosts; do
			[ -n "$selected" ] && break
		done
	fi

	if [ -z "$selected" ]; then
		echo "[ERROR] No ssh host selected" >&2
		exit 1
	fi

	printf '%s\n' "$selected"
}

sanitize_mount_name() {
	printf '%s' "$1" | sed 's#[/:]#_#g'
}

HOST_ALIAS=""
REMOTE_PATH="."
PORT=""

while [ "$#" -gt 0 ]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	-p)
		if [ "$#" -lt 2 ]; then
			echo "[ERROR] -p requires a port" >&2
			usage >&2
			exit 1
		fi
		PORT="$2"
		shift 2
		;;
	-d)
		if [ "$#" -lt 2 ]; then
			echo "[ERROR] -d requires a remote path" >&2
			usage >&2
			exit 1
		fi
		REMOTE_PATH="$2"
		shift 2
		;;
	-*)
		echo "[ERROR] Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	*)
		if [ -n "$HOST_ALIAS" ]; then
			echo "[ERROR] Unexpected argument: $1" >&2
			usage >&2
			exit 1
		fi
		HOST_ALIAS="$1"
		shift
		;;
	esac
done

if [ -z "$HOST_ALIAS" ]; then
	HOST_ALIAS="$(choose_ssh_host)"
fi

# Fix the ~ path issue
[ "$REMOTE_PATH" = "~" ] && REMOTE_PATH="."

MOUNT_NAME="$(sanitize_mount_name "$HOST_ALIAS")"
[ -n "$PORT" ] && MOUNT_NAME="${MOUNT_NAME}_p${PORT}"
MOUNT_DIR="$HOME/.sshfs/$MOUNT_NAME"

mkdir -p "$MOUNT_DIR"

if ! mount | grep -Fq "$MOUNT_DIR"; then
	echo "[INFO] Mounting $HOST_ALIAS:$REMOTE_PATH -> $MOUNT_DIR"
	if [ -n "$PORT" ]; then
		sshfs -o "port=$PORT" "$HOST_ALIAS:$REMOTE_PATH" "$MOUNT_DIR" || {
			echo "[ERROR] sshfs mount failed"
			exit 1
		}
	else
		sshfs "$HOST_ALIAS:$REMOTE_PATH" "$MOUNT_DIR" || {
			echo "[ERROR] sshfs mount failed"
			exit 1
		}
	fi
else
	echo "[INFO] Already mounted: $MOUNT_DIR"
fi

vifm "$MOUNT_DIR" "$HOME"
