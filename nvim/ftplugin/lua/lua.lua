-- >> JUKIT

vim.g.jukit_comment_mark = "--"
vim.g.jukit_terminal = "kitty"
vim.g.jukit_shell_cmd = "ilua"


-- >> OPTS

vim.opt.shiftwidth = 2
vim.opt.expandtab = true

require("keyall").setup(vim.bo.filetype)

