### Changing Your Username and Home Directory on Linux

Based on the ArchWiki documentation you referenced (from the "Users and groups" page, section on changing a user's login name or home directory), here are straightforward, step-by-step instructions to change your username (login name) and home directory safely. These commands require root privileges, so you'll need to run them as root (e.g., via `sudo` if configured, or by logging in as root directly).

**Important Warnings:**

- Do **not** perform these changes while logged in as the user you're modifying. Instead, log in as a different user (or root) and open a new terminal session (e.g., press `Ctrl+Alt+F6` to switch to a virtual console, log in as root, and run the commands there).
- Back up your data first, especially files in your current home directory, in case something goes wrong.
- Test the changes by logging out and back in after completion.
- If you're using sudo, update `/etc/sudoers` afterward (see step 4 below).
- These instructions assume you're on a standard Linux system like Arch Linux. Adjust paths if your setup differs.

#### Step 1: Change the Home Directory

This moves your existing home directory contents to a new location.

1. Decide on the new home directory path (e.g., `/home/newusername`).
2. Run the following command as root to change the home directory and move the contents:
    ```
    # usermod -d /path/to/new/home -m oldusername
    ```

    - Replace `/path/to/new/home` with your desired new home path (e.g., `/home/newusername`).
    - Replace `oldusername` with your current username.
    - The `-m` flag creates the new directory if it doesn't exist and moves all files from the old home directory to the new one.
3. (Optional) Create a symbolic link from the old home directory to the new one to avoid breaking programs with hardcoded paths:
    ```
    # ln -s /path/to/new/home /path/to/old/home
    ```

    - Replace `/path/to/new/home` and `/path/to/old/home` with the actual paths.
    - Ensure there's no trailing slash on the old path (e.g., `/home/oldusername`, not `/home/oldusername/`).

#### Step 2: Change the Username (Login Name)

Do this after changing the home directory, as it references the username.

1. Run the following command as root:
    ```
    # usermod -l newusername oldusername
    ```

    - Replace `newusername` with your desired new username.
    - Replace `oldusername` with your current username.
2. If the user has a group with the same name as the old username, rename that group too:
    ```
    # groupmod -n newusername oldusername
    ```

#### Step 3: Update Related Files and Configurations

After the changes, several system files and configurations may reference the old username or home path. Update them to avoid issues:

1. **Sudoers file** (if using sudo):
    - Edit `/etc/sudoers` as root using `visudo` (this locks the file to prevent errors):
        ```
        # visudo
        ```
    - Replace any references to the old username with the new one.

2. **Personal crontabs** (scheduled tasks):
    - Rename the crontab file:
        ```
        # mv /var/spool/cron/oldusername /var/spool/cron/newusername
        ```
    - Edit the crontab to update any paths:
        ```
        # crontab -e newusername
        ```
    - This adjusts permissions automatically.

3. **Wine directories** (if using Wine for Windows apps):
    - Manually rename or edit directories like `~/.wine/drive_c/users` and `~/.local/share/applications/wine/Programs` to match the new username.

4. **Other applications** (e.g., Thunderbird addons like Enigmail may need reinstallation).

5. **System-wide configurations**:
    - Search for references to the old username or home path in `/etc/` files (e.g., Samba, CUPS):
        ```
        # grep -r oldusername /etc/
        ```
    - Edit the affected files manually to update paths.
    - Also check for absolute paths in desktop shortcuts, shell scripts, etc., on your system. Use `~` or `$HOME` in scripts to avoid future issues.

#### Step 4: Verify and Test

1. Check the user database for correctness:
    ```
    # pwck
    ```
2. Log out of all sessions for the old user.
3. Log back in with the new username and verify:
    - Your home directory is correct (`echo $HOME`).
    - Files are accessible.
    - Commands like `whoami` show the new username.
4. If issues arise (e.g., permissions errors), double-check file ownership:
    ```
    # chown -R newusername:newusername /path/to/new/home
    ```

If you encounter errors or need to revert, restore from backups and consult the full ArchWiki page for advanced troubleshooting. For automated scripts in your `linux-system-utils` project, consider wrapping these commands in a Bash script with error checking, but test thoroughly first. If this isn't what you meant by "machine name" (e.g., if you meant the system's hostname instead), clarify for hostname change instructions!
