#!/bin/bash

# This script provides system information utilities: watch CPU frequency or display memory speed.
# ============================================================================
# System Info Watcher
# ============================================================================

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

usage() {
  echo "Usage: $SCRIPT_NAME [OPTIONS]"
  echo "Options:"
  echo "  --cpu    Watch CPU MHz"
  echo "  --mem    Show memory speed (MHz)"
  echo "  --help   Show this help"
  exit 0
}

watch_cpu() {
  echo "Watching CPU MHz. Press Ctrl+C to exit."
  watch -n1 "grep 'cpu MHz' /proc/cpuinfo"
}

show_mem() {
  echo "Memory speed (MHz):"
  sudo dmidecode --type memory | grep Speed
}

# Parse arguments
processed=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --cpu)
      watch_cpu
      processed=true
      ;;
    --mem)
      show_mem
      processed=true
      ;;
    --help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
  shift
done

# If no valid arguments were processed, show usage
if [[ "$processed" == false ]]; then
  usage
fi
