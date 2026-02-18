#!/usr/bin/env python3
import gi

gi.require_version("Playerctl", "2.0")
import argparse
import json
import logging
import os
import signal
import sys
from typing import List

import gi
from gi.repository import GLib, Playerctl
from gi.repository.Playerctl import Player

logger = logging.getLogger(__name__)


def signal_handler(sig, frame):
    """
    Handle signals to gracefully exit the program.

    This function is called when SIGINT or SIGTERM is received,
    logging the event and exiting the program.

    Parameters:
    sig (int): The signal number.
    frame: The current stack frame (unused).
    """
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


class PlayerManager:
    """
    Manages media players using Playerctl.

    This class handles the lifecycle of media players, connects to signals,
    and outputs metadata information in JSON format for status bars or similar.
    """

    def __init__(self, selected_player=None):
        """
        Initialize the PlayerManager.

        Sets up the Playerctl manager, connects to player appearance and
        disappearance signals, sets up signal handlers, and initializes
        existing players.

        Parameters:
        selected_player (str, optional): Name of the specific player to monitor.
                                         If None, monitors all players.
        """
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect("name-appeared", self._on_name_appeared)
        self.manager.connect("player-vanished", self._on_player_vanished)

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        self.selected_player = selected_player

        self.init_players()

    def init_players(self):
        """
        Initialize all currently available players.

        Iterates through existing player names and initializes those that
        match the selected player filter (if any).
        """
        for player in self.manager.props.player_names:
            if (
                self.selected_player is not None
                and self.selected_player != player.name
            ):
                logger.debug(
                    "%s is not the filtered player, skipping it", player.name
                )
                continue
            self.init_player(player)

    def run(self):
        """
        Start the main event loop.

        This method runs the GLib main loop to listen for player events.
        """
        logger.info("Starting main loop")
        self.loop.run()

    def _on_name_appeared(self, manager, player):
        """Handle player appearance signal."""
        self.on_player_appeared(manager, player)

    def _on_player_vanished(self, manager, player):
        """Handle player disappearance signal."""
        self.on_player_vanished(manager, player)

    def init_player(self, player):
        """
        Initialize a specific player.

        Connects to playback status and metadata change signals for the player,
        manages it with the manager, and triggers initial metadata output.

        Parameters:
        player: The Playerctl player object to initialize.
        """
        logger.info("Initialize new player: %s", player.name)
        player = Playerctl.Player.new_from_name(player)
        player.connect(
            "playback-status", self.on_playback_status_changed, None
        )
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> List[Player]:
        """
        Get the list of managed players.

        Returns:
        List[Player]: A list of Playerctl Player objects.
        """
        return self.manager.props.players

    def write_output(self, text, player):
        """
        Write the output in JSON format to stdout.

        Parameters:
        text (str): The text to output.
        player: The Playerctl player object.
        """
        logger.debug("Writing output: %s", text)

        output = {
            "text": text,
            "class": "custom-" + player.props.player_name,
            "alt": player.props.player_name,
        }

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        """
        Clear the output by writing a newline to stdout.
        """
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        """
        Handle playback status changes.

        Triggers metadata update when playback status changes.

        Parameters:
        player: The Playerctl player object.
        status: The new playback status.
        _: Unused parameter.
        """
        logger.debug(
            "Playback status changed for player %s: %s",
            player.props.player_name,
            status,
        )
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self):
        """
        Get the first playing player, or the first player if none are playing.

        Returns the most recently added playing player, or the first player
        if none are playing.

        Returns:
        Player or None: The selected player or None if no players exist.
        """
        players = self.get_players()
        logger.debug(
            "Getting first playing player from %d players", len(players)
        )
        if len(players) > 0:
            # if any are playing, show the first one that is playing
            # reverse order, so that the most recently added ones are preferred
            for player in players[::-1]:
                if player.props.status == "Playing":
                    return player
            # if none are playing, show the first one
            return players[0]
        else:
            logger.debug("No players found")
            return None

    def show_most_important_player(self):
        """
        Display the most important player.

        Shows the currently playing player, or the first paused player,
        or clears output if no players.
        """
        logger.debug("Showing most important player")
        # show the currently playing player
        # or else show the first paused player
        # or else show nothing
        current_player = self.get_first_playing_player()
        if current_player is not None:
            self.on_metadata_changed(
                current_player, current_player.props.metadata
            )
        else:
            self.clear_output()

    def on_metadata_changed(self, player, metadata, _=None):
        """
        Handle metadata changes for a player.

        Constructs the track info string and outputs it if this player
        is the most important one.

        Parameters:
        player: The Playerctl player object.
        metadata: The metadata dictionary.
        _: Unused parameter.
        """
        logger.debug(
            "Metadata changed for player %s", player.props.player_name
        )
        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()

        track_info = ""
        if (
            player_name == "spotify"
            and "mpris:trackid" in metadata.keys()
            and ":ad:" in player.props.metadata["mpris:trackid"]
        ):
            track_info = "Advertisement"
        elif artist is not None and title is not None:
            track_info = f"{artist} - {title}"
        else:
            track_info = title

        if track_info:
            if player.props.status == "Playing":
                track_info = " " + track_info
            else:
                track_info = " " + track_info
        # only print output if no other player is playing
        current_playing = self.get_first_playing_player()
        if (
            current_playing is None
            or current_playing.props.player_name == player.props.player_name
        ):
            self.write_output(track_info, player)
        else:
            logger.debug(
                "Other player %s is playing, skipping",
                current_playing.props.player_name,
            )

    def on_player_appeared(self, _, player):
        """
        Handle a new player appearing.

        Initializes the player if it matches the filter.

        Parameters:
        _: The manager (unused).
        player: The appearing player object.
        """
        logger.info("Player has appeared: %s", player.name)
        if player is not None and (
            self.selected_player is None or player.name == self.selected_player
        ):
            self.init_player(player)
        else:
            logger.debug(
                "New player appeared, but it's not the selected player, skipping"
            )

    def on_player_vanished(self, _, player):
        """
        Handle a player vanishing.

        Updates the display to show the most important remaining player.

        Parameters:
        _: The manager (unused).
        player: The vanishing player object.
        """
        logger.info("Player %s has vanished", player.props.player_name)
        self.show_most_important_player()


def parse_arguments():
    """
    Parse command-line arguments.

    Returns:
    argparse.Namespace: The parsed arguments.
    """
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)

    # Define for which player we're listening
    parser.add_argument("--player")

    parser.add_argument("--enable-logging", action="store_true")

    return parser.parse_args()


def main():
    """
    Main entry point of the script.

    Parses arguments, sets up logging, and starts the player manager.
    """
    arguments = parse_arguments()

    # Initialize logging
    if arguments.enable_logging:
        logfile = os.path.join(
            os.path.dirname(os.path.realpath(__file__)), "media-player.log"
        )
        logging.basicConfig(
            filename=logfile,
            level=logging.DEBUG,
            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s",
        )

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info("Filtering for player: %s", arguments.player)
    player = PlayerManager(arguments.player)
    player.run()


if __name__ == "__main__":
    main()
