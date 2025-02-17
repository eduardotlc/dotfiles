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

    cli_args_images(args, parser)


if __name__ == "__main__":
    main()
