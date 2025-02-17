import argparse
import re
from os import getcwd

import argtypes
from logger import LOGGER

TEST_DICT = {
    "input_color": argtypes.check_color,
    "pastel_factor": argtypes.check_float_range(0, 1),
    "background_color": argtypes.check_color,
    "text_color": argtypes.check_color,
    "dir_path": argtypes.check_dir_path,
    "file_extension": argtypes.check_extension,
    "metadata_name": argtypes.check_in_list(["category", "artist", "genre", "grouping"]),
    "files_list": argtypes.check_files_list,
    "video_path": argtypes.check_existing_file,
    "video_url": argtypes.check_site,
    "video_dir_path": argtypes.check_dir_path,
    "metadata_field": argtypes.check_in_list(["category", "artist", "genre", "grouping"]),
}

DEFAULT_DICT = {
    "theme_name": "Dracula",
    "dir_path": getcwd(),
    "video_dir_path": "/home/eduardotc/Videos/p/videos",
    "metadata_field": "all",
    "argparse_group_name": "All",
}


class ArgHandle(argparse.Action):
    """Custom argparse Action to handle argument parsing with validation and user prompting."""

    def __call__(self, parser, namespace, values, option_string=None):
        """Check every time is called, for the argparse specific argument, length and types.

        Function to handle argparse arguments from a flag, in respect to the total number of args
        in this flag, checked based on this flag metavar, that should have the same length as the
        total arguments inputted on the flag, and also check for each metavar type, based on
        the 'TEST_DICT', that contains each metavar type function based on its name.

        When the class confirms that the length of given arguments is lower than the length of
        that flag metavar, it either do one of the 3 following:

            - Optional
                If the metavar name contains (Optional), than that metavar should necessary be
                defined in 'DEFAULT_DICT' variable, with its correspondent default value, otherwise
                None will be added as argument, which will result in the last point of this list
                to execute
            - Default
                If the metavar contains (Default: value), it will automatically add value as
                the missing argument
            - User input:
                It will prompt to the user input a value

        """
        values = self._ensure_list(values)

        # Dictionary of custom validation functions

        # Determine required argument count
        metavar_length = len(self.metavar) if self.metavar else 1

        # Prompt for missing values
        while len(values) < metavar_length:
            missing_arg = (
                self.metavar[len(values)] if self.metavar else f"Argument {len(values) + 1}"
            )
            missing_arg, optBool = self._handle_otional_params(missing_arg)
            if not optBool:
                if self.choices:
                    LOGGER.print_col(f"Choices: {' '.join(self.choices)}", "BLUE")
                LOGGER.print_same_line(
                    ["please provide a value for ", missing_arg, ": "], ["text", "yellow", "text"]
                )
                new_value = input().strip()
            test_value = self._convert_value(new_value, TEST_DICT, missing_arg)
            if test_value != "repeat":
                values.append(test_value)

        self._handle_multiple_optionals(values)
        for i, value in enumerate(values):
            metavar_key = self.metavar[i] if self.metavar else None
            test_type = TEST_DICT.get(metavar_key, self.type)
            values[i] = self._handle_repeat(value, test_type, metavar_key)

        setattr(namespace, self.dest, values)

    def _handle_multiple_optionals(self, values):
        """Check if any metavar matches "str (Multiple)", indicating it has multiple optionals."""
        try:
            matches = [m for m in self.metavar if re.search(r"^(\S*)\s\(Multiple\)", m)]
            self.metavar.extend(matches * (len(values) - len(self.metavar)))
            return
        except (TypeError, AttributeError, OSError):
            return

    def _handle_otional_params(self, missing_arg):
        """Handle arguments matching str (Optional) or str (default) pattern.

        Parameters
        ----------
        missing_arg : any
            Element from the argparse argument namespace metavar, being the metavar with the
            index matching the first missing argument (this function should be called only
            when the size of inserted args and needed don't match)

        Returns
        -------
        any
            Either the default value to this kind of argument, if it matches the summary indicated
            pattern, being this default value defined on `DEFAULT_DICT` and `DEFAULT_MATCH`
            , or return the same value inputed if it don't match with the defined patterns.
        bool
            Indicative if the function returned different by this instance, or if it keeps the same.

        """
        optional_match = re.search(r"^(\S*)\s\(Optional\)", missing_arg)
        DEFAULT_MATCH = re.search(r"\(default:\s*([^)]*)\)", missing_arg)

        if optional_match:
            new_value = DEFAULT_DICT.get(optional_match.group(1), None)
            return new_value, True

        elif DEFAULT_MATCH:
            new_value = DEFAULT_MATCH.group(1)
            return new_value, True

        return missing_arg, False

    def _ensure_list(self, values):
        """Ensure the values are in a list format."""
        return values if isinstance(values, list) else [values]

    def _convert_value(self, value, TEST_DICT, metavar_key):
        """Convert and validate an input value based on its expected type."""
        try:
            return TEST_DICT[metavar_key](value) if metavar_key in TEST_DICT else self.type(value)
        except ValueError:
            print(
                f"Invalid value. Expected a {metavar_key or self.type.__name__}. Please try again."
            )
            return self._convert_value(
                input(f"Provide a value for {metavar_key}: ").strip(), TEST_DICT, metavar_key
            )

    def _handle_repeat(self, value, test_type, metavar_key):
        """Handle cases where the user inputs 'repeat'."""
        value = test_type(value)
        while value == "repeat":
            new_value = input(f"Provide a new value for {metavar_key or 'Argument'}: ").strip()
            try:
                assert test_type(new_value) != "repeat"
                return test_type(new_value)
            except (AssertionError, ValueError):
                print(
                    f"Invalid value. Expected {metavar_key or self.type.__name__}. Please try again."
                )
        return value


HANDLER = ArgHandle
__all__ = [HANDLER]
