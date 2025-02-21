-- >> VARIABLES

local fold_pattern = "^%s*#%s+%>%>+%s+%S+[%w#<>_()-%s]+"
local fold_str_part = "^%s*#%s+%>%>+%s+(%S+[%w#<>_()-%s]+.*)"
local init_pattern = "#!.*"
local first_pattern = "^%s*.*%# %>%> %S+"

local function draw_fold(text)
  local folded_line_num = vim.v.foldend - vim.v.foldstart
  return text .. string.rep(" ", 55 - string.len(text)) ..
  " (" .. folded_line_num .. " L) " .. string.rep(" ", 4 - string.len(tostring(folded_line_num)))
end

function BashDuFolds(lnum)
  local cur_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)

  if lnum == 1 then
    if string.match(cur_line, init_pattern) then
      return "1"
    end
  end

  if string.match(cur_line, fold_pattern) then
    local ntst = string.len(string.match(cur_line, "%>%>+")) / 2
    return ">" .. string.format(ntst)
  end

  if cur_line == "" and (string.match(next_line, first_pattern)) then
    return "<1"
  end

  return "="
end


-- >> FOLDING TEXT

function BashDuFoldText()

  local line = vim.fn.getline(vim.v.foldstart)

  if string.match(line, init_pattern) then
    local line_text = "# BASH"
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

vim.opt.foldexpr = "v:lua.BashDuFolds(v:lnum)"
vim.opt.foldtext = "v:lua.BashDuFoldText()"
