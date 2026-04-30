#!/usr/bin/env bash
set -u

ROOT="${CODEX_HOME:-$HOME/.codex}"
WATCH="$ROOT/skills/.system"
IMAGEGEN="$WATCH/imagegen"
LOG="$ROOT/log/imagegen-system-monitor.log"
INTERVAL="${IMAGEGEN_SYSTEM_MONITOR_INTERVAL:-2}"

mkdir -p "$(dirname "$LOG")"

snapshot() {
  local now marker state app_pids
  now="$(date '+%Y-%m-%d %H:%M:%S %z')"
  marker="missing"
  if [ -f "$WATCH/.codex-system-skills.marker" ]; then
    marker="$(tr -d '\n' < "$WATCH/.codex-system-skills.marker" 2>/dev/null || true)"
  fi
  if [ -e "$IMAGEGEN" ]; then
    state="present|$(stat -f 'root_inode=%i root_birth=%SB root_mtime=%Sm root_ctime=%Sc' -t '%Y-%m-%dT%H:%M:%S%z' "$WATCH" 2>/dev/null)|$(stat -f 'imagegen_inode=%i imagegen_birth=%SB imagegen_mtime=%Sm imagegen_ctime=%Sc' -t '%Y-%m-%dT%H:%M:%S%z' "$IMAGEGEN" 2>/dev/null)|marker=$marker"
  elif [ -e "$WATCH" ]; then
    state="system-present-imagegen-missing|$(stat -f 'root_inode=%i root_birth=%SB root_mtime=%Sm root_ctime=%Sc' -t '%Y-%m-%dT%H:%M:%S%z' "$WATCH" 2>/dev/null)|marker=$marker"
  else
    state="system-missing|skills_root=$(stat -f 'inode=%i birth=%SB mtime=%Sm ctime=%Sc' -t '%Y-%m-%dT%H:%M:%S%z' "$ROOT/skills" 2>/dev/null || echo unavailable)|marker=$marker"
  fi
  app_pids="$(ps -axo pid,ppid,lstart,command | /usr/bin/grep -E '/Applications/Codex.app|/Resources/codex( |$)|codex_chronicle' | /usr/bin/grep -v grep | tr '\n' ';' | cut -c 1-1200)"
  printf '%s | %s | pids=%s\n' "$now" "$state" "$app_pids"
}

{
  echo "=== imagegen system monitor started $(date '+%Y-%m-%d %H:%M:%S %z') pid=$$ watch=$WATCH interval=${INTERVAL}s ==="
  last=""
  while :; do
    current="$(snapshot)"
    comparable="${current#* | }"
    if [ "$comparable" != "$last" ]; then
      echo "$current"
      last="$comparable"
    fi
    sleep "$INTERVAL"
  done
} >> "$LOG" 2>&1
