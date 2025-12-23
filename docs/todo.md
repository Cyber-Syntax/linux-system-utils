# todos

## testing

- [ ] BUG: idle.sh not stop when using zoom etc. which there is no playerctl

    - [ ] add audio logic to detected via playerctl and than pactl and than proc/asound location
    - [ ] add option to detect fullscreen and disable idle
    - [ ] Add option to decrease brightness before lock
    - [ ] decrease brightness after 20% battery
    - [ ] fedora 42 not suspend successfully -> it probably because of nfancurve.service, now disabled.

```
abrt-server[475559]: Deleting problem directory '/var/spool/abrt/ccpp-2025-11-21-14:46:08.135431-2664'
```

## in-progress

- [ ] lets move linux-system-utils name to scripts or another.
- [ ] add a useful small bash script cli to get current memory ghz, cpu ghz
- [ ] Make a arch and fedora package manager for polybar instead only fedora.
- [ ] use all.sh in that directory and source them, one for detection distro,
one of pacman.sh one for dnf.sh one for flatpak.sh would be better.

```
watch -n1 "grep 'cpu MHz' /proc/cpuinfo"
```

## todo

- [ ] make spotify .cache/spotify/data/\* removal script weekly
- [ ] Refactor the path on WM's to the repo installed xdg base dir
- [ ] add auto-cpufreq on desktop
- [ ] checkbox need to be shown when the update script called and if it successfully update all the packages
    - we might be fetch the updates again quickly after update option called.
- [ ] ~/Documents/mysql/backup add cleanup util script
- [ ] deploy.sh --dev is copy .git files to share location

## backlog

- [ ] configure nfancurve.service again with defaults and try to solve display issue again.

## done

- [x] BUG: idle.sh send 2-3 audio detected notification.
