#!/usr/bin/env bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  vssh
  vssh <ssh-host>
  vssh <ssh-host> -p <port>
  vssh <ssh-host> -u <user>
  vssh <ssh-host> -p <port> -u <user>
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

	if command -v fczf >/dev/null 2>&1; then
		selected="$(printf '%s\n' "$hosts" | fczf --preview '
			ssh -G {} 2>/dev/null | grep -E "user|hostname|port"
			echo "----"
			ssh -o ConnectTimeout=1 {} "uptime" 2>/dev/null
		' || true)"
	elif command -v fzf >/dev/null 2>&1; then
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

HOST_ALIAS=""
PORT=""
USER=""

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
	-u)
		if [ "$#" -lt 2 ]; then
			echo "[ERROR] -u requires a user" >&2
			usage >&2
			exit 1
		fi
		USER="$2"
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

echo "[INFO] Connecting to $HOST_ALIAS..."
if [ -n "$PORT" ]; then
	if [ -n "$USER" ]; then
		ssh -p "$PORT" "$USER@$HOST_ALIAS"
	else
		ssh -p "$PORT" "$HOST_ALIAS"
	fi
else
	if [ -n "$USER" ]; then
		ssh "$USER@$HOST_ALIAS"
	else
		ssh "$HOST_ALIAS"
	fi
fi
