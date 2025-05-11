#!/bin/sh

# Power off the Fedora server via SSH
ssh fedora-server 'sudo systemctl poweroff'

# if everything went well, print a success message
if [ $? -eq 0 ]; then
    echo "Fedora server is powering off..."
else
    echo "Failed to power off Fedora server"
fi

