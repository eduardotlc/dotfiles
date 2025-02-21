from typing import List

from kitty.boss import Boss
from kittens.tui.handler import result_handler

# if not os.path.isfile(nvim_address):
# match = re.match(r"/tmp/mynvim-([0-9]{1,2})", nvim_address)
# if os.path.isfile(re.sub(match.group(1), str(int(match.group(1)) - 1), nvim_address)):
# nvim_address = re.sub(match.group(1), str(int(match.group(1)) - 1), nvim_address)
# elif os.path.isfile(re.sub(match.group(1), str(int(match.group(1)) + 1), nvim_address)):
# nvim_address = re.sub(match.group(1), str(int(match.group(1)) + 1), nvim_address)

def main(args: List[str]) -> None:
	pass


@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss: Boss) -> None:
	prev = len(args) > 1
	tm = boss.active_tab_manager
	tab = boss.active_tab
	if tm is None or tab is None:
		return
	if prev:
		if tab.windows.active_group_idx == 0 and len(tm.tabs) > 1:
			boss.previous_tab()
		else:
			tab.previous_window()
	else:
		if tab.windows.active_group_idx >= len(tab.windows) - 1 and len(tm.tabs) > 1:
			boss.next_tab()
		else:
			tab.next_window()
