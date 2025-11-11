#!/usr/bin/env bash
#
# Quiet idle monitor for qtile / xautolock:
# - Detects whether audio is playing (PulseAudio `pactl` or `playerctl`) quietly.
# - When audio plays: disables xautolock and disables screensaver/DPMS (by setting timeouts to 0).
# - When audio stops: re-enables xautolock and restores original xset settings captured at startup.
# - Sends a single notification on state changes (if notify-send available).
#
# Simple, conservative behavior: saves original xset state at start and restores it on exit or
# when audio stops. Avoids using `-dpms` toggles so that externally-triggered "force off"
# calls do not unduly revert settings.
#
# Place this in your qtile autostart or run it in your X session.
# Poll interval default is 300 seconds (5 minutes). Export INTERVAL to override.

# Quiet helpers
quiet_cmd() { command "$@" >/dev/null 2>&1 || true; }

# Require xautolock present
if ! command -v xautolock >/dev/null 2>&1; then
  echo "xautolock is not installed. Please install it before running this script." >&2
  exit 1
fi

INTERVAL=${INTERVAL:-300}

XAUTOLOCK_CMD=(xautolock -time 15 -locker 'systemctl suspend' -notify 600 -notifier 'i3lock | xset dpms force off')

start_xautolock_if_needed() {
  if ! pgrep -x xautolock >/dev/null 2>&1; then
    "${XAUTOLOCK_CMD[@]}" &>/dev/null &
    sleep 0.2
  fi
}

# Detect audio playing (quiet)
is_audio_playing() {
  if command -v pactl >/dev/null 2>&1; then
    pactl list sinks 2>/dev/null | grep -q 'State: RUNNING' >/dev/null 2>&1 && return 0
    return 1
  fi

  if command -v playerctl >/dev/null 2>&1; then
    local status
    status=$(playerctl status 2>/dev/null) || return 1
    [ "$status" = "Playing" ] && return 0
    return 1
  fi

  return 1
}

# Notification (no-op if none)
notify_user() {
  local msg="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u normal "Idle monitor" "$msg"
  fi
}

# Capture original xset state so we can restore it later.
# Populates globals:
#   ORIG_SS_TIMEOUT ORIG_SS_CYCLE ORIG_SS_ENABLED
#   ORIG_DPMS_STANDBY ORIG_DPMS_SUSPEND ORIG_DPMS_OFF ORIG_DPMS_ENABLED
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

  # Screen saver timeout and cycle
  ORIG_SS_TIMEOUT=$(printf "%s\n" "$out" | sed -n 's/.*timeout: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_SS_CYCLE=$(printf "%s\n" "$out" | sed -n 's/.*cycle: *\([0-9]*\).*/\1/p' | head -n1)
  ORIG_SS_TIMEOUT=${ORIG_SS_TIMEOUT:-0}
  ORIG_SS_CYCLE=${ORIG_SS_CYCLE:-0}
  if [ "$ORIG_SS_TIMEOUT" -gt 0 ]; then
    ORIG_SS_ENABLED="on"
  else
    ORIG_SS_ENABLED="off"
  fi

  # DPMS values
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
}

# Apply "disable screensaver/DPMS" policy while audio plays:
# - Turn screensaver off
# - Set DPMS timeouts to 0 0 0 (effectively disabling automatic DPMS actions)
apply_disable_xset() {
  if ! command -v xset >/dev/null 2>&1; then
    return
  fi
  # disable screensaver
  quiet_cmd xset s off
  # set DPMS timeouts to zero (quiet)
  quiet_cmd xset dpms 0 0 0
  # don't flip the DPMS enabled flag; timeouts = 0 is conservative and reversible
}

# Restore original xset state captured earlier
restore_xset_state() {
  if ! command -v xset >/dev/null 2>&1; then
    return
  fi

  # Restore screensaver timeout/cycle and state
  if [ -n "${ORIG_SS_TIMEOUT+x}" ]; then
    # if original timeout is non-zero, set it and enable screensaver
    if [ "$ORIG_SS_TIMEOUT" -gt 0 ]; then
      quiet_cmd xset s "$ORIG_SS_TIMEOUT" "$ORIG_SS_CYCLE"
      quiet_cmd xset s on
    else
      # zero timeout -> screensaver disabled
      quiet_cmd xset s off
    fi
  fi

  # Restore DPMS enabled state and timeouts
  if [ -n "${ORIG_DPMS_ENABLED+x}" ]; then
    if [ "$ORIG_DPMS_ENABLED" = "Enabled" ]; then
      quiet_cmd xset +dpms
    else
      quiet_cmd xset -dpms
    fi
    # restore original timeouts (standby suspend off)
    quiet_cmd xset dpms "$ORIG_DPMS_STANDBY" "$ORIG_DPMS_SUSPEND" "$ORIG_DPMS_OFF"
  fi
}

# Ensure we restore original xset settings on exit
cleanup_and_exit() {
  restore_xset_state
  # Ensure xautolock is enabled on exit to avoid leaving locking disabled
  quiet_cmd xautolock -enable
  exit 0
}
trap cleanup_and_exit EXIT INT TERM

# Start xautolock if missing
start_xautolock_if_needed

# Capture original xset state now (before we change anything)
capture_xset_state

# Track previous audio state to avoid spamming toggles and notifications
prev_state="unknown"

# Initial state: set things according to current audio state, but don't notify on startup
if is_audio_playing; then
  prev_state="playing"
  quiet_cmd xautolock -disable
  apply_disable_xset
else
  prev_state="stopped"
  quiet_cmd xautolock -enable
  restore_xset_state
fi

# Main loop: poll and only act on state changes
while true; do
  if is_audio_playing; then
    state="playing"
  else
    state="stopped"
  fi

  if [ "$state" != "$prev_state" ]; then
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
  fi

  sleep "$INTERVAL"
done
