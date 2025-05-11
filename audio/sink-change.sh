# #!/bin/bash

# Run pactl command to get the list of sinks
pactl_output=$(pactl list sinks short)

# Get active sink name
running_sink=$(echo "$pactl_output" | grep "RUNNING" | cut -f 2)

# # Get available sink available_sinks
# available_sinks=$(pactl list sinks short | cut -f 2)

# Define sink available_sinks
headset='alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game'
DP_0='alsa_output.pci-0000_2b_00.1.hdmi-stereo'
DP_1='alsa_output.pci-0000_26_00.1.hdmi-stereo-extra1'
DP_2='alsa_output.pci-0000_2b_00.1.hdmi-stereo-extra1.2'
DP_4='alsa_output.pci-0000_2b_00.1.hdmi-stereo'

# Create a hash table to store the available sinks
declare -A available_sinks
printf -v available_sinks "%s " "$pactl_output"
while read -r sink; do
    available_sinks[$sink]=1
done < <(echo "$pactl_output" | awk '{print $2}')

# Function to print current active sink name
print_sink() {
    if [ "$running_sink" = "$headset" ]; then
        echo "Headset"
    elif [ "$running_sink" = "$DP_1" ]; then
        echo "DP-1"
    elif [ "$running_sink" = "$DP_2" ]; then
        echo "DP-2"
    elif [ "$running_sink" = "$DP_0" ]; then
        echo "DP-0"
    elif [ "$running_sink" = "$DP_4"]; then
        echo "DP-4"
    fi
}

# Function to change sink
change_sink() {
    if [ "$running_sink" = "$headset" ]; then
        if [[ $available_sinks == *"$DP_1"* ]]; then
            pactl set-default-sink $DP_1
            echo "DP-1"
        elif [[ $available_sinks == *"$DP_2"* ]]; then
            pactl set-default-sink $DP_2
            echo "DP-2"
        elif [[ $available_sinks == *"$DP_0"* ]]; then
            pactl set-default-sink $DP_0
            echo "DP-0"
        else
            echo "Cannot find DP-1, DP-2 or DP-0. Exiting."
        fi
    elif [ "$running_sink" = "$DP_1" ]; then
        if [[ $available_sinks == *"$headset"* ]]; then
            pactl set-default-sink $headset
            echo "Headset"
        elif [[ $available_sinks == *"$DP_2"* ]]; then
            pactl set-default-sink $DP_2
            echo "DP-2"
        elif [[ $available_sinks == *"$DP_0"* ]]; then
            pactl set-default-sink $DP_0
            echo "DP-0"
        else
            echo "Cannot find headset, DP-2 or DP-0. Exiting."
        fi
    elif [ "$running_sink" = "$DP_2" ]; then
        if [[ $available_sinks == *"$headset"* ]]; then
            pactl set-default-sink $headset
            echo "Headset"
        elif [[ $available_sinks == *"$DP_1"* ]]; then
            pactl set-default-sink $DP_1
            echo "DP-1"
        elif [[ $available_sinks == *"$DP_0"* ]]; then
            pactl set-default-sink $DP_0
            echo "DP-0"
        else
            echo "Cannot find headset, DP-1 or DP-0. Exiting."
        fi
    else
        pactl set-default-sink $headset
    fi
}

# # Function to volume level on running sink
volume_level() {
    # Get the index of the currently active audio sink
    running_sink=$(pactl list sinks short | awk -v sink="$(pactl info | awk -F': ' '/Default Sink/{print $2}')" '$0 ~ sink {print NR}')

    # Check if the sink is muted
    is_muted=$(pactl list sinks | grep '^[[:space:]]Mute:' | head -n $(( $running_sink )) | tail -n 1 | sed -n -e 's/^[[:space:]]Mute:[[:space:]]yes$/muted/p')

    # Get the volume level of the sink
    level=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $running_sink )) | tail -n 1 | sed -n -e 's/^.* \([0-9][0-9]*\)%.*$/\1/p')

    # Print the volume level or "Muted" if the sink is muted
    if [ "$is_muted" = "muted" ]; then
        echo "Muted"
    else
        # Print default sink name
        if [ "$running_sink" = "1" ]; then
            echo "Headset": $level                    
        elif [ "$running_sink" = "2" ]; then
            echo "DP-1": $level
        elif [ "$running_sink" = "3" ]; then
            echo "DP-2": $level
        elif [ "$running_sink" = "4" ]; then
            echo "DP-0": $level
        fi

        # Print the volume level
    fi
}

# Check command line arguments and call functions
if [ "$1" = "--status" ]; then
    print_sink
    volume_level

elif [ "$1" = "--change" ]; then
    change_sink
else
    echo "Invalid argument"
fi
