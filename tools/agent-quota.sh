#!/usr/bin/env bash
# Show subscription quota/usage information for local agent CLIs.
#
# Usage:
#   aq
#   aq --json        # raw JSON for providers that expose structured data

set -euo pipefail

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.grok/bin:$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell bash)"
  fnm use default >/dev/null 2>&1 || true
  npm_bin="$(npm config get prefix 2>/dev/null)/bin"
  [ -d "$npm_bin" ] && export PATH="$npm_bin:$PATH"
fi

JSON_MODE=false
case "${1:-}" in
  --json)
    JSON_MODE=true
    ;;
  -h|--help)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  "")
    ;;
  *)
    echo "Usage: aq [--json]" >&2
    exit 1
    ;;
esac

# Colors (disabled when stdout is not a terminal)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  WHITE='\033[1;37m'
  GRAY='\033[0;90m'
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN=''
  WHITE='' GRAY='' BOLD='' DIM='' RESET=''
fi

have() {
  command -v "$1" >/dev/null 2>&1
}

line() {
  printf '%b\n' "$*"
}

section() {
  printf '\n%b== %s ==%b\n' "$BOLD$CYAN" "$1" "$RESET"
}

human_time() {
  local epoch="${1:-}"
  if [ -z "$epoch" ] || [ "$epoch" = "null" ]; then
    printf 'unknown'
    return
  fi

  if date -d "@$epoch" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
    date -d "@$epoch" '+%Y-%m-%d %H:%M:%S %Z'
  else
    date -r "$epoch" '+%Y-%m-%d %H:%M:%S %Z'
  fi
}

duration_mins() {
  local mins="${1:-}"
  case "$mins" in
    60) printf 'hourly' ;;
    300) printf '5-hour' ;;
    1440) printf 'daily' ;;
    10080) printf 'weekly' ;;
    43200|44640) printf 'monthly-ish' ;;
    ""|null) printf 'unknown' ;;
    *) printf '%s min' "$mins" ;;
  esac
}

format_tokens() {
  local n="${1:-0}"
  awk -v n="$n" 'BEGIN {
    if (n >= 1000000000) printf "%.2fB", n / 1000000000;
    else if (n >= 1000000) printf "%.2fM", n / 1000000;
    else if (n >= 1000) printf "%.1fK", n / 1000;
    else printf "%d", n;
  }'
}

# Draw a usage bar. Args: percent (0-100), [width]
#   solid block (█) = remaining (available) portion
#   light shade (░) = consumed (used) portion
bar() {
  local pct="${1:-0}" width="${2:-20}"
  case "$pct" in
    ''|null) pct=0 ;;
  esac
  pct="$(awk -v p="$pct" 'BEGIN { if (p < 0) p = 0; if (p > 100) p = 100; printf "%d", p }')"
  local filled
  filled="$(awk -v p="$pct" -v w="$width" 'BEGIN { printf "%d", int(p/100*w + 0.5) }')"
  local empty=$(( width - filled ))
  local i solid="" shade=""
  for ((i = 0; i < filled; i++)); do solid+="█"; done
  for ((i = 0; i < empty; i++)); do shade+="░"; done
  printf '  [%b%s%b%s] %b%s%% left' "$GREEN" "$solid" "$RESET" "$DIM$shade$RESET" "$WHITE" "$pct"
}

codex_json() {
  node <<'NODE'
const { spawn } = require("child_process");

const child = spawn("codex", ["app-server", "--stdio"], {
  stdio: ["pipe", "pipe", "pipe"],
});

let buffer = "";
let stderr = "";
const responses = new Map();
const notifications = [];

function send(id, method, params) {
  const msg = params === undefined ? { id, method } : { id, method, params };
  child.stdin.write(JSON.stringify(msg) + "\n");
}

function handleLine(line) {
  if (!line.trim()) return;
  try {
    const msg = JSON.parse(line);
    if (Object.prototype.hasOwnProperty.call(msg, "id")) {
      responses.set(msg.id, msg);
    } else {
      notifications.push(msg);
    }
  } catch (error) {
    stderr += `\nFailed to parse stdout line: ${line}`;
  }
}

child.stdout.on("data", (chunk) => {
  buffer += chunk.toString();
  let idx;
  while ((idx = buffer.indexOf("\n")) >= 0) {
    const line = buffer.slice(0, idx);
    buffer = buffer.slice(idx + 1);
    handleLine(line);
  }
});

child.stderr.on("data", (chunk) => {
  stderr += chunk.toString();
});

function waitFor(id, timeoutMs) {
  const started = Date.now();
  return new Promise((resolve, reject) => {
    const timer = setInterval(() => {
      if (responses.has(id)) {
        clearInterval(timer);
        resolve(responses.get(id));
      } else if (Date.now() - started > timeoutMs) {
        clearInterval(timer);
        reject(new Error(`timeout waiting for response id ${id}`));
      }
    }, 50);
  });
}

(async () => {
  try {
    send(1, "initialize", {
      clientInfo: { name: "agent-quota", title: "Agent Quota", version: "0.1.0" },
      capabilities: null,
    });
    await waitFor(1, 5000);

    send(2, "account/read", { refreshAuth: true });
    send(3, "account/rateLimits/read");
    send(4, "account/usage/read");

    const [account, rateLimits, usage] = await Promise.all([
      waitFor(2, 15000),
      waitFor(3, 15000),
      waitFor(4, 15000),
    ]);

    child.kill("SIGTERM");
    console.log(JSON.stringify({
      ok: true,
      account: account.result || null,
      rateLimits: rateLimits.result || null,
      usage: usage.result || null,
      notifications,
    }));
  } catch (error) {
    child.kill("SIGTERM");
    console.log(JSON.stringify({ ok: false, error: error.message, stderr }));
    process.exitCode = 1;
  }
})();
NODE
}

# ---------------------------------------------------------------------------
# Kiro (Amazon Q / CodeWhisperer)
# ---------------------------------------------------------------------------

# Read Kiro social token from SQLite, refresh if expired. Prints access_token.
kiro_access_token() {
  local db="$HOME/.local/share/kiro-cli/data.sqlite3"
  [ -f "$db" ] || return 1

  local raw
  raw=$(sqlite3 "$db" "SELECT value FROM auth_kv WHERE key='kirocli:social:token';" 2>/dev/null)
  [ -n "$raw" ] || return 1

  local at expires_at rt profile_arn provider
  at=$(jq -r '.access_token // empty' <<<"$raw" 2>/dev/null)
  expires_at=$(jq -r '.expires_at // empty' <<<"$raw" 2>/dev/null)
  rt=$(jq -r '.refresh_token // empty' <<<"$raw" 2>/dev/null)
  profile_arn=$(jq -r '.profile_arn // empty' <<<"$raw" 2>/dev/null)
  provider=$(jq -r '.provider // empty' <<<"$raw" 2>/dev/null)

  [ -n "$at" ] || return 1

  # Check expiry (60s margin)
  if [ -n "$expires_at" ] && [ "$expires_at" != "null" ]; then
    local now exp
    now=$(date '+%s')
    exp=$(date -d "$expires_at" '+%s' 2>/dev/null || printf '0')
    if [ "$exp" -gt 0 ] && [ "$((exp - now))" -gt 60 ]; then
      printf '%s' "$at"
      return 0
    fi
  fi

  # Token expired — try to refresh via Kiro auth service
  [ -n "$rt" ] || return 1
  [ -n "$provider" ] || return 1

  local auth_base="https://prod.us-east-1.auth.desktop.kiro.dev"
  local refresh_resp new_at new_rt new_exp
  refresh_resp=$(curl -sS -m 15 -X POST "${auth_base}/refreshToken" \
    -H 'Content-Type: application/json' \
    -d "{\"refreshToken\":\"$rt\",\"provider\":\"$provider\"}" 2>/dev/null)

  new_at=$(jq -r '.accessToken // empty' <<<"$refresh_resp" 2>/dev/null)
  [ -n "$new_at" ] || return 1

  # Persist refreshed token back to SQLite
  new_rt=$(jq -r '.refreshToken // empty' <<<"$refresh_resp" 2>/dev/null)
  new_exp=$(jq -r '.expiresIn // empty' <<<"$refresh_resp" 2>/dev/null)
  local new_expiry_iso
  if [ -n "$new_exp" ] && [ "$new_exp" != "null" ]; then
    new_expiry_iso=$(date -u -d "+${new_exp} seconds" '+%Y-%m-%dT%H:%M:%S.000000000Z' 2>/dev/null || true)
  fi
  local new_profile_arn
  new_profile_arn=$(jq -r '.profileArn // empty' <<<"$refresh_resp" 2>/dev/null)

  local tmp_payload
  tmp_payload=$(jq -nc \
    --arg at "$new_at" \
    --arg exp "${new_expiry_iso:-}" \
    --arg rt "${new_rt:-$rt}" \
    --arg pa "${new_profile_arn:-$profile_arn}" \
    --arg pv "$provider" \
    '{access_token:$at, expires_at:$exp, refresh_token:$rt, provider:$pv, profile_arn:$pa}')
  sqlite3 "$db" "INSERT OR REPLACE INTO auth_kv (key, value) VALUES ('kirocli:social:token', '$(echo "$tmp_payload" | sed "s/'/''/g")');" 2>/dev/null || true

  printf '%s' "$new_at"
}

# Fetch Kiro usage via Amazon CodeWhisperer GetUsageLimits API.
# Args: access_token, profile_arn
# Prints JSON on success.
kiro_fetch_quota() {
  local access_token="$1" profile_arn="$2"
  local endpoint="https://codewhisperer.us-east-1.amazonaws.com"
  local payload
  payload=$(jq -nc --arg pa "$profile_arn" '{profileArn:$pa, resourceType:"AGENTIC_REQUEST"}')

  local resp
  resp=$(curl -sS -m 15 -X POST "$endpoint" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-Type: application/x-amz-json-1.0" \
    -H "X-Amz-Target: AmazonCodeWhispererService.GetUsageLimits" \
    -d "$payload" 2>/dev/null)

  # Check for valid response (has usageBreakdownList key)
  if jq -e '.usageBreakdownList // .limits' <<<"$resp" >/dev/null 2>&1; then
    printf '%s' "$resp"
    return 0
  fi
  return 1
}

show_kiro() {
  section "Kiro"
  if ! have jq; then
    line "status: ${RED}requires jq${RESET}"
    return
  fi
  if ! have sqlite3; then
    line "status: ${RED}requires sqlite3${RESET}"
    return
  fi
  if ! have curl; then
    line "status: ${RED}requires curl${RESET}"
    return
  fi

  local db="$HOME/.local/share/kiro-cli/data.sqlite3"
  if [ ! -f "$db" ]; then
    line "status: ${DIM}Kiro not installed (no data.sqlite3)${RESET}"
    return
  fi

  local raw
  raw=$(sqlite3 "$db" "SELECT value FROM auth_kv WHERE key='kirocli:social:token';" 2>/dev/null)
  if [ -z "$raw" ]; then
    line "status: ${RED}no Kiro token (run 'kiro-cli login')${RESET}"
    return
  fi

  local email profile_arn
  email=$(jq -r '.email // "unknown"' <<<"$raw" 2>/dev/null)
  profile_arn=$(jq -r '.profile_arn // empty' <<<"$raw" 2>/dev/null)

  if [ -z "$profile_arn" ] || [ "$profile_arn" = "null" ]; then
    line "status: ${RED}no profile_arn in token${RESET}"
    return
  fi

  # Get access token (auto-refresh)
  local access_token
  access_token=$(kiro_access_token 2>/dev/null)
  if [ -z "$access_token" ]; then
    line "status: ${RED}no valid token (run 'kiro-cli login')${RESET}"
    return
  fi

  # Fetch live quota
  local live_data=""
  live_data=$(kiro_fetch_quota "$access_token" "$profile_arn" 2>/dev/null || true)

  if $JSON_MODE; then
    if [ -n "$live_data" ]; then
      jq -n --argjson k "$live_data" '{kiro:$k}'
    else
      jq -n '{kiro:null, error:"failed to fetch usage"}'
    fi
    return
  fi

  line "account: ${GREEN}$email${RESET}"
  line "profile: ${DIM}$profile_arn${RESET}"

  if [ -n "$live_data" ]; then
    # Parse subscription info
    local sub_type sub_title upgrade_capable overage_capable
    sub_type=$(jq -r '.subscriptionInfo.type // "unknown"' <<<"$live_data" 2>/dev/null)
    sub_title=$(jq -r '.subscriptionInfo.subscriptionTitle // "unknown"' <<<"$live_data" 2>/dev/null)
    upgrade_capable=$(jq -r '.subscriptionInfo.upgradeCapability // false' <<<"$live_data" 2>/dev/null)
    overage_capable=$(jq -r '.subscriptionInfo.overageCapability // false' <<<"$live_data" 2>/dev/null)

    line "plan: ${YELLOW}$sub_title${RESET} ${DIM}($sub_type)${RESET}"

    # Parse usage breakdown (iterate over each resource type)
    jq -c '.usageBreakdownList[]?' <<<"$live_data" 2>/dev/null | while IFS= read -r entry; do
      local display_name resource_type current_usage usage_limit unit
      local overage_rate overage_charges overage_cap next_reset days_until_reset
      display_name=$(jq -r '.displayName // "unknown"' <<<"$entry" 2>/dev/null)
      resource_type=$(jq -r '.resourceType // "unknown"' <<<"$entry" 2>/dev/null)
      current_usage=$(jq -r '.currentUsage // 0' <<<"$entry" 2>/dev/null)
      usage_limit=$(jq -r '.usageLimit // 0' <<<"$entry" 2>/dev/null)
      unit=$(jq -r '.unit // "unknown"' <<<"$entry" 2>/dev/null)
      overage_rate=$(jq -r '.overageRate // 0' <<<"$entry" 2>/dev/null)
      overage_charges=$(jq -r '.overageCharges // 0' <<<"$entry" 2>/dev/null)
      overage_cap=$(jq -r '.overageCap // 0' <<<"$entry" 2>/dev/null)
      next_reset=$(jq -r '.nextDateReset // 0' <<<"$entry" 2>/dev/null)
      days_until_reset=$(jq -r '.daysUntilReset // 0' <<<"$live_data" 2>/dev/null)

      # Calculate remaining percentage
      local pct=0
      if [ "$usage_limit" -gt 0 ] 2>/dev/null; then
        pct=$(awk -v u="$current_usage" -v l="$usage_limit" 'BEGIN { printf "%d", (1 - u/l)*100 }')
      fi

      line "  ${BOLD}$display_name${RESET} ${DIM}($resource_type)${RESET}"
      line "    ${DIM}usage: ${CYAN}$current_usage${RESET} ${DIM}/ $usage_limit $unit${RESET}"
      line "$(bar "$pct")"

      if [ "$overage_rate" != "0" ] && [ "$overage_rate" != "0.0" ]; then
        line "    ${DIM}overage: \$${YELLOW}${overage_rate}${RESET}${DIM}/${unit} (charges: \$${YELLOW}${overage_charges}${RESET}${DIM}, cap: ${overage_cap})${RESET}"
      fi

      if [ "$next_reset" != "0" ] && [ "$next_reset" != "null" ]; then
        local reset_epoch
        reset_epoch=$(printf '%.0f' "$next_reset" 2>/dev/null || echo "0")
        if [ "$reset_epoch" -gt 0 ]; then
          line "    ${DIM}resets: $(human_time "$reset_epoch")${RESET}"
        fi
      fi
    done

    # Parse overage status
    local overage_status
    overage_status=$(jq -r '.overageConfiguration.overageStatus // empty' <<<"$live_data" 2>/dev/null)
    if [ -n "$overage_status" ] && [ "$overage_status" != "null" ]; then
      line "  ${DIM}overage: ${YELLOW}$overage_status${RESET}"
    fi
  else
    line "  ${RED}quota: unavailable (API request failed)${RESET}"
  fi
}

show_codex() {
  section "Codex"
  if ! have codex; then
    line "status: ${RED}codex command not found${RESET}"
    return
  fi
  if ! have node || ! have jq; then
    line "status: ${RED}requires node and jq${RESET}"
    return
  fi

  local data
  if ! data="$(codex_json)"; then
    line "status: ${RED}failed${RESET}"
    jq -r '.error // empty, .stderr // empty' <<<"$data" 2>/dev/null || printf '%s\n' "$data"
    return
  fi

  if $JSON_MODE; then
    jq '{codex: .}' <<<"$data"
    return
  fi

  local email plan
  email="$(jq -r '.account.account.email // "unknown"' <<<"$data")"
  plan="$(jq -r '.account.account.planType // "unknown"' <<<"$data")"
  line "account: ${GREEN}$email${RESET}"
  line "plan: ${YELLOW}$plan${RESET}"

  jq -c '
    .rateLimits.rateLimitsByLimitId
    // (if .rateLimits.rateLimits then {(.rateLimits.rateLimits.limitId // "default"): .rateLimits.rateLimits} else {} end)
    | to_entries[]
  ' <<<"$data" | while IFS= read -r entry; do
    local key name used window reset secondary_used secondary_window secondary_reset credits unlimited balance reached
    key="$(jq -r '.key' <<<"$entry")"
    name="$(jq -r '.value.limitName // .value.limitId // .key' <<<"$entry")"
    used="$(jq -r '.value.primary.usedPercent // empty' <<<"$entry")"
    window="$(jq -r '.value.primary.windowDurationMins // empty' <<<"$entry")"
    reset="$(jq -r '.value.primary.resetsAt // empty' <<<"$entry")"
    secondary_used="$(jq -r '.value.secondary.usedPercent // empty' <<<"$entry")"
    secondary_window="$(jq -r '.value.secondary.windowDurationMins // empty' <<<"$entry")"
    secondary_reset="$(jq -r '.value.secondary.resetsAt // empty' <<<"$entry")"
    unlimited="$(jq -r '.value.credits.unlimited // false' <<<"$entry")"
    balance="$(jq -r '.value.credits.balance // empty' <<<"$entry")"
    credits="$(jq -r '.value.credits.hasCredits // false' <<<"$entry")"
    reached="$(jq -r '.value.rateLimitReachedType // empty' <<<"$entry")"

    line "limit: ${BOLD}$name${RESET} ($key)"
    if [ -n "$used" ]; then
      local remaining
      remaining=$((100 - used))
      line "$(bar "$remaining")  ${DIM}primary $(duration_mins "$window"), resets $(human_time "$reset")${RESET}"
    else
      line "  ${DIM}primary: unavailable${RESET}"
    fi
    if [ -n "$secondary_used" ]; then
      local secondary_remaining
      secondary_remaining=$((100 - secondary_used))
      line "$(bar "$secondary_remaining")  ${DIM}secondary $(duration_mins "$secondary_window"), resets $(human_time "$secondary_reset")${RESET}"
    fi
    line "  ${DIM}credits: has=$credits unlimited=$unlimited balance=${balance:-0}${RESET}"
    [ -n "$reached" ] && line "  ${RED}reached: $reached${RESET}"
  done || true

  local reset_count
  reset_count="$(jq -r '.rateLimits.rateLimitResetCredits.availableCount // 0' <<<"$data")"
  line "${YELLOW}reset credits: $reset_count available${RESET}"
  jq -r '.rateLimits.rateLimitResetCredits.credits[]? | "  - \(.title // "reset") expires \(.expiresAt // "unknown")"' <<<"$data" |
    while IFS= read -r row; do
      local epoch
      epoch="${row##* expires }"
      printf '%b\n' "  ${DIM}${row% expires *} expires $(human_time "$epoch")${RESET}"
    done || true

  local lifetime peak streak today week month
  lifetime="$(jq -r '.usage.summary.lifetimeTokens // 0' <<<"$data")"
  peak="$(jq -r '.usage.summary.peakDailyTokens // 0' <<<"$data")"
  streak="$(jq -r '.usage.summary.currentStreakDays // 0' <<<"$data")"
  today="$(jq -r --arg d "$(date +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate == $d) | .tokens] | add // 0' <<<"$data")"
  week="$(jq -r --arg d "$(date -d '6 days ago' +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate >= $d) | .tokens] | add // 0' <<<"$data")"
  month="$(jq -r --arg d "$(date -d '29 days ago' +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate >= $d) | .tokens] | add // 0' <<<"$data")"
  line "tokens: ${GREEN}today $(format_tokens "$today")${RESET}, ${CYAN}7d $(format_tokens "$week")${RESET}, ${BLUE}30d $(format_tokens "$month")${RESET}, ${DIM}lifetime $(format_tokens "$lifetime")${RESET}"
  line "peak daily tokens: ${MAGENTA}$(format_tokens "$peak")${RESET}; current streak: ${YELLOW}${streak}d${RESET}"
}

# Convert an ISO-8601 timestamp (e.g. 2026-06-15T18:01:56Z) to a human string.
iso_time() {
  local iso="${1:-}"
  [ -z "$iso" ] || [ "$iso" = "null" ] && { printf 'unknown'; return; }
  if date -d "$iso" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
    date -d "$iso" '+%Y-%m-%d %H:%M:%S %Z'
  else
    date -j -f '%Y-%m-%dT%H:%M:%SZ' "$iso" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || printf '%s' "$iso"
  fi
}

# Convert ISO-8601 string to UNIX epoch seconds.
iso_to_epoch() {
  local iso="${1:-}"
  [ -z "$iso" ] || [ "$iso" = "null" ] && { printf '0'; return; }
  if date -d "$iso" '+%s' >/dev/null 2>&1; then
    date -d "$iso" '+%s'
  else
    date -j -f '%Y-%m-%dT%H:%M:%SZ' "$iso" '+%s' 2>/dev/null || printf '0'
  fi
}

# Display one quota bucket.
# Args: label, remainingFraction, resetTime(ISO), description
agy_bucket() {
  local label="$1" frac="$2" reset="$3" desc="$4"
  local remaining now reset_secs
  now="$(date '+%s')"
  if [ -n "$frac" ] && [ "$frac" != "null" ]; then
    reset_secs="$(iso_to_epoch "$reset")"
    if [ "$reset_secs" -gt 0 ] && [ "$reset_secs" -lt "$now" ]; then
      line "$(bar 100)  ${BOLD}$label${RESET}, resets $(iso_time "$reset") ${DIM}(expired / quota available)${RESET}"
    else
      remaining="$(awk -v f="$frac" 'BEGIN { printf "%d", f * 100 }')"
      if [ -n "$desc" ] && [ "$desc" != "null" ]; then
        line "$(bar "$remaining")  ${BOLD}$label${RESET}, resets $(iso_time "$reset")"
        line "    ${DIM}$desc${RESET}"
      else
        line "$(bar "$remaining")  ${BOLD}$label${RESET}, resets $(iso_time "$reset")"
      fi
    fi
  else
    line "  ${DIM}$label: unavailable${RESET}"
  fi
}

# Return a valid Google OAuth access_token from the antigravity token file,
# refreshing it first if expired. Prints the token on stdout, empty on failure.
#
# The token at ~/.gemini/antigravity-cli/antigravity-oauth-token is a Google
# OAuth credential. Its access_token expires hourly, so we refresh it with the
# refresh_token using Antigravity's public OAuth client (the same client id/
# secret pair embedded in the agy CLI binary — public, not a personal secret).
# To avoid storing any credential literal in this repo, the client secret is
# extracted at runtime from the agy binary rather than hardcoded.
agy_refresh_token() {
  local token_file="$HOME/.gemini/antigravity-cli/antigravity-oauth-token"
  [ -f "$token_file" ] || return 1

  local refresh_token access_token expiry
  refresh_token=$(jq -r '.token.refresh_token // empty' "$token_file" 2>/dev/null)
  access_token=$(jq -r '.token.access_token // empty' "$token_file" 2>/dev/null)
  expiry=$(jq -r '.token.expiry // empty' "$token_file" 2>/dev/null)

  # Check if current token is still valid (with 60s margin)
  if [ -n "$access_token" ] && [ -n "$expiry" ] && [ "$expiry" != "null" ]; then
    local now exp
    now=$(date '+%s')
    exp=$(date -d "$expiry" '+%s' 2>/dev/null || printf '0')
    if [ "$exp" -gt 0 ] && [ "$((exp - now))" -gt 60 ]; then
      printf '%s' "$access_token"
      return 0
    fi
  fi

  # Token expired — refresh with the refresh_token.
  [ -n "$refresh_token" ] || return 1
  local agy_cid="" agy_csec=""

  # Prefer a local .env (same file antigravity.sh reads) if present.
  local env_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
  if [ -f "$env_file" ]; then
    agy_cid=$(grep -E "^ANTIGRAVITY_CLIENT_ID=" "$env_file" | cut -d'=' -f2- | sed 's/["'"'"']//g' | tr -d '\r')
    agy_csec=$(grep -E "^ANTIGRAVITY_CLIENT_SECRET=" "$env_file" | cut -d'=' -f2- | sed 's/["'"'"']//g' | tr -d '\r')
  fi

  # Fallbacks: Antigravity's public OAuth client. The client id is a stable,
  # publicly distributed identifier (it ships in the agy CLI binary), so it is
  # not a secret. The matching client secret is scraped at runtime from the agy
  # binary instead of being stored here.
  if [ -z "$agy_cid" ]; then
    agy_cid="1071006060591-tmhssin2h21lcre235vtolojh4g403ep.apps.googleusercontent.com"
  fi
  if [ -z "$agy_csec" ]; then
    local agy_bin
    agy_bin="$(command -v agy || true)"
    [ -z "$agy_bin" ] && agy_bin="$(readlink -f "$HOME/.local/bin/agy" 2>/dev/null || true)"
    if [ -n "$agy_bin" ] && [ -f "$agy_bin" ]; then
      # The Antigravity client secret is the first GOCSPX-… secret embedded in
      # the binary. The two secrets are concatenated without a separator, so we
      # match exactly 28 alphanumeric chars after "GOCSPX-" to capture only the
      # first one (it contains no hyphen; the second starts at the next GOCSPX-).
      agy_csec=$(grep -aoE 'GOCSPX-[A-Za-z0-9]{28}' "$agy_bin" 2>/dev/null | head -1)
    fi
  fi
  [ -n "$agy_cid" ] && [ -n "$agy_csec" ] || return 1

  local resp new_at new_exp new_rt
  resp=$(curl -sS -m 15 -X POST 'https://oauth2.googleapis.com/token' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=$refresh_token" \
    --data-urlencode "client_id=$agy_cid" \
    --data-urlencode "client_secret=$agy_csec" 2>/dev/null)

  local resp new_at new_exp new_rt
  resp=$(curl -sS -m 15 -X POST 'https://oauth2.googleapis.com/token' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=$refresh_token" \
    --data-urlencode "client_id=$agy_cid" \
    --data-urlencode "client_secret=$agy_csec" 2>/dev/null)

  new_at=$(jq -r '.access_token // empty' <<<"$resp" 2>/dev/null)
  [ -n "$new_at" ] || return 1

  # Persist refreshed token back to file
  new_exp=$(jq -r '.expires_in // empty' <<<"$resp" 2>/dev/null)
  new_rt=$(jq -r '.refresh_token // empty' <<<"$resp" 2>/dev/null)
  local expiry_iso
  if [ -n "$new_exp" ] && [ "$new_exp" != "null" ]; then
    expiry_iso=$(date -u -d "+${new_exp} seconds" '+%Y-%m-%dT%H:%M:%S.000000000Z' 2>/dev/null || true)
  fi

  local tmp
  tmp=$(mktemp)
  jq --arg at "$new_at" \
     --arg exp "${expiry_iso:-}" \
     --arg rt "${new_rt:-$refresh_token}" \
     '.token.access_token = $at | .token.expiry = $exp | .token.refresh_token = $rt' \
     "$token_file" >"$tmp" 2>/dev/null && mv -f "$tmp" "$token_file"

  printf '%s' "$new_at"
}

# Fetch Antigravity quota data via Google Cloud Code API (direct HTTP JSON).
# Args: access_token
# Prints JSON with groups[] on success.
agy_fetch_quota() {
  local access_token="$1"
  local ua="vscode/1.X.X (Antigravity/4.3.0)"
  local endpoints=("daily-cloudcode-pa.googleapis.com" "daily-cloudcode-pa.sandbox.googleapis.com" "cloudcode-pa.googleapis.com")

  # Step 1: Get project_id via loadCodeAssist
  local project_id=""
  for host in "${endpoints[@]}"; do
    local resp
    resp=$(curl -sS -m 10 -X POST "https://$host/v1internal:loadCodeAssist" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-Type: application/json" \
      -H "User-Agent: $ua" \
      -d '{"metadata":{"ideType":"ANTIGRAVITY"}}' 2>/dev/null)
    project_id=$(jq -r '.cloudaicompanionProject // empty' <<<"$resp" 2>/dev/null)
    [ -n "$project_id" ] && break
  done
  [ -n "$project_id" ] || return 1

  # Step 2: Fetch quota summary via retrieveUserQuotaSummary
  local payload="{\"project\":\"$project_id\"}"
  for host in "${endpoints[@]}"; do
    local resp status
    resp=$(curl -sS -m 10 -X POST "https://$host/v1internal:retrieveUserQuotaSummary" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-Type: application/json" \
      -H "User-Agent: $ua" \
      -d "$payload" 2>/dev/null)
    # Check for success (has "groups" key)
    if jq -e '.groups' <<<"$resp" >/dev/null 2>&1; then
      printf '%s' "$resp"
      return 0
    fi
  done
  return 1
}

render_live_bucket() {
  local label="$1" frac="$2" reset_epoch="$3" desc="$4"
  local remaining now
  now="$(date '+%s')"
  if [ -n "$frac" ] && [ "$frac" != "null" ]; then
    remaining="$(awk -v f="$frac" 'BEGIN { printf "%d", f * 100 }')"

    # Calculate time remaining till reset
    local left lh lm
    left=$(( reset_epoch - now ))
    if [ "$left" -gt 0 ]; then
      lh="$(( left / 3600 ))"
      lm="$(( (left % 3600) / 60 ))"
      line "      $(bar "$remaining")  $label, resets $(human_time "$reset_epoch") (in ${lh}h ${lm}m)"
    else
      # If remaining is 100%, show it as available
      if [ "$remaining" -eq 100 ]; then
        line "      $(bar 100)  $label, resets $(human_time "$reset_epoch") (expired / quota available)"
      else
        line "      $(bar "$remaining")  $label, resets $(human_time "$reset_epoch")"
      fi
    fi
  else
    line "      $label: unavailable"
  fi
}

show_agy() {
  section "AGY / Gemini"
  if ! have jq; then
    line "status: ${RED}requires jq${RESET}"
    return
  fi
  if ! have curl; then
    line "status: ${RED}requires curl${RESET}"
    return
  fi

  local accounts_file="$HOME/.antigravity_tools/accounts.json"
  if [ ! -f "$accounts_file" ]; then
    line "status: ${RED}$accounts_file not found${RESET}"
    return
  fi

  local now
  now=$(date '+%s')

  # Get access token (auto-refresh if expired)
  local access_token
  access_token=$(agy_refresh_token 2>/dev/null || true)
  if [ -z "$access_token" ]; then
    line "status: ${DIM}no valid Google OAuth token (run 'agy' to re-authenticate)${RESET}"
    return
  fi

  # Fetch live quota data
  local live_data=""
  live_data=$(agy_fetch_quota "$access_token" 2>/dev/null || true)

  # Collect enabled account emails
  local emails=()
  while IFS= read -r email; do
    [ -n "$email" ] && emails+=("$email")
  done < <(jq -r '.accounts[]? | select(.disabled != true) | .email // empty' "$accounts_file" 2>/dev/null)

  local total=${#emails[@]}
  line "accounts: ${CYAN}$total${RESET} configured"

  if [ "$total" -eq 0 ]; then
    return
  fi

  # All accounts share the same quota (single OAuth token), so show once
  if [ -n "$live_data" ]; then
    local acct_list="${emails[*]}"
    line "account: ${GREEN}${acct_list// /, }${RESET} ${DIM}(live)${RESET}"

    # Parse Gemini Models group
    local g_weekly_frac g_weekly_reset g_weekly_desc
    local g_5h_frac g_5h_reset g_5h_desc
    g_weekly_frac=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-weekly") | .remainingFraction // empty' <<<"$live_data")
    g_weekly_reset=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-weekly") | .resetTime // empty' <<<"$live_data")
    g_weekly_desc=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-weekly") | .description // empty' <<<"$live_data")
    g_5h_frac=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-5h") | .remainingFraction // empty' <<<"$live_data")
    g_5h_reset=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-5h") | .resetTime // empty' <<<"$live_data")
    g_5h_desc=$(jq -r '.groups[] | select(.displayName == "Gemini Models") | .buckets[] | select(.bucketId == "gemini-5h") | .description // empty' <<<"$live_data")

    # Parse Claude and GPT Models group
    local c_weekly_frac c_weekly_reset c_weekly_desc
    local c_5h_frac c_5h_reset c_5h_desc
    c_weekly_frac=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-weekly") | .remainingFraction // empty' <<<"$live_data")
    c_weekly_reset=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-weekly") | .resetTime // empty' <<<"$live_data")
    c_weekly_desc=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-weekly") | .description // empty' <<<"$live_data")
    c_5h_frac=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-5h") | .remainingFraction // empty' <<<"$live_data")
    c_5h_reset=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-5h") | .resetTime // empty' <<<"$live_data")
    c_5h_desc=$(jq -r '.groups[] | select(.displayName == "Claude and GPT models") | .buckets[] | select(.bucketId == "3p-5h") | .description // empty' <<<"$live_data")

    line "  ${BOLD}google (gemini):${RESET}"
    line "    ${YELLOW}Weekly Limit:${RESET}"
    agy_bucket "flash" "$g_weekly_frac" "$g_weekly_reset" ""
    agy_bucket "pro" "$g_weekly_frac" "$g_weekly_reset" ""
    line "    ${YELLOW}Five Hour Limit:${RESET}"
    agy_bucket "gemini" "$g_5h_frac" "$g_5h_reset" ""

    line "  ${BOLD}cloud (claude/gpt):${RESET}"
    line "    ${YELLOW}Weekly Limit:${RESET}"
    agy_bucket "claude/gpt" "$c_weekly_frac" "$c_weekly_reset" ""
    line "    ${YELLOW}Five Hour Limit:${RESET}"
    agy_bucket "claude/gpt" "$c_5h_frac" "$c_5h_reset" ""
  else
    # Fallback: show account info only
    for email in "${emails[@]}"; do
      line "account: ${GREEN}$email${RESET}"
      line "  ${RED}quota: unavailable (API request failed)${RESET}"
    done
  fi
}

# Refresh the xAI OIDC access token using the cached refresh token in
# ~/.grok/auth.json. Prefers the cached access token if still valid; otherwise
# refreshes via auth.x.ai. xAI rotates the refresh_token on every use, so the
# new refresh_token (if any) is persisted back to the auth file, mirroring grok
# CLI behavior. Prints the access token on stdout.
grok_access_token() {
  local auth_file="$HOME/.grok/auth.json"
  [ -f "$auth_file" ] || return 1
  local entry
  entry="$(jq -c 'to_entries[0]' "$auth_file" 2>/dev/null)"
  [ -n "$entry" ] || return 1
  local cid rt ekey at expires_at
  ekey="$(jq -r '.key' <<<"$entry")"
  cid="$(jq -r '.key' <<<"$entry" | sed 's#.*::##')"
  rt="$(jq -r '.value.refresh_token // empty' <<<"$entry")"
  at="$(jq -r '.value.key // empty' <<<"$entry")"
  expires_at="$(jq -r '.value.expires_at // empty' <<<"$entry")"

  # Reuse the cached access token if it is still valid (with a 60s safety margin).
  if [ -n "$at" ] && [ -n "$expires_at" ] && [ "$expires_at" != "null" ]; then
    local now exp
    now="$(date '+%s')"
    exp="$(date -u -d "$expires_at" '+%s' 2>/dev/null || date -u -d "${expires_at%.*}Z" '+%s' 2>/dev/null || printf '0')"
    if [ "$exp" -gt 0 ] && [ "$((exp - now))" -gt 60 ]; then
      printf '%s' "$at"
      return 0
    fi
  fi

  [ -n "$cid" ] && [ -n "$rt" ] || return 1

  local resp new_rt
  resp="$(curl -sS -m 15 -X POST 'https://auth.x.ai/oauth2/token' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=refresh_token' \
    --data-urlencode "client_id=$cid" \
    --data-urlencode "refresh_token=$rt" 2>/dev/null)"
  at="$(jq -r '.access_token // empty' 2>/dev/null <<<"$resp")"
  [ -n "$at" ] || return 1

  # Persist the rotated refresh_token (and refreshed access token / expiry) back.
  new_rt="$(jq -r '.refresh_token // empty' 2>/dev/null <<<"$resp")"
  local new_exp
  new_exp="$(jq -r '.expires_in // empty' 2>/dev/null <<<"$resp")"
  local tmp
  tmp="$(mktemp)"
  if jq -c --arg k "$ekey" --arg at "$at" --arg rt "${new_rt:-$rt}" \
        --argjson exp_offset "${new_exp:-0}" \
        '.[$k].key = $at | .[$k].refresh_token = $rt' "$auth_file" >"$tmp" 2>/dev/null; then
    mv -f "$tmp" "$auth_file"
    chmod 600 "$auth_file" 2>/dev/null || true
  else
    rm -f "$tmp" 2>/dev/null || true
  fi

  printf '%s' "$at"
}

show_grok() {
  section "Grok"
  if ! have grok; then
    line "status: grok command not found"
    return
  fi
  if ! have curl || ! have jq; then
    line "status: requires curl and jq"
    return
  fi

  local at
  at="$(grok_access_token)" || at=""
  if [ -z "$at" ]; then
    line "status: no valid grok token (run \`grok login\`)"
    return
  fi

  local billing user
  billing="$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' \
    'https://cli-chat-proxy.grok.com/v1/billing?format=credits' 2>/dev/null)"
  user="$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' \
    'https://cli-chat-proxy.grok.com/v1/user?include=subscription' 2>/dev/null)"

  if $JSON_MODE; then
    jq -n --argjson b "$billing" --argjson u "$user" '{grok:{billing:$b,user:$u}}'
    return
  fi

  if [ -z "$billing" ] || [ "$(jq -r 'if type=="object" then has("config") else false end' <<<"$billing" 2>/dev/null)" != "true" ]; then
    line "status: ${RED}failed to fetch billing${RESET}"
    printf '%b\n' "${DIM}$(printf '%s' "$billing" | head -c 200)${RESET}"
    return
  fi

  local email tier
  email="$(jq -r '.email // "unknown"' <<<"$user" 2>/dev/null)"
  tier="$(jq -r '.subscriptionTier // "unknown"' <<<"$user" 2>/dev/null)"
  line "account: ${GREEN}$email${RESET}"
  line "tier: ${YELLOW}$tier${RESET}"

  # Grok exposes a single weekly usage group (credits) for grok-build.
  local cfg ptype pstart pend used oncap onused prepaid
  cfg="$(jq -c '.config' <<<"$billing")"
  ptype="$(jq -r '.currentPeriod.type // "unknown"' <<<"$cfg" | sed 's/USAGE_PERIOD_TYPE_//; s/.*/\L&/')"
  pstart="$(jq -r '.currentPeriod.start // empty' <<<"$cfg")"
  pend="$(jq -r '.currentPeriod.end // empty' <<<"$cfg")"
  used="$(jq -r '.creditUsagePercent // empty' <<<"$cfg")"
  oncap="$(jq -r '.onDemandCap.val // 0' <<<"$cfg")"
  onused="$(jq -r '.onDemandUsed.val // 0' <<<"$cfg")"
  prepaid="$(jq -r '.prepaidBalance.val // 0' <<<"$cfg")"

  line "limit: ${BOLD}credits${RESET} ($ptype)"
  if [ -n "$used" ]; then
    local used_int
    used_int=$(printf '%.0f' "$used" 2>/dev/null || echo "0")
    local remaining=$((100 - used_int))
    line "$(bar "$remaining")${pstart:+, period ${DIM}$(iso_time "$pstart") → $(iso_time "$pend")${RESET}}"
  else
    line "  ${DIM}used: unavailable${RESET}"
  fi
  line "  ${DIM}on-demand: used ${CYAN}$(format_tokens "$onused")${RESET} ${DIM}/ cap ${CYAN}$(format_tokens "$oncap")${RESET}"
  line "  ${DIM}prepaid balance: ${CYAN}$(format_tokens "$prepaid")${RESET}"
  jq -r '.productUsage[]? | "  - \(.product): \(.usagePercent)%"' <<<"$cfg" 2>/dev/null
}

# Cursor usage via the DashboardService Connect RPC (same endpoint the CLI uses).
# Args: access_token
# Prints JSON {"usage":..., "hardLimit":...} on success.
cursor_fetch_quota() {
  local at="$1"
  local usage hard
  usage="$(curl -sS -m 15 -X POST 'https://api2.cursor.sh/aiserver.v1.DashboardService/GetCurrentPeriodUsage' \
    -H "Authorization: Bearer $at" -H 'Content-Type: application/json' -d '{}' 2>/dev/null)"
  hard="$(curl -sS -m 15 -X POST 'https://api2.cursor.sh/aiserver.v1.DashboardService/GetHardLimit' \
    -H "Authorization: Bearer $at" -H 'Content-Type: application/json' -d '{}' 2>/dev/null)"
  [ -z "$usage" ] && usage='{}'
  [ -z "$hard" ] && hard='{}'
  jq -nc --argjson u "$usage" --argjson h "$hard" '{usage:$u, hardLimit:$h}'
}

show_cursor() {
  section "Cursor"
  if ! have cursor-agent; then
    line "status: ${DIM}cursor not installed (run 'cur' to install)${RESET}"
    return
  fi
  if ! have curl || ! have jq; then
    line "status: ${RED}requires curl and jq${RESET}"
    return
  fi

  local auth_file="$HOME/.config/cursor/auth.json"
  [ -f "$auth_file" ] || { line "status: ${RED}no cursor auth ($auth_file)${RESET}"; return; }
  local at
  at="$(jq -r '.accessToken // empty' "$auth_file" 2>/dev/null)"
  [ -n "$at" ] || { line "status: ${RED}no access token in auth${RESET}"; return; }

  local data
  data="$(cursor_fetch_quota "$at")"

  if $JSON_MODE; then
    jq -n --argjson c "$data" '{cursor:$c}'
    return
  fi

  local usage
  usage="$(jq -r '.usage // empty' <<<"$data")"
  if [ -z "$usage" ] || [ "$(jq -r 'type' <<<"$usage" 2>/dev/null)" != "object" ] \
    || [ "$(jq -r 'has("planUsage")' <<<"$usage" 2>/dev/null)" != "true" ]; then
    line "status: ${RED}failed to fetch usage${RESET}"
    printf '%b\n' "${DIM}$(printf '%s' "$data" | head -c 200)${RESET}"
    return
  fi

  local email
  email="$(jq -r '.authInfo.email // "unknown"' "$HOME/.cursor/cli-config.json" 2>/dev/null)"

  line "account: ${GREEN}$email${RESET}"

  local start end auto api total ondemand start_s end_s olim orem msg
  start="$(jq -r '.billingCycleStart // empty' <<<"$usage")"
  end="$(jq -r '.billingCycleEnd // empty' <<<"$usage")"
  auto="$(jq -r '.planUsage.autoPercentUsed // 0' <<<"$usage")"
  api="$(jq -r '.planUsage.apiPercentUsed // 0' <<<"$usage")"
  total="$(jq -r '.planUsage.totalPercentUsed // 0' <<<"$usage")"
  ondemand="$(jq -r '.hardLimit.noUsageBasedAllowed // false' <<<"$data")"

  [ -n "$start" ] && start_s="$(awk -v ms="$start" 'BEGIN{printf "%d", ms/1000}')"
  [ -n "$end" ] && end_s="$(awk -v ms="$end" 'BEGIN{printf "%d", ms/1000}')"

  line "limit: ${BOLD}included usage${RESET}"
  line "$(bar "$(awk -v u="$total" 'BEGIN{printf "%d",100-u}')")${start_s:+, period ${DIM}$(human_time "$start_s") → $(human_time "$end_s")${RESET}}"
  line "  ${DIM}auto: $(bar "$(awk -v u="$auto" 'BEGIN{printf "%d",100-u}')")${RESET}"
  line "  ${DIM}api:  $(bar "$(awk -v u="$api" 'BEGIN{printf "%d",100-u}')")${RESET}"

  if [ "$ondemand" = "true" ]; then
    line "  ${DIM}on-demand: ${RED}disabled${RESET}"
  else
    olim="$(jq -r '.usage.spendLimitUsage.overallLimit // 0' <<<"$data")"
    orem="$(jq -r '.usage.spendLimitUsage.overallRemaining // 0' <<<"$data")"
    line "  ${DIM}on-demand: used $((olim - orem)) / cap ${olim}${RESET}"
  fi

  msg="$(jq -r '.usage.displayMessage // empty' <<<"$data")"
  [ -n "$msg" ] && line "  ${DIM}$msg${RESET}"
}

if $JSON_MODE; then
  codex_json_block=""
  if ! have codex; then
    codex_json_block='{"ok":false,"error":"codex command not found"}'
  elif ! have node || ! have jq; then
    codex_json_block='{"ok":false,"error":"requires node and jq"}'
  else
    codex_json_block="$(codex_json)"
  fi

  agy_block="null"
  if have jq && have curl; then
    _agy_token=$(agy_refresh_token 2>/dev/null || true)
    _agy_quota=""
    if [ -n "$_agy_token" ]; then
      _agy_quota=$(agy_fetch_quota "$_agy_token" 2>/dev/null || true)
    fi
    agy_block=$(jq -nc --argjson q "${_agy_quota:-null}" --argjson a "$(
      jq -c '{accounts:[.accounts[]? | {email, disabled, last_used}]}' \
        "$HOME/.antigravity_tools/accounts.json" 2>/dev/null || echo '{"accounts":[]}'
    )" '{accounts: $a.accounts, quota: $q}' 2>/dev/null || echo "null")
  fi

  grok_block="null"
  if have grok && have curl && have jq; then
    at="$(grok_access_token)" || at=""
    if [ -n "$at" ]; then
      grok_block="$(jq -nc \
        --argjson b "$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' 'https://cli-chat-proxy.grok.com/v1/billing?format=credits' 2>/dev/null || printf '{}')" \
        --argjson u "$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' 'https://cli-chat-proxy.grok.com/v1/user?include=subscription' 2>/dev/null || printf '{}')" \
        '{billing:$b,user:$u}')"
    fi
  fi

  kiro_block="null"
  if have sqlite3 && have curl && have jq; then
    _kiro_db="$HOME/.local/share/kiro-cli/data.sqlite3"
    if [ -f "$_kiro_db" ]; then
      _kiro_raw=$(sqlite3 "$_kiro_db" "SELECT value FROM auth_kv WHERE key='kirocli:social:token';" 2>/dev/null)
      if [ -n "$_kiro_raw" ]; then
        _kiro_at=$(kiro_access_token 2>/dev/null || true)
        _kiro_pa=$(jq -r '.profile_arn // empty' <<<"$_kiro_raw" 2>/dev/null)
        _kiro_quota=""
        if [ -n "$_kiro_at" ] && [ -n "$_kiro_pa" ]; then
          _kiro_quota=$(kiro_fetch_quota "$_kiro_at" "$_kiro_pa" 2>/dev/null || true)
        fi
        kiro_block=$(jq -nc --argjson q "${_kiro_quota:-null}" --arg email "$(jq -r '.email // "unknown"' <<<"$_kiro_raw" 2>/dev/null)" --arg pa "${_kiro_pa:-}" '{email:$email, profile_arn:$pa, usage:$q}' 2>/dev/null || echo "null")
      fi
    fi
  fi

  cursor_block="null"
  if have curl && have jq && [ -f "$HOME/.config/cursor/auth.json" ]; then
    _cur_at="$(jq -r '.accessToken // empty' "$HOME/.config/cursor/auth.json" 2>/dev/null)"
    if [ -n "$_cur_at" ]; then
      cursor_block="$(cursor_fetch_quota "$_cur_at" 2>/dev/null || printf 'null')"
    fi
  fi

  jq -n --argjson c "$codex_json_block" --argjson a "${agy_block:-null}" --argjson g "${grok_block:-null}" --argjson k "${kiro_block:-null}" --argjson cur "${cursor_block:-null}" \
    '{codex:$c, agy:$a, grok:$g, kiro:$k, cursor:$cur}'
else
  line "Agent quota snapshot ($(date '+%Y-%m-%d %H:%M:%S %Z'))"
  show_codex
  show_agy
  show_grok
  show_cursor
  show_kiro
fi
