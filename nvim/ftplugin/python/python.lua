-- >> IMPORTING

local vim = vim
local g = vim.g
local opt = vim.opt

--KeyDu = require("keyall")

-- >> JUKIT

g.jukit_shell_cmd = "ipython3 --init %load_ext copy_terminal_output_magic"
g.jukit_terminal = "kitty"
g.jukit_comment_mark = "#"
g.jukit_highlight_markers = 1
g.jukit_enable_textcell_bg_hl = 1
g.jukit_enable_textcell_syntax = 1
g.jukit_auto_output_hist = 0
g.jukit_savefig_dpi = 150
g.jukit_mpl_block = 1
g.jukit_use_tcomment = 0
g.jukit_inline_plotting = 1
g.jukit_max_size = 80
g.jukit_notebook_viewer = "jupyter-notebook"
g.jukit_venv_in_output_hist = 1
g.jukit_file_encodings = "utf-8"
g.jukit_convert_open_default = 1
g.jukit_custom_backend = "kitcat"
g.jukit_mpl_style = "/home/eduardotc/.local/share/nvim/plugged/vim-jukit/helpers/matplotlib-backend-kitty/backend.mplstyle"
g.jukit_venv_in_output_hist = 1
g.jukit_layout = {
  split = "horizontal",
  p1 = 0.65,
  val = {
    "file_content",
    {
      split = "vertical",
      p1 = 0.6,
      val = { "output", "output_history" }
    }
  }
}


-- >> OPTS

opt.expandtab = true
opt.smartindent = true
opt.smarttab = true
opt.autoindent = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.indentexpr = ""

--local ts_query = [[
  --(string (string_content) @docstring)
  --(parameters (identifier) @docstring.params)
  --(parameters (typed_parameter (identifier) @docstring.params))
  --(function_definition
    --return_type: (type) @docstring.returns)
--]]

--local ts_highlights = {
  --["docstring"] = "DocstringDescription",
  --["docstring.params"] = "DocstringParams",
  --["docstring.returns"] = "DocstringReturns",
--}


--local parser = vim.treesitter.get_parser(0, "python")
--local query = vim.treesitter.query.parse("python", ts_query)
--parser:for_each_tree(function(tstree)
  --local root = tstree:root()
  --for id, node, _ in query:iter_captures(root, 0) do
    --local hl = ts_highlights[query.captures[id]]
    --if hl then
      --vim.api.nvim_buf_add_highlight(0, -1, hl, node:start())
    --end
  --end
--end)

--vim.cmd[[
  --highlight DocstringSummary guifg=#FFD700 gui=bold
  --highlight DocstringParams guifg=#87D7FF gui=italic
  --highlight DocstringReturns guifg=#87FF87 gui=italic
  --highlight DocstringType guifg=#FFA07A gui=bold
  --highlight DocstringDescription guifg=#C0C0C0
--]]


require("keyall").setup(vim.bo.filetype)

-- >> REFERENCES

-- set smartindent
-- set syntax =python
-- set tabstop =4
-- set shiftwidth =4
-- set noautoindent
-- set tabstop=4
-- set smarttab
-- set shiftwidth=4
-- set softtabstop=4
-- set expandtab
-- set autoindent
-- let g:jukit_convert_overwrite_default = -1
-- let g:jukit_hl_ext_enabled = "/home/eduardotc/.config/nvim/highlights.scm"
-- let g:jukit_output_bg_color = get(g:, 'jukit_output_bg_color', '#712b5b')
-- let g:jukit_output_fg_color = get(g:, 'jukit_output_fg_color', '#d7f1ed')
-- let g:jukit_outhist_bg_color = get(g:, 'jukit_outhist_bg_color', '#6272A4')
-- let g:jukit_outhist_fg_color = get(g:, 'jukit_outhist_fg_color', '#FF79C6')
-- highlight jukit_textcell_bg_colors guibg=#35385d     guifg=#d1efed
-- highlight jukit_cellmarker_colors  guibg=#712b5b     guifg=#712b5b
-- highlight jukit_textcell_quotes    guibg=#5a1e31     guifg=#ebe663
-- highlight NotifyINFOBorder         guifg=#7e8bbc
-- highlight NotifyINFOTitle          guifg=#ebe663
-- highlight NotifyINFOIcon           guifg=#ebe663
