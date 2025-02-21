-- >> VARIABLES

local fold_pattern = "^%s*#%s+%>%>+%s+%S+[%w#<>_()-%s]+"
local fold_str_part = "^%s*#%s+%>%>+%s+(%S+[%w#<>_()-%s]+.*)"
local cls_pattern = "^%s*class%s+[%w_]+"
local cls_str_part = "class%s+(.-):"
local fn_pattern = "^%s*def%s+[%w_]+"
local fn_str_part = "%s*def%s+([%w_]+).*"
local init_pattern = "#!/usr/bin/env python3"
local first_pattern = "^%s*.*%# %>%> %S+"
local triple_quote_pattern = "^%s*%\"%\"%\""
local six_quote_pattern = "^%s*%\"%\"%\"+.*%\"%\"%\"^"
DocStrLines = {}

local function numberExists(tbl, num)
  for _, value in ipairs(tbl) do
    if value == num then
      return true
    end
  end
  return false
end

local function draw_fold(text)
  local folded_line_num = vim.v.foldend - vim.v.foldstart
  return text .. string.rep(" ", 55 - string.len(text)) ..
  " (" .. folded_line_num .. " L) " .. string.rep(" ", 4 - string.len(tostring(folded_line_num)))
end

function DetectPythonDocstringRange(lnum)
  local total_lines = vim.fn.line("$")
  local cur_line = vim.fn.getline(lnum)

  if string.match(cur_line, triple_quote_pattern) then
    if string.match(cur_line, six_quote_pattern) then
      return lnum, lnum
    end

    if numberExists(DocStrLines, lnum) then
      return nil, nil
    end
    -- Search for the end of the docstring
    for i = lnum + 1, total_lines do
      local line = vim.fn.getline(i)
      if string.match(line, triple_quote_pattern) then
        return lnum, i -- Return the start and end line numbers
      end
    end
  end
  return nil, nil
end

-- >> FOLDING FUNCTION

function PyDuFolds(lnum)
  local cur_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)

  if lnum == 1 then
    if string.match(cur_line, init_pattern) then
      return ">1"
    end
  end

  if string.match(cur_line, cls_pattern) then
    return ">1" -- Set the fold level for classes
  end

  if string.match(cur_line, fn_pattern) then
    return ">2" -- Set function folds one level deeper than classes
  end

  if string.match(cur_line, fold_pattern) then
    local ntst = string.len(string.match(cur_line, "%>%>+")) / 2
    return ">" .. string.format(ntst)
  end

  local start_line, end_line = DetectPythonDocstringRange(lnum)
  if start_line then
    table.insert(DocStrLines, end_line)
    return "a1"
  end

  if numberExists(DocStrLines, lnum) then
    return "s1"
  end

  if cur_line == "" and (string.match(next_line, first_pattern) or string.match(next_line, cls_pattern)) then
    return "<1"
  end

  return "="
end

-- >> FOLDING TEXT

function PyDuFoldText()
  local line = vim.fn.getline(vim.v.foldstart)

  if string.match(line, init_pattern) then
    local line_text = "# PYTHON3"
    return draw_fold(line_text)
  end

  if string.match(line, triple_quote_pattern) then
    local line_text = string.rep("#", vim.fn.foldlevel(line)) .. " [Docstr]"
    return draw_fold(line_text)
  end

  if string.match(line, cls_pattern) then
    local line_text = "# CLASS " .. string.match(line, cls_str_part)
    return draw_fold(line_text)
  end

  if string.match(line, fn_pattern) then
    local line_text = "## fn " .. string.match(line, fn_str_part)
    return draw_fold(line_text)
  end

  if string.match(line, fold_pattern) then
    local line_text = string.rep("#", vim.v.foldlevel) .. " " .. string.match(line, fold_str_part)
    return draw_fold(line_text)
  end

  local line_text = string.rep("#", vim.v.foldlevel) .. " " .. line
  return draw_fold(line_text)
end

-- >> VIM VARS

vim.cmd [[
  hi Folded guibg=#282A36 guifg=#FF79C6
  hi FoldColumn guifg=#8BE9FD
]]


-- >> VIM OPTS

vim.opt.foldexpr = "v:lua.PyDuFolds(v:lnum)"
vim.opt.foldtext = "v:lua.PyDuFoldText()"
