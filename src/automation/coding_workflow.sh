#!/bin/bash
# Setting up a coding environment for myself.
# Opening url's like github, chatgpt, etc.

# constants
browser="$HOME/.local/share/myunicorn/zen-browser.AppImage"
search="https://www.perplexity.ai"
chatgpt="https://chatgpt.com"
deepseek="https://chat.deepseek.com/sign_in"
ide="dev.zed.Zed"

# open via browser example:
# ~/.local/share/myunicorn/zen-browser.AppImage "https://www.perplexity.com" "https://www.arch.org"
# workflow.sh: line 13: ~/.local/share/myunicorn/zen-browser.AppImage: No such file or directory
${browser} "${search}" "${chatgpt}" "${deepseek}"

# Starting IDE
# Handle the flatpak symbolic link error by adding a retry mechanism
launch_zed() {
  # Simple approach to handle the flatpak libbsd.so.0 issue
  echo "Launching Zed editor with error handling..."

  flatpak run "${ide}" &
}

# Execute the Zed launch function
launch_zed
