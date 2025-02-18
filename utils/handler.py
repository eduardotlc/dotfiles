#!/usr/bin/env python3
"""
Created on 2025-02-18 13:53:36.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Argparse core class handler for arguments parsing and checking.
Checks if passed the numbner of passed arguments is matching the number of metavars, if not user is
prompted to input a value to the flag, and also checks if the passed argument have the correct type,
based on argtypes, and by `TEST_DICT` dictionary values, to each metavar key.

In case the metavar is "metavar (Optional)" it assigns to metavar the value from `DEFAULT_DICT` in
case it is not provided, while if it matches "metavar (Default: `value`)", it assigns the `value`
format.
"""

import argparse
import re

import argtypes
from logger import LOGGER

TEST_DICT = {
    "left_icon": argtypes.check_existing_file,
    "right_text": argtypes.check_string,
    "right_color": argtypes.check_string,
    "output_svg": argtypes.check_string,
    "left_color": argtypes.check_string,
    "input_color": argtypes.check_color,
    "package_name": argtypes.check_existing_pypi_version,
    "scale_factor": float,
    "font_size": float,
}

DEFAULT_DICT = {
    "left_color": None,
}


class ArgHandle(argparse.Action):
    """Custom argparse Action to handle argument parsing with validation and user prompting."""

    def __call__(self, _: any, namespace: argparse.Namespace, values: any, __: any):
        """
        Check every time is called, for the argparse specific argument, length and types.

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
            missing_arg, opt_bool = self._handle_otional_params(missing_arg)
            if not opt_bool:
                if self.choices:
                    LOGGER.print_col(f"Choices: {' '.join(self.choices)}", "BLUE")
                LOGGER.print_same_line(
                    ["please provide a value for ", missing_arg, ": "],
                    ["text", "yellow", "text"],
                )
                new_value = input().strip()
            else:
                new_value = missing_arg

            test_value = self._convert_value(missing_arg, new_value, TEST_DICT)
            if test_value != "repeat":
                values.append(test_value)

        self._handle_multiple_optionals(values)
        for i, value in enumerate(values):
            metavar_key = self.metavar[i] if self.metavar else None
            test_type = TEST_DICT.get(metavar_key, self.type)
            values[i] = self._handle_repeat(value, test_type, metavar_key)

        setattr(namespace, self.dest, values)

    def _handle_multiple_optionals(self, values: list):
        """Check if any metavar matches "str (Multiple)", indicating it has multiple optionals."""
        try:
            matches = [m for m in self.metavar if re.search(r"^(\S*)\s\(Multiple\)", m)]
            self.metavar.extend(matches * (len(values) - len(self.metavar)))
            return
        except (TypeError, AttributeError, OSError):
            return

    def _handle_otional_params(self, missing_arg: any) -> (any, bool):
        """
        Handle arguments matching str (Optional) or str (default) pattern.

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
        default_match = re.search(r"\(default:\s*([^)]*)\)", missing_arg)

        if optional_match:
            new_value = DEFAULT_DICT.get(optional_match.group(1), None)
            return new_value, True

        elif default_match:
            new_value = default_match.group(1)
            return new_value, True

        return missing_arg, False

    def _ensure_list(self, values: any) -> list:
        """Ensure the values are in a list format."""
        return values if isinstance(values, list) else [values]

    def _convert_value(self, metavar_key: str, value: any, types_dict: dict = TEST_DICT) -> any:
        """Convert and validate an input value based on its expected type."""
        try:
            return types_dict[metavar_key](value) if metavar_key in types_dict else self.type(value)
        except ValueError:
            print(
                f"Invalid value. Expected a {metavar_key or self.type.__name__}. Please try again.",
            )
            return self._convert_value(
                input(f"Provide a value for {metavar_key}: ").strip(),
                types_dict,
                metavar_key,
            )

    def _handle_repeat(self, value: any, test_type: argtypes, metavar_key: str) -> any:
        """Handle cases where the user inputs 'repeat'."""
        value = test_type(value)
        while value == "repeat":
            new_value = input(f"Provide a new value for {metavar_key or 'Argument'}: ").strip()
            try:
                assert test_type(new_value) != "repeat"
                return test_type(new_value)
            except (AssertionError, ValueError):
                err = f"Expected {metavar_key or self.type.__name__}. Please try again."
                LOGGER.error(err)
        return value


HANDLER = ArgHandle
__all__ = ["HANDLER"]
