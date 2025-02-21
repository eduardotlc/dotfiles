-- >> INITING

local vim = vim
local g = vim.g
local opt = vim.opt
local duquotes = require("startify/duquotes")
local M = {}


-- >> NVIM CONFIGS

-- >>>> Opt
opt.termguicolors = true

-- >>>> Global
g.airline_powerline_fonts = 1
g.startify_padding_left = 35
g.startify_files_number = 20
g.startify_session_dir = '/home/eduardotc/Programming/vim'
g.startify_change_to_dir = 0
g.startify_session_sort = 1
g.startify_disable_at_vimenter = 0
g.startify_enable_unsafe = 1
g.startify_session_delete_buffers = 0
g.startify_session_persistence = 0
g.startify_session_before_save = { 'silent! tabdo NERDTreeClose' }
g.startify_update_oldfiles = 1
g.startify_enable_special = 1
-- TODO: Check variable name problem
g.startify_session_savevars = { _G.tab_names }


-- >> VARIABLES

local width = vim.api.nvim_get_option_value("columns", {})
local left_margin = math.floor(width / 4)
local border_size = left_margin * 2
local total_idx = {'A', 'C', 'D', 'E', 'G', 'H', 'I', 'J'}


-- >> FUNCTIONS

-- >>>> Local

---Split a long string in multiple lines
---@param str string Complete string to be splitted
---@param chunk_size number Max size that the line should have
---@return table chunks Table with the string parts, and the line number
local function split_long_string(str, chunk_size)
    local chunks = {}
    local current_line = ""

    for word in str:gmatch("%S+") do
        if #current_line + #word + 1 <= chunk_size then
            if #current_line > 0 then
                current_line = current_line .. " " .. word
            else
                current_line = word
            end
        else
            table.insert(chunks, current_line)
            current_line = word
        end
    end

    -- Add the last line if there's any remaining content
    if #current_line > 0 then
        table.insert(chunks, current_line)
    end

    return chunks
end

---Center a text to the start of startify header line (left justified), by adding blank spaces.
---@param text string String that should be centered
---@param l_space number number of extra left spaces in relation to the border
---@return string # String with added blank spaces
local function center_border(text, l_space)
  return string.rep(" ", (left_margin + l_space)) .. text
end

---Create Startify header lines horizontal borders
---@return string # String of the line, with lef blank spaces, and a line of '==='
local function create_border()
  return string.rep(" ", left_margin) .. string.rep("=", border_size)
end

---Center a text, with blank spaces to the left and to the right of the text.
---Used to create a colored line through highlight group startifysection
---@param text string Text that will be in the center of the colored line
---@return string final_text Text with blank spaces added to left and right
local function center_blank(text)
    local centered_text = string.rep(" ", left_margin) .. text
    local final_text = centered_text .. string.rep(" ", width - #centered_text - 1) .. "."
    return final_text
end

---Get a custom header to startify beginning
---@return table new_table Table with each element being each line string of the header
local function get_my_header()
  local time = center_border(tostring((os.date("%H:%M:%S"))), 0)
  local index = math.random(#duquotes.quotes)
  local border = create_border()
  local selected_quote_table = duquotes.quotes[index]

  local new_table = {
    time,
    border,
  }
  for _, line in ipairs(selected_quote_table) do
    if #line > ( border_size -4 ) then
      local chunks = split_long_string(line, (border_size - 4))
      for _, val in ipairs(chunks) do
        table.insert(new_table, center_border(val, 2))
      end
    elseif #line == 0 then
      table.insert(new_table, "")
    else
      table.insert(new_table, center_border(line, 2))
    end
  end
	table.insert(new_table, border)
  return new_table
end

---Assigns each element from a table to the file paths from a local dir
---@param list table List containing elements to assign in th final table
---@return table filteredList table containing each element from the param table and the file path
local function filterListByFileCount(list)
  local directory = "/home/eduardotc/Programming/vim"
  local handle = io.popen('ls -1 "' .. directory .. '" | wc -l')
  if handle then
		HandleResult = tonumber(handle:read("*a"))
		handle:close()
  else
		print("Error: Unable to read from handle")
  end
  local filteredList = {}
  for i = 1, HandleResult - 1 do
    table.insert(filteredList, list[i])
  end
  return filteredList
end

---Define startify bookmarks variable
local function def_bookmarks()
  vim.g.startify_bookmarks = {
      { ['a'] = '~/.config/nvim/lua/keyall.lua' },
      { ['d'] = '~/.config/nvim/lua/du.lua' },
      { ['F'] = '~/.config/kitty/font_symbols.conf' },
      { ['u'] = '~/.config/nvim/init.lua' },
      { ['K'] = '~/.config/kitty/kitty.conf' },
      { ['r'] = '~/.config/nvim/lua/servbuf.lua' },
      { ['z'] = '~/.zshrc' },
  }
end

---Go to the beginning of the startify page
local function go_to_beginning()
  vim.cmd('normal! gg')
end

---Define startify lists variable.
local function def_lists()
  vim.g.startify_lists = {
      { type = 'sessions' , header = {center_blank('  SESSIONS')} },
      { type = 'commands' , header = {center_blank('  COMMANDS')} },
      { type = 'bookmarks', header = {center_blank('  FAVORITES')} },
      { type = 'files'    , header = {center_blank('  RECENTS')} },
  }
end

---Define startify default commands table.
local function def_cmds()
  vim.g.startify_commands = {
      { ['@'] =  { '󰱼  Find File', 'Telescope find_files theme=ivy' } },
      { ['w'] =  { '  Find Word', 'Telescope live_grep theme=dropdown' } },
      { ['f'] =  { '󰄛  Kitty FZF', 'lua DuMod.fzf_kitty_choose()', } },
      { ['N'] =  { '󰎜  Add Note', 'lua DuMod.create_notebook_note("/home/eduardotc/Notes")', } },
      { ['xb'] = { '󰉤  Tmp Bash', 'TmpSh', } },
      { ['xd'] = { '  Daily', 'lua DuMod.daily_note()' } },
      { ['xn'] = { '󱓧  Notebooks', 'lua DuMod.markdown_notebooks("/home/eduardotc/Notes")', } },
      { ['xp'] = { '  Tmp Py', 'TmpPy', } },
      { ['xP'] = { '📑 Plugins READMES', 'lua DuMod.markdown_notebooks("/home/eduardotc/.local/share/nvim/plugged")', } },
      { ['xs'] = { '  Startify CWD', 'lua DuStart.CWD()', } },
  }
end

-- >>>> Global

---Reset startify to default.
---This function redefines the tables vim.g.startify_lists and vim.g.startify_commands, by running
---respectively [Function](lua://def_lists()) and [Function](lua://def_cmds()), and ends with
---Startify command execution to reload it.
function M.Reset()
  def_lists()
  def_cmds()
  vim.cmd("Startify")
  go_to_beginning()
end

---Open startify page, with the only section being the current dir files.
function M.CWD()
  vim.g.startify_lists = {
    { type = 'dir', header = {center_blank('  ' .. vim.fn.getcwd())} },
    { type = 'commands', header = {center_blank("Teste")} },
  }
  vim.g.startify_commands = {
    { ['b'] =  { 'Go Back', 'lua DuStart.Reset()' } },
  }
  vim.g.startify_enable_special = 0
  vim.cmd("Startify")
  go_to_beginning()
end


-- >> STARTIFY CONFIGS/MENUS

-- >>>> Configs
vim.g.startify_custom_indices = filterListByFileCount(total_idx)
vim.g.startify_custom_header = get_my_header()

-- >>>> Menus

def_cmds()

def_bookmarks()

def_lists()



-- >> COLORS

vim.cmd([[
  highlight startifyheader          guibg=none          guifg=#58f3c7
  highlight startifysection         guibg=#4a42fa       guifg=#fcf6a2
  highlight startifynumber			guibg=none			guifg=#ff79c6
  highlight startifybracket         guibg=none          guifg=#7ec8c3
  highlight startifyfile            guibg=none          guifg=#b981fc
  highlight startifyfooter          guibg=none          guifg=#fcde36
  highlight startifypath            guibg=none          guifg=#f8f2eb
  highlight startifyselect          guibg=none          guifg=#cbfcf5
  highlight startifyslash           guibg=none          guifg=#c82357
  highlight startifyspecial         guibg=none          guifg=#7388ff
  highlight startifyvar             guibg=none          guifg=#fcbb81
]])


-- >> REFERENCES

--local shift = math.floor((width - #text) / 2)
--vim.g.startify_custom_header = vim.fn['startify#center'](vim.fn['startify#fortune#boxed']())

return M
