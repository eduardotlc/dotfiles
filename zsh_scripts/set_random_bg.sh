#!/bin/bash
KITTY_CONF="${HOME}/.config/kitty/kitty.conf"
IMAGE_DIR="${HOME}/.config/kitty/terminal_background_images"
SELECTED_IMAGE_A=$(find "$IMAGE_DIR" -type f -name '*.png' | shuf -n 1)
SELECTED_IMAGE_B=$(find "$IMAGE_DIR" -type f -name '*.png' | shuf -n 1)
hydrapaper -c  "${SELECTED_IMAGE_A}" "${SELECTED_IMAGE_B}"

sed -i "s|^background_image[[:space:]]\+.*$|background_image\t\t   $SELECTED_IMAGE_A|" "${KITTY_CONF}"
kitty @ load-config "$(pidof kitty)" > /dev/tty
kitty @ action --match all load_config_file "${HOME}/.config/kitty/kitty.conf"
#Kill command that restarts kitty when execed, to automatic change the backgroun when its changed.
#kill -SIGUSR1 "$(pidof kitty)" > /dev/tty
