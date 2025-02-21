vim.g.jukit_in_style = 1
vim.g.jukit_comment_mark = '"'
vim.g.jukit_shell_cmd = "ipython3"
vim.g.jukit_notebook_viewer = "jupyter-notebook"
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
if vim.bo.buftype == "nofile" then
  require("keyall").setup(vim.bo.buftype)
end
