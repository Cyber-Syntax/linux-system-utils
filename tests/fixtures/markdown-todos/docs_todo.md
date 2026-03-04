# todos

## testing

- [x] make a simple script to copy home dirs when specified the paths for easy distro hop

## in-progress

- [ ] borgbackup scripts now moved the auto-penguin-setup cli tools to automate borgbackup setup process. Remove it safely.
- [ ] make scrap script better to get only content? article tags etc.?
- [ ] P2: make sytemd-service for cleanup superproductivity backups?
- [ ] P1: better script location ~/scripts instead of ~/.local/share/linux-system-utils ?
    - [ ] Main problem for this; I don't use qtile anymore but fedora-package-management.sh is outdated so script try to do that with old code...
    - [ ] We also need to update linux-system-utils script to make sure about to updates and version check for this script, so maybe we can make a bin to do that or maybe we can make a cli tool directly related for this scripts?
    - [ ] move some scripts direclty to bin like changelog script to be able to call it like a installed script which we need it for example for the superproductivity clean script because it is already able to remove it from anywhere like, any path without issue.
    - [ ] P1: Use symlinks to ~/.local/bin/ direclty, so it would be up to date all the time?
    - [ ] Each scripts prints its own git version
    - [ ] Add auto updater `my-tools-update` which do git pull and start the install.sh from the linux-system-utils repo or git repo if not exist?
    - [ ] Your install script should:
  Detect broken symlinks
  Refuse to overwrite real files
  Validate executables

```bash
~/src/my-tools/        # Git repo (authoritative)
├── bin/
│   ├── mytool
│   └── othertool
├── share/
│   └── completions/
└── install.sh
```

```bash
mytool --version
# mytool v1.4.2 (commit abc123)
```

- [ ] implement copy_agents.sh
- [ ] don't bother with rsync script: <https://github.com/deajan/osync?tab=readme-ov-file#quick-sync-mode>
- [ ] check more: <https://wiki.archlinux.org/title/Synchronization_and_backup_programs>
- [ ] make changelog_commits.md rewrite the all file instead of append which
      we are going to keep the changelog_commits.md file in project dirs all the time
      and it would be much better to not append the same commits over and over again.
- [ ] lets move linux-system-utils name to scripts or another.
- [ ] add a useful small bash script cli to get current memory ghz, cpu ghz
- [ ] Make a arch and fedora package manager for polybar instead only fedora.
- [ ] use all.sh in that directory and source them, one for detection distro,
      one of pacman.sh one for dnf.sh one for flatpak.sh would be better.

```bash
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

- [ ] BUG: idle.sh not stop when using zoom etc. which there is no playerctl
    - [ ] add audio logic to detected via playerctl and than pactl and than proc/asound location
    - [ ] add option to detect fullscreen and disable idle
    - [ ] Add option to decrease brightness before lock
    - [ ] decrease brightness after 20% battery
    - [x] fedora 42 not suspend successfully -> it probably because of nfancurve.service, now disabled.

```bash
abrt-server[475559]: Deleting problem directory '/var/spool/abrt/ccpp-2025-11-21-14:46:08.135431-2664'
```

## done

- [x] BUG: idle.sh send 2-3 audio detected notification.
