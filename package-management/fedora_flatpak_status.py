import subprocess
from typing import Union


def run_command(command: str, timeout: int = 10) -> Union[str, None]:
    """Run a shell command with a timeout.

    Args:
        command (str): The command to execute.
        timeout (int): Timeout in seconds for the command.

    Returns:
        Union[str, None]: The command output or None if it fails.
    """
    try:
        result = subprocess.run(
            command, shell=True, text=True, capture_output=True, timeout=timeout
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except subprocess.TimeoutExpired:
        return None


def get_fedora_update_count() -> str:
    """Get the count of Fedora (dnf) updates available.

    Returns:
        str: The count of updates or '?' if an error occurs.
    """
    command = "dnf check-update --refresh"
    output = run_command(command)

    if output is None:
        return "?"

    lines = [
        line
        for line in output.splitlines()
        if line
        and not line.startswith("Last metadata")
        and not line.startswith("Upgrade")
    ]
    return str(len(lines)) if lines else "0"


def get_flatpak_update_count() -> str:
    """Get the count of Flatpak updates available.

    Returns:
        str: The count of updates or '?' if an error occurs.
    """
    command = "flatpak remote-ls --updates"
    output = run_command(command)

    if output is None:
        # Fallback to flatpak update if remote-ls fails
        command = "flatpak update --no-deploy"
        output = run_command(command)
        if output is None or "Error" in output:
            return "?"
        if "Nothing to do." in output:
            return "0"
        lines = [line for line in output.splitlines() if line.strip().startswith("1.")]
        return str(len(lines)) if lines else "?"

    lines = [line for line in output.splitlines() if line.strip()]
    return str(len(lines)) if lines else "0"


def main():
    """Main function to display Fedora and Flatpak update counts."""
    fedora_count = get_fedora_update_count()
    flatpak_count = get_flatpak_update_count()

    # Show checkmark instead of "0" for better readability
    fedora_count = "✅" if fedora_count == "0" else fedora_count
    flatpak_count = "✅" if flatpak_count == "0" else flatpak_count

    fedora_icon = "\uf30a"  # FontAwesome Fedora logo
    print(f"{fedora_icon} : {fedora_count} | 📦: {flatpak_count}")


if __name__ == "__main__":
    main()
