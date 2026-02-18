#!/bin/sh
#Resource: https://github.com/polybar/polybar-scripts/blob/master/polybar-scripts/updates-fwupd/updates-fwupdmgr.sh

#FIXME:
# fwupdmgr refresh
# WARNING: UEFI capsule updates not available or enabled in firmware setup
# See https://github.com/fwupd/fwupd/wiki/PluginFlag:capsules-unsupported for more information.
# Metadata is up to date; use --force to refresh again.
fwupdmgr refresh >> /dev/null 2>&1

updates=$(fwupdmgr get-updates 2> /dev/null | grep -c "Updatable")

if [ "$updates" -gt 0 ]; then
    echo "# $updates"
else
    echo ""
fi