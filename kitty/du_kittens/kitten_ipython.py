#!/usr/bin/env python3
"""
Created on 2025-02-12 22:45:12.

@author: eduardotc
@email: eduardotcampos@hotmail.com
@license: GPL v3 Copyright: 2018, Kovid Goyal <kovid at kovidgoyal.net>

Kitten to implement and integrate ipython3 with with kitty and neovim.
# sys.path.append("/home/eduardotc/.local/kitty")
"""

import glob
import json
import os
import re
import subprocess
import sys

import pynvim
from kittens.tui.handler import result_handler
from kitty.boss import Boss, get_boss


def OPTIONS() -> str:
    from kitty.constants import standard_icon_names
    return """
-o --open --split
type=bool-set
Splits the current kitty window, executing ipython 3 predefined snippets
of ipythom3 startimg.


--env -e
default=base
Python environment path to run the python command.


--layout -L
type=list
List containing kitty layout elements, to use when splitting the windows schema.


--urgency -u
default=normal
choices=normal,low,critical
The urgency of the notification.

teste
teste command without flag trace.
"""


help_text = """\
Send notifications to the user that are displayed to them via the
desktop environment's notifications service. Works over SSH as well.

To update an existing notification, specify the identifier of the notification
with the --identifier option. The value should be the same as the identifier specified for
the notification you wish to update.

If no title is specified and an identifier is specified using the --identifier
option, then instead of creating a new notification, an existing notification
with the specified identifier is closed.
"""

usage = "TITLE [BODY ...]"

if __name__ == "__main__":
    raise SystemExit("To use this script run it like...`")

elif __name__ == "__doc__":
    cd = sys.cli_docs  # type: ignore
    cd["usage"] = usage
    cd["options"] = OPTIONS
    cd["help_text"] = help_text
    cd["short_desc"] = "Send notifications to the user"


VIM_PROCESS_NAME = "nvim"
IPYTHON_CMD = "/home/eduardotc/miniforge3/envs/nvim/bin/ipython3"
STORAGE_FILE = os.path.expanduser("~/.config/kitty/kitty-ipython.json")

# Path to the persistent storage file


def load_persistent_data():
    """Load persistent data from storage."""
    if os.path.exists(STORAGE_FILE):
        try:
            with open(STORAGE_FILE, encoding="utf-8") as f:
                return json.load(f)
        except json.JSONDecodeError:
            return {}
    return {}


def save_persistent_data(data):
    """Save persistent data to storage."""
    with open(STORAGE_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)


def get_kitty_boss():
    """Get the active Kitty boss instance."""
    return get_boss()


def get_current_window():
    """Get the active Kitty window."""
    boss = get_kitty_boss()
    return boss.active_window if boss else None


def get_ipython_window():
    """Find an existing Kitty window running IPython."""
    boss = get_kitty_boss()
    if not boss:
        return None

    for tab in boss.tabs:
        for window in tab.windows:
            if window.title and "ipython" in window.title.lower():
                return window
    return None


def split_and_run_ipython():
    """Split the current Kitty window and start IPython3 in the new pane."""
    current_window = get_current_window()
    if not current_window:
        print("Error: No active Kitty window found.", file=sys.stderr)
        return

    subprocess.run(
        ["kitten", "@", "launch", "--type=horizontal", "--title", "IPython", "ipython3"],
        check=False
    )


def send_code_to_ipython(code):
    """Send a line or selection of code to the existing IPython window."""
    ipython_window = get_ipython_window()
    if not ipython_window:
        print("Error: No IPython window found. Run `split-ipython` first.", file=sys.stderr)
        return

    escaped_code = code.replace('"', '\\"')

    subprocess.run(
        ["kitten", "@", "send-text", "-m", f"id:{ipython_window.id}", f"{escaped_code}\n"],
        check=False
    )


def store_variable(name, value):
    """Store a variable persistently."""
    data = load_persistent_data()
    data[name] = value
    save_persistent_data(data)
    print(f"Stored variable: {name} = {value}")


def show_stored_variables():
    """Display stored variables in a Kitty overlay."""
    data = load_persistent_data()
    if not data:
        message = "No stored variables."
    else:
        message = "\n".join([f"{key} = {value}" for key, value in data.items()])

    subprocess.run(
        ["kitten", "@", "overlay", "--title", "Stored Variables", "--text", message],
        check=False
    )


def main(args):
    pass
    """Run main instance for the custom kitten."""
    # if len(args) < 2:
        # print("Usage: kitty-ipython.py <command> [args]", file=sys.stderr)
        # return


@result_handler(no_ui=False)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    if len(args) < 2 or args[1] not in ("left", "right", "prev", "next"):
        return

    direction = args[1]
    window = boss.window_id_map.get(target_window_id)
    tab, tm = boss.active_tab, boss.active_tab_manager

    if not tab or not tm:
        return

    command = args[1]
    print(command)

    # if command == "split-ipython":
        # split_and_run_ipython()
    # elif command == "send-code":
        # if len(args) < 3:
            # print("Error: No code provided to send.", file=sys.stderr)
            # return
        # send_code_to_ipython(args[2])
    # elif command == "store-var":
        # if len(args) < 4:
            # print("Error: Usage: store-var <name> <value>", file=sys.stderr)
            # return
        # store_variable(args[2], args[3])
    # elif command == "show-vars":
        # show_stored_variables()
    # else:
        # print(f"Error: Unknown command '{command}'", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv)


# def main(args: list[str]) -> None:
    # pass


# def is_window_cmd(window, cmd):
    # fp = window.child.foreground_processes
    # return any(re.search(cmd, p["cmdline"][0] if len(p["cmdline"]) else "", re.I) for p in fp)


# def is_neovim_running(window) -> bool:
    # """Check if Neovim is running by detecting `NVIM_LISTEN_ADDRESS`."""
    # return "NVIM_LISTEN_ADDRESS" in os.environ and is_window_cmd(window, VIM_PROCESS_NAME)


# def get_neovim_instance():
    # """Connect to Neovim via `NVIM_LISTEN_ADDRESS`."""
    # nvim_address = os.environ.get("NVIM_LISTEN_ADDRESS")
    # if not os.path.isfile(nvim_address):
        # matching_files = glob.glob(os.path.join("/tmp", "my-nvim*"))
        # nvim_address = matching_files[-1]
    # try:
        # return pynvim.attach("socket", path=nvim_address)
    # except Exception as e:
        # print(f"Error connecting to Neovim: {e}")
        # return None


# def check_nvim_buffer_name(nvim, buf_name_regex) -> bool:
    # """Check if the current Neovim buffer is a NERDTree instance.

    # Parameters
    # ----------
    # nvim : pynvim.api.nvim.Nvim
        # Neovim api object
    # buf_name_regex : str
        # String regex to search for in the the checked buffer name

    # Returns
    # -------
    # bool
        # True if nerdtree window is opened, and with the current cursor focus

    # """
    # try:
        # buf_name = os.path.basename(nvim.current.buffer.name or "")
        # return re.search(buf_name_regex, buf_name)
    # except Exception:
        # return False


# def is_nerdtree_open(nvim) -> bool:
    # """Check if NERDTree is currently open in Neovim.

    # Parameters
    # ----------
    # nvim : pynvim.api.nvim.Nvim

    # Returns
    # -------
    # bool
        # True if Nerdtree window is opened, indepent on where is the focus of the cursor.

    # """
    # try:
        # cmd_out = nvim.command_output("let NERDTree.IsOpen()")
        # cmd_out = cmd_out.split()[-1]
        # return bool(cmd_out == "#1")
    # except Exception:
        # return False


# def send_neovim_command(command: str) -> None:
    # """Send a command to the running Neovim instance."""
    # nvim = get_neovim_instance()
    # if nvim:
        # try:
            # nvim.command(command)
        # except Exception as e:
            # print(f"Error executing Neovim command '{command}': {e}")


# def switch_nvim_focus(nvim):
    # """Switch neovim focused window.

    # Switch the focus between neovim windows, continuing this change based on defined windows options
    # that are allowed or not, on the target changed window.
    # """
    # loop_bool = True
    # while loop_bool:
        # send_neovim_command("windo -1")
        # check_nvim_buffer_name(nvim, "notify")
        # check_nvim_buffer_name(nvim, "notify")
    # # print(vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype"))


# @result_handler(no_ui=True)
# def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    # if len(args) < 2 or args[1] not in ("left", "right", "prev", "next"):
        # return

    # direction = args[1]
    # window = boss.window_id_map.get(target_window_id)
    # tab, tm = boss.active_tab, boss.active_tab_manager

    # if not tab or not tm:
        # return

    # # If running inside Neovim, check for NERDTree
    # if is_neovim_running(window):
        # nvim = get_neovim_instance()
        # if nvim:
            # nerdtree_active = check_nvim_buffer_name(nvim, r"NERD_tree_tab*")
            # nerdtree_open = is_nerdtree_open(nvim)

            # if nerdtree_active and direction in ("left", "prev"):
                # boss.previous_tab()
                # return

            # elif nerdtree_active and direction in ("right", "next"):
                # neighbor = tab.neighboring_group_id(direction)

                # send_neovim_command("windo -1")
                # return

            # if nerdtree_open and direction in ("right", "next"):
                # boss.next_tab()
                # return

            # elif nerdtree_open and direction in ("prev", "left"):
                # send_neovim_command("NERDTreeFocus")
                # return

    # if is_window_cmd(window, IPYTHON_CMD):
        # if direction in ("right", "next"):
            # boss.next_tab()
            # return
        # elif direction in ("prev", "left"):
            # boss.prev_window()
            # return

    # # Default Kitty behavior (tab or window switching)
    # neighbor = tab.neighboring_group_id(direction)

    # if neighbor:
        # tab.windows.set_active_group(neighbor)
    # else:
        # {"left": boss.previous_tab, "right": boss.next_tab}[direction]()


# VIM_PROCESS_NAME = "nvim"

# IPYTHON_CMD = "/home/eduardotc/miniforge3/envs/nvim/bin/ipython3"


# def main(args: list[str]) -> None:
    # pass
