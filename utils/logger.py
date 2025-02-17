#!/usr/bin/env python3
"""
Created on 2025-02-05 15:49:15.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Logger module function, defined on a separate file, since it is a core utillity.

Used to print messages to the user terminal. Can be configured to print this messages including
or not ansi colors, as well as include to the printing stdout errors or not.

Between this module uses, there is configuring it to LOGGER.set_use_colors(False) to remove the
printing colors on pytests, for removing ansi colors that can give errors.

this file class is exported to the rest of the module globally to be used as `LOGGER`

Define the following TypeAlias

- LoggerColorsNames
    Used for the possible colors names, defined by the class dict of ansi colors

- LoggerColors
    Define the possible colors formats to be passed to the class to use

- LoggerLineStyle
    Define the strigs binded to lines styles when printing lines

- LoggerArgs
    Define the optional args strings that may be passed to some of the class functions
"""

import sys
from typing import Literal, TextIO, TypeAlias

LoggerColorsNames: TypeAlias = Literal[
    "RED",
    "GRN",
    "YLW",
    "BLUE",
    "MGN",
    "CYAN",
    "PRP",
    "PNK",
    "RST",
    "BLD",
    "TXT",
    "BLCK",
    "WHT",
    "AQUA",
    "ORANGE",
    "DGRAY",
    "GRAY",
    "LGRAY",
    "blue",
    "yellow",
    "red",
    "green",
    "magenta",
    "purple",
    "pink",
    "reset",
    "white",
    "black",
    "cyan",
    "text",
    "foreground",
    "bold",
    "aqua",
    "orange",
    "dark_gray",
    "gray",
    "light_gray",
    "light_red",
]

LoggerColors: TypeAlias = LoggerColorsNames | list[LoggerColorsNames] | tuple[LoggerColorsNames]

LoggerLineStyle: TypeAlias = Literal["single", "simple", "double"]

LoggerArgs: TypeAlias = LoggerLineStyle | Literal["print_next_line"]


class ScriptLogger:
    """Handle script messages with optional ANSI colors and stderr redirection.

    This class provides methods for formatting messages in different categories,
    such as info, warning, error, success, and debug. ANSI colors can be enabled
    or disabled, and error/warning messages can optionally be redirected to stderr.

    Parameters
    ----------
    use_colors : bool, optional
        Whether to use ANSI colors in the output (default is True).
    use_stderr : bool, optional
        Whether to send error and warning messages to stderr (default is True).

    Attributes
    ----------
    use_colors : bool
        Stores whether ANSI colors should be used in the output.
    use_stderr : bool
        Controls whether warnings and errors are printed to stderr.

    Examples
    --------
    >>> logger = ScriptLogger(use_colors=False, use_stderr=False)
    >>> logger.info("Hello")
    [INFO] Hello
    >>> logger.error("Something went wrong")
    [ERROR] Something went wrong
    >>> logger.success("Done!")
    [SUCCESS] Done!
    >>> logger.set_use_colors(True)  # Enable colors (not visible in doctest)
    >>> logger.set_use_stderr(False)  # Redirect errors to stdout
    """

    def __init__(self, use_colors: bool = True, use_stderr: bool = True):
        self.ansi_dicts = {
            "RED": "\033[38;5;001m",
            "LRED": "\033[38;5;203m",
            "GRN": "\033[38;5;002m",
            "YLW": "\033[38;5;003m",
            "BLUE": "\033[38;5;004m",
            "MGN": "\033[38;5;005m",
            "CYAN": "\033[38;5;006m",
            "PRP": "\033[38;5;056m",
            "PNK": "\033[38;5;201m",
            "RST": "\033[0m",
            "BLD": "\033[38;5;015m",
            "TXT": "\033[38;5;007m",
            "BLCK": "\033[38;5;232m",
            "WHT": "\033[38;5;255m",
            "AQUA": "\033[38;5;081m",
            "ORANGE": "\033[38;5;208m",
            "DGRAY": "\033[38;5;237m",
            "GRAY": "\033[38;5;242m",
            "LGRAY": "\033[38;5;249m",
        }

        self.MESSAGES = {
            "info": [self.ansi_dicts["BLUE"], self.ansi_dicts["BLD"]],
            "warning": [self.ansi_dicts["YLW"], self.ansi_dicts["BLD"]],
            "error": [self.ansi_dicts["RED"], self.ansi_dicts["LRED"]],
            "success": [self.ansi_dicts["GRN"], self.ansi_dicts["AQUA"]],
            "debug": [self.ansi_dicts["MGN"], self.ansi_dicts["BLD"]],
            "reset": self.ansi_dicts["RST"],
        }

        _aliases = {
            "blue": self.ansi_dicts["BLUE"],
            "yellow": self.ansi_dicts["YLW"],
            "red": self.ansi_dicts["RED"],
            "green": self.ansi_dicts["GRN"],
            "magenta": self.ansi_dicts["MGN"],
            "purple": self.ansi_dicts["PRP"],
            "pink": self.ansi_dicts["PNK"],
            "reset": self.ansi_dicts["RST"],
            "white": self.ansi_dicts["WHT"],
            "black": self.ansi_dicts["BLCK"],
            "cyan": self.ansi_dicts["CYAN"],
            "text": self.ansi_dicts["TXT"],
            "foreground": self.ansi_dicts["TXT"],
            "bold": self.ansi_dicts["BLD"],
            "aqua": self.ansi_dicts["AQUA"],
            "orange": self.ansi_dicts["ORANGE"],
            "dark_gray": self.ansi_dicts["DGRAY"],
            "gray": self.ansi_dicts["GRAY"],
            "light_gray": self.ansi_dicts["LGRAY"],
            "light_red": self.ansi_dicts["LRED"],
        }

        for k, c in _aliases.items():
            self.ansi_dicts[k] = c

        self.use_colors = use_colors
        self.use_stderr = use_stderr

    def _format_message(self, msg_type: str, message: str) -> str:
        """Format the message with optional ANSI color.

        Parameters
        ----------
        msg_type : str
            The type of message (e.g., "info", "warning", "error", etc.).
        message : str
            The message text to be displayed.

        Returns
        -------
        str
            The formatted message string.
        """
        reset = [self.MESSAGES["reset"], self.MESSAGES["reset"]] if self.use_colors else ["", ""]
        colors = self.MESSAGES.get(msg_type, ["", ""])
        prefix = f"[{msg_type.upper()}]"
        return f"{colors[0]}{prefix}{reset[0]} {colors[1]}{message}{reset[1]}" if self.use_colors else f"{prefix} {message}"

    def _get_output_stream(self, msg_type: str) -> TextIO:
        """Return the appropriate output stream based on the message type and settings.

        Parameters
        ----------
        msg_type : str
            Logging level of the message, like error or warning, can be:
                - info
                - warning
                - error
                - success
                - debug
                - reset

        Returns
        -------
        TextIO
            Either sys.stdout or sys.stderr.

        """
        return sys.stderr if self.use_stderr and msg_type in {"error", "warning"} else sys.stdout

    def info(self, message: str) -> None:
        """Print an info message."""
        print(self._format_message("info", message), file=self._get_output_stream("info"))

    def warning(self, message: str) -> None:
        """Print a warning message."""
        print(self._format_message("warning", message), file=self._get_output_stream("warning"))

    def error(self, message: str) -> None:
        """Print an error message."""
        print(self._format_message("error", message), file=self._get_output_stream("error"))

    def success(self, message: str) -> None:
        """Print a success message."""
        print(self._format_message("success", message), file=self._get_output_stream("success"))

    def debug(self, message: str) -> None:
        """Print a debug message."""
        print(self._format_message("debug", message), file=self._get_output_stream("debug"))

    def plain(self, message: str) -> None:
        """Print a plain message without any type prefix or color."""
        print(message, file=self._get_output_stream("plain"))

    def set_use_colors(self, enable: bool) -> None:
        """Enable or disable ANSI colors in the output.

        Parameters
        ----------
        enable : bool
            If True, enable ANSI colors; otherwise, disable them.
        """
        self.use_colors = enable

    def set_use_stderr(self, enable: bool) -> None:
        """Enable or disable stderr redirection for errors and warnings.

        Parameters
        ----------
        enable : bool
            If True, errors and warnings will be printed to stderr; otherwise, to stdout.
        """
        self.use_stderr = enable

    def _handle_color(self, iter_color: tuple | list | str) -> str | tuple[str, str]:
        """Handle and sanitize a color parameter.

        Check a color given parameter, if it is either a list or tuple, with elements being strings
        between the allowed ones (color names from 'self.ansi_dicts').

        If the parameter is not in the correct ones cited above, the function fallbacks to retrurn
        the default text color without any background color to be used.

        If the given parameter tuple/list has two elements, it considers the first one as the color
        background color, and the second one as the color foreground.

        Parameters
        ----------
        iter_color : tuple | list

        Returns
        -------
        str
            The ansi escape color for the color, or the joinig of the multiple colors
        """
        if (
            (not isinstance(iter_color, (tuple, list, str)))
            or (isinstance(iter_color, (tuple, list)) and not (1 <= len(iter_color) <= 2))
            or (isinstance(iter_color, str) and iter_color not in self.ansi_dicts)
            or (
                isinstance(iter_color, (tuple, list))
                and any(v not in self.ansi_dicts for v in iter_color)
            )
        ):
            return self.ansi_dicts["TXT"]
        elif isinstance(iter_color, str):
            return self.ansi_dicts[iter_color]
        elif len(iter_color) == 1:
            return self.ansi_dicts[iter_color[0]]

        converted_bg = self.ansi_dicts[iter_color[0]].replace("[38", "[48")
        return f"{converted_bg}{self.ansi_dicts[iter_color[1]]}"

    def print_col(
        self, text: str, color: LoggerColors = None, left_prefix: str = "", right_prefix: str = ""
    ):
        """Print a given text, including the given colors.

        The color can be a color name string, matching any `self.ansi_dicts` keys color name;
        can be a iterable list or element, with values matching the same the previous keys one,
        being in case the tuple/list have just one color name, it will be the color foreground
        to te printed text, or in case it have two colors, the first one will match the background
        color and the secon one the foreground.

        If the list/tuple have more than 2 elements, or any other formatting problem, it will
        fallback tou originals foreground color to the text (white or black)

        Parameters
        ----------
        text : str
        color : list | tuple | str
            list or tuple, being each element of it being a color name, matching the names in the
            keys from  `self.ansi_dicts`.
            In correct formatting, in the case of 2 colors in it, one should be a foreground
            color and other a background color, otherwise, the secon color will override the
            first one.
            If a str, it should be only one color name, matching the `self.ansi_dicts` keys.

        Examples
        --------
        >>> logger = ScriptLogger(use_colors=False, use_stderr=True)
        >>> logger.print_col("test", ("yellow", "red"))
        test

        >>> logger.print_col("test_b", "BLUE")
        test_b

        >>> logger.print_col("only_text")
        only_text
        """
        try:
            message = (
                f"{self._handle_color(color)}{text}{self.ansi_dicts['RST']}"
                if self.use_colors
                else f"{text}"
            )
            message = f"{left_prefix}{message}{right_prefix}"

        except (ValueError, TypeError, OSError) as e:
            print(e, file=self._get_output_stream("error"))
            return

        print(message, file=self._get_output_stream("success"), flush=True)

    def print_line(
        self,
        size_el: str | int,
        color: LoggerColors = None,
        style: Literal["double", "single"] = "double",
    ):
        """Print a line, that may be the union of different chars, like "-", defined by the param.

        Parameters
        ----------
        size_el : str | int
            String element which length defines the line length, so the line should be the same size
            as this string, or integer of the line total length.
        color : str | list | tuple | None, default None
            Color element to this line
        style : | Literal["double", "single"], default "double"
            Which chars should this line be made of, "simple"/"single" would be "-", "double" would
            be "=".
        """
        style_dict = {
            "simple": "-",
            "single": "-",
            "double": "=",
        }
        total_len = (
            size_el
            if isinstance(size_el, int)
            else (len(size_el) if isinstance(size_el, str) else None)
        )
        self.print_col(style_dict[style] * total_len, color=color)

    def print_section(
        self,
        text: str,
        color: LoggerColors,
        *args: LoggerArgs,
    ):
        """Print a section start/header, that may consist of the title, and and optional line.

        Parameters
        ----------
        text : str
            Text to print in the section title
        color : LoggerColors
        args : LoggerArgs
        """
        self.print_col(text, color)
        if "print_next_line" in args:
            if isinstance(color, (tuple, list)) and len(color) >= 2:
                color = color[0]
            self.print_line(
                text, color, next((n for n in args if n in ["simple", "double"]), "simple")
            )

    def print_same_line(
        self,
        text: str | tuple[str] | list[str],
        color: list[LoggerColors] | tuple[LoggerColors] | str = None,
        separator: str = "",
        left_prefix: str = "",
        right_prefix: str = "",
    ):
        """Print multiple given strings, in the same line.

        Parameters
        ----------
        text : str | tuple[str] | list[str]
            Text to be printed
        color : list[LoggerColors] | tuple[LoggerColors] | str, default None
        separator : str, default None
            String to be added between every text element on the line, default ""

        Returns
        -------
        None

        """
        if isinstance(text, str):
            text = [
                text,
            ]
        if isinstance(color, str):
            color = [
                color,
            ]
        if color is None:
            color = ["text"] * len(text)
        if len(color) < len(text):
            color.extend(["text"] * (len(text) - len(color)))
        if len(color) > len(text):
            color = color[: len(text)]
        color_list = list(map(self._handle_color, color))
        result_str = ""
        try:
            assert len(color_list) == len(text)
            for i, n in enumerate(text):
                result_str += (
                    f"{color_list[i]}{n}{self.ansi_dicts['RST']}{separator}"
                    if self.use_colors
                    else f"{n}"
                )
        except (AssertionError, TypeError, ValueError) as e:
            print(f"Error printing with logger to the same line: {e}")

        result_str = f"{left_prefix}{result_str}{right_prefix}"

        print(
            result_str,
            file=self._get_output_stream("success"),
            flush=True,
        )

    def handle_input(
        self, text: tuple | list | str, colors: tuple | list | str, separator: str = ""
    ):
        """Handle user input prompts instances."""
        if isinstance(text, str):
            text = [
                text,
            ]
        if isinstance(colors, str):
            colors = [
                colors,
            ]
        if colors is None:
            colors = ["text"] * len(text)
        if len(colors) < len(text):
            colors.extend(["text"] * (len(text) - len(colors)))
        if len(colors) > len(text):
            colors = colors[: len(text)]
        color_list = list(map(self._handle_color, colors))
        result_str = ""
        try:
            assert len(color_list) == len(text)
            for i, n in enumerate(text):
                result_str += (
                    f"{color_list[i]}{n}{self.ansi_dicts['RST']}{separator}"
                    if self.use_colors
                    else f"{n}"
                )
        except (AssertionError, TypeError, ValueError) as e:
            print(f"Error printing with logger to the same line: {e}")

        input_cmd = input(prompt=result_str)

        return input_cmd


LOGGER = ScriptLogger()
__all__ = LOGGER
