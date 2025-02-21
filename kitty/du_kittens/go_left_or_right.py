#!/usr/bin/env python3
"""
Created on 2025-02-08 13:12:38.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Handle kitty user keyboard input, detecting if Neovim is active, checking NERDTree state,
and executing the correct action based on conditions.
"""

import glob
import os
import re
import sys

import pynvim
from kittens.tui.handler import result_handler
from kitty.boss import Boss
from kitty.constants import standard_icon_names

standard_icon_names = standard_icon_names


def OPTIONS() -> str:
    return """
-n --next next
type=bool-set
Changes current focused window instance to the next one


-p --previous previous
default=bool-set
Changes current focused window instance to the previous one

-r --right right
Alias to -n / --next

-l --left left
Alias to -p / --previous

-d --debug debug
Activate console logging and neovim printing of debuggin infos

--layout -L
type=list
List containing kitty layout elements, to use when splitting the windows schema.
"""


help_text = """\
Handle kitty terminal windows focus changing, integrating and unifying different focusing programs
type in one only shortcut handler, including between the possible commands  in window to call this
kitten:
    - Neovim editor
        Neovim editor, differentiating the focusing command based on the type of the current neovim
        focused instance, having different commands for the following types:
        - Normal filetypes
        - Nerdtree

        It also considers notify type of windows, and remove then from possible focus
    - Ipython kitty split
    - Normal kitty window
"""

usage = "TITLE [BODY ...]"


if __name__ == "__doc__":
    cd = sys.cli_docs  # type: ignore
    cd["usage"] = usage
    cd["options"] = OPTIONS
    cd["help_text"] = help_text
    cd["short_desc"] = "Send tab changing focusing command to the terminal"


VIM_PROCESS_NAME = "nvim"
IPYTHON_CMD = "/home/eduardotc/miniforge3/envs/nvim/bin/ipython3"


def main(args: list[str]) -> None:
    pass


def is_window_cmd(window, cmd):
	fp = window.child.foreground_processes
	return any(
		re.search(cmd, p["cmdline"][0] if len(p["cmdline"]) else "", re.I) for p in fp
	)


def is_neovim_running(window) -> bool:
    """Check if Neovim is running by detecting `NVIM_LISTEN_ADDRESS`."""
    return "NVIM_LISTEN_ADDRESS" in os.environ and is_window_cmd(window, VIM_PROCESS_NAME)


def get_neovim_instance():
    """Connect to Neovim via `NVIM_LISTEN_ADDRESS`."""
    nvim_address = os.environ.get("NVIM_LISTEN_ADDRESS")
    if not os.path.isfile(nvim_address):
        matching_files = glob.glob(os.path.join("/tmp", "my-nvim*"))
        nvim_address = matching_files[-1]
    try:
        return pynvim.attach("socket", path=nvim_address)
    except Exception as e:
        print(f"Error connecting to Neovim: {e}")
        return None


def is_nerdtree_open(nvim) -> bool:
    """Check if NERDTree is currently open in Neovim.

    Parameters
    ----------
    nvim : pynvim.api.nvim.Nvim

    Returns
    -------
    bool
        True if Nerdtree window is opened, indepent on where is the focus of the cursor.

    """
    try:
        cmd_out = nvim.command_output("let NERDTree.IsOpen()")
        cmd_out = cmd_out.split()[-1]
        return bool(cmd_out == "#1")
    except (TypeError, OSError, ValueError):
        return False


def switch_nvim_focus(nvim):
    """Switch neovim focused window.

    Switch the focus between neovim windows, continuing this change based on defined windows options
    that are allowed or not, on the target changed window.

    NERDTree :
        - vim.bo.buftype : nofile
        - vim.bo.filetype : nerdtree
    Notfiy :
        - vim.bo.buftype : nofile
        - vim.bo.filetype : notify
    """
    EXCLUDED_TYPES = {"nofile", "notify", "nerdtree"}
    for win in nvim.windows:
        buf = win.buffer
        buftype = buf.options.get("buftype", "")
        filetype = buf.options.get("filetype", "")
        if filetype in EXCLUDED_TYPES or buftype in EXCLUDED_TYPES:
            continue

        nvim.current.window = win
        return


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    if len(args) < 2 or args[1] not in ("left", "right", "prev", "next"):
        raise SystemExit("To use this script run it like...`")

    direction = args[1]
    window = boss.window_id_map.get(target_window_id)
    tab, tm = boss.active_tab, boss.active_tab_manager

    if not tab or not tm:
        return

    if is_neovim_running(window):
        nvim = get_neovim_instance()
        if nvim:
            active_ft = nvim.current.buffer.options.get("filetype")
            nerdtree_active = bool(active_ft == "nerdtree")
            if nerdtree_active and direction in ["left", "prev"]:
                boss.previous_tab()
                return

            elif nerdtree_active and direction in ["right", "next"]:
                switch_nvim_focus(nvim)
                return

            if is_nerdtree_open(nvim) and direction in ["prev", "left"]:
                nvim.command("NERDTreeFocus")
                return

    if is_window_cmd(window, IPYTHON_CMD):
        if direction in ("right", "next"):
            boss.next_tab()
            return
        elif direction in ("prev", "left"):
            boss.prev_window()
            return

    # Default Kitty behavior (tab or window switching)
    neighbor = tab.neighboring_group_id(direction)

    if neighbor:
        tab.windows.set_active_group(neighbor)
    else:
        {"left": boss.previous_tab, "prev": boss.previous_tab, "next": boss.next_tab, "right": boss.next_tab}[direction]()
