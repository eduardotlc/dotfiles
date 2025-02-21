-- >> FOLDING FUNCTION
function TexFolds(lnum)
  vim.cmd('hi Folded guifg=#FF79C6')
  vim.cmd('hi FoldColumn guifg=#8BE9FD')
  local cur_line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)
  if string.match(cur_line, '^\\section{') or string.match(cur_line, '^\\documentclass[') then
    return '>1'
  elseif string.match(cur_line, '^%%* >> \\S') then
    return '>' .. (string.match(cur_line, '^%%*') + 1)
  elseif string.match(cur_line, '^\\subsection{') then
    return '>2'
  elseif string.match(cur_line, '^\\subsubsection{') then
    return '>3'
  elseif string.match(cur_line, '\\begin{itemize}') or string.match(cur_line, '\\begin{enumerate}') or string.match(cur_line, '\\begin{table}') or string.match(cur_line, '\\begin{tocentry}') or string.match(cur_line, '\\begin{abstract}') then
    return '>4'
  elseif string.match(cur_line, '^\\begin{document}') then
    return '<1'
  else
    if cur_line == '' and string.match(next_line, '^\\section{') then
      return 0
    elseif cur_line == '' and string.match(next_line, '^%% >> \\S') then
      return 0
    else
      return '='
    end
  end
end

-- >> FOLDING TEXT
function TexFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local folded_line_num = vim.v.foldend - vim.v.foldstart
  -- Section and Subsections
  local string_part = string.match(line, '\\(sub\\){0,2}section{\\zs.\\{-}\\ze}')
  if string.match(line, '^\\section{') then
    string_part = '  ' .. string_part
  elseif string.match(line, '^\\subsection{') then
    string_part = '󱞁  ' .. string_part
  elseif string_part == '' then
    -- Begin environments
    string_part = string.match(line, '\\begin{\\zs.\\{-}\\ze}')
    if string.match(line, '\\begin{itemize') or string.match(line, '\\begin{enumerate') then
      string_part = '  ' .. string_part
    elseif string.match(line, '\\begin{table') then
      string_part = ' ' .. string_part
    elseif string.match(line, '\\begin{tocentry') then
      string_part = '  ' .. string_part
    elseif string.match(line, '\\begin{abstract') then
      string_part = '  ' .. string_part
    elseif string_part == '' then
      -- Documentclass and custom fold
      string_part = string.match(line, '^\\documentclass.*{\\zs.*\\ze}') .. string.match(line, '\\(%%\\){1,3}.*>>\\zs.*\\ze')
      if string.match(line, '^\\documentclass[') then
        string_part = '  ' .. string_part
      elseif string.match(line, '^%%* >> \\S') then
        local comment_count = string.len(string.match(line, '^\\v%%+'))
        string_part = string.rep(' ', comment_count) .. string.rep(' ', (3 - comment_count)) .. string_part
      end
    end
  end
  return string_part .. string.rep(' ', 45 - string.len(string_part)) .. ' (' .. folded_line_num .. ' L) ' .. string.rep(' ', 4 - string.len(folded_line_num))
end

-- >> VARIABLES
vim.api.nvim_create_autocmd({'BufReadPost', 'FileReadPost'}, {
  pattern = '*',
  command = 'normal zR'
})
-- vim.opt.nofoldenable = true
vim.opt.foldlevelstart = 0
vim.opt.foldnestmax = 10
vim.opt.foldmethod = 'expr'
vim.opt.foldcolumn = '1'
vim.opt.fillchars = 'fold:-'
vim.opt.foldexpr = 'v:lua.TexFolds(v:lnum)'
vim.opt.foldtext = 'v:lua.TexFoldText()'
