#!/usr/bin/env python3
"""
Created on 2025-02-17 09:40:22.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Client module for personal dotfiles utils helping functions.
"""


# >> IMPORT

import argparse

import argtypes
from handler import ArgHandle
from logger import LOGGER
from svg_utils import modify_template_svg

# >> CLI FUNCTIONS


# >>>> Print group help
def group_help_printing(
    parser: argparse.ArgumentParser, group_name: str = "All", detailed_bool: bool = False,
):
    """
    Print argparse client groups help.

    Prints all the argparse parser groups help, with the group name and description, followed
    by passing each action present in the group to the last part to print each action help

    Parameters
    ----------
    parser : argparse.ArgumentParser
    group_name : str, default 'All'
        Name of the argparse group to print the help, if used 'All' prints every group help
    detailed_bool : bool, default False
        Toggle detailed description of commands on the help
    """
    arg_dict = {"choices": ["BLUE", "Choices"], "metavar": ["YLW", "Args:"]}
    group_dict = {
        "Images": ("PRP", "BLCK"),
    }

    if not detailed_bool:
        arg_dict.pop("choices")

    for group in parser._action_groups:
        if group.title.lower() == group_name.lower() or (
            group_name == "All" and group.title in group_dict
        ):
            print("\n")
            LOGGER.print_section(group.title, group_dict[group.title], "print_next_line", "double")
            LOGGER.print_col(group.description, "bold")
            for action in group._group_actions:
                LOGGER.print_same_line(
                    [" ".join(action.option_strings), action.help],
                    ["pink", "bold"],
                    separator="\t\t",
                )
                for k in arg_dict:
                    if action.__dict__[k] is not None:
                        LOGGER.print_same_line(
                            [arg_dict[k][1], " ".join(action.__dict__[k])],
                            ["text", arg_dict[k][0]],
                            separator="\t\t\t",
                        )


# >> CREATING PARSER


def create_parser() -> argparse.ArgumentParser:
    """
    Create an argparse parser, to manage client arguments.

    Return
    ------
    parser : argparse.ArgumentParser

    Examples
    --------
    >>> parser = create_parser()
    >>> print(parser.prog)
    dotfiles_utils
    """
    parser = argparse.ArgumentParser(
        prog="dotfiles_utils",
        add_help=False,
        usage="python main.py [FLAGS] [ARGUMENTS]",
        allow_abbrev=True,
    )
    parser.add_argument(
        "--help",
        "-h",
        nargs="*",
        type=argtypes.check_string,
        help="Print Function help",
        action="store",
    )
    return parser


# >> GROUPS


def cli_parse_groups(parser: argparse._ArgumentGroup) -> argparse._ArgumentGroup:
    """
    Create an argparse groups parser, to add arguments and options to argparse groups.

    Parameters
    ----------
    parser : argparse.ArgumentParser

    Examples
    --------
    >>> parser = create_parser()
    >>> test = cli_parse_groups(parser)
    >>> print(test[0].description)
    Images utillities related commands.
    """
    group_images = parser.add_argument_group(
        "Images",
        description="Images utillities related commands.",
    )

    parser = argparse.ArgumentParser()

    return group_images


# >> CREATING FLAGS


# >>>> Images
def cli_group_images(group_images: argparse._ArgumentGroup):
    """
    Argparse client group for colors related flags.

    Parameters
    ----------
    group_colors : argparse._ArgumentGroup
        Argparse arguments group

    Examples
    --------
    >>> parser = create_parser()
    >>> test = cli_parse_groups(parser)
    >>> img = test[0]
    >>> cli_group_colors(img)
    >>> img._group_actions[0].option_strings
    ['--generate-badge']
    """
    group_images.add_argument(
        "--generate-badge",
        nargs="*",
        metavar=["left_icon", "right_text", "right_color", "output_svg", "left_color (Optional)"],
        action=ArgHandle,
        type=argtypes.check_any,
        help="""
        Generate a badge svg icon, with two separated rectangle colors, with a given icon on the
        left rectangle, with gray background, and a given written text on the right rectangle,
        with the given background color.
        Accepts other config optional values by passing the following optional flags:
        --scale : float
            scaling factor to the left inserted icon (defaults to 0.8).
        --font-size : float
            Size of written text px (defaults to 19, should be pased only the number without px)
        --text-align : float
            coordinate to insert the text, by dividing the svg rectangle by this number. Lowering
            this value lowers the text elementheight (defaults to 1.75)
        """,
    )

    group_images.add_argument(
        "--generate-pypi-badge",
        nargs="*",
        metavar=["package_name", "output_svg"],
        action=ArgHandle,
        type=argtypes.check_string,
        help="Generate a pypi badge icon svg, with the given package version on it.",
    )

    group_images.add_argument(
        "--scale",
        nargs="*",
        metavar=["scale_factor"],
        action=ArgHandle,
        type=float,
        help="""
        Scale factor used to resize some image element. Should be used as an optional addition to
        other commands, like for example --generate-badge, to indicate the left icon scaling.
        """,
    )

    group_images.add_argument(
        "--font-size",
        nargs="*",
        metavar=["font_size"],
        action=ArgHandle,
        type=float,
        help="""
        Font size, in px, to use to resize text elements. Should be used as an optional addition
        to other commands, like for example --generate-badge, to indicate the right rectangle text
        size. Defaults to 19px.
        """,
    )

    group_images.add_argument(
        "--text-align",
        nargs="*",
        metavar=["height_division_factor"],
        action=ArgHandle,
        type=float,
        help="""
        Float value to divide the svg rectangle during the text element centering. Theorically 2
        would center the text on the rectanlge, but for larger size texts, slightly low values can
        be tryed (this is defaulted to 1.75).
        This flag should be used as an optional addition, together with other flag command, like
        --generate-command.
        """,
    )


# >>>> General utils
def cli_args_general_utils(args: argparse.Namespace, parser: argparse.ArgumentParser):
    """
    Client handling function for general related utils group flags.

    Parameters
    ----------
    args : argparse.Namespace
        Argparse arguments class
    parser : argparse.ArgumentParser
        Argparse parser class

    """
    if args.help is not None:
        if len(args.help) == 0:
            group_help_printing(parser, "All", True)
        else:
            for n in args.help:
                group_help_printing(parser, n, True)


# >>>> Images
def cli_args_images(args: argparse.Namespace) -> argparse.Namespace:
    """
    Client handling functions colors related utils group flags.

    Parameters
    ----------
    args : argparse.Namespace
        Argparse arguments class
    parser : argparse.ArgumentParser
        Argparse parser class

    """
    font_size = 19 if args.font_size is None else args.font_size[0]
    scale_factor = 0.8 if args.scale is None else args.scale[0]
    text_align = 1.75 if args.text_align is None else args.text_align[0]

    if args.generate_badge is not None:
        modify_template_svg(
            left_icon=args.generate_badge[0],
            right_text=args.generate_badge[1],
            right_color=args.generate_badge[2],
            output_path=args.generate_badge[3],
            template_path="../badges/badge_template.svg",
            left_color=args.generate_badge[4],
            scale_factor=scale_factor,
            font_size=font_size,
            text_align=text_align,
        )

    if args.generate_pypi_badge is not None:
        modify_template_svg(
            left_icon="../bages/python.svg",
            right_text=f"V.{args.generate_pypi_badge[0]}",
            output_path=args.generate_pypi_badge[1],
            right_color="#ffff00",
        )
        # print(args.generate_pypi_badge[0])

    return args
