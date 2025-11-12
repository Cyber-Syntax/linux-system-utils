#!/usr/bin/env bash
#
# Quiet idle monitor for qtile / xautolock
# - Detects whether audio is playing (prefer playerctl, fall back to pactl, skip ALSA on PipeWire)
# - When audio plays: disables xautolock and sets xset DPMS/screensaver timeouts to 0
# - When audio stops: re-enables xautolock and restores original xset settings captured at startup
# - Debounces transient audio flaps and suppresses notification spam via cooldown
#
# Edits: single-instance lock, playerctl-first priority, corked-state handling, debounce, notification cooldown.
# Poll interval default is 300 seconds (5 minutes). Export INTERVAL to override.
set -euo pipefail

# Helpers
quiet_cmd() {
  if [ "${DEBUG:-0}" -ne 0 ]; then
    local rc=0
    local out
    # Avoid set -e terminating the script while we capture command output/exit code
    set +e
    out="$(command "$@" 2>&1)"
    rc=$?
    set -e
    DEBUG_LOG=${DEBUG_LOG:-/tmp/idle-audio-monitor.log}
    printf '%s CMD: %s\n' "$(date '+%F %T')" "$*" >>"$DEBUG_LOG"
    printf '%s RET=%d\n%s\n' "$(date '+%F %T')" "$rc" "$out" >>"$DEBUG_LOG"
    # Also emit a concise summary to stderr for interactive debugging
    printf '%s CMD: %s (rc=%d)\n' "$(date '+%F %T')" "$*" "$rc" >&2
    [ -n "$out" ] && printf '%s\n' "$out" >&2
    return $rc
  else
    command "$@" >/dev/null 2>&1 || true
  fi
}

# Ensure xautolock exists
if ! command -v xautolock >/dev/null 2>&1; then
  echo "xautolock is not installed. Please install it before running this script." >&2
  exit 1
fi

INTERVAL=${INTERVAL:-300}
NOTIFY_COOLDOWN=${NOTIFY_COOLDOWN:-10} # seconds between notifications
LOCKDIR="/run/user/$(id -u)/idle-audio-monitor.lock"
# Optional debug log if DEBUG=1 exported
DEBUG_LOG=${DEBUG_LOG:-/tmp/idle-audio-monitor.log}
DEBUG=${DEBUG:-0}

_debug() {
  [ "${DEBUG:-0}" -ne 0 ] || return 0
  DEBUG_LOG=${DEBUG_LOG:-/tmp/idle-audio-monitor.log}
  printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$DEBUG_LOG"
  # Also echo debug messages to stderr so --debug prints everything to the terminal
  printf '%s %s\n' "$(date '+%F %T')" "$*" >&2
}

# Enable debug mode at runtime.
# Usage:
#   ./idle.sh --debug   -> enable debug logging to DEBUG_LOG
#   ./idle.sh --trace   -> enable debug logging and shell xtrace (PS4 includes timestamps)
enable_debug_mode() {
  DEBUG=1
  DEBUG_LOG=${DEBUG_LOG:-/tmp/idle-audio-monitor.log}
  # create/truncate log if possible
  : >"$DEBUG_LOG" 2>/dev/null || true
  _debug "debug mode enabled"
}

# Basic CLI support: allow starting the script with --debug / -d or --trace
case "${1:-}" in
-d | --debug)
  enable_debug_mode
  shift || true
  ;;
--trace)
  enable_debug_mode
  # timestamped PS4 and enable xtrace for step-by-step shell tracing
  export PS4='+ $(date "+%F %T")\011 '
  set -x
  shift || true
  ;;
esac

# Single-instance guard via lock directory
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  _debug "another instance detected; exiting"
  exit 0
fi

# Ensure lock cleanup on exit
cleanup_lockdir() {
  rm -rf "$LOCKDIR" 2>/dev/null || true
}
trap 'cleanup_lockdir; cleanup_and_exit' EXIT INT TERM

# Start xautolock if missing
XAUTOLOCK_CMD=(xautolock -time 15 -locker 'systemctl suspend' -notify 600 -notifier 'i3lock | xset dpms force off')
start_xautolock_if_needed() {
  if ! pgrep -x xautolock >/dev/null 2>&1; then
    "${XAUTOLOCK_CMD[@]}" &>/dev/null &
    sleep 0.2
  fi
}

# is_audio_playing: prioritize playerctl (accurate for media), then pactl (with corked check)
# Return 0 if audio is playing, 1 otherwise
#
# Priority order:
# 1. playerctl - Check MPRIS media players first (Spotify, VLC, Firefox, etc.)
#    This correctly distinguishes "Playing" vs "Paused" states
# 2. pactl - Check for non-corked (not paused) sink-inputs
#    Catches non-MPRIS audio (system sounds, older apps)
#    Properly handles PipeWire systems by checking corked state
# 3. /proc/asound - Legacy fallback, only used if pactl unavailable
#    (PipeWire keeps ALSA streams open even when paused, causing false positives)
#
is_audio_playing() {
  # Layer 1: Check MPRIS media players via playerctl (HIGHEST PRIORITY)
  # This prevents false positives from ALSA/pactl when media is paused
  if command -v playerctl >/dev/null 2>&1; then
    local all_players
    all_players=$(playerctl -l 2>/dev/null || true)

    if [ -n "$all_players" ]; then
      # Check each player individually
      while IFS= read -r player; do
        [ -z "$player" ] && continue
        local status
        status=$(playerctl -p "$player" status 2>/dev/null || true)
        if [ "$status" = "Playing" ]; then
          _debug "audio active: playerctl reports '$player' is Playing"
          return 0
        fi
        _debug "playerctl: '$player' status='$status' (not playing)"
      done <<<"$all_players"
    else
      _debug "playerctl: no media players found"
    fi
  else
    _debug "playerctl: command not available"
  fi

  # Layer 2: Check PulseAudio/PipeWire sink-inputs (SECOND PRIORITY)
  # This catches non-MPRIS audio like system sounds
  # Important: Check for corked state to avoid false positives from paused streams
  if command -v pactl >/dev/null 2>&1; then
    local pactl_output
    pactl_output=$(pactl list sink-inputs 2>/dev/null || true)

    if [ -n "$pactl_output" ]; then
      # Check if there are any sink-inputs that are NOT corked (not paused)
      # We need to parse each sink-input block separately
      local in_sink_input=0
      local current_corked=""
      local current_state=""
      local found_active=0

      while IFS= read -r line; do
        if echo "$line" | grep -q "^Sink Input #"; then
          # New sink-input block - reset state
          in_sink_input=1
          current_corked=""
          current_state=""
        elif [ $in_sink_input -eq 1 ]; then
          # Check for State
          if echo "$line" | grep -q 'State: RUNNING'; then
            current_state="RUNNING"
          fi

          # Check for corked property (true = paused, false or absent = playing)
          if echo "$line" | grep -q 'pulse.corked = "true"'; then
            current_corked="true"
          elif echo "$line" | grep -q 'pulse.corked = "false"'; then
            current_corked="false"
          fi

          # If we have both state and corked info, evaluate
          if [ -n "$current_state" ] && [ -n "$current_corked" ]; then
            if [ "$current_state" = "RUNNING" ] && [ "$current_corked" != "true" ]; then
              _debug "audio active: pactl sink-input RUNNING and not corked (non-MPRIS audio)"
              found_active=1
              break
            elif [ "$current_state" = "RUNNING" ] && [ "$current_corked" = "true" ]; then
              _debug "pactl: found RUNNING sink-input but it's corked (paused), ignoring"
            fi
            # Reset for next sink-input
            current_state=""
            current_corked=""
          fi
        fi
      done <<<"$pactl_output"

      [ $found_active -eq 1 ] && return 0
    fi
    _debug "pactl: no active (non-corked) sink-inputs"

    # If pactl is available, we skip ALSA check to avoid PipeWire false positives
    _debug "ALSA: skipping (using PulseAudio/PipeWire layer instead)"
  else
    _debug "pactl: command not available"

    # Layer 3: Check ALSA kernel streams (LEGACY FALLBACK - only if pactl unavailable)
    # Note: PipeWire keeps ALSA streams open when paused, causing false positives
    if [ -d /proc/asound ]; then
      for status_file in /proc/asound/card*/pcm*/sub*/status; do
        [ -f "$status_file" ] || continue
        if grep -q 'state: RUNNING' "$status_file" 2>/dev/null; then
          _debug "audio active: ALSA stream RUNNING in $status_file (non-MPRIS audio)"
          return 0
        fi
      done
      _debug "ALSA: no active streams in /proc/asound"
    else
      _debug "ALSA: /proc/asound not available"
    fi
  fi

  _debug "no audio activity detected (all layers checked)"
  return 1
}

# Debounce/confirmation: ensure the desired state persists for 'trials' checks
confirm_state() {
  local want="$1" # "playing" or "stopped"
  local trials=${2:-2}
  local delay_sec=${3:-0.3} # seconds between checks; accepts float
  local i=0
  while [ "$i" -lt "$trials" ]; do
    if is_audio_playing; then
      cur="playing"
    else
      cur="stopped"
    fi
    if [ "$cur" != "$want" ]; then
      _debug "confirm_state: expected $want but saw $cur (attempt $((i + 1))/$trials) -> fail"
      return 1
    fi
    i=$((i + 1))
    if [ "$i" -lt "$trials" ]; then
      sleep "$delay_sec"
    fi
  done
  _debug "confirm_state: confirmed $want ($trials checks)"
  return 0
}

# Notification with cooldown
LAST_NOTIFY=0
notify_user() {
  local msg="$1"
  local now
  now=$(date +%s)
  if [ $((now - LAST_NOTIFY)) -lt "$NOTIFY_COOLDOWN" ]; then
    _debug "notify suppressed (cooldown): $msg"
    return 0
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u normal "Idle monitor" "$msg"
    LAST_NOTIFY=$now
    _debug "notified: $msg"
  else
    _debug "notify-send not available; would notify: $msg"
  fi
}

# Capture and restore xset state (same logic as before)
capture_xset_state() {
  ORIG_SS_TIMEOUT=0
  ORIG_SS_CYCLE=0
  ORIG_SS_ENABLED="off"
  ORIG_DPMS_STANDBY=0
  ORIG_DPMS_SUSPEND=0
  ORIG_DPMS_OFF=0
  ORIG_DPMS_ENABLED="Disabled"

  if ! command -v xset >/dev/null 2>&1; then
    return
  fi

  local out
  out="$(xset q 2>/dev/null)" || out=""

  ORIG_SS_TIMEOUT=$(printf "%s\n" "$out" | sed -n 's/.*timeout: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_SS_CYCLE=$(printf "%s\n" "$out" | sed -n 's/.*cycle: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_SS_TIMEOUT=${ORIG_SS_TIMEOUT:-0}
  ORIG_SS_CYCLE=${ORIG_SS_CYCLE:-0}
  if [ "$ORIG_SS_TIMEOUT" -gt 0 ]; then
    ORIG_SS_ENABLED="on"
  else
    ORIG_SS_ENABLED="off"
  fi

  ORIG_DPMS_STANDBY=$(printf "%s\n" "$out" | sed -n 's/.*Standby: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_DPMS_SUSPEND=$(printf "%s\n" "$out" | sed -n 's/.*Suspend: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_DPMS_OFF=$(printf "%s\n" "$out" | sed -n 's/.*Off: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_DPMS_STANDBY=${ORIG_DPMS_STANDBY:-0}
  ORIG_DPMS_SUSPEND=${ORIG_DPMS_SUSPEND:-0}
  ORIG_DPMS_OFF=${ORIG_DPMS_OFF:-0}

  if printf "%s\n" "$out" | grep -q 'DPMS is Enabled'; then
    ORIG_DPMS_ENABLED="Enabled"
  else
    ORIG_DPMS_ENABLED="Disabled"
  fi
  _debug "captured xset state: ss_timeout=$ORIG_SS_TIMEOUT dpms_enabled=$ORIG_DPMS_ENABLED dpms=$ORIG_DPMS_STANDBY/$ORIG_DPMS_SUSPEND/$ORIG_DPMS_OFF"
}

apply_disable_xset() {
  if ! command -v xset >/dev/null 2>&1; then
    return
  fi
  quiet_cmd xset s off
  quiet_cmd xset dpms 0 0 0
  _debug "applied disable xset"
}

restore_xset_state() {
  if ! command -v xset >/dev/null 2>&1; then
    return
  fi

  if [ -n "${ORIG_SS_TIMEOUT+x}" ]; then
    if [ "$ORIG_SS_TIMEOUT" -gt 0 ]; then
      quiet_cmd xset s "$ORIG_SS_TIMEOUT" "$ORIG_SS_CYCLE"
      quiet_cmd xset s on
    else
      quiet_cmd xset s off
    fi
  fi

  if [ -n "${ORIG_DPMS_ENABLED+x}" ]; then
    if [ "$ORIG_DPMS_ENABLED" = "Enabled" ]; then
      quiet_cmd xset +dpms
    else
      quiet_cmd xset -dpms
    fi
    quiet_cmd xset dpms "$ORIG_DPMS_STANDBY" "$ORIG_DPMS_SUSPEND" "$ORIG_DPMS_OFF"
  fi
  _debug "restored xset state"
}

# Cleanup function invoked by trap
cleanup_and_exit() {
  restore_xset_state
  quiet_cmd xautolock -enable
  _debug "cleanup complete; exiting"
  exit 0
}

# Startup: ensure xautolock, capture xset state
start_xautolock_if_needed
capture_xset_state

# Track previous state and initialize accordingly (no notifications on startup)
prev_state="unknown"
if is_audio_playing; then
  prev_state="playing"
  quiet_cmd xautolock -disable
  apply_disable_xset
  _debug "startup: audio playing -> applied playing policy"
else
  prev_state="stopped"
  quiet_cmd xautolock -enable
  restore_xset_state
  _debug "startup: audio stopped -> restored policy"
fi

# Main loop: poll and act only on confirmed changes
while true; do
  if is_audio_playing; then
    state="playing"
  else
    state="stopped"
  fi

  if [ "$state" != "$prev_state" ]; then
    _debug "detected candidate state change: $prev_state -> $state; confirming..."
    if confirm_state "$state" 2 0.3; then
      if [ "$state" = "playing" ]; then
        quiet_cmd xautolock -disable
        apply_disable_xset
        notify_user "Audio detected — screen lock/suspend and screensaver/DPMS are disabled while audio plays."
      else
        quiet_cmd xautolock -enable
        restore_xset_state
        notify_user "No audio detected — screen lock/suspend and screensaver/DPMS restored."
      fi
      prev_state="$state"
    else
      _debug "state change was transient; ignoring"
      # don't flip prev_state; wait for stable change
    fi
  fi

  sleep "$INTERVAL"
done
