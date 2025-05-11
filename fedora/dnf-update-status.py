#!/usr/bin/python3
"""
System update status checker for Fedora.

This script checks for available updates using DNF package manager
and Flatpak, then displays the count of pending updates.
"""

import subprocess
import sys
from abc import ABC, abstractmethod
from typing import Optional


class UpdateChecker(ABC):
    """Abstract base class for system update checkers."""

    @abstractmethod
    def check_updates(self) -> Optional[int]:
        """
        Check for available updates.

        Returns:
            Optional[int]: Number of available updates or None on error
        """
        pass


class DNFUpdateChecker(UpdateChecker):
    """Class for checking DNF package updates."""

    def check_updates(self) -> Optional[int]:
        """
        Check for available DNF package updates.

        Returns:
            Optional[int]: Number of available updates or None on error
        """
        try:
            # Use check-update instead of updateinfo for broader compatibility
            result = subprocess.run(
                ["dnf", "check-update", "--quiet"],
                capture_output=True,
                text=True,
                check=False,  # don't raise exception on non-zero return code
            )

            # DNF returns code 100 when updates are available
            if result.returncode not in [0, 100]:
                return None

            # Count non-empty lines in the output
            lines = [line for line in result.stdout.split("\n") if line.strip()]
            return len(lines)
        except Exception as e:
            print(f"DNF error: {e}", file=sys.stderr)
            return None


class FlatpakUpdateChecker(UpdateChecker):
    """Class for checking Flatpak updates."""

    def check_updates(self) -> Optional[int]:
        """
        Check for available Flatpak updates.

        Returns:
            Optional[int]: Number of available updates or None on error
        """
        try:
            result = subprocess.run(
                ["flatpak", "remote-ls", "--updates"],
                capture_output=True,
                text=True,
                check=True,
            )

            # Count non-empty lines in the output
            lines = [line for line in result.stdout.split("\n") if line.strip()]
            return len(lines)
        except Exception as e:
            print(f"Flatpak error: {e}", file=sys.stderr)
            return None


class UpdateStatusFormatter:
    """Class for formatting update status messages."""

    def format_status(
        self, dnf_count: Optional[int], flatpak_count: Optional[int]
    ) -> str:
        """
        Format the update status message based on update counts.

        Args:
            dnf_count: Number of DNF updates available or None on error
            flatpak_count: Number of Flatpak updates available or None on error

        Returns:
            str: Formatted status message
        """
        if dnf_count is None and flatpak_count is None:
            return "Could not check for updates. Please verify DNF and Flatpak are installed."

        if dnf_count is None:
            dnf_count = 0
        if flatpak_count is None:
            flatpak_count = 0

        if dnf_count == 0 and flatpak_count == 0:
            return "Up to Date"

        messages = []
        if dnf_count > 0:
            messages.append(f"DNF: {dnf_count}")

        if flatpak_count > 0:
            messages.append(f"Flatpak: {flatpak_count}")

        return "\n".join(messages)


class UpdateManager:
    """Class for managing the update checking process."""

    def __init__(self):
        """Initialize update checkers and formatter."""
        self.dnf_checker = DNFUpdateChecker()
        self.flatpak_checker = FlatpakUpdateChecker()
        self.formatter = UpdateStatusFormatter()

    def check_and_format(self) -> str:
        """
        Check for updates and return a formatted status message.

        Returns:
            str: Formatted status message
        """
        dnf_count = self.dnf_checker.check_updates()
        flatpak_count = self.flatpak_checker.check_updates()
        return self.formatter.format_status(dnf_count, flatpak_count)


def main():
    """Main function - check for updates and display results."""
    manager = UpdateManager()
    status = manager.check_and_format()
    print(status)


if __name__ == "__main__":
    main()
