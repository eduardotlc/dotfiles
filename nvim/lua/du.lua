-- >> REQUIREMENTS

local vim = vim
local ls = require("luasnip")
local notify = require("notify")
local ffi = require("ffi")
local C = ffi.C

ffi.cdef [[
typedef struct DIR DIR;
struct dirent {
  unsigned long  d_ino;
  unsigned long  d_off;
  unsigned short d_reclen;
  unsigned char  d_type;
  char           d_name[256];
};
DIR *opendir(const char *name);
struct dirent *readdir(DIR *dir);
int closedir(DIR *dir);
]]

local notebook_replacements = {
  ["anki"] = "󰘸  Anki",
  ["fedora"] = "  Fedora",
  ["studies"] = "󰑴  Studies",
  ["daily"] = "  Daily",
  ["tex"] = " 	Tex",
  ["home"] = "  Home",
  ["personal"] = "  Personal",
  ["references"] = "󱉟  References",
  ["todo"] = "  Todo",
  ["chemistry"] = "🥼 Chemistry",
  ["python"] = "  Python",
}

-- >> LOCAL FUNCTIONS

local M = {}

---Round a x given number to n decimals.
---@param x number Number to round
---@param n integer Total number of decimals in the final number
---@return number  # Rounded number
---@usage
---local test_round = decimal_round(10.5464, 2)
---print(test_round) -- Outputs 10.54
local function decimal_round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

---Return selected words.
---@return string text
---Current selected words, separated by spaces, and lines separated by line jumping.
local function get_selection()
  local a_orig = vim.fn.getreg("a")
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    vim.cmd([[normal! gv]])
  end
  vim.cmd([[silent! normal! "aygv]])
  local text = vim.fn.getreg("a")
  vim.fn.setreg("a", a_orig)
  return text
end

---Execute a bash command, and output its result as a notification.
---@alias notify_mode # Default normal
---| '"normal"'
---| '"debug"'
---| '"warn"'
---| '"error"'
---| '"info"'
---| '"trace"'
---| '"off"'
---@param cmd string Bash command to execute
---@param notify_mode? notify_mode
---@param opts? { title: string, icon: string, timeout: (number | boolean) } Notify options table
---For more values options check [Notify Options](lua://notify.Options)
local function bash_exec_notify(cmd, notify_mode, opts)
  notify_mode  = notify_mode or "normal"
  opts         = opts or {}
  local handle = io.popen(cmd)
  if handle == nil then
    notify("Command Parameter Needed!", "error")
    return
  end
  local result = handle:read("*a")
  local words  = {}
  for word in result:gmatch("%S+") do
    table.insert(words, word)
  end
  local phrase = table.concat(words, " ")
  local no_ansi_phrase = phrase:gsub("\27%[%d+m", "")
  handle:close()
  notify(no_ansi_phrase, notify_mode, opts)
end

---Execute a bash command, returning the output value.
---@param cmd string Bash command to execute
---@return (string|nil) phrase Output of the bash command
local function bash_exec_return(cmd)
  local handle = io.popen(cmd)
  if handle == nil then
    notify("Command Parameter Needed!", "error")
    return nil
  end
  local result = handle:read("*a")
  local words = {}
  for word in result:gmatch("%S+") do
    table.insert(words, word)
  end
  local phrase = table.concat(words, " ")
  handle:close()
  return phrase
end


---Check if a given file exists
---@param path string Complete file path
---@return boolean
---Example [Global function](lua://M.open_tmp_file()) that include this function
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    io.close(f)
    return true
  else
    return false
  end
end

---Write template text lines to a file, based on the file extension.
---@param file_path string Complete path to file. If don't exist, the file is created.
---Example [Global function](lua://M.open_tmp_file()) that include this function
local function write_template_extension(file_path)
  local extension = file_path:match("^.+%.([^%.]+)$")
  local date_time = os.date("%Y-%m-%d %H:%M:%S")
  local f = io.open(file_path, "w")
  if f == nil then
    notify("File Parameter Invalid!", "error")
    return nil
  end
  if extension == "py" then
    f:write("#!/usr/bin/env python3\n")
    f:write('"""')
    f:write("Created " .. date_time .. ".\n\n")
    f:write("Formatted with ruff\n")
    f:write('"""\n')
    f:write("\n")
  elseif extension == "sh" then
    f:write("#!/usr/bin/env zsh\n")
    f:write("# Created " .. date_time .. "\n")
    f:write("\n")
  elseif extension == "lua" then
    f:write("#!/usr/bin/env luajit\n")
    f:write("-- Created " .. date_time .. "\n")
    f:write("\n")
  end
  f:close()
end

---Get the line number that a file should be opened,  based on the written template.
---@param extension string File extension without the '.', like 'py'
---@return string Line_to_open String of an integer number, being the line number
---[Function](lua://write_template_extension()) that defines the number of lines in the template
---[Global function](lua://M.open_tmp_file()) example that implements this function
local function get_template_line_to_open(extension)
  if extension == "py" then
    Line_to_open = "6"
  elseif extension == "sh" then
    Line_to_open = "3"
  elseif extension == "lua" then
    Line_to_open = "3"
  else
    Line_to_open = "1"
  end
  return Line_to_open
end

---Execute a command based on the given file extension, based on programming temporary files.
---@param extension string File extension without the '.', like 'py'
---Example of [command executed](lua://vim.cmd(JukitOut)) on file open.
---[Global function](lua://M.open_tmp_file()) that implements this function.
local function open_command_extension(extension)
  if extension == "py" then
    vim.api.nvim_command("silent! JukitOut mamba activate nvim")
  elseif extension == "sh" then
    vim.api.nvim_command("silent! JukitOut ()")
  elseif extension == "lua" then
    vim.api.nvim_command("silent! JukitOut luajit")
  end
  local current_file_path = vim.api.nvim_buf_get_name(0)
  vim.api.nvim_command("silent! !chmod +x " .. current_file_path)
end

---Return a number to a given letter.
---@param key string
---@return number
local function key_to_number(key)
  local key_map = {
    ["a"] = 1,
    ["s"] = 2,
    ["d"] = 3,
    ["f"] = 4,
    ["j"] = 5,
    ["k"] = 6,
    ["l"] = 7,
    ["q"] = 8,
    ["w"] = 9,
  }
  return tonumber(key) or key_map[key]
end

---Split a given text to a table, based on parameter delimiter
---@param str string Text input that should be splitted
---@param delimiter string The delimiter between each text element
---@return table Table with elements being the separations from the given original text
local function split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

-- >> MATH

---Multiply selected numbers by the number parameter
---@param multiply_factor number Single number to multiply all the selected numbers by
function M.multiply_selection(multiply_factor)
  local numbers = {}
  local selected_numbers = get_selection()
  for num in selected_numbers:gmatch("%S+") do
    table.insert(numbers, tonumber(num))
  end
  for _, num in ipairs(numbers) do
    local result = num * multiply_factor
    print(result)
  end
end

---Multiply selected numbers by an input number.
function M.multiply_selection_input()
  local inp_number = tonumber(vim.fn.input("Enter Multiplication number: "))
  local numbers = {}
  local selected_numbers = get_selection()
  for num in selected_numbers:gmatch("%S+") do
    table.insert(numbers, tonumber(num))
    local result = num * inp_number
    print(num .. " * " .. inp_number .. " = " .. result)
  end
end

---Divide selected numbers by the parameter quotient.
---@param quotient number Number which selected numbers will be divide by.
function M.divide_selection(quotient)
  local numbers = {}
  local selected_numbers = get_selection()
  for num in selected_numbers:gmatch("%S+") do
    table.insert(numbers, tonumber(num))
  end
  for _, num in ipairs(numbers) do
    local result = num / quotient
    print(result)
  end
end

-- >> MARKS

--TODO: Check for the neccesity of so many global variables instead of locals.

---Prompt the user to input a letter, and sets the letter mark on current line if don't exist yet.
function M.input_mark()
  MarkExists = true
  repeat
    CurrentChar = vim.fn.input("Enter a letter to mark: ")
    MarkExists = vim.fn.getpos(string.format("'%s", CurrentChar))[2] ~= 0
    if MarkExists then
      notify(string.format("Mark %s already exists.", CurrentChar), "warn")
    end
  until not MarkExists
  if #CurrentChar == 1 and CurrentChar:match("%a") then
    local mark_command = string.format("normal! m%s", CurrentChar)
    vim.cmd(mark_command)
    print(string.format("%s Marked at current line", CurrentChar))
  else
    notify("Invalid input. Please enter a single letter.", "error")
  end
end

---Deletes user inputted letter mark from the current file.
function M.delete_mark()
  local current_char = vim.fn.input("Enter letter marks to delete: ")
  local delete_mark_cmd = string.format("normal! delm%s", current_char)
  vim.cmd(delete_mark_cmd)
  print(string.format("%s Mark(s) deleted", current_char))
end

local function change_mark_on_current_line()
  local marks = vim.fn.getmarklist(".") -- Get local marks in the current file
  local current_line = vim.api.nvim_win_get_cursor(0)[1] -- Get current line number
  local old_mark = nil

  for _, mark in ipairs(marks) do
    if mark.pos[2] == current_line then
      old_mark = mark.mark:sub(2) -- Extract mark name (without the leading `'`)
      break
    end
  end

  if not old_mark then
    print("No mark found on the current line")
    return
  end

  local new_mark = vim.fn.input("Enter new mark (a-z): "):lower()
  if not new_mark:match("^[a-z]$") then
    print("Invalid mark! Must be a single letter (a-z).")
    return
  end

  vim.api.nvim_command("delmarks " .. old_mark)
  vim.api.nvim_command("mark " .. new_mark)

  print(string.format("Changed mark '%s' to '%s' on line %d", old_mark, new_mark, current_line))
end

function M.show_local_marks_in_window()
  local marks = vim.fn.getmarklist(".") -- Get marks for the current file
  if #marks == 0 then
    notify("No local marks found", "error", {icon = " ", timeout = 500, title = "Marks Error" })
    return
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

  local output = { "Local Marks in Current File:", "-----------------------------------" }
  local mark_positions = {} -- Store mark positions for jumping

  for _, mark in ipairs(marks) do
    local mark_name = mark.mark:sub(2) -- Remove leading `'`
    local line_number = mark.pos[2]
    local col_number = mark.pos[3]
    local line_content = vim.fn.getline(line_number)

    table.insert(mark_positions, { mark = mark_name, line = line_number, col = col_number })

    table.insert(output, string.format("'%s'  →  Line %d, Col %d: %s", mark_name, line_number, col_number, line_content))
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  local win_height = math.min(10, #output + 2) -- Set height based on content (max 10 lines)
  vim.cmd("botright " .. win_height .. "split") -- Open a bottom split
  local win = vim.api.nvim_get_current_win() -- Get new window ID
  vim.api.nvim_win_set_buf(win, buf) -- Set buffer to the new window

  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = true

  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1) -- Header
  vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 1, 0, -1) -- Separator Line

  for i, mark in ipairs(mark_positions) do
    local line_idx = i + 2 -- Offset for title and separator
    local line_text = output[line_idx]

    local mark_start, mark_end = line_text:find("'%a'")
    if mark_start and mark_end then
      vim.api.nvim_buf_add_highlight(buf, -1, "Constant", line_idx - 1, mark_start - 1, mark_end)
    end

    local line_num_start, line_num_end = line_text:find("Line %d+")
    if line_num_start and line_num_end then
      vim.api.nvim_buf_add_highlight(buf, -1, "Identifier", line_idx - 1, line_num_start - 1, line_num_end)
    end

    local code_start = line_text:find(": ") -- Find the start of the code preview
    if code_start then
      vim.api.nvim_buf_add_highlight(buf, -1, "String", line_idx - 1, code_start + 1, -1)
    end
  end

  local function go_to_mark()
    local cursor_pos = vim.api.nvim_win_get_cursor(win)[1] -- Get current cursor line in marks window
    local index = cursor_pos - 2 -- Adjust index to match mark positions (skip header lines)

    if mark_positions[index] then
      local mark = mark_positions[index]
      vim.api.nvim_win_close(win, true) -- Close marks window
      vim.api.nvim_win_set_cursor(0, { mark.line, mark.col - 1 }) -- Jump to mark
    end
  end

  local function delete_mark()
    local cursor_pos = vim.api.nvim_win_get_cursor(win)[1]
    local index = cursor_pos - 2

    if mark_positions[index] then
      local mark = mark_positions[index]
      vim.api.nvim_command("delmarks " .. mark.mark) -- Delete the mark
      print("Deleted mark '" .. mark.mark .. "' from line " .. mark.line)
      vim.api.nvim_win_close(win, true) -- Close window and refresh
      M.show_local_marks_in_window() -- Refresh marks window
    end
  end

  local function change_mark()
    local cursor_pos = vim.api.nvim_win_get_cursor(win)[1]
    local index = cursor_pos - 2

    if mark_positions[index] then
      local mark = mark_positions[index]
      local new_mark = vim.fn.input("Enter new mark (a-z): "):lower()

      if not new_mark:match("^[a-z]$") then
        print("Invalid mark! Must be a single letter (a-z).")
        return
      end

      vim.api.nvim_command("delmarks " .. mark.mark) -- Delete old mark
      vim.api.nvim_win_close(win, true) -- Close window before setting new mark
      vim.api.nvim_command("mark " .. new_mark) -- Set new mark at the same line
      print(string.format("Changed mark '%s' to '%s' on line %d", mark.mark, new_mark, mark.line))

      M.show_local_marks_in_window() -- Refresh marks window
    end
  end

  local function close_marks_window()
    vim.api.nvim_win_close(win, true) -- Close window
  end

  local function wkshow()
    local wk = require("which-key")
    wk.show()
  end

  vim.api.nvim_buf_set_keymap(buf, "n", "<C-x>", "Go to mark", { noremap = true, callback = go_to_mark, silent = true })  -- Jump to mark
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-r>", "Delete mark", { noremap = true, callback = delete_mark, silent = true }) -- Delete mark
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-c>", "Change mark", { noremap = true, callback = change_mark, silent = true }) -- Change mark
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-q>", "Close marks window", { noremap = true, callback = close_marks_window, silent = true }) -- Close window
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-?>", "Show shortcuts", { noremap = true, callback = wkshow, silent = true })
end


---If a mark with the letter 'k' exists in the file, moves to this mark line and delete it,
---if the mark don't exist, create it on the current line.
function M.quick_checkpoint_mark()
  local mark_exists = vim.fn.getpos("'k")[2] ~= 0
  if mark_exists then
    vim.cmd("'k")
    vim.cmd("delmarks k")
  else
    vim.cmd("normal! mkg`k")
  end
end


-- >> COLORS

---Converts an html color notation to rgb, ranging 0 - 1
---@param htmlColor string Html hex code color
---@return number r Number red value, ranging 0-1
---@return number g Number green value, ranging 0-1
---@return number b Number blue value, ranging 0-1
---@usage
---a, b, c = M.htmlColorToRGB("#f8f9b6")
---print(string.format("r: %s  g: %s  b: %s", a, b, c)) -- Outputs r: 0.97  g: 0.98  b: 0.71
function M.htmlColorToRGB(htmlColor)
  if htmlColor:sub(1, 1) == "#" then
    htmlColor = htmlColor:sub(2)
  end
  local r = tonumber(htmlColor:sub(1, 2), 16)
  local g = tonumber(htmlColor:sub(3, 4), 16)
  local b = tonumber(htmlColor:sub(5, 6), 16)
  r = r / 255
  g = g / 255
  b = b / 255
  vim.fn.setreg("+",
    string.format("%s %s %s", decimal_round(r, 2), decimal_round(g, 2), decimal_round(b, 2)))
  return r, g, b
end

---Read current word and match the correspondent pattern, assigning values to r, g, b isolated
---variables rangion 0-1.
---@param operation "convert"|"normalize"
---@return (number|nil|string) r float rangion 0-1
---@return (number|nil|string) g float rangion 0-1
---@return (number|nil|string) b float rangion 0-1
function M.AnalyzeColor(operation)
  operation = operation or "convert"
  local html_pattern = "^#(%x%x)(%x%x)(%x%x)$"
  local rgb_long_pattern = "(%d+),(%d+),(%d+)"
  local rgb_clean_pattern = "(%d%.%d+) (%d%.%d+) (%d%.%d+)"
  local rgb_norm_pattern = "(%d%.%d+),(%d%.%d+),(%d%.%d+)"
  --local wordUnderCursor = vim.fn.expand("<cWORD>")
  local wordUnderCursor = get_selection()
  local rno, gno, bno = wordUnderCursor:match(rgb_long_pattern)
  local rnno, gnno, bnno = wordUnderCursor:match(rgb_norm_pattern)
  local rh, gh, bh = wordUnderCursor:match(html_pattern)
  local rc, gc, bc = wordUnderCursor:match(rgb_clean_pattern)
  if rno and gno and bno then
    rno, gno, bno = tonumber(rno), tonumber(gno), tonumber(bno)
    if rno <= 255 and gno <= 255 and bno <= 255 then
      --print(string.format("R G B: (%d,%d,%d).   Normalizing...", rno, gno, bno))
      rno, gno, bno = rno / 255, gno / 255, bno / 255
      --print(string.format("Normalized R G B: (%.2f,%.2f,%.2f)", rno, gno, bno))
      return rno, gno, bno
    end
  elseif rnno and gnno and bnno then
    --print(string.format("R G B: (%.2f,%.2f,%.2f)", rnno, gnno, bnno))
    return rnno, gnno, bnno
  elseif rh and gh and bh then
    local r, g, b = vim.api.nvim_command("normal! lua htmlColorToRGB(wordUnderCursor)")
    --print(string.format("Detected HTML color: %s", wordUnderCursor))
    vim.fn.setreg("+", string.format("%.2f %.2f %.2f", r, g, b))
    vim.cmd([[normal! n]])
    return r, g, b
  elseif rc and gc and bc then
    rc, gc, bc = tonumber(rc), tonumber(gc), tonumber(bc)
    if rc <= 255 and gc <= 255 and bc <= 255 then
      local rn = math.floor(tonumber(rc) * 255)
      local gn = math.floor(tonumber(gc) * 255)
      local bn = math.floor(tonumber(bc) * 255)
      -- Format the values as a hex string
      if operation == "convert" then
        vim.fn.setreg("+", string.format("#%02X%02X%02X", rn, gn, bn))
        vim.cmd([[normal! n]])
      end
      if operation == "normalize" then
        vim.fn.setreg("+", string.format("(%.2f,%.2f,%.2f)", rn, gn, bn))
        vim.cmd([[normal! n]])
      end
    end
  else
    print("No valid color format detected")
    return nil, nil, nil
  end
end


-- >> NAVIGATION

---Open a given folder in telescope, and search given extension files
---@param dir string Path to the dir to search for
---@param ext? string Extension of the files to search for, if don't start wit '.', '.' is added
function M.open_dir_telescope(dir, ext)
  ext = ext or ""
  if ext ~= "" and not ext:match("^%.") then
    ext ="." .. ext
  end
  dir = dir or vim.fn.input("Input Dir Path: ")
  vim.cmd("cd " .. dir)
  vim.cmd("Telescope find_files default_text=" .. ext)
end

function M.prev_tab()
  local curr_buff = vim.fn.expand("%")
  local cmd_out = vim.api.nvim_cmd({cmd = "let", args = {"NERDTree.IsOpen()"}}, {output = true})
  local cmd_filtered = string.match(cmd_out, "#(%d+)")
  if string.match(curr_buff, "^NERD_tree_tab") then
    vim.api.nvim_command("silent! !kitty @ kitten next_window_or_tab.py -1")
  elseif cmd_filtered == "1" then
    vim.api.nvim_command("silent! NERDTreeFocus")
  else
    vim.api.nvim_command("silent! !kitty @ kitten du_kittens/next_window_or_tab.py -1")
  end
end

function M.next_tab()
  local curr_buff = vim.fn.expand("%")
  if string.match(curr_buff, "^NERD_tree_tab") then
    vim.api.nvim_command("silent! windo -1")
  else
    vim.api.nvim_command("silent! !kitty @ kitten du_kittens/next_window_or_tab.py")
  end
end

function M.split_vertical()
  local curr_buff = vim.fn.expand("%:p")
  vim.api.nvim_command("silent! !kitty @ launch --self --location vsplit nvim -n -- " .. curr_buff)
end

function M.split_horizontal()
  local curr_buff = vim.fn.expand("%:p")
  vim.api.nvim_command("silent! !kitty @ launch --self --location hsplit nvim -n -- " .. curr_buff)
end

-- >> UTILS

---Unload alla notify messages that are currently visible
function M.unload_notify_message()
  local ntf = require("notify")
  if ntf then
    ntf.dismiss({ silent = true, pending = true })
  end
end

---Append selection to buffer register + (The main register of copy/paste from linux)
function M.AppendSelectionToRegister()
  local selection = get_selection()
  local new_selection = vim.fn.getreg("+") .. selection
  vim.fn.setreg("+", new_selection)
  print("Appended to register +")
  vim.api.nvim_command("silent! normal! v")
end

---Clean buffer register +, the main buffer register from linux
function M.CleanSelectionToRegister()
  vim.fn.setreg("+", "")
  print("Cleaned register +")
end

---Add selection to a temporary file, that acts like a buffer, to permit copy multiple different
---lines, without pasting, to paste in the end.
---To paste after the copy is used [Global function](lua://M.PasteTmp())
function M.CopyTmp()
  local curr_selection = get_selection()
  local file = io.open(vim.fn.expand("/home/eduardotc/Programming/vim/tmp.txt"), "a")
  if not file then return end
  file:write(curr_selection .. "") -- Add space to separate entries
  file:close()
end

---Pate the lines from a defined temporary file, and in the end remove all the written lines from it.
function M.PasteTmp()
  -- Read the content of tmp.txt
  local file = io.open(vim.fn.expand("/home/eduardotc/Programming/vim/tmp.txt"), "r")
  if not file then return end
  local content = file:read("*a")
  file:close()

  -- Paste the content into the current buffer
  vim.api.nvim_put({ content }, "", true, true)

  -- Clear the contents of ~/tmp.txt
  file = io.open(vim.fn.expand("/home/eduardotc/Programming/vim/tmp.txt"), "w")
  if file then
    file:write("")
    file:close()
  end
end

---Require on lua all the files existing in a given dir.
---@param base_dir string Complete path to the dir
function M.RequireDir(base_dir)
  local scan = require('plenary.scandir') -- Requires 'plenary.nvim'
  local files = scan.scan_dir(base_dir, { depth = 1, add_dirs = false })

  local base_name = vim.fn.fnamemodify(base_dir, ":t") -- Extract the base directory name

  for _, file in ipairs(files) do
    if file:match("%.lua$") then
      local module_name = base_name .. "." .. file:sub(#base_dir + 2, -5):gsub("/", ".") -- Include base directory name
      local ok, err = pcall(require, module_name)
      if not ok then
        vim.api.nvim_err_writeln("Error loading module: " .. module_name .. "\n" .. err)
      end
    end
  end
end

-- >> PROGRAMMING

function M.jukit_resize()
  local inp_number = tostring(tonumber(vim.fn.input("Enter numbner total to resize: ")))
  --vim.api.nvim_call_function("jukit#send#send_to_split", .. code_block:gsub('"', '\\"') .. '")')
  vim.api.nvim_command("!kitten @action --match=neighbor:right resize_window " .. inp_number)
end

function M.list_help_files()
  -- Get the list of all help tags
  local handle = io.popen("nvim --headless -c 'helptags ALL' -c 'q'")
  if handle then handle:close() end

  handle = io.popen("find ~/.local/share/nvim/site/doc -name '*.txt' -exec grep -H '^\\*.*\\*' {} +")
  if not handle then return end

  local result = handle:read("*a")
  handle:close()

  -- Parse the result and extract tags
  local tags = {}
  for line in result:gmatch("[^\r\n]+") do
    local filename, tag = line:match("([^:]+):%*([^%*]+)%*")
    if filename and tag then
      tags[tag] = filename
    end
  end

  -- Print tags with hyperlinks
  print("Available help files:")
  for tag, file in pairs(tags) do
    print(string.format(":h %s - %s", tag, file))
  end
end


--- Print a lua table variable, principally for debuging/developing
---@param tbl table
---@param md_format? boolean Whether the formatting of table should be markdown friendly or not (defaults to false)
---@param persistent? boolean|number Wheter table should close automatically (false) or not
function M.display_table(tbl, md_format, persistent)
  persistent = persistent or 1000
  md_format = md_format or false
  local new_tbl = {}
  for i, j in pairs(tbl) do
    if type(j) == "table" then
      table.insert(new_tbl, "")
      if md_format then
        table.insert(new_tbl, (string.format("\n\n### %s", tostring(i))))
      else
        table.insert(new_tbl,
          (string.format("\n\n%s\n%s\n%s", string.rep("#", #tostring(i)), i, string.rep("#", #tostring(i)))))
      end
      for n, k in pairs(j) do
        if type(k) == "table" then
          if md_format then
            table.insert(new_tbl, (string.format("\n#### %s", tostring(n))))
          else
            table.insert(new_tbl,
              (string.format("\n%s\n%s", tostring(n), string.rep("=", #tostring(n)))))
          end
          for a, b in pairs(k) do
            if type(b) == "table" then
              if md_format then
                table.insert(new_tbl, (string.format("##### %s\n", tostring(a))))
              else
                table.insert(new_tbl,
                  (string.format("%s\n%s", tostring(a), string.rep("-", #tostring(a)))))
              end
              for c, d in pairs(b) do
                if type(d) == "table" then
                  table.insert(new_tbl, string.format("{%s}:  [%s]", c, table.concat(d, ", ")))
                else
                  table.insert(new_tbl, string.format("{%s}:  %s", c, d))
                end
              end
            else
              table.insert(new_tbl, string.format("%s: %s", a, b))
            end
          end
        else
          table.insert(new_tbl, string.format("%s: %s", n, k))
        end
      end
    else
      table.insert(new_tbl, string.format("%s: %s", i, j))
    end
  end
  local str = string.format("%s", table.concat(new_tbl, "\n"))
  notify(str, "normal", { title = "display_table", icon = " ", timeout = persistent })
  vim.api.nvim_command("silent! windo 1")
end


-- >> MARKDOWN

---Create or edit current day daily notes, stored in ~/Notes/daily, with the file name in the
---format mm_dd_yy.md
function M.daily_note()
  local current_date = os.date("%m_%d_%y")
  local file_path = vim.fn.expand("/home/eduardotc/Notes/daily/" .. current_date .. ".md")
  local exists = vim.fn.filereadable(file_path) == 1

  if exists then
    vim.cmd("edit " .. file_path)
  else

    local file, err = io.open(vim.fn.expand(file_path), "w")
    if not file then
      error("Failed to run find command: " .. err)
    end

    file:write("# " .. current_date .. "\n")
    file:write("\n---\n")
    file:write("\n---\n")
    file:write("\n ")

    file:close()

    vim.cmd("edit " .. file_path)
    vim.cmd("7")

  end
end

---Create or edit the daily note corresponding to the day before the current.
---Stored in ~/Notes/daily, with the file name in the format mm_dd_yy.md
---Example [Global function](lua://M.daily_note()), similar but for today date notes.
function M.yesterday_note()
  -- Calculate yesterday's date
  local yesterday = os.date("*t")
  yesterday.day = yesterday.day - 1
  local year = tostring(yesterday.year % 100) -- Get last 2 digits of the year
  local formatted_date = string.format("%02d_%02d_%02d", yesterday.month, yesterday.day, year)

  -- Check if the file exists
  local file_path = vim.fn.expand("~/Notes/daily/" .. formatted_date .. ".md")
  local exists = vim.fn.filereadable(file_path) == 1

  if exists then
    vim.cmd("edit " .. file_path)
  else
    notify("Yesterday Note Don't Exists!", "error")
  end
end

---Search recursivelly markdown files.
---@param dir string Dir root complete path, to start the search in.
---@return table Table containing the complete path to every found markdown file.
local function find_markdown_files(dir)
  local files = {}
  local pfile, err = io.popen('find "' .. dir .. '" -type f -name "*.md"')

  if not pfile then
    error("Failed to run find command: " .. err)
  end

  for filename in pfile:lines() do
    table.insert(files, filename)
  end

  pfile:close()
  return files
end

local function get_folders_in_dir(dir)
  -- Ensure the directory path ends with a slash
  if dir:sub(-1) ~= "/" then
    dir = dir .. "/"
  end

  local handle, err = io.popen("ls -d " .. dir .. "*/ 2>/dev/null")
  if not handle then
    error("Failed to run ls command: " .. err)
  end

  local result = handle:read("*a")
  handle:close()

  local folders = {}
  for folder in result:gmatch(dir .. "([^/]+)/") do
    table.insert(folders, folder)
  end

  return folders
end

local function find_string_in_table(tbl, search_string)
  for _, value in pairs(tbl) do
    if type(value) == "string" and string.find(value, search_string) then
      return value
    end
  end
  return nil
end

local function get_filenames_from_paths(paths)
  local filenames = {}
  for _, path in ipairs(paths) do
    local filename = path:match("([^/\\]+)$")
    table.insert(filenames, filename)
  end
  return filenames
end

local function find_matching_index(element, lookup_table)
  for index, value in ipairs(lookup_table) do
    if value == element then
      return index
    end
  end
  return nil
end

local function substitute_specific_strings(strings, replacements)
  local result = {}

  for _, str in ipairs(strings) do
    local replaced = false
    for match, replacement in pairs(replacements) do
      if str == match then
        table.insert(result, replacement)
        replaced = true
        break
      end
    end
    if not replaced then
      table.insert(result, str)
    end
  end

  return result
end

function M.glow_input()
  local mdfile = tostring(vim.fn.input("Enter Markdown File: "))
  local mdtable = find_markdown_files("/home/eduardotc/Notes")
  local result = find_string_in_table(mdtable, mdfile)
  if result then
    vim.cmd(string.format("Glow %s", result))
  else
    notify("Invalid inserted file!", "error")
  end
end

---Recursivelly browse from paramater dir for markdown files, openning the chosen one with glow
---Vim plugin.
---@param markdown_base_path string Dir path to use as base to search recursivelly
function M.glow_choose(markdown_base_path)
  local mdtable = find_markdown_files(string.format("%s", markdown_base_path))
  local mdfiles = get_filenames_from_paths(mdtable)
  vim.ui.select(mdfiles, {
    prompt = "Select a Markdown File:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), mdfiles)
      vim.cmd("Glow " .. mdtable[index])
    end
  end)
end

---Recursivelly browse from paramater dir for markdown files, openning the chosen one with in edit.
---@param markdown_base_path string Dir path to use as base to search recursivelly
function M.markdown_choose(markdown_base_path)
  local mdtable = find_markdown_files(string.format("%s", markdown_base_path))
  local mdfiles = get_filenames_from_paths(mdtable)
  vim.ui.select(mdfiles, {
    prompt = "Select a Markdown File:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), mdfiles)
      vim.cmd("edit " .. mdtable[index])
    end
  end)
end

---Search recursivelly given basse dir parameter, for markdown nb notebooks dir, openning a input
---window to the user to choose, and then displaying available notes on the dir to edit.
---@param notebooks_base_path string Dir base path to search recursivelly for
function M.markdown_notebooks(notebooks_base_path)
  local dir = string.format("%s", notebooks_base_path)
  local notebooks = get_folders_in_dir(dir)
  local display_notebooks = {}
  for _, str in ipairs(notebooks) do
    table.insert(display_notebooks, str)
  end
  local update_strings = substitute_specific_strings(display_notebooks, notebook_replacements)
  vim.ui.select(update_strings, {
    prompt = "󰠮  Select a Notebook:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), update_strings)
      local path = string.format("%s/%s", dir, notebooks[index])
      local mdtable = find_markdown_files(path)
      local mdfiles = get_filenames_from_paths(mdtable)
      vim.ui.select(mdfiles, {
        prompt = "󱞁  Select Note:",
      }, function(choice_n)
        if choice_n then
          local index_new = find_matching_index(string.format("%s", choice_n), mdfiles)
          vim.cmd("edit " .. mdtable[index_new])
        end
      end)
    end
  end)
end

---Create a new md note, with name inputted by the user, in a selected notebook dir.
---After creating the note, write to it the default initing, with a level 1 header title based on
---the given note name, as wel as md lines ('---') bellow it.
---The function ends opening the note with neovim to edit, with the cursor on the proper line.
---@param notebooks_base_path string Path to the base dir containing notebooks
function M.create_notebook_note(notebooks_base_path)
  local dir = string.format("%s", notebooks_base_path)
  local notebooks = get_folders_in_dir(dir)
  local display_notebooks = {}
  for _, str in ipairs(notebooks) do
    table.insert(display_notebooks, str)
  end
  local update_strings = substitute_specific_strings(display_notebooks, notebook_replacements)
  vim.ui.select(update_strings, {
    prompt = "󰠮  Select a Notebook:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), update_strings)
      local path = string.format("%s/%s", dir, notebooks[index])
      local word = tostring(vim.fn.input("Note Name: "))
      if word:sub(-3) == ".md" then
        NoteName = string.format("%s/%s", path, word)
      else
        NoteName = string.format("%s/%s.md", path, word)
      end
      local exists = vim.fn.filereadable(NoteName) == 1
      if word == "" then
        notify("Operation Canceled!", "info")
        return
      end
      if exists then
        -- Edit the file
        notify("Note Already Exists!", "info")
        vim.cmd("edit " .. NoteName)
      else
        local first_letter = string.upper(string.sub(word, 1, 1))
        local remaining_string = string.lower(string.sub(word, 2))
        -- Create the file
        local file, err = io.open(vim.fn.expand(NoteName), "w")
        if not file then
          error("Failed to run find command: " .. err)
        end
        file:write("# " .. first_letter .. remaining_string)
        file:write("\n")
        file:write("\n---")
        file:write("\n")
        file:write("\n---")
        file:write("\n ")
        file:write("\n ")
        file:close()
        -- Edit the file
        vim.cmd("edit " .. NoteName)
        vim.cmd("7")
      end
    end
  end)
end

-- >> GRAMMAR

---Print synonyms of thesaurus from inputted word
---@param word? string
function M.thesaurus_query(word)
  if word == nil then
    word = tostring(vim.fn.input("Enter a Word to Query: "))
  end
  local format_word = string.format('"%s"', word)
  if format_word then
    vim.cmd("Telescope thesaurus query word=" .. format_word)
  else
    print("Invalid inserted word!")
  end
end

---Translate to portuguese selected words in visual mode.
function M.dutrans_pt()
  local text = get_selection()
  local cmd = ("trans :pt-BR -b " .. text)
  bash_exec_notify(cmd, "trace", { icon = "󰗊 ", title = "To pt-BR Translate" })
end

---Translate to english selected words in visual mode.
function M.dutrans_en()
  local text = get_selection()
  local cmd = ("trans :en -b " .. text)
  bash_exec_notify(cmd, "trace", { icon = "󰗊 ", title = "To en Translate" })
end

---Interactive terminal translation.
---@param language string Terminal trans language to translate to.
function M.trans_interactive(language)
  local language_fmt = string.format("%s", language)
  local cmd = ("trans :" .. language_fmt .. " -v -I -no-rlwrap")
  M.open_floating_window(cmd)
end

local function get_code_block_language()
  local current_line = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local inside_block = false
  local block_language = nil
  for i = 1, current_line do
    local line = lines[i]
    local match = line:match("^```(%S*)$")
    if match then
      inside_block = not inside_block
      block_language = inside_block and match or nil
    elseif line:match("^```$") and inside_block then
      inside_block = false
      block_language = nil
    end
  end
  return inside_block and block_language or nil
end

---Comment the current line or selection with '#'
function M.comment_markdown_code_block()
  local language = get_code_block_language()
  if language == "python" then
    CommentMark = "#"
  elseif language == "lua" then
    CommentMark = "--"
  elseif language == "bash" or language == "sh" or language == "zsh" then
    CommentMark = "#"
  elseif language == "vimscript" then
    CommentMark = '""'
  elseif language == "js" or language == "javascript" then
    CommentMark = "//"
  end
  if language == nil then
    print("Not inside a Python code block.")
    return
  end
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    StartLine = vim.fn.line(".")
    EndLine = vim.fn.line(".")
  else
    vim.cmd([[silent! normal! "aygv]])
    StartLine = vim.fn.line("'<")
    EndLine = vim.fn.line("'>")
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  for line = StartLine, EndLine do
    Content = vim.fn.getline(line)
    if Content:match("^%s*"..CommentMark) then
      NewContent = Content:gsub("^%s*"..CommentMark.."%s*", "")
      -- Trailing tab/white spaces
      --new_content = new_content:gsub("^%s*", "")
      vim.fn.setline(line, "" .. Content:gsub("^%s*"..CommentMark.."%s*", "")) -- Remove # and leading whitespace
    else
      vim.fn.setline(line, CommentMark .. " " .. Content)
    end
  end
end

---- >> Test
---Prints execution result of current markdown python code block
local function print_python_code_block()
  local buf = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = nil
  for i = current_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if line:match("^```$") then
      break
    end
    if line:match("```python") then
      start_line = i + 1
      break
    end
  end
  if start_line then
    local collected_lines = {}
    for i = start_line, vim.api.nvim_buf_line_count(buf) do
      local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
      if line:match("```") then
        break
      end
      table.insert(collected_lines, line)
    end
    local code_block = table.concat(collected_lines, "\n")
    vim.api.nvim_command('call jukit#send#send_to_split("' .. code_block:gsub('"', '\\"') .. '")')
  else
    print("No '```python' found above the current line.")
  end
end


function M.append_jukit_output()
  local cmd = get_selection()
  --local selection = table.concat(cmd, "\n")
  print()

  -- Write selection to a temporary file
  local temp_file = "/tmp/nvim_jukit_exec.py"
  local file = io.open(cmd, "w")
  --local file = io.open(temp_file, "w")
  if not file then
    notify("Error creating temporary file", "error")
    return
  end
  file:write(cmd)
  file:close()

  ---- Execute the file with Python using vim-jukit and capture output
  local ipython_cmd = string.format("ipython3 %s", temp_file)
  local handle = io.popen(ipython_cmd)
  print(handle)
  if handle ~= nil then
    result = handle:read("*a")
    handle:close()
  else
    notify("Error creating temporary file", "error")
    return
  end

  -- Append the result to Wayland clipboard
  local clipboard_cmd = string.format('wl-copy --append "%s"', result:gsub('"', '\\"'))
  os.execute(clipboard_cmd)

  -- Notify the user
  vim.notify("Result appended to Wayland clipboard!", vim.log.levels.INFO)
  os.execute("rm -rf " .. temp_file)
end


--"/home/eduardotc/Programming/python/duutils/main.py --notes"
function M.open_floating_window(cmd_param)
  local cmd = string.format("%s", cmd_param)
  local width = vim.api.nvim_get_option_value("columns", {})
  local height = vim.api.nvim_get_option_value("lines", {})
  local win_width = math.ceil(width * 0.8)
  local win_height = math.ceil(height * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "none",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_set_option_value("winhl", "Normal:Normal", { scope = "local", win = win })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
    end
  })
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_command("startinsert")
end

---Prompts to user choose a local kitty fzf command and exec it
function M.fzf_kitty_choose()
  local fzf_opts = {
    "󱞁  Notes",
    "  Todo",
    "  History",
    "  LaTeX",
    "🖺  Man",
    "  PS",
    "📖 Translation Br",
    "📗 Translation En",
  }
  local tstn = {
    "/home/eduardotc/Programming/python/duutils/main.py --notes",
    "/home/eduardotc/Programming/python/duutils/main.py --todo",
    "/home/eduardotc/Programming/python/duutils/main.py --history",
    "/home/eduardotc/Programming/python/duutils/main.py --fzf-latex",
    "/home/eduardotc/Programming/python/duutils/main.py --man",
    "/home/eduardotc/Programming/python/duutils/main.py --ps-manage",
    "trans -v -I -no-rlwrap :pt-BR",
    "trans -v -I -no-rlwrap :en",
  }
  vim.ui.select(fzf_opts, {
    prompt = "󰥭  Command",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), fzf_opts)
      M.open_floating_window(string.format("%s", tstn[index]))
    end
  end)
end

-- TODO: Check if its possible to config the floating window in this function, without running
-- M.open floating window
function M.fzf_read_input()
  local node = ls.get_current_choices()
  local str = string.format("%s", table.concat(node, " "))
  local str_table = {}
  local idx_table = {}
  local idx = 0
  for word in str:gmatch("%S+") do
    table.insert(str_table, word)
    idx = idx + 1
    table.insert(idx_table, string.format("%s", idx))
  end

  vim.ui.select(str_table, {
    prompt = "Option ",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), str_table)
      print(index)
      ls.set_choice(tonumber(index))
      --vim.api.nvim_command_output("silent! lua require('luasnippets').set_choice(" .. index .. ")")
      --M.open_floating_window(string.format("%s", choice))
    end
  end)
end

---Function to format python files with ruff.
---The config file used by ruff is the cwd pyproject.toml, and if it not exists, uses the default
---ruff.toml config file in the .config/nvim folder.
function M.format_with_ruff()
  local file_dir = vim.fn.expand("%:p:h")
  local file_name = vim.fn.expand("%:p") -- Get the full path of the current file
  local pyproject_path = file_dir .. "/pyproject.toml"
  local exists = vim.fn.filereadable(pyproject_path) == 1
  PyprojectRuff = false
  if exists then
    local lines = vim.fn.readfile(pyproject_path)
    for _, line in ipairs(lines) do
      if string.match(line, "ruff") then
        PyprojectRuff = true
      end
    end
  end
  vim.api.nvim_command("silent! !isort " .. file_name)
  if PyprojectRuff then
    local cmd_check = ("silent! !ruff check " .. file_name .. " --config " .. pyproject_path)
    local cmd_format = ("silent! !ruff format " .. file_name .. " --config " .. pyproject_path)
    vim.api.nvim_command(cmd_check)
    vim.api.nvim_command(cmd_format)
    notify(("" .. file_name .. " Formmated with PyProject toml!"), "normal",
      { title = "Ruff", icon = " ", timeout = 1000 })
  else
    local cmd_check = ("silent! !ruff check " .. file_name .. " --config /home/eduardotc/.config/nvim/ruff.toml --fix --extend-select=I")
    local cmd_format = ("silent! !ruff format " .. file_name .. " --config /home/eduardotc/.config/nvim/ruff.toml")
    vim.api.nvim_command(cmd_check)
    vim.api.nvim_command(cmd_format)
    notify(("" .. file_name .. " Formmated with nvim ruff config!"), "info",
      { title = "Ruff", icon = " ", timeout = 1000 })
  end
end

function M.format_folding_lines()
  -- Get the lines of the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local updated_lines = {}
  local i = 1

  while i <= #lines do
    local line = lines[i]
    local _, comment_marks, _ = line:match("^(%s*)(#+)(.*>>.*)$")

    if comment_marks then
      local comment_count = #comment_marks

      -- Calculate how many blank lines are before and after the current line
      local preceding_blank_lines = 0
      local following_blank_lines = 0

      -- Count preceding blank lines
      for j = i - 1, 1, -1 do
        if lines[j]:match("^%s*$") then
          preceding_blank_lines = preceding_blank_lines + 1
        else
          break
        end
      end

      -- Count following blank lines
      for j = i + 1, #lines do
        if lines[j]:match("^%s*$") then
          following_blank_lines = following_blank_lines + 1
        else
          break
        end
      end

      -- Adjust preceding blank lines based on comment count
      if comment_count == 1 then
        -- Ensure 2 blank lines before
        while preceding_blank_lines < 2 do
          table.insert(updated_lines, "")
          preceding_blank_lines = preceding_blank_lines + 1
        end
        -- Remove excess preceding blank lines
        while preceding_blank_lines > 2 do
          table.remove(updated_lines, #updated_lines)
          preceding_blank_lines = preceding_blank_lines - 1
        end
        table.insert(updated_lines, line)
        -- Ensure 1 blank line after
        if following_blank_lines == 0 then
          table.insert(updated_lines, "")
        end
        i = i + following_blank_lines -- Skip already counted blank lines
      else
        -- Ensure 1 blank line before
        if preceding_blank_lines < 1 then
          table.insert(updated_lines, "")
        end
        table.insert(updated_lines, line)
        -- No blank lines after
        i = i + following_blank_lines -- Skip already counted blank lines
      end
    else
      table.insert(updated_lines, line)
    end

    i = i + 1
  end

  -- Replace the buffer lines with the updated ones
  vim.api.nvim_buf_set_lines(0, 0, -1, false, updated_lines)
end

function M.ToggleFolding()
  -- Check if folding is currently enabled
  local folding_enabled = vim.wo.foldenable

  if folding_enabled then
    -- Disable folding
    vim.wo.foldenable = false
    print("Folding disabled")
  else
    -- Enable folding
    vim.wo.foldenable = true
    print("Folding enabled")
  end
end


---Define a function to jump to a buffer by number or mapped letter.
function M.jump_to_buffer()
  local char = vim.fn.getchar()
  local key = vim.fn.nr2char(char)
  local buffer_number = key_to_number(key)
  if buffer_number then
    vim.cmd("LualineBuffersJump " .. buffer_number)
  else
    print("Invalid input: Not a valid number or mapped key")
  end
end

---Define a function to jumpt an specific tab by number or mapped letter
function M.jump_to_tab()
  local char = vim.fn.getchar()
  local key = vim.fn.nr2char(char)
  local tab_number = key_to_number(key)
  if tab_number then
    vim.cmd("tabnext" .. tab_number)
  else
    print("Invalid input: Not a valid number or mapped key")
  end
end

---Create a temporary file, with the template based on the file type, also executing programming
---configured commands at start. The files are created at /tmp, having their name based on their
---type. If a file already exists from this type in /tmp (files in /tmp are reseted in ever reboot),
---prompts the user to choose to open this file, or to create a new one, not deleting the existing
---one.
---@param extension string File type/extension, like 'py'.
function M.open_tmp_file(extension)
  local file_path = "/tmp/tmp." .. extension
  local line_to_open = get_template_line_to_open(extension)
  if file_exists(file_path) then
    notify(
      "File " .. file_path .. " already exists. Open it (o) or create a new one (n)? '",
      "info",
      { timeout = false }
    )
    local answer = vim.fn.input("")
    notify.dismiss()
    if answer == "o" then
      vim.cmd("edit " .. file_path)
    elseif answer == "n" then
      local n = 1
      local new_file_path = "/tmp/tmp" .. n .. "." .. extension
      while file_exists(new_file_path) do
        n = n + 1
        new_file_path = "/tmp/tmp" .. n .. "." .. extension
      end
      write_template_extension(new_file_path)
      vim.cmd("edit " .. file_path)
      --vim.api.nvim_command("silent! edit " .. new_file_path)
    else
      notify("Invalid input. Aborted!", "error")
      return
    end
  else
    write_template_extension(file_path)
    vim.cmd("edit " .. file_path)
  end
  open_command_extension(extension)
  vim.cmd(line_to_open)
end

--- Prompts user to choose from sessions saved in a local dir, and opens this chosen session.
function M.list_open_session()
  local dir = "/home/eduardotc/Programming/vim"
  local file_paths = {}
  local file_names = {}

  local dirp = C.opendir(dir)
  if dirp == nil then return nil end
  while true do
    local entry = C.readdir(dirp)
    if entry == nil then break end
    local name = ffi.string(entry.d_name)
    if name ~= "." and name ~= ".." then
      local full_path = dir .. "/" .. name
      if entry.d_type == 8 then
        table.insert(file_paths, full_path)
        table.insert(file_names, name)
      end
    end
  end
  C.closedir(dirp)
  vim.ui.select(file_names, {
    prompt = "  Select a Session:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), file_names)
      vim.api.nvim_command("silent! source " .. file_paths[index])
    end
  end)
end

--- Prompts user to choose from sessions saved in a local dir, to delete a session file.
function M.list_delete_session()
  local dir = "/home/eduardotc/Programming/vim"
  local file_paths = {}
  local file_names = {}

  local dirp = C.opendir(dir)
  if dirp == nil then return nil end
  while true do
    local entry = C.readdir(dirp)
    if entry == nil then break end
    local name = ffi.string(entry.d_name)
    if name ~= "." and name ~= ".." then
      local full_path = dir .. "/" .. name
      if entry.d_type == 8 then
        table.insert(file_paths, full_path)
        table.insert(file_names, name)
      end
    end
  end
  C.closedir(dirp)
  vim.ui.select(file_names, {
    prompt = "  Delete a Session:",
  }, function(choice)
    if choice then
      local index = find_matching_index(string.format("%s", choice), file_names)
      vim.api.nvim_command("silent! !rm -rf " .. file_paths[index])
    end
  end)
end

function M.toggle_statusline()
  ---@diagnostic disable-next-line: undefined-field
  local statusline_value = vim.opt.laststatus:get()
  if statusline_value ~= 0 then
    vim.opt.laststatus = 0
  else
    vim.opt.laststatus = 2
  end
end

function M.Status_command()
  local lst = notify.history()[#notify.history()]
  if lst then
    return string.format("%s%s  %s  %s",
      lst["message"]["icon"] or "",
      lst["title"][2],
      lst["title"][1],
      lst["message"][1] or ""
    ) or ""
  end
  return ""
end

--- Deletes all files in a given local dir, if param is not given the user is prompted to insert one
---@param dir? string Complete local path to directory which files should be deleted
function M.delete_dir_files(dir)
  dir = dir or vim.fn.input("Complete folder path: ")
  local exp_dir = vim.fn.expand(dir)
  local files = vim.fn.globpath(exp_dir, "*", false, true)
  local count = #files
  if count == 0 then
    print("No files found in " .. dir)
    return
  end
  local confirm = vim.fn.input("Found " ..
    count .. " files in " .. exp_dir .. "\nAre you sure you want to delete them? (y/N): ")
  if confirm:lower() ~= "y" then
    print("Operation canceled.")
    return
  end
  local deleted_count = 0
  for _, file in ipairs(files) do
    if vim.fn.delete(file) == 0 then
      deleted_count = deleted_count + 1
    end
  end
  print("Deleted " .. deleted_count .. " files from " .. dir)
end

--- Store the current file path in a local temporary file, used to reopen last closed file
---[Global Function](lua://M.open_last_file()) Function implements the reopen of recent closed file
function M.store_current_file()
  local file_name = vim.fn.expand("%:p")
  local dir = "/tmp/nvim"
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p") -- Create the directory if it doesn't exist
  end
  local tmp_path = dir .. "/last_files"
  local lines = {}
  local tmp_file = io.open(tmp_path, "r")
  if tmp_file then
    for line in tmp_file:lines() do
      table.insert(lines, line)
    end
    tmp_file:close()
  end
  table.insert(lines, 1, file_name)
  while #lines > 5 do
    table.remove(lines)
  end
  tmp_file = io.open(tmp_path, "w")
  if tmp_file then
    for _, line in ipairs(lines) do
      tmp_file:write(line .. "\n")
    end
    tmp_file:close()
  else
    print("Error: Could not open " .. tmp_path .. " for writing.")
  end
end

function M.test(arg)
  arg = arg or vim.fn.input("Recent files (1-5) to open: ")
  local tbldu = {}
  if type(arg) == "string" then
    for num in string.gmatch(arg, "%d+") do
      table.insert(tbldu, tonumber(num))
    end
  end
  M.display_table(tbldu)
end

function M.open_last_file(line_str)
  local line_numbers = {}
  line_str = line_str or vim.fn.input("Recent files (1-5) to open: ")
  if type(line_str) == "string" then
    for num in string.gmatch(line_str, "%d+") do
      table.insert(line_numbers, tonumber(num))
    end
  end
  local tmp_path = "/tmp/nvim/last_files"
  local tmp_file = io.open(tmp_path, "r")
  if not tmp_file then
    notify("Error: Could not open " .. tmp_path, "error", {})
    return
  end
  local lines = {}
  for line in tmp_file:lines() do
    table.insert(lines, line)
  end
  tmp_file:close()
  for _, line_number in ipairs(line_numbers) do
    if line_number >= 1 and line_number <= 5 and lines[line_number] then
      local file_path = lines[line_number]
      if file_path ~= "" then
        vim.cmd("edit " .. file_path)
        print("Opened file: " .. file_path)
      else
        print("Warning: Line " .. line_number .. " is empty.")
      end
    else
      print("Error: Invalid line number " .. line_number)
    end
  end
end

function M.close_all_current_window_buffers()
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tabpage)
  M.display_table(windows)
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_loaded(buf) then
      if not vim.bo[buf].modified then
        vim.api.nvim_buf_delete(buf, {})
      else
        print("Buffer " .. vim.api.nvim_buf_get_name(buf) .. " is modified, not closing.")
      end
    end
  end
end

function M.close_term_buffers_in_current_tab()
  local bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      if not vim.bo[buf].modified then
        BufName = vim.api.nvim_buf_get_name(buf)
        M.store_current_file()
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end
end

-- Function to prompt user input and rename current tab in lualine
function M.RenameTab()
  vim.ui.input({ prompt = "Enter new tab name: " }, function(input)
    if input then
      local tab_number = vim.api.nvim_get_current_tabpage()
      vim.t[tab_number].tabname = input
      require('lualine').refresh() -- Refresh lualine to update the tab name
    end
  end)
end

-- Map the function to a keybinding for convenience (optional)
vim.api.nvim_set_keymap('n', '<leader>rt', ':lua RenameTab()<CR>', { noremap = true, silent = true })

-- Function to count Python functions without docstrings in the current buffer
function CountUndocumentedFunctions()
  -- Get the current buffer lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Initialize variables
  local undocumented_functions = 0
  local in_function = false
  local has_docstring = false

  -- Regex patterns to match functions and docstrings
  -- Allow leading spaces for indented functions inside classes
  local function_pattern = "^%s*def%s+[%w_]+%s*%("
  local docstring_pattern = '^%s*"""'

  -- Loop through each line
  for _, line in ipairs(lines) do
    -- Check if the line is a function definition
    if line:match(function_pattern) then
      -- If we were in a function and it didn't have a docstring, count it
      if in_function and not has_docstring then
        undocumented_functions = undocumented_functions + 1
      end
      -- Reset flags for the new function
      in_function = true
      has_docstring = false
    elseif in_function and line:match(docstring_pattern) then
      -- If we're inside a function and found a docstring, set the flag
      has_docstring = true
    elseif in_function and line == "" then
      -- If we reach an empty line and were in a function, check for a docstring
      if not has_docstring then
        undocumented_functions = undocumented_functions + 1
      end
      -- Reset the function flag as we've exited the function body
      in_function = false
    end
  end

  -- If the last function doesn't have a docstring, count it
  if in_function and not has_docstring then
    undocumented_functions = undocumented_functions + 1
  end

  return undocumented_functions
end

-- Function to integrate the count into the statusline
function M.UndocumentedFunctionsInStatusline()
  -- Check if the current file is a Python file
  local filetype = vim.bo.filetype
  if filetype == "python" then
    local count = CountUndocumentedFunctions()
    return string.format("  %d Missing Docstr", count)
  else
    return "" -- Return empty string for non-Python files
  end
end

function M.JukitCondaEnv(conda_env_dir)
  -- Get all subdirectories (environment names) from the conda_env_dir
  conda_env_dir = conda_env_dir or "/home/eduardotc/miniforge3/envs"
  local handle, err = io.popen('find ' .. conda_env_dir .. ' -maxdepth 1 -mindepth 1 -type d')
  if not handle then
    error("Failed to run find command: " .. err)
  end
  local result = handle:read("*a")
  handle:close()
  -- Split the result into a list of environment names
  local envs = {}
  for env in result:gmatch("[^\r\n]+") do
    table.insert(envs, vim.fn.fnamemodify(env, ":t"))
  end
  table.insert(envs, "base")

  -- Prompt user to select an environment
  vim.ui.select(envs, { prompt = "Choose a conda environment:" }, function(choice)
    if choice then
      local cmd2 = "conda activate " .. choice

      -- Run the first command using the jukit function to open ipython console
      vim.fn["jukit#kitty#splits#output"](cmd2)

      -- Send the conda activate command to the new ipython window
      vim.defer_fn(function()
        --vim.fn["jukit#send#send_to_split"]("!kitty @ set-window-title jukit-py")
        --vim.api.nvim_command("silent! !kitty @ set-colors --match=neighbor:right '/home/eduardotc/.config/kitty/kitty-themes/themes/JetBrains_Darcula.conf'")
      end, 500)  -- Delay to ensure the window is ready
    end
  end)
end


function M.extract_numpydocstr_example_code()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, vim.api.nvim_win_get_cursor(0)[1], -1, false)

  local examples_section = false
  local code_lines = {}

  for _, line in ipairs(lines) do
    if line:match("^%s*Examples") then
      examples_section = true
    elseif examples_section and line:match('%s*"""') then
      break
    elseif examples_section then
      if line:match("^%s*>>>*") then
        local clean_line = line:gsub("^%s*>>>%s*", "")
        table.insert(code_lines, clean_line)
      end
    end
  end
  --M.display_table(code_lines)
  for _, code_line in ipairs(code_lines) do
    vim.api.nvim_call_function("jukit#kitty#cmd#send_text", {buf, code_line})
  end
end
---Toggle the left side bar sign column
function M.toggle_sign_column()
  local current = vim.wo.signcolumn
  if current == "no" then
    vim.wo.signcolumn = "yes"
  else
    vim.wo.signcolumn = "no"
  end
end

--- Copies the content of the current file to the system clipboard using xclip.
--- If no file is loaded, notifies the user that there is no file to copy.
function M.CopyCurrentFileToClipboard()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    print("No file to copy")
    return
  end
  local command = "cat " .. vim.fn.shellescape(filepath) .. " | xclip -selection clipboard"
  vim.fn.system(command)
  print("Copied file content to clipboard: " .. filepath)
end

--- Copies the path of the current file to the system clipboard using xclip.
--- If no file is loaded, notifies the user that there is no file to copy.
function M.CopyFilePathToClipboard()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    print("No file path to copy")
    return
  end
  local command = "echo -n " .. vim.fn.shellescape(filepath) .. " | xclip -selection clipboard"
  vim.fn.system(command)
  print("Copied file path to clipboard: " .. filepath)
end


-- >> LSP

---Open a html server to preview .html files.
function M.serve_and_open_html()
  local filepath = vim.fn.expand("%:p:h") -- Get the directory of the current file
  local filename = vim.fn.expand("%:p")   -- Get the full path of the current file
  local ft = vim.bo[0].filetype
  if ft == "html" then
    local check_port = io.popen("lsof -i :8486")
    if not check_port then return end
    local server_running = check_port:read("*a")
    local flp_loc = "/home/eduardotc/.local/floorp/obj-x86_64-pc-linux-gnu/dist/bin/floorp --remote -P Du --new-tab http://0.0.0.0:8486"
    local flp_nm = vim.fn.fnamemodify(filename, ":t")
    check_port:close()
    if not string.find(server_running, "LISTEN") then
      --vim.fn.jobstart("python -m http.server 8486 --directory " .. filepath, {
      vim.fn.jobstart("gh markdown-preview --port=8486 --remote=0.0.0.0 --disable-auto-open " .. filepath, {
        on_exit = function(code)
          if code == 0 then
            --notify("HTTP Server started on http://0.0.0.0:8486/", "normal",
            notify("Gh markdown server started on http://0.0.0.0:8486/", "normal",
              { title = "HTML Server", icon = "󰖟 ", timeout = 1000 })
            vim.fn.jobstart(flp_loc .. flp_nm, { detach = true })
          else
            --notify("Failed to start HTTP Server", "error",
            notify("Failed to start Gh markdown server", "error",
              { title = "HTML Server", icon = "󰖟 ", timeout = 1000 })
          end
        end,
        detach = true
      })
    else
      notify("HTTP Server is already running on port 8486", "warning",
        { title = "HTML Server", icon = "󰖟 ", timeout = 1000 })
      vim.fn.jobstart(flp_loc .. flp_nm, { detach = true })
    end
  else
    notify("Current file is not an HTML file.", "warning",
      { title = "HTML Server", icon = "󰖟 ", timeout = 1000 })
  end
end


function M.ToggleDiagnostics()
  local is_enabled = vim.diagnostic.is_enabled()
  if is_enabled then
    vim.diagnostic.disable(0)
    notify("Diagnostics disabled.", "normal", { title = "LSP", icon = "󰱼 ", timeout = 600})
  else
    vim.diagnostic.disable(0)
    notify("Diagnostics enabled.", "normal", { title = "LSP", icon = "󰱼 ", timeout = 600})
  end
end

---Toggle On/Off an specific given lsp client.
---@param lsp_name string
function M.ToggleLspCli(lsp_name)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.name == lsp_name then
      CliStopped = client.is_stopped()
      if CliStopped == true then
        vim.lsp.start_client(client.id)
        print(lsp_name .. " Client Starting...")
        return
      else
        vim.lsp.stop_client(client.id, true)
        print("Disabling " .. lsp_name .. "LSP...")
        return
      end
    end
  end
  vim.cmd("LspStart " .. lsp_name)
  print(lsp_name .. " Client Starting...")
end


function M.StartRecordingMacro()
  -- Prompt the user to input a letter
  vim.ui.input({ prompt = "Enter a register letter to record the macro: " }, function(input)
    if input and input:match("^[a-zA-Z]$") then
      -- Start recording the macro for the given register
      vim.cmd("normal! q" .. input)
      print("Recording macro in register: " .. input)
    else
      print("Invalid input. Please enter a single letter.")
    end
  end)
end


-- >> CREATING COMMANDS
function M.get_colorscheme_colors()
  local colors = {}
  local highlight_groups = {
    "Normal", "Comment", "Constant", "String", "Identifier", "Statement",
    "PreProc", "Type", "Special", "Underlined", "Todo", "Error", "WarningMsg",
    "Markup", "Cursor", "CursorColumn", "Conceal"
  }

  for _, group in ipairs(highlight_groups) do
    local ok, color = pcall(vim.api.nvim_get_hl, 0, {name = group, link = true})
    if ok then
      colors[group] = color
    end
  end
  --M.display_table(colors)
  return colors
end

function M.DeleteExceptMatching(range_start, range_end, pattern)
  local lines = vim.api.nvim_buf_get_lines(0, range_start - 1, range_end, false)
  local new_lines = {}

  for _, line in ipairs(lines) do
    if line:match(pattern) then
      table.insert(new_lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(0, range_start - 1, range_end, false, new_lines)
end

vim.api.nvim_create_user_command(
  'DeleteExceptMatching',
  function(opts)
    M.DeleteExceptMatching(opts.line1, opts.line2, opts.args)
  end,
  { nargs = 1, range = true }
)



--vim.api.nvim_create_user_command("GetColors", get_colorscheme_colors, {})
vim.api.nvim_create_user_command("ToggleSignCol", function() M.toggle_sign_column() end, {})
vim.api.nvim_create_user_command("OpenSession", function() M.list_open_session() end, {})
vim.api.nvim_create_user_command("DeleteSession", function() M.list_delete_session() end, {})
vim.api.nvim_create_user_command("TmpPy", function() M.open_tmp_file("py") end, {})
vim.api.nvim_create_user_command("TmpSh", function() M.open_tmp_file("sh") end, {})
vim.api.nvim_create_user_command("TmpLua", function() M.open_tmp_file("lua") end, {})
vim.api.nvim_create_user_command("PrintPythonCodeBlock", print_python_code_block, {})
vim.api.nvim_create_user_command("DeleteDirFiles", function() M.delete_dir_files() end, {})
vim.api.nvim_create_user_command("StoreCurrentFile", function() M.store_current_file() end, {})
vim.api.nvim_create_user_command("ReopenLastFile", function() M.open_last_file("1") end, {})
vim.api.nvim_create_user_command("OpenFilesFromLines", function() M.open_last_file() end, {})
vim.api.nvim_create_user_command("CloseBuffers", M.close_all_current_window_buffers, {})
vim.api.nvim_create_user_command("Tst", M.close_term_buffers_in_current_tab, {})
vim.api.nvim_create_user_command("DocstrRun", M.extract_numpydocstr_example_code, {})
vim.api.nvim_create_user_command("CopyFile", M.CopyCurrentFileToClipboard, {})
vim.api.nvim_create_user_command("CopyFilePath", M.CopyFilePathToClipboard, {})
vim.api.nvim_create_user_command("ToggleDiagnostics", M.ToggleDiagnostics, {})
vim.api.nvim_create_user_command("CommentMdBlock", M.comment_markdown_code_block, {})
vim.api.nvim_create_user_command("RecordMacro", M.StartRecordingMacro, {})
vim.api.nvim_create_user_command("ToggleFold", M.ToggleFolding, {})
vim.api.nvim_create_user_command("JukitResize", M.jukit_resize, {})
vim.api.nvim_create_user_command("MarksLocal", M.show_local_marks_in_window, {})
vim.api.nvim_create_user_command("MarkChange", change_mark_on_current_line, {})

vim.api.nvim_create_user_command("DeleteSwapFiles",
  function() M.delete_dir_files("/home/eduardotc/.local/state/nvim/swap") end, {})

vim.api.nvim_create_user_command("H", function(opts)
  if opts.args == "" then
    opts.args = vim.fn.input("Help name: ")
  end
  vim.api.nvim_command("silent! help " .. opts.args)
  vim.api.nvim_command("silent! only")
end, { nargs = "*" })

vim.api.nvim_create_user_command("PyTelescope",
  function() M.open_dir_telescope("/home/eduardotc/Programming/python", "py") end, {})

vim.api.nvim_create_user_command("MdTelescope",
  function() M.open_dir_telescope("/home/eduardotc/Notes", "md") end, {})

function M.infer_type(default)
  if default:match('^".*"$') or default:match("^'.*'$") then
    return "str"
  elseif tonumber(default) then
    return "int"
  elseif default == "True" or default == "False" then
    return "bool"
  elseif default:match("^%[.*%]$") then
    return "list"
  elseif default:match("^{.*}$") then
    return "dict"
  else
    return "type"
  end
end
local function isStringInTable(str, tbl)
    for _, value in pairs(tbl) do
        if value == str then
            return true
        end
    end
    return false
end


return M
