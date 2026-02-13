# Module: script

The module will wait for the exec script to finish until updating its contents. If you are launching an application, make sure you are sending it to the background by appending & after the line that executes the application.
If your script is using an infinite loop in combination with tail = true, the exec-if condition is only checked until it evaluates to true for the first time, because it is only checked before running the exec command and since the exec command never returns (because of the infinite loop), exec-if is never evaluated again, once the exec command is running. So if the exec-if condition at some point, while the infinite loop is running, would evaluate to false the script will not suddenly stop running and the module will not disappear.
To be displayed on the bar, the script's output has to be newline terminated (as most commands do).
If you want the module to disappear from the bar in some cases, your script must produce a single empty line of output and a zero exit code. Otherwise an outdated output is still on the bar. See #504 and #2861.

## updates-flatpak

```bash
#!/bin/sh

updates=$(flatpak update 2>/dev/null | tail -n +5 | grep -Ecv "^$|^Proceed|^Nothing")

if [ "$updates" -gt 0 ]; then
    echo "flatpak: $updates"
else
    echo ""
fi
```

## updates-dnf

```bash
#!/bin/sh

updates=$(dnf updateinfo -q list | wc -l)

if [ "$updates" -gt 0 ]; then
    echo "# $updates"
else
    echo ""
fi
```
