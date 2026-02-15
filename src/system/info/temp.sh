#!/usr/bin/env sh
# temp.sh - Display system temperatures
# VERSION: 1.0.0
# Description: Retrieves and displays temperatures for CPU, GPU(nvidia), 
# and NVMe from system sensors.
# Usage: temp.sh [--cpu] [--gpu] [--nvme]
# Example:
#   ./temp.sh --gpu --nvme --cpu
#   CPU: 34.0°C
#   GPU: 33°C
#   NVME: 38.9°C

show_cpu=false
show_gpu=false
show_nvme=false

while [ $# -gt 0 ]; do
    case $1 in
        --cpu) show_cpu=true ;;
        --gpu) show_gpu=true ;;
        --nvme) show_nvme=true ;;
        *) echo "Usage: $0 [--cpu] [--gpu] [--nvme]" >&2; exit 1 ;;
    esac
    shift
done

# If no flags specified, show CPU by default
if [ "$show_cpu" = false ] && [ "$show_gpu" = false ] && [ "$show_nvme" = false ]; then
    show_cpu=true
fi

if [ "$show_cpu" = true ]; then
    temp=$(sensors | grep 'Tdie:' | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    temp=${temp:-0}
    echo "CPU: ${temp}°C"
fi

if [ "$show_gpu" = true ]; then
    if command -v nvidia-settings >/dev/null 2>&1; then
        temp=$(nvidia-settings -q gpucoretemp -t 2>/dev/null)
        temp=${temp:-0}
        echo "GPU: ${temp}°C"
    else
        echo "GPU: nvidia-settings not available"
    fi
fi

if [ "$show_nvme" = true ]; then
    temp=$(sensors | grep 'Composite:' | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    temp=${temp:-0}
    echo "NVME: ${temp}°C"
fi
