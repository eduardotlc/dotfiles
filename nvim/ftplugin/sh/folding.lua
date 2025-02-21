-- >> FOLDING FUNCTION
function ZshduFolds(lnum)
  vim.cmd("hi Folded guibg=#282A36 guifg=#FF79C6")
  vim.cmd("hi FoldColumn guifg=#8BE9FD")
  local cur_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)
  if string.match(cur_line, "^.*%# %>%>+ %S+") then
    local ntst = string.len(string.match(cur_line, "%>%>+")) / 2
    return ">" .. string.format(ntst)
  end
  if cur_line == "" and string.match(next_line, "^%# %>%> %S+") then
    return ">1"
  else
    return "="
  end
end

-- >> FOLDING TEXT
function ZshduFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local folded_line_num = vim.v.foldend - vim.v.foldstart
  local ntst = string.len(string.match(line, "%>%>+")) / 2
  local level_count = ntst
  local string_part = string.match(line, "^%#+ %>%>+ (%S+.*)")
  local line_text = string.gsub(line, line,
    string.rep("#", level_count) .. string.rep(" ", 8 - level_count) .. string_part)
  return line_text ..
  string.rep(" ", 55 - string.len(line_text)) ..
  " (" .. folded_line_num .. " L) " .. string.rep(" ", 4 - string.len(tostring(folded_line_num)))
end

-- VARIABLES
vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
  pattern = "*",
  command = "normal zR"
})

vim.opt.foldexpr = "v:lua.ZshduFolds(v:lnum)"
vim.opt.foldtext = "v:lua.ZshduFoldText()"
