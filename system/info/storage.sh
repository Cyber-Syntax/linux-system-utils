#!/bin/sh
# Copyright (c) 2025, Cyber-Syntax Serif
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Define mount points to check
mounts=("/" "/home" "/root" "/backup" "/nix")
warning=20
critical=10

output=""
tooltip=""
overall_class=""

for m in "${mounts[@]}"; do
  # Get the df output for the mount point (skip error if mount not found)
  df_line=$(df -h -P -l "$m" 2>/dev/null | tail -n 1)
  [ -z "$df_line" ] && continue

  # Parse fields from df output: Filesystem, Size, Used, Avail, Use%, Mounted on
  filesystem=$(echo "$df_line" | awk '{print $1}')
  size=$(echo "$df_line" | awk '{print $2}')
  used=$(echo "$df_line" | awk '{print $3}')
  avail=$(echo "$df_line" | awk '{print $4}')
  usepct=$(echo "$df_line" | awk '{print $5}')
  mountpoint=$(echo "$df_line" | awk '{print $6}')

  # Remove the trailing % from the use percentage
  usepct_num=$(echo "$usepct" | tr -d '%')
  free=$(expr 100 - "$usepct_num")

  # Determine the mount point's severity
  mount_class=""
  if [ "$free" -lt "$critical" ]; then
    mount_class="critical"
  elif [ "$free" -lt "$warning" ]; then
    mount_class="warning"
  fi

  # Only add mount points that are under the defined free-space threshold
  if [ -n "$mount_class" ]; then
    output="${output}[${m}: ${free}% free] "
    tooltip="${tooltip}Filesystem: ${filesystem}\nMounted on: ${mountpoint}\nSize: ${size}\nUsed: ${used}\nAvail: ${avail}\nUse%: ${usepct}\n\n"
    # Set overall class to the most severe encountered
    if [ "$mount_class" = "critical" ]; then
      overall_class="critical"
    elif [ -z "$overall_class" ]; then
      overall_class="warning"
    fi
  fi
done

# If no mount point is under threshold, display an OK message
if [ -z "$output" ]; then
  output=" "
  tooltip="All mount points have sufficient free space."
fi

# Output JSON formatted for waybar
printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$output" "$tooltip" "$overall_class"

