---
id: dotfiles
aliases: []
tags: []
---
# Todo.md

> [!NOTE]
>
> neovim, i3, qtile and other dotfiles tasks.

## testing

## in-progress

- [ ] setup.sh problem on dotfiles that move files like this if it's already exist
       fix this problem
       setup a new option to backup current existing default ones
       and than we can stow it to our dotfiles

```
dot-config/alacritty/alacritty/
dot-config/dunst/dunst/
dot-config/gtk-3.0/gtk-3.0/
dot-config/i3/i3/
dot-config/picom/picom/
dot-config/polybar/polybar/
```

- [ ] tmux dotfiles need to git clone tpm to tmux/plugins folder than install the plugins prefix and press shift and I to install
- [ ] add ~/.vscode here
- [ ] xfce-power-manager won't lock the screen so it won't sleep..
- [ ] remove ollama from laptop
- [ ] hyprland
    - [ ] Learn how to decrease brightness
    - [ ] Setup appimage to new wayland setting, test in superproductivity
    - [ ] use a bash script or python script to make i3 tabbed structure
- [ ] dunst, use context to focus on vscode when click the notification come from zed or vscode?

- [ ] my-unicorn must be figured it out, if we ignore with syncthing, we can't sync to dotfiles repo
    - [ ] Currently; I don't symling the my-unicorn config on my laptop but better to find another way

- [ ] Checkbox can't be used with tab when in visual probably related with plugin
- [ ] just change laptop zsh history and desktop history which we lose history of desktop sometimes
- [ ] change shortcut for `space + m` better which I always forget it
- [ ] ollama already on neovim but not work, codecompanion also not work with agentic but work for asking
- [ ] paste link to word on neovim easily? <https://github.com/antonk52/markdowny.nvim>
- [ ] gtkrc configs
    - [ ] make proper gtkrc config, get it from gnome or kde cachyos
    - [ ] stow gtkrc
- [ ] update zshrc with this: <https://github.com/mcornella/dotfiles/blob/main/zshenv#L57>
- [ ] add git config to .config/git location for better ?
"
Specifies the pathname to the file that contains patterns to describe paths that are not meant to be tracked, in addition to .gitignore (per-directory) and .git/info/exclude. Defaults to $XDG_CONFIG_HOME/git/ignore. If $XDG_CONFIG_HOME is either not set or empty, $HOME/.config/git/ignore is used instead. See gitignore[5].
"

## todo

- [ ] maybe we can use neorg or vimwiki?
    - [ ] test neorg
    - [ ] test vimwiki
- [ ] add rofi to dotfiles
    - [x] change nord.rasi to use `~` this instead of developer name
- [ ] add tmux update readme.md, firstly remove all plugin folders including tpm
and nordic-tmux too, than clone tpm and than get in to tmux and install all
plugins with `alt + shift + I`. Probably better to write a basic bash script.

- [ ] Polybar
    - [ ] playerctl script cause issue when two instance of output

```bash
#!/bin/sh

player_status=$(playerctl status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    echo "#1 $(playerctl metadata artist) - $(playerctl metadata title)"
elif [ "$player_status" = "Paused" ]; then
    echo "#2 $(playerctl metadata artist) - $(playerctl metadata title)"
else
    echo "#3"
fi
```

- [ ] systray icon so small
- [ ] checkout useful scripts and brainstrom <https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/info-dualshock4>
- [x] make a script to show turkish months, so I could remember them
- [ ] percentage not aligned correctly on widgets
- [ ] ewmh is completely wrong paddings
    - switch i3 workspaces more easy
- [ ] update polybar status when scripts done

## done

- [x] my-unicorn is synced with laptop because of dotfiles? (ignore the my-unicorn on syncthing)

- [x] enable ollama on neovim to better grammar and privacy on note taking

- [x] P1: BUG: obsidian.nvim not able to link rsync.md file to here...

- [x] decrease font size

- [x] remove indent-blankline.nvim, we use different now
- [x] create todo.md for dotfiles or use this?
- [x] remove todo.md from nvim

- [x] Testing xfce4-power-panel on i3 for better management

- [x] add backintime config to dotfiles

- [x] Cleanup config and i3 folder from old backups
- [x] idle.sh for locking, auto sleep or xfce4-power-manager
- [x] install xfce power manager, and use that for sleep lock to i3

xfce4-power-manager

(xfce4-power-manager:439622): xfce4-power-manager-WARNING \*\*: 22:46:24.649: Unable to connect to session manager : Failed to connect to the session manager: SESSION_MANAGER environment variable not defined

- [X] character errors
    - below checkbox is cause issue, even with siji + other all fonts
    I changed that character on my script to work with polybar for workaround solution
    - Problem was `polybar|notice:  Loaded font "Noto Color Emoji:style=Regular=Medium:size=11" (name=Noto Color Emoji, offset=0, file=/usr/share/fonts/google-noto-color-emoji-fonts/NotoColorEmoji.ttf)
` this font missing

```bash
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
polybar|warn:  Dropping unmatched character '✅' (U+2705) in '✅ Up-to-date'
```

- [x] make obsidian.nvim to create names for notes directly same without using number like 12348714ASDGAS.md
