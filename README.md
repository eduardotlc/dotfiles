# Dotfiles

---

---

1. [Neovim](#neovim)

2. [Zsh Scripts](#zsh-scripts)

3. [Kitty Terminal](#kitty-terminal)

4. [Fedora Services](#fedora-services)

5. [Firefox Homepage](#firefox-homepage)

6. [README Assets](#readme-assets)

## Neovim

---

**Placed in `~/.config`**

Lua personal neovim scripts and configs to different plugins.

- Plugins installed with [vim-plug](https://github.com/junegunn/vim-plug)

## Zsh Scripts

---

**Placed in any dir in `$PATH`**

- count-line-of-codes

  Analyses the code in the current project

- set-random-bg.sh

  Change `kitty.conf` terminal background image to a random one automatically.

## Kitty Terminal

---

**Placed in `~/.config`**

Kitty terminal configs files, includes:

- Personal `tab_bar.py` tabs theming

- `kitty.conf` main config

- `unicode-input-favorites.conf` favorite unicode symbols

- `diff.conf`

- `kitty-themes` from [github repo](https://github.com/dexpota/kitty-themes)

- `terminal_background_images` with background images to the terminal

## Fedora Services

---

**Placed in `~/.config/systemd/user`**

Includes:

- `ckb-next.service` and `ckb-next-daemon.service` auto starting of [corsair keyboard manager](https://github.com/ckb-next/ckb-next)

- `homepage.service` personal serving of homepage html starting firefox page

- `set-random-bg.service` and `set-random-bg.timer` auto execution of `set-random-bg.sh` to change kitty
  terminal background from time to time

## Firefox Homepage

---

**Placed in `~/.config/systemd/user`**

Personal starting page to firefox, still under development.

Includes:

- An scientific article reader

- Bookmarks

- Clock

## README assets

---

### Badges

- [![eslintbadge]][eslint]

- [![nodebadge]][node]

- [![npmbadge]][npm]

- [![floorpbadgev11231]][floorp]

- [![npmbadgev1092]][npm]

[eslintbadge]: https://github.com/eduardotlc/dotfiles/blob/main/badges/eslint_badge.svg
[eslint]: https://eslint.org
[nodebadge]: https://github.com/eduardotlc/dotfiles/blob/main/badges/node_badge.svg
[node]: https://nodejs.org
[npmbadge]: https://github.com/eduardotlc/dotfiles/blob/main/badges/npm_badge.svg
[npm]: https://npmjs.com
[npmbadge]: https://github.com/eduardotlc/dotfiles/blob/main/badges/npm_badge.svg
[npmbadgev1092]: https://github.com/eduardotlc/dotfiles/blob/main/badges/npm_badge_v_10_9_2.svg
[floorpbadgev11231]: https://github.com/eduardotlc/dotfiles/blob/main/badges/floorp_badge_v_11_23_1.svg
[floorp]: https://github.com/Floorp-Projects/Floorp
[feb25]: https://github.com/eduardotlc/dotfiles/blob/main/badges/feb_25.svg
[eduardotlc]: https://github.com/eduardotlc
