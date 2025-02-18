#!/usr/bin/env python3
"""
Created on 2025-02-18 13:07:05.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Main dotfiles utils python package handling module. Unite all argparse group and arguments creating
functions, as well as the argparse arguments handling functions.
Used to run the module by the command

.. code-block::
   :caption: Main module terminal execution
       python main.py [FLAGS] [FLAGS_VALUES]
"""

import sys

from cli import (
    cli_args_general_utils,
    cli_args_images,
    cli_group_images,
    cli_parse_groups,
    create_parser,
)


def main():
    """Handle and unite personal functions from module."""
    parser = create_parser()
    (group_images) = cli_parse_groups(parser)
    cli_group_images(group_images)
    args = parser.parse_args()
    if (len(sys.argv)) == 1:
        args = parser.parse_args(["--help"])

    cli_args_general_utils(args, parser)

    cli_args_images(args)


if __name__ == "__main__":
    main()
