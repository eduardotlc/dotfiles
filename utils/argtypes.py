# !/usr/bin/env python3
"""
Created on 2025-02-17 17:26:02.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Argparse arguments type checking functions. The functions here defined are passed to each argument
in its flag definition, done by `argparse._ArgumentGroup.add_argument`, in this function `type`
parameter, like shown in the bellow examples

The argtypes are also used by `handler`, on its argparse handler class definition, that checks
each of the argparse flag argument type, and if this argument was correctly given by the user,
but instead of raising an error and exiting in the negative case, if an argument is given with
the wrong type or not given at all, the user is prompted to insert the value.

See Also
--------
handler.py : Argparse arguments handling core utils, that utilizes this module argtypes on a dict
             that associates each paramter name / metavars to one specific type.

argparse._ArgumentGroup.add_argument : Can use tis modules argrtypes on its type section.

Examples
--------
Using this module argtypes.check_html_hex on a created --color flag parameter, to assert the
given value to it matches a 6 or 8 digit html hex color.

>>> group_images = parser.add_argument_group(
...     "Images",
...     description="Images utillities related commands.",
... )

>>> group_images.add_argument(
...     "--color",
...     nargs="*",
...     metavar=["scale_factor"],
...     type=argtypes.check_html_hex,
... )
"""

import re
from os.path import isdir, isfile
from typing import Literal, Union

import requests
from logger import LOGGER

# >> FUNCTIONS


# >>>> Any
def check_any(arg: any) -> any:
    """
    Check passed argument, for any type of argument, returning arg itself.

    Used for argparse arguments definitions, that is intended to accept any kind of argument,
    assuring it won't raise any error, as long as any argument is given.

    Parameters
    ----------
    arg : any

    Returns
    -------
    arg
    """
    return arg


# >>>> Float range
def check_float_range(mini: float, maxi: float) -> Union[float, Literal["repeat"]]:
    """
    Return function handle of an argument.

    ArgumentParser checking a float range: mini <= arg <= maxi

    Parameters
    ----------
    mini : float
        minimum acceptable argument
    maxi : float
        maximum acceptable argument

    Returns
    -------
    float_range_checker : function
       Function handle to checking function

    Example
    -------
    >>> checker_function = check_float_range(1, 10)
    >>> LOGGER.set_use_colors(False)
    >>> LOGGER.set_use_stderr(False)
    >>> checker_function(17)
    [ERROR] Must be in range 1 .. 10!
    'repeat'
    """

    def _check_float_range(arg: float) -> float:
        """Check new Type function for argparse - a float within predefined range."""
        try:
            f = float(arg)
            if not isinstance(f, float):
                err = "Must be a floating point number!"
                raise TypeError(err)
            if f < mini or f > maxi:
                err = f"Must be in range {mini} .. {maxi}!"
                raise ValueError(err)
        except (TypeError, ValueError) as e:
            LOGGER.error(e)
            return "repeat"

        return f

    return _check_float_range


# >>>> Check string
def check_string(arg: any) -> str:
    """
    Check if passed parameter is str type.

    Parameters
    ----------
    arg : any

    Returns
    -------
    str
        The same ass the parameter, if it matched str type, or 'repeat' if it was other type

    Examples
    --------
    >>> test = check_string(20)  # doctest: +ELLIPSIS
    [ERROR] Must be string type!

    >>> test = check_string("text input")
    >>> print(test)
    text input
    """
    try:
        assert isinstance(arg, str)
    except (ValueError, AssertionError):
        LOGGER.error("Must be string type!")
        return "repeat"
    return arg


# >>>> Check integer
def check_integer(arg: any) -> Union[int, Literal["repeat"]]:
    """
    Check if arg is integer.

    Parameters
    ----------
    arg : any

    Returns
    -------
    int or 'repeat'
        The same ass the parameter, if it matched int type, or 'repeat' if it was other type

    Examples
    --------
    >>> test = check_integer(20)
    >>> print(test)
    20

    >>> test = check_integer("text input")
    [ERROR] invalid literal for int() with base 10: 'text input'
    >>> print(test)
    repeat
    """
    try:
        i = int(arg)
        assert isinstance(i, int)

    except ValueError as e:
        LOGGER.error(e)
        return "repeat"

    return i


# >>>> Check integer range
def check_integer_range(mini: any, maxi: any) -> Union[int, Literal["repeat"]]:
    """
    Return function handle.

    Used with  an argument type function for ArgumentParser checking a float
    range: mini <= arg <= maxi

    Parameters
    ----------
    mini : float
        minimum acceptable argument
    maxi : float
        maximum acceptable argument

    Returns
    -------
    check_integer_range : function
       Function handle to checking function

    Example
    -------
    >>> checker_function = check_integer_range(1, 10)
    >>> print(checker_function(9))
    9

    >>> checker_function = check_integer_range(1, 10)
    >>> test = checker_function(100)
    [ERROR] 100 is not in allowed integer range 1 - 10
    >>> print(test)
    repeat

    """

    # Define the function with default arguments
    def _check_integer_range(arg: any) -> Union[int, Literal["repeat"]]:
        """Check new Type function for argparse - a float within predefined range."""
        try:
            assert isinstance(arg, int)
            assert arg > mini and arg < maxi
        except AssertionError:
            LOGGER.error(f"{arg} is not in allowed integer range {mini} - {maxi}")
            return "repeat"

        return arg

    return _check_integer_range


# >>>> Check extensions
def check_extension(arg: any) -> str:
    """
    Check argparse argument if match a file extension name.

    Parameters
    ----------
    arg : any

    Return
    ------
    str
        The arg parameter itself, if it matches a file extension str, or 'repeat' if not

    Examples
    --------
    >>> LOGGER.set_use_colors(False)
    >>> LOGGER.set_use_stderr(False)

    >>> test = check_extension(".png")
    >>> print(test)
    .png

    >>> test = check_extension(".pdf")
    >>> print(test)
    .pdf

    >>> test = check_extension("complete_file.mp4")
    [ERROR] complete_file.mp4 Don't match a file extension!
    """
    file_extension_pattern = re.compile(r"^\.[0-9a-zA-Z]+$")
    try:
        ext = file_extension_pattern.match(arg)
        assert ext
    except AssertionError:
        LOGGER.error(f"{arg} Don't match a file extension!")
        return "repeat"

    return ext.group()


def check_html_hex(arg: any) -> str:
    """
    Check if argparse argument matches html hex color, returning the same html color if True.

    The passed argument hax color can be 6 digits color, or 8 digist hex color, in which the last
    two digits represent the color opacity. If the given argument is an html color but without
    the start "#" char, the function insert it on the returned value, and if the color is passed
    with extras quotes in it, the function removes then.
    If the passed argument is not an string, the function consider it is note an html color.

    Parameters
    ----------
    arg : any
        The parameter to check

    Return
    ------
    str
        Html hex color string or "repeat" if the argument don't match a hex color

    Examples
    --------
    Configuring output logger for removing ansi colors on pytest
    >>> LOGGER.set_use_colors(False)

    >>> print(check_html_hex("#FFAABB"))  # True
    #FFAABB

    >>> print(check_html_hex("#FFAABBCC"))  # True
    #FFAABBCC

    >>> print(check_html_hex("#GGAABB"))  # False
    [ERROR] Given color don't match 6 or 8 digit html hex color code
    repeat

    >>> print(check_html_hex("#12345678"))  # True
    #12345678

    >>> print(check_html_hex("123456"))
    #123456

    >>> print(check_html_hex(545153))
    [ERROR] 545153 is not a string!
    repeat
    """
    pattern = r"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$"
    try:
        if not isinstance(arg, str):
            err = f"{arg} is not a string!"
            raise ValueError(err)
        if (arg.startswith('"') and arg.endswith('"')) or (
            arg.startswith("'") and arg.endswith("'")
        ):
            arg = arg.replace('"', "").replace("'", "")
        if not arg.startswith("#") and (len(arg) == 6 or len(arg) == 8):
            arg = f"#{arg}"

        if not bool(re.match(pattern, arg)):
            err = "Given color don't match 6 or 8 digit html hex color code"
            raise TypeError(err)
    except (TypeError, ValueError) as e:
        LOGGER.error(e)
        return "repeat"

    return arg


# >>>> Check html color
def check_html_color(arg: any) -> Union[tuple, Literal["repeat"]]:
    """
    Check if passed argparse argument matches html hex color, returning the color rgb tuple.

    Parameters
    ----------
    arg : any
        The parameter to check

    Return
    ------
    tuple or "repeat"
        Either return a rgb normalized from 0-1 tuple, if it identifyies the input parameter as a
        color, or return the 'repeat' string if don't.

    Examples
    --------
    >>> test = check_html_color("#fcb6c3")
    >>> print(test)
    (0.988, 0.714, 0.765)

    >>> test = check_html_color("#Blue")
    [ERROR] #Blue don't match an html hex code pattern!
    >>> print(test)
    repeat
    """
    try:
        if not isinstance(arg, str):
            err = f"{arg} is not a string!"
            raise ValueError(err)
        if (arg.startswith('"') and arg.endswith('"')) or (
            arg.startswith("'") and arg.endswith("'")
        ):
            arg = arg.replace('"', "").replace("'", "")
        if not arg.startswith("#") and len(arg) == 6:
            arg = f"#{arg}"
        html_match = re.match(r"^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$", arg)
        if html_match is None:
            err = f"{arg} don't match an html hex code pattern!"
            raise NameError(err)
        hex_value = html_match.group(1)
        if not hex_value:
            err = f"{arg} don't match an html hex code pattern!"
            raise ValueError(err)

        if len(hex_value) == 6:
            r, g, b = (round(int(hex_value[i : i + 2], 16) / 255.0, 3) for i in (0, 2, 4))
        else:
            r, g, b = (
                round(int(c * 2, 16) / 255.0, 3) for c in hex_value
            )  # Expand '#RGB' to '#RRGGBB'

    except (NameError, ValueError) as e:
        LOGGER.error(e)
        return "repeat"

    return (r, g, b)


# >>>> Check rgb color
def check_rgb_color(arg: any) -> Union[tuple, Literal["repeat"]]:
    """
    Check if the passed parameter is a valid RGB color.

    After checking if arg matches either a string of an rgb color, or a tuple, accepting both 0-1
    and 0-255 normalized formats, it returns a tuple of the rgb color if the parameter matches one
    rgb color, not changing the normalization base (untill 1 or 255).
    Note that if arg is a string that corresponds to an rgb color, it will be converted and returned
    as the same color but as a tuple.

    Parameters
    ----------
    color : any
        The parameter to check.

    Returns
    -------
    tuple
        A tuple of (r, g, b) if valid, or None if invalid.

    Examples
    --------
    >>> test = check_rgb_color((0.53, 0.35, 0.77))
    >>> print(test)
    (0.53, 0.35, 0.77)

    >>> test = check_rgb_color((150, 144, 32))
    >>> print(test)
    (150, 144, 32)

    >>> test = check_rgb_color("(0.53, 0.35, 0.77)")
    >>> print(test)
    (0.53, 0.35, 0.77)

    >>> test = check_rgb_color("0.53, 0.35, 0.77")
    >>> print(test)
    (0.53, 0.35, 0.77)

    >>> test = check_rgb_color("#fcb3c2")
    [ERROR] #fcb3c2 don't match an rgb color
    >>> print(test)
    repeat
    """

    def is_255_format(c: any) -> bool:
        return isinstance(c, (int, float)) and 1 <= c <= 255

    def is_1_format(c: any) -> bool:
        return isinstance(c, (int, float)) and 0 <= c <= 1

    try:
        if isinstance(arg, str):
            rgb_regex = r"\(?\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*,"
            rgb_regex += r"\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*,"
            rgb_regex += r"\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*\)?"

            match = re.fullmatch(rgb_regex, arg)
            if match:
                r, g, b = (float(num) if "." in num else int(num) for num in match.groups())
                return (r, g, b)
            else:
                err = f"{arg} don't match an rgb color"
                raise ValueError(err)

        if (isinstance(arg, tuple) and len(arg) == 3) and (
            all(is_255_format(c) for c in arg) or all(is_1_format(c) for c in arg)
        ):
            return tuple(arg)

    except ValueError as e:
        LOGGER.error(e)
        return "repeat"


# >>>> Check color
def check_color(arg: any) -> Union[tuple, Literal["repeat"]]:
    """
    Check if paased arg matches a color.

    Color formats accepted are: rgb (0-1 and 0-255), being both tuples or strings possible, with the
    strings one starting or not with "("; html hex code strings, starting or not wit "#".

    If arg is an rgb color, it will be returned as a tuple, with the same numbers as the
    original, in the same normalizing base (0-1 or 0-255).

    If arg is an html hex color, it will be returned as an rgb tuple, normalized by 1, of the
    converted color.

    Parameters
    ----------
    arg : any
        Argument that will be checked if match any kind of color (str or tuple/rgb or html)

    Returns
    -------
    "repeat" or tuple
        tuple of (r,g,b) color or "repeat" if arg don't match a color

    Examples
    --------
    >>> LOGGER.set_use_colors(False)
    >>> LOGGER.set_use_stderr(False)

    >>> test = check_color("#f7b9c3")
    >>> print(test)
    (0.969, 0.725, 0.765)

    >>> test = check_color((0.53, 0.51, 0.94))
    >>> print(test)
    (0.53, 0.51, 0.94)

    >>> test = check_color("(115, 151, 13)")
    >>> print(test)
    (115, 151, 13)

    >>> test = check_color("Yellow")
    [ERROR] Yellow string don't match neither an html hex color or rgb tuple
    """

    def is_255_format(c: any) -> bool:
        return isinstance(c, (int, float)) and 1 <= c <= 255

    def is_1_format(c: any) -> bool:
        return isinstance(c, (int, float)) and 0 <= c <= 1

    try:
        if isinstance(arg, str):
            orig = arg
            if (arg.startswith('"') and arg.endswith('"')) or (
                arg.startswith("'") and arg.endswith("'")
            ):
                arg = arg.replace('"', "").replace("'", "")
            if (
                not arg.startswith("#")
                and len(arg) == 6
                and not any(c in arg for c in [",", ")", "("])
            ):
                arg = f"#{arg}"
            rgb_regex = r"\(?\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*,"
            rgb_regex += r"\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*,"
            rgb_regex += r"\s*(0(?:\.\d+)?|1(?:\.0+)?|[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\s*\)?"

            rgb_match = re.fullmatch(rgb_regex, arg)
            html_match = re.match(r"^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$", arg)
            if rgb_match:
                r, g, b = (float(num) if "." in num else int(num) for num in rgb_match.groups())
                return (r, g, b)
            elif html_match:
                if len(html_match.group(1)) == 6:
                    r, g, b = (
                        round(int(html_match.group(1)[i : i + 2], 16) / 255.0, 3) for i in (0, 2, 4)
                    )
                else:
                    r, g, b = (round(int(c * 2, 16) / 255.0, 3) for c in html_match.group(1))
                return (r, g, b)
            else:
                err = f"{orig} string don't match neither an html hex color or rgb tuple"
                raise ValueError(err)

        elif (isinstance(arg, tuple) and len(arg) == 3) and (
            all(is_255_format(c) for c in arg) or all(is_1_format(c) for c in arg)
        ):
            return tuple(arg)

        else:
            err = f"{arg} don't match neither an html hex color or rgb tuple"
            raise ValueError(err)

    except ValueError as e:
        LOGGER.error(e)
        return "repeat"


# >>>> Check dir path
def check_dir_path(arg: any) -> str:
    """
    Check if given arparse argument matches and existing dir.

    Parameters
    ----------
    arg : any

    Return
    ------
    str
        Given dir path or "repeat" if the given arg don't matches an existing dir

    Exaples
    -------
    Removing ansi colors to the printed results, for better passing pytests.
    >>> LOGGER.set_use_colors(False)

    >>> print(check_dir_path("../badges"))
    ../badges

    >>>print(check_dir_path("non_existing/path"))
    [ERROR] non_existing/path is not an existing dir path!
    repeat

    """
    try:
        assert isdir(arg)
    except AssertionError:
        LOGGER.error(f"{arg} is not an existing dir path!")
        return "repeat"
    return arg


def check_site(arg: any) -> str:
    """
    Check if given arparse argument matches and existing url site.

    Parameters
    ----------
    arg : any

    Return
    ------
    str
        Given dir url string or "repeat" if the given arg don't matches an reachable site.

    Exaples
    -------
    Removing ansi colors to the printed results, for better passing pytests.
    >>> LOGGER.set_use_colors(False)

    >>> print(check_site("https://github.com"))
    https://github.com

    >>>check_site("https://non_existing_site_aaaaa.bbb") # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE
    [ERROR] HTTPSConnectionPool...Name or service not known)"))
    'repeat'

    """
    try:
        response = requests.head(arg, allow_redirects=True, timeout=5)
        assert response.status_code < 400
    except (requests.exceptions.RequestException, ConnectionError, AttributeError) as e:
        LOGGER.error(e)
        return "repeat"
    return arg


def check_existing_file(arg: any) -> str:
    """
    Check if given arparse argument matches an existing file.

    Parameters
    ----------
    arg : any

    Return
    ------
    str
        Given str file path or "repeat" if the given arg don't matches an existing file path.

    Exaples
    -------
    Removing ansi colors to the printed results, for better passing pytests.
    >>> LOGGER.set_use_colors(False)

    >>> print(check_existing_file("../badges/badge_template.svg"))
    ../badges/badge_template.svg

    >>> print(check_existing_file("../non_existing/path"))
    [ERROR] ../non_existing/path file is not an existing file path!
    repeat

    """
    try:
        if not isfile(arg):
            err = f"{arg} file is not an existing file path!"
            raise ValueError(err)
    except ValueError as e:
        LOGGER.error(e)
        return "repeat"

    return arg


def check_existing_pypi_version(arg: any) -> str:
    """
    Check given pypi version existance, and returns it varsion.

    Parameters
    ----------
    arg : any

    Returns
    -------
    str
        Most recent version of the given package, or repeat if this version requesting failed.

    Examples
    --------
    Retrieving numpy version, and asserting it is 2.*
    >>> assert re.match("2*", (check_existing_pypi_version("numpy")))

    """
    try:
        latest_version = requests.get(f"https://pypi.org/pypi/{arg}/json").json()["info"]["version"]
    except KeyError as e:
        LOGGER.error(e)
        return "repeat"

    return latest_version
