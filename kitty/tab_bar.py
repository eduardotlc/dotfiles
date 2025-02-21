#!/usr/bin/env python3
"""

Custom kitty terminal tabs drawing.

Module to render tab bar at kitty terminal, defining custom styles
from colors, icons, titles and others in the tabs, as well as defining
a custom current tab associated icon in the left and a statusline with
diferent variables on the bottom right of the tabline.

The following values are obtained from the kitty user config, therefore should
be defined and customized by the users. If they are not set a random color will be
set for this values, but this is majorly to avoid errors, and the design and harmony[
of colors will be a complete disgrace.

active_tab_background, active_tab_foreground,
inactive_tab_background, inactive_tab_foreground,
url_color (used in the todo.txt task rendering)

===============
# Neovim Config
===============

Neovim settings in init.lua for correct defining terminal window title
makes it display 'nvim file_name' as the title from the terminal.

vim.opt.title = true
vim.opt.titlestring = 'nvim %{expand("%:t")}'
vim.opt.titlelen = 0

==============
# Kitty Config
==============

Download Nerd font symbols  at
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/NerdFontsSymbolsOnly.zip
Add to your kitty.conf or other .conf your load on kitty.conf

# Tabs bar 󰝴            󰈦                   󰬷       󱔎       󰽥             
symbol_map U+F0774,U+E69B,U+F0226,U+E73E,U+E73C,U+F0B37,U+F150E,U+F0F65,U+F1A1,U+EA84 symbols Nerd Font Mono
# Tabs bar                                    󰭎              
symbol_map U+F36F,U+EB03,U+E640,U+E69C,U+E65D,U+EBAF,U+F0B4E,U+F005,U+F30A symbols Nerd Font Mono
# Tabs bar             󰄛                         󰬇       󰘸       󰉤
symbol_map U+EB0D,U+F10A,U+F110B,U+F338,U+E673,U+F232,U+F0B07,U+F0638,U+F0264 symbols Nerd Font Mono
# Tabs bar 󰲱       󰲯       󰲭       󰲫       󰲩       󰲧       󰲥       󰲣       󰲡
symbol_map U+F0CB1,U+F0CAF,U+F0CAD,U+F0CAB,U+F0CA9,U+F0CA7,U+F0CA5,U+F0CA3,U+F0CA1 Symbols Nerd Font Mono
# Tabs bar                               󰻶             󰑴             󰌌
symbol_map U+E7B0,U+E712,U+F17B,U+EB11,U+E22E,U+F0EF6,U+F1DE,U+F0474,U+F1C5,U+F030C Symbols Nerd Font Mono
# Tabs bar                    󰑬       󰆴       󰖟       󱉟       
symbol_map  U+E0BC,U+E0BB,U+E0BA,U+F046C,U+F0B14,U+F059F,U+F125F,U+E64B Symbols Nerd Font Mono

========
todo.txt
========

The todo.txt file contains todo task one per line.
The syntax match:

(P) MM-DD task string todo +project @tag

P (Optional):        Task priority letter (A, B, C and D), with A being highest priority
MM-DD (Optionail):   Day the task is added or which is due to.
task string todo:    The task itself.
+project (optional): A + followed by a string containing the project name of this task
@tag (Optional):     A @ followed by a string, with one tag of this task

Example of a todo.txt file:
(B) 08-06 Train llama3.1 inverse model +AI @torchchat
(A) 08-06 Config tab max length +kitty @tab_bar.py

"""

import random
import re
import subprocess
from datetime import datetime
from os import environ, getlogin, uname
from os.path import isdir

from kitty.boss import get_boss
from kitty.cli import create_default_opts

# >> IMPORTS
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.options.types import Options
from kitty.rgb import color_from_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)
from kitty.typing import PowerlineStyle
from kitty.utils import Color, color_as_int, log_error
from kitty.window import Window

# >> DEFINITIONS

# Shouldn't change this values unless you know what you are doing
timer_id = None
timer_todo = None
opts = get_options()

TASK_REGEX = r"""
^(x\s+)?                         # 1: Opt 'x' at the beginning, followed by whitespace
(\((?:A|B|C|D)\)\s+)?            # 2: Opt '(L)' with L as A, B, C, or D, followed by whitespace
((?:\d{2}-\d{2}\s*){0,2})        # 3: Opt date(s) in mm-dd format, allowing up to two dates
# \s+?([^\+@]+?)                 # 4: Req  description (anything up until + or @), lazy match
([a-zA-Z\s]*)                    # 5: Req  description (anything up until + or @), lazy match
((?:\+[a-zA-Z|_|-]+\s?){0,2})          # 5: Opt '+str' project names. Accepts multiples ocurrences.
((?:@[a-zA-Z|_|-]+\s?){0,2})           # 6: Opt '@str' tags occurrences, accepts multiple elments.
((?:\+[a-zA-Z|_|-]+\s?){0,2})          # 7: Opt '+str' project names if they are after the tags.
"""

# >> CONFIGS

# >> Important Definitions
# Space between right margin and the end of the right statusline
RIGHT_MARGIN = 1
REFRESH_TIME = 2
REFRESH_TODO = 120
# Max length of active tabs name
ACTIVE_TAB_LENGTH = 10
# Max length of inactive tabs name
INACTIVE_TAB_LENGTH = 6
# Numbers of tabs which when reached, inactive tab name will start to be the icon and file
# extension when it exists. If not desired this behaviour, set this variable to a large number
N_TABS_TO_SHORTEN_TITLE = 4

# -TODO:Add a fzf task widget, may  be mine or the original todo.txt one
#
# >> Local Paths
# Path to a todo.txt file. this file should have todo tasks
TODO_PATH = "/home/eduardotc/Notes/todo/todo.txt"

# >> Getting Options Variables To Use
KITTY_CONFIG_VARS = [
    "color0",
    "color1",
    "color2",
    "color3",
    "color4",
    "color5",
    "color6",
    "color7",
    "color8",
    "color9",
    "color10",
    "color11",
    "color12",
    "active_tab_foreground",
    "active_tab_background",
    "inactive_tab_background",
    "inactive_tab_foreground",
    "inactive_border_color",
    "background",
    "foreground",
    "tab_bar_background",
    "tab_bar_edge",
    "tab_bar_margin_color",
    "mark1_background",
    "mark1_foreground",
    "mark2_background",
    "mark2_foreground",
    "mark3_background",
    "mark3_foreground",
    "url_color",
    "selection_background",
    "selection_foreground",
]

# >> Icons
PROGRAMS_ICONS_BY_NAME = {
    "pdf": "󰈦 ",
    "markdown": " ",
    "md": " ",
    "lua": "󰽥 ",
    "tex": " ",
    "nvim": " ",
    "config": " ",
    ".config": " ",
    "Makefile": " ",
    "make": " ",
    "bin": " ",
    "python": " ",
    "py": " ",
    "latex": " ",
    "dnf": " ",
    "cards": "󰘸 ",
    "telescope": "󰭎 ",
    "fzf": "󰭎 ",
    "star": " ",
    "notebook": " ",
    "Notes": " ",
    "org": " ",
    "nb": " ",
    "gimp": " ",
    "scholar": "󰑴 ",
    "nchat": " ",
    "tablet": " ",
    "zsh": "󰬇 ",
    "git": " ",
    "gh": " ",
    "~": " ",
    str(getlogin()): " ",
    "rtv": " ",
    "bash": "󰉤 ",
    "mamba": "󱔎 ",
    "miniforge3": "󱔎 ",
    "conda": "󱔎 ",
    "icat": " ",
    "img": " ",
    "pictures": " ",
    "kitty": "󰄛 ",
    "kitten": "󰄛 ",
    "rm": "󰆴 ",
    "ninja": "󰝴 ",
    "jupyter": " ",
    "jupyterlab": " ",
    "duutils --tt": "󰌌 ",
    "kitty-scrollback.nvim": "󰻶 ",
    "scrollback": "󰻶 ",
    "anki": "󰘸 ",
    "library": "󱉟 ",
    ".ssh": " ",
    "sudo": " ",
    "add": "󱘒 ",
    "newsboat": "󰑬 ",
    "html": "󰖟 ",
    "docker": " ",
    "podman": " ",
    "linux": " ",
    "unix": " ",
    "Android": " ",
    "cuda": " ",
    "branch": " "  ,
    "remote": " ",
}

TAB_IDX_ICONS = (
    " 󰲡 ",
    "󰲣 ",
    "󰲥 ",
    "󰲧 ",
    "󰲩 ",
    "󰲫 ",
    "󰲭 ",
    "󰲯 ",
    "󰲱 ",
)

CUSTOM_ICONS = {
    "TODO_ICON": " ",
    "ICON": " ",
    "BRANCH_ICON": " ",
    "GIT_ICON": " ",
    "NVIM_ICON": " ",
    "LEFT_SEP": "",
}

POWERLINE_SYMBOLS: dict[PowerlineStyle, tuple[str, str]] = {
    "slanted": ("", "╱"),
    "round": ("", ""),
}


DEFAULT_TEMPLATE = {
    "blacks": [
        "#282A36",
        "#44475A",
        "#1F0E2C",
        "#000000",
        "#111922",
        "#252A28",
        "#2A2C37",
        "#45475A",
        "#313244",
        "#1E1E2E",
        "#181825",
        "#11111B",
    ],
    "whites": [
        "#F8F8F2",
        "#FFFFFF",
        "#FAFAFA",
        "#F3FAFF",
    ],
    "grays": [
        "#585B70",
        "#666973",
        "#A6ADC8",
        "#9FA4AB",
        "#BAC2DE",
        "#6272A4",
        "#CDD6F4",
        "#7F849C",
        "#9399B2",
        "#6C7086",
        "#79829F",
    ],
    "diverse_color": [
        "#F7768E",
        "#FF9E64",
        "#E0AF68",
        "#73DACA",
        "#B4F9F8",
        "#2AC3DE",
        "#7DCFFF",
        "#7AA2F7",
        "#BB9AF7",
        "#7AA2F7",
        "#7DCFFF",
        "#2DF4C0",
        "#FFC777",
        "#B994F1",
        "#04D1F9",
        "#B4A4F4",
        "#F67F81",
        "#73DACA",
        "#B4F9F8",
        "#E89DFC",
        "#69F0AD",
        "#7EF1EA",
        "#4F71FF",
        "#7FDBCA",
        "#FF5874",
        "#21C7A8",
        "#ECC48D",
        "#82AAFF",
        "#AE81FF",
        "#7FDBCA",
        "#f38ba8",
        "#F1FA8C",
        "#89dceb",
        "#f5c2e7",
        "#fab387",
        "#94e2d5",
        "#4f71ff",
    ],
}


def get_random_color():
    """

    Get a random rgb color.

    Parameters
    ----------
    None

    Returns
    -------
    kitty.options.type.Color
        Kitty rgb random color

    """
    r = random.randint(0, 255)
    g = random.randint(0, 255)
    b = random.randint(0, 255)
    return Color(r, g, b)


def calculate_contrast(color1, color2):
    """
    Calculate the contrast ratio between two colors. The input colors can be either RGB tuples or HTML hex strings.

    Parameters
    ----------
    color1 : int
        Kitty int color format
    color2 : Color
        Kitty int color format

    Returns
    -------
    float
        The contrast ratio between the two colors.

    See Also
    --------
    `form`
        Function used to format html hex, rgb tuples, and kitty Color type, to integer color
    """

    def relative_luminance(r, g, b):
        # Convert sRGB components to linear light (0 to 1 range)
        def srgb_to_linear(c):
            c /= 255.0
            return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

        r_lin = srgb_to_linear(r)
        g_lin = srgb_to_linear(g)
        b_lin = srgb_to_linear(b)
        # Calculate relative luminance
        return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin

    def contrast_ratio(lum1: float, lum2: float) -> float:
        """Calculate the contrast ratio between two luminances."""
        lighter = max(lum1, lum2)
        darker = min(lum1, lum2)
        return (lighter + 0.05) / (darker + 0.05)

    color1 = color_from_int(color1)
    color2 = color_from_int(color2)

    try:
        rgb1 = (color1.r, color1.g, color1.b)
        rgb2 = (color2.r, color2.g, color2.b)

    except TypeError:
        print("Passed format from rgb color don't match kitty integer!")
        return

    lum1 = relative_luminance(*rgb1)
    lum2 = relative_luminance(*rgb2)

    # Calculate contrast ratio
    # l1, l2 = max(lum1, lum2), min(lum1, lum2)
    # contrast_ratio = (l1 + 0.05) / (l2 + 0.05)
    contrast_ratio = contrast_ratio(lum1, lum2)

    return contrast_ratio


def form(color):
    """

    Format passed color.

    Parameters
    ----------
    color
        Of type kitty.options.type.Color, str or kitty.utils.Options,
        being one color.

    Returns
    -------
    color : int
        Given color formatted to kitty integer type.

    """
    if isinstance(color, Color):
        return as_rgb(color_as_int(color))

    elif isinstance(color, int):
        try:
            assert isinstance(color_from_int(color), Color)
            return color
        except ValueError:
            print("Integer color in invalid format!")

    elif isinstance(color, Options):
        try:
            assert color.__dict__
            assert color.__dict__[str(color)]
            if isinstance(color.__dict__[str(color)], Color):
                return as_rgb(color_as_int(color.__dict__[str(color)]))
            raise ValueError

        except ValueError:
            print("Options passed in place of Color!")

    elif isinstance(color, tuple):
        try:
            assert Color(color[0], color[1], color[2])
            return as_rgb(color_as_int(Color(color[0], color[1], color[2])))
        except ValueError:
            print("Passed tuple has invalid format!")

    elif isinstance(color, str):
        try:
            hex_match = re.match(r"^#([0-9a-fA-F]{6})$", color)
            rgb_match = re.match(r"^\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$", color)

            if hex_match:
                hex_list = []
                hex_value = hex_match.group(1)
                for i in (0, 2, 4):
                    hex_list.append(int(hex_value[i : i + 2], 16))
                return as_rgb(color_as_int(Color(hex_list[0], hex_list[1], hex_list[2])))

            elif rgb_match:
                r = int(rgb_match.group(1))
                g = int(rgb_match.group(2))
                b = int(rgb_match.group(3))
                return as_rgb(color_as_int(Color(r, g, b)))

            raise ValueError

        except ValueError:
            print("Passed string not identified as html or rgb tuple string")

    else:
        return None


class CfgVars:
    """Class to handle kitty options from config.

    Attributes
    ----------
    opts : kitty.options.type.Options
        Kitty options
    variables : dict
        Dictionary of kitty configs, with the config name string as a key,
        and the value of it in the value.

    Methods
    -------
    add_var(name: str)
        Adds in variables dict the given name option, getting it from the kitty config,
        or setting a random color value if it is not present in the config.
    val(name: str)
        Get and format if necessary the given name value from the variables dict.
    add_list_var(list_names : list)
        Adds in variables dict all the list strings options, getting the values from the
        kitty config, or setting a random color value if its is not present in the config.
    """

    def __init__(self):
        """Init function of the class."""
        self.opts = get_options()
        self.default = create_default_opts()
        self.variables = {}

    def add_var(self, name):
        """Add a variable to the color variables dictionary.

        Parameters
        ----------
        name : str
            Name of the config to be added in the dictionary key as string,
            being its value obtained from kitty correspondent config, or if
            not set in the configs, a random color is inserted in its place.

        Returns
        -------
        None
        """
        if name in self.opts and self.opts[name] is not None:
            self.variables[name] = getattr(self.opts, name)
        elif name in self.default and self.default[name] is not None:
            self.variables[name] = self.default[name]
        else:
            self.variables[name] = get_random_color()

    def val(self, name):
        """Get a color value from the color variables dictionary.

        Parameters
        ----------
        name : str
            Name of the kitty.conf color/value to get, corresponding
            to the variable colors dictionary key

        Returns
        -------
        kitty.options.type.Color
            Kitty color value
        """
        got_val = self.variables.get(name, None)
        form_val = form(got_val)
        return form_val

    def add_list_var(self, list_names):
        """Add all the names in the list corresponding variables to dictionary.

        Parameters
        ----------
        list_names : list
            list of strings, corresponding the strings to kitty.conf config names.

        Returns
        -------
        None
        """
        for name in list_names:
            self.add_var(name)

    def check_vars_contrast(self, additional_colors=None):
        colors_dict = {
            "colors_1": ["active_tab_foreground", "inactive_tab_foreground"],
            "colors_2": ["active_tab_background", "inactive_tab_background"],
            "contrast_lim": [7, 3],
        }

        # colors_bg = ["active_tab_background"]
        contrast = 0
        for n in range(0, len(colors_dict["colors_1"])):
            if self.val(colors_dict["colors_1"][n]) and self.val(colors_dict["colors_2"][n]):
                while contrast < colors_dict["contrast_lim"][n]:
                    contrast = calculate_contrast(
                        (
                            color_from_int(self.val(colors_dict["colors_1"][n])).r,
                            color_from_int(self.val(colors_dict["colors_1"][n])).g,
                            color_from_int(self.val(colors_dict["colors_1"][n])).b,
                        ),
                        (
                            color_from_int(self.val(colors_dict["colors_2"][n])).r,
                            color_from_int(self.val(colors_dict["colors_2"][n])).g,
                            color_from_int(self.val(colors_dict["colors_2"][n])).b,
                        ),
                    )
                    log_error(contrast)
                    self.variables[colors_dict["colors_1"][n]] = get_random_color()


# >> Class Obtained variables
cfgvars = CfgVars()


cfgvars.add_list_var(KITTY_CONFIG_VARS)
# cfgvars.check_vars_contrast()
# >> COLORS

PRIORITY_COLOR_DICT = {
    "A": [cfgvars.val("color3"), "󰲡 "],  # Yellow
    "B": [cfgvars.val("color2"), "󰲣 "],  # Green
    "C": [cfgvars.val("color5"), "󰲥 "],  # Magenta
    "D": [cfgvars.val("color6"), "󰲧 "],  # Cyan
}

CUSTOM_COLORS = {
    "DATE_COLOR": "#6254af",  # Red
    "DESC_COLOR": cfgvars.val("color3"),  # Yellow
    "GIT_DIRTY": Color(221, 139, 24),  # Orange
    "GIT_CLEAN": cfgvars.val("color6"),  # Cyan
    "PROJECTS_COLOR": "#8911b1",  # Purple
    "HOST_COLOR": "#58f1b9",  # Emerald
    "PRIORITY_NEUTRAL": cfgvars.val("color0"),  # Gray
    "TODO_ICON_COLOR": "#F8F9B6",  # Bright Yellow
    "ICON_BACKGROUND": "#3b2caf",  # Dark Blue
    "ICON_FOREGROUND": "#ca2056",  # Red
    "NVIM_COLOR": "#58f1b9",  # "#a6ccf4",  # Light Blue
}

EXT_COLOR_DICT = {
    "md": cfgvars.val("color4"),  # Blue
    "py": cfgvars.val("color3"),  # Yellow
    "txt": Color(213, 123, 124),  # Salmon
    "lua": "#a665f4",  # Purple
    "conf": "#a7f4a2",  # Bright Green
}

EXEC_COLOR_DICT = {
    "nb": "#d06631",  # Orange
    "nchat": cfgvars.val("color2"),  # Green
    "rtv": cfgvars.val("color1"),  # Red
    "glow": cfgvars.val("color3"),  # Yellow
}

RIGHT_STATUS_ELEMENTS = {
    "hostname": False,
    "todo": True,
    "github": True,
    "cursor_position": False,
}


# >> Config Variables Handling Classes
class CfgCustom:
    """Class to get and use variables values from the kitty config options.

    Attributes
    ----------
    opts : kitty.options.type.Options
        Kitty options
    custom_colors : dict
         Colors dictionary with the tab diferent elements colors.
    ext_color_dict : dict
        Colors dictionary associated with files extensions, for associating
        file types with specific colors. Used mainly to define tab colors
    exec_color_dict : dict
        Colors dictionary associated with executing programs/commands. Used
        to define tab colors according to the running command on it.
    priority_color_dict : dict
        Colors dictionary associated with the priority set in todo.txt tasks.
    tab_idx_icons : tuple
        Tuple containing the icons used in the start of the tab name, with the
        icon number.


    Methods
    -------
    form(color)
        Formatting color function, checking which is the given format (Html hex
        string, kitty Option, kitty Color, rgb string) and returning the color
        in the appropriate kitty rgb integer format.
    col(name : str)
        Given a name from the define CUSTOM_COLORS dict, apply the formatting on the
        color value associated to this name and return it.
    priot_dict(letter : str)
        Given a letter (A, B, C and D) returns the color and a icon associated
        with it.
    set_dict(dict : dict)
        Used to create new dictionarys based on execution of any of the class functions.
    idx_icon(index : int)
        Given a integer, returns the icon with number to be used in the start of the tab
        name associated with it.

    """

    def __init__(self):
        """Init function of the class."""
        self._new_dict = {}
        self.custom_colors = CUSTOM_COLORS
        self.ext_color_dict = EXT_COLOR_DICT
        self.exec_color_dict = EXEC_COLOR_DICT
        self.priority_color_dict = PRIORITY_COLOR_DICT
        self.tab_idx_icons = TAB_IDX_ICONS

    def col(self, name):
        """Get color from the user custom_colors dict.

        Parameters
        ----------
        name : str
            Name of the custom_color defined in the dict. Can be given lower cased
            to match the dict upper cased keys.

        Returns
        -------
        color : int
            Given color formatted to kitty integer type.

        """
        if name or name.uppercase in self.custom_colors:
            pre_col = self.custom_colors.get(name)
            color = form(pre_col)
            return color

    def prio_dict(self, letter):
        """Get todo.txt priority associated number icon to render, and color to be displayed.

        Parameters
        ----------
        letter : str
            Priority letter (A, B, C or D).

        Returns
        -------
        prio_color : int
            Given color formatted to kitty integer type.
        prio : str
            Icon with a number corresponding to the priority, to render in the status.

        """
        if letter or letter.uppercase in self.priority_color_dict:
            prio_color = self.priority_color_dict.get(letter)[0]
            prio_color = as_rgb(color_as_int(prio_color))
            prio = self.priority_color_dict.get(letter)[1]
            return prio_color, prio

    def set_dict(self, raw_dict):
        """Format a color dictionary.

        Internal function to convert dictionarys color values, getting an already defined
        dict, and converting all the color values to the appropriate kiitty integer.

        Parameters
        ----------
        raw_dict : dict
            Original colors dictionary to be converted
            Keys are str, values are colors Of type kitty.options.type.Color,
            str or kitty.utils.Options.

        Returns
        -------
        _new_dict : dict
            Converted dictionary, with the same keys from the original one,
            and values corresponding to the original dictionary colors formatted
            to the kitty integer format.


        """
        _new_dict = {}
        for k, v in raw_dict.items():
            _new_dict[k] = form(v)
        return _new_dict

    def idx_icon(self, index):
        """Given a index number, returns associated number icon to use in tab drawing.

        Parameters
        ----------
        index : int
            Tab index number

        Returns
        -------
        icon : str
            Icon of the index number, used in the tab drawing.

        """
        if not isinstance(index, int):
            log_error(f"Index type passed to function is {type(index)} and not integer")
        return self.tab_idx_icons[(index - 1)]

    def check_vars_contrast(self, param_bg):
        for key, value in self.custom_colors.items():
            color = form(value)
            log_error(color)
            contrast = calculate_contrast(
                (
                    color_from_int(color).r,
                    color_from_int(color).g,
                    color_from_int(color).b,
                ),
                (
                    color_from_int(param_bg).r,
                    color_from_int(param_bg).g,
                    color_from_int(param_bg).b,
                ),
            )
            if key == "ICON_BACKGROUND":
                contrast = 10
            while contrast < 2:
                color = get_random_color()
                contrast = calculate_contrast(
                    (
                        color.r,
                        color.g,
                        color.b,
                    ),
                    (
                        color_from_int(param_bg).r,
                        color_from_int(param_bg).g,
                        color_from_int(param_bg).b,
                    ),
                )
                self.custom_colors[key] = color


cfg_custom = CfgCustom()
ext_color_dict, exec_color_dict = (
    cfg_custom.set_dict(cfg_custom.ext_color_dict),
    cfg_custom.set_dict(cfg_custom.exec_color_dict),
)
# cfg_custom.check_vars_contrast(cfgvars.val("active_tab_background"))
# log_error(cfg_custom.custom_colors)
# log_error(cfg_custom.set_dict.custom_colors)
# log_error(exec_color_dict)


def truncate_path(path: str, max_length: int) -> str:
    """Truncate given string to a maximum n size.

    Parameters
    ----------
    path : str
        String with a path
    max_length : int
        Integer of maximum size from the truncated return

    Returns
    -------
    path : str
        Truncated given path, substituting excessive start part of the file with '...'

    Examples
    --------
    >>> test = truncate_path("/home/user/Documents", 10)
    >>> print(test)
    u/Documents

    """
    # Reverse the path to start breaking from the last part
    reversed_path = path[::-1]

    # If the reversed path is already within the max length, return the path as is
    if len(reversed_path) <= max_length:
        return path

    # Find the position of the nearest slash within the max_length
    break_pos = reversed_path.find("/", max_length)

    if break_pos == -1:  # If no slash is found, return the full reversed path truncated
        truncated_reversed = reversed_path[:max_length]
    else:
        truncated_reversed = reversed_path[
            : break_pos + 1
        ]  # Include the slash in the truncated part

    # Reverse the truncated path back to its original order
    truncated_path = truncated_reversed[::-1]

    # Find the segment before the breaking point and get its first letter(s)
    remaining_path_length = len(path) - len(truncated_path)
    first_letter_segment = path[:remaining_path_length].rstrip("/").split("/")[-1]
    if first_letter_segment.startswith("."):
        first_letter = first_letter_segment[
            :2
        ]  # Take the first two characters if it starts with a '.'
    else:
        first_letter = first_letter_segment[0] if first_letter_segment else ""

    # Return the final result
    return f"{first_letter}/{truncated_path.lstrip('/')}"


def get_custom_title(tab_title: str, max_length: int):
    """Get the tab title string.

    Based on the tab max length, the tab title type (if its a path, a file
    name, or strings separated by space), filters the name string to
    truncate it in the proper way.

    Parameters
    ----------
    tab_title : str
        tab title string
    max_length : int
        max tab name length, used to truncate the title

    Returns
    -------
    custom_title : str
        truncated and filtered tab title

    Examples
    --------
    >>> test_path = get_custom_title("/Documents/test/folder", 8)
    >>> print(test_path)
    D/test/folder

    >>> test_file = get_custom_title("test_file_name.py", 8)
    >>> print(test_file)
    test...py

    >>> test_nvim_file = get_custom_title("nvim test.py", 9)
    >>> print(test_nvim_file)
      test.py

    >>> test_command_spaced = get_custom_title("nb shell", 7)
    >>> print(test_command_spaced)
      she...

    """
    match = re.match(r"(\S.*)\s(\S.*)", tab_title)
    path_match = re.match(r"/", tab_title)
    file_match = re.match(r"(\S.*)\.(\S.*)", tab_title)
    if match is not None:
        if match.group(1) is not None and match.group(2) is not None:
            custom_title = PROGRAMS_ICONS_BY_NAME.get(match.group(1), "")
            file_match = re.match(r"(\S.*)\.(\S.*)", match.group(2))
            path_match = re.match(r"/", match.group(2))
            if file_match is not None:
                if len(file_match.group()) > max_length - 2:
                    file_name = (
                        f"{file_match.group(1)[0 : max_length - len(file_match.group(2)) - 2]}"
                    )
                    ext_name = f"{file_match.group(2)}"
                    custom_title = f"{custom_title} {file_name}...{ext_name}"
                else:
                    custom_title = f"{custom_title} {file_match.group()}"
            elif path_match is not None:
                custom_title = f"{custom_title} {truncate_path(match.group(2), max_length)}"
            else:
                custom_title = f"{custom_title} {match.group(2)[0 : max_length - 4]}..."
    elif path_match is not None:
        custom_title = f"{truncate_path(tab_title, max_length)}"
    elif file_match is not None:
        if file_match.group(1) is not None and file_match.group(2) is not None:
            file_name = f"{file_match.group(1)[0 : max_length - len(file_match.group(2)) - 2]}"
            ext_name = f"{file_match.group(2)}"
            custom_title = f"{file_name}...{ext_name}"
    else:
        # custom_title = f"{tab_title[0:max_length]}"
        custom_title = f"{truncate_path(tab_title, max_length)}"
    return custom_title


def git_info(cwd: str):
    """Obtain github status info.

    Get current working dir github status, giving the branch, the upstream synced branch, and
    untracked files in the local repo.

    Parameters
    ----------
    cwd : str
        String of the current working dir to get the git status

    Returns
    -------
    result_line : list
        list of strings containing the local branch, and the upstream synced branch, or returns
        False if execed in a direcotry not corresponding to a git repo
    len_untracked : int
        Number of untracked files in the local folder in relation of the upstream branch

    Examples
    --------
    In a working dir that is not a github repository:

    >>> import os.getlogin
    >>> test_git = git_info(f"/home/{os.getlogin()}")
    >>> print(test_git)
    (None, 0)

    Notice that above example uses getlogin method only to fit in
    automatic docstrings testing. The passed parameter to git_info
    will correspond to the user home directory (shouldn't be identifyed
    by the function as a github repository)

    In a working dir that is a github cloned repository:

    >>> import os.environ
    >>> test_repo = git_info(f"{os.environ['HOME']}/.local/kitty")
    >>> print(test_repo)  # doctest: +SKIP
    ('master', 3)

    """
    if isdir(cwd + "/.git"):
        untracked_len = 0
        my_env = dict(environ.copy())
        my_env["GIT_DISCOVERY_ACROSS_FILESYSTEM"] = "false"
        try:
            result = subprocess.check_output(
                ["git", "status", "--porcelain", "-b", "--ignore-submodules"],
                stderr=subprocess.DEVNULL,
                text=True,
            )
        except subprocess.CalledProcessError:
            result = ""

        if result == "":
            return None, 0
        result = result.split("\n")
        untracked_len = len(result) - 1
        result_line = result[0]
        status_sep = re.match(r"(\#.*)\s(\w.*)(\.{3})(\w.*)/(\w.*)$", result_line)
        current_branch = status_sep.group(2)
        return current_branch, untracked_len
    else:
        return None, 0


def get_todo():
    r"""Get a random todo task from a local todo.txt.

    Parameters
    ----------
    None

    Returns
    -------
    tasks : list
        List of concatenated strings parts from the todo.txt file, including the date added,
        the project and filter tags, (+str @str) and the string of the task.

    tasks_colors : list
        List containing the colors from each part of the todo added in the tasks list.

    Examples
    --------
    Creating a file todo.txt
    >>> file_path = "/tmp/todo.txt"
    >>> lines = [
    ...     "(B) 08-06 Train llama3.1 inverse model +AI @torchchat",
    ...     "(A) 08-06 Config tab max length +kitty @tab_bar.py",
    ... ]
    >>> with open(file_path, "w") as file:
    ...     file.write("\n".join(lines))
    >>> TODO_PATH = "/tmp/todo.txt"

    Executing the function
    >>> test_tasks, test_tasks_colors = get_todo()
    >> print(test_tasks)
    [' \ue69c  \U000f0ca1 ', '08-09 ', 'testing function', '+kitty', '@tabs']
    >>> print(test_tasks_colors)
    [4290314242, 1649716994, 4290314242, 2299638018, 8895746]

    """
    global timer_todo
    global random_line_number
    file_path = TODO_PATH
    tasks = []
    tasks_colors = []

    if timer_todo is None:
        timer_todo = datetime.now()
        with open(TODO_PATH) as file:
            lines = file.readlines()
            random_line_number = random.randint(1, len(lines))

    if timer_todo:
        timer_exec = datetime.now().second - timer_todo.second

    if timer_exec > REFRESH_TODO:
        timer_todo = datetime.now()
        with open(TODO_PATH) as file:
            lines = file.readlines()
            random_line_number = random.randint(1, len(lines))

    try:
        with open(file_path) as file:
            lines = file.readlines()
            exit_choose = False
            while not exit_choose:
                regex = re.compile(TASK_REGEX, re.VERBOSE)
                random_line = lines[random_line_number - 1].strip()
                match = regex.match(random_line)
                if match.group(4) and match.group(1) is None:
                    exit_choose = True
                else:
                    random_line_number = random.randint(1, len(lines))

    except FileNotFoundError:
        return "File not found. Please check the file path."

    priority = match.group(2)
    dates = match.group(3)
    description = match.group(4)
    projects = match.group(5)
    tags = match.group(6)
    if projects == (""):
        projects = match.group(7)

    if priority is not None and priority != "":
        letter = str(priority[1])
        prio_color, prio = cfg_custom.prio_dict(letter)
        if not prio_color:
            prio_color = cfg_custom.col("PRIORITY_NEUTRAL")
            prio = ""
        tasks.append(f" {CUSTOM_ICONS['TODO_ICON']} {prio}")
        tasks_colors.append(prio_color)

    else:
        tasks.append(f" {CUSTOM_ICONS['TODO_ICON']}")
        tasks_colors.append(cfg_custom.col("PRIORITY_NEUTRAL"))

    if dates is not None and dates != "":
        datestd = str(match.group(3))
        tasks.append(datestd)
        tasks_colors.append(cfg_custom.col("DATE_COLOR"))

    if description is not None and description != "":
        desc = match.group(4).strip()
        words_desc = desc.split()

        if (len(words_desc)) > 5:
            tasks.append(" ".join(words_desc[:5]) + "...")
            tasks_colors.append(cfg_custom.col("DESC_COLOR"))
        else:
            tasks.append(" ".join(words_desc))
            tasks_colors.append(cfg_custom.col("DESC_COLOR"))

    if projects is not None and projects != "":
        tasks.append(projects)
        tasks_colors.append(cfg_custom.col("PROJECTS_COLOR"))

    if tags is not None and tags != "":
        tasks.append(tags)
        tasks_colors.append(cfgvars.val("url_color"))

    return tasks, tasks_colors


def nvim_check_extension(file_ext):
    if file_ext in PROGRAMS_ICONS_BY_NAME:
        exe_icon = PROGRAMS_ICONS_BY_NAME[file_ext]
        if file_ext in ext_color_dict:
            dict_color = ext_color_dict[file_ext]
            return exe_icon, dict_color

        return exe_icon, cfg_custom.col("NVIM_COLOR")

    else:
        exe_icon = CUSTOM_ICONS["NVIM_ICON"]

    return exe_icon, cfg_custom.col("NVIM_COLOR")


def tab_title_check(tab: TabBarData, active: bool):
    active_tab_title = tab.title
    exe_icon = None
    file_ext = None
    if active:
        color = cfgvars.val("active_tab_foreground")
    else:
        color = cfgvars.val("inactive_tab_foreground")

    tab_title_list = active_tab_title.split(" ")
    if len(tab_title_list) == 1:
        path_list = active_tab_title.split("/")
    elif len(tab_title_list) >= 2:
        path_list = tab_title_list
    else:
        path_list = tab_title_list
    for n in reversed(path_list):
        if (n or n.lower()) in PROGRAMS_ICONS_BY_NAME:
            if exe_icon is None:
                exe_icon = PROGRAMS_ICONS_BY_NAME[n]

            if n == "nvim":
                file_name = path_list[-1].split(".")
                file_ext = file_name[-1]
                exe_icon, color = nvim_check_extension(file_ext)
                if exe_icon == CUSTOM_ICONS["NVIM_ICON"]:
                    file_ext = True
                return exe_icon, color, file_ext

            if n in exec_color_dict:
                exe_icon = PROGRAMS_ICONS_BY_NAME[n]
                color = exec_color_dict[n]
                file_ext = True

                return exe_icon, color, file_ext

    if exe_icon is None:
        exe_icon = CUSTOM_ICONS["ICON"]
    if file_ext is None:
        file_ext = False

    return exe_icon, color, file_ext


def _draw_icon(screen: Screen, index: int, exe_icon: str) -> int:
    if index != 1:
        return 0
    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.cursor.fg = cfg_custom.col("ICON_FOREGROUND")
    screen.cursor.bg = cfg_custom.col("ICON_BACKGROUND")
    screen.draw(exe_icon)
    screen.cursor.x = len(exe_icon)
    screen.cursor.fg, screen.cursor.bg = fg, bg
    screen.cursor.fg = cfg_custom.col("ICON_BACKGROUND")
    screen.draw(CUSTOM_ICONS["LEFT_SEP"])
    return screen.cursor.x


def _draw_right_status(
    screen: Screen,
    is_last: bool,
    cells: list,
) -> int:
    if not is_last:
        return 0
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.fg = 0
    for color, status in cells:
        screen.cursor.fg = color
        screen.draw(status)
    screen.cursor.bg = 0
    return screen.cursor.x


def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


def get_right_status(cells: list, current_win: Window):
    global right_status_length
    cwd = current_win.cwd_of_child or ""

    if RIGHT_STATUS_ELEMENTS["cursor_position"]:
        xscreen_pos, yscreen_pos = (
            current_win.screen.cursor.x,
            current_win.screen.cursor.y,
        )
        cells.append((
            (cfg_custom.col("TODO_ICON_COLOR")),
            f" |{xscreen_pos}x{yscreen_pos}|",
        ))

    if RIGHT_STATUS_ELEMENTS["github"]:
        current_branch, untracked_len = git_info(cwd)
        if untracked_len > 1:
            git_color = cfg_custom.col("GIT_DIRTY")
        else:
            git_color = cfg_custom.col("GIT_CLEAN")
        if current_branch is None:
            cells.append((git_color, ""))
        else:
            cells.append((
                git_color,
                f" {CUSTOM_ICONS['GIT_ICON']} {current_branch} {untracked_len}",
            ))

    if RIGHT_STATUS_ELEMENTS["hostname"]:
        app = " " + getlogin() + "@"
        host = uname()[1]
        cells.append((cfg_custom.col("HOST_COLOR"), f"{app}{host}"))

    if RIGHT_STATUS_ELEMENTS["todo"]:
        # Todo.txt Task
        tasks, colors_todo = get_todo()
        for n, j in enumerate(tasks):
            cells.append((colors_todo[n], f"{j} "))

    # Length
    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[1]))

    return cells, right_status_length


def draw_custom_powerline(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    max_tab_length: int,
    index: int,
    extra_data: ExtraData,
    color: int,
    tabs: list,
    file_ext: str,
    static_icon: str,
) -> int:
    tab_bg, tab_fg = screen.cursor.bg, screen.cursor.fg
    default_bg = cfgvars.val("background")
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol, soft_separator_symbol = POWERLINE_SYMBOLS.get(
        draw_data.powerline_style, ("", "")
    )
    number_icon = cfg_custom.idx_icon(index) + " "
    if tab.is_active:
        screen.cursor.bg = cfgvars.val("active_tab_background")
        max_tab_length = ACTIVE_TAB_LENGTH
        is_active = True
    else:
        screen.cursor.bg = tab_bg
        # screen.cursor.bg = cfgvars.val("tab_bar_background")
        is_active = False
        max_tab_length = INACTIVE_TAB_LENGTH
    screen.cursor.fg = color
    screen.cursor.bg = tab_bg
    screen.draw(number_icon)
    if file_ext and len(tabs) > N_TABS_TO_SHORTEN_TITLE and not is_active:
        if isinstance(file_ext, bool):
            screen.draw(static_icon)
        else:
            screen.draw(f"{static_icon} {file_ext}")
    else:
        if len(tab.title) > max_tab_length:
            custom_title = get_custom_title(tab.title, max_tab_length)
            screen.draw(custom_title)
        else:
            draw_title(draw_data, screen, tab, index, max_tab_length)

    if not needs_soft_separator:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(separator_symbol)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        elif tab_bg != default_bg:
            c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
            c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
            if c1 < c2:
                screen.cursor.fg = default_bg
        screen.cursor.fg = cfgvars.val("inactive_border_color")
        screen.draw(f" {soft_separator_symbol}")
        screen.cursor.fg = prev_fg

    end = screen.cursor.x
    if end < screen.columns:
        screen.draw(" ")
    return end


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    global exe_icon
    file_ext = False
    cells = []
    tabs = []
    boss = get_boss()
    tm = boss.active_tab_manager
    for n in boss.all_tabs:
        tabs.append(n)
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, 2.0, False)

    if tm is not None:
        w = tm.active_window
        if w is not None:
            cells, _ = get_right_status(
                cells,
                current_win=w,
            )

    if tab.is_active:
        exe_icon, color, file_ext = tab_title_check(tab, True)
        static_icon = exe_icon
    else:
        static_icon, color, file_ext = tab_title_check(tab, False)

    _draw_icon(
        screen,
        index,
        exe_icon,
    )

    draw_custom_powerline(
        draw_data,
        screen,
        tab,
        max_title_length,
        index,
        extra_data,
        color,
        tabs,
        file_ext,
        static_icon,
    )

    _draw_right_status(
        screen,
        is_last,
        cells,
    )

    return screen.cursor.x
