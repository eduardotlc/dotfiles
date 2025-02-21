vim.api.nvim_buf_create_user_command(0, 'Lint', function(opts)
  vim.cmd('compiler bibertool | lmake' .. (opts.bang and '!' or ''))
end, { bang = true })

vim.api.nvim_create_augroup('VimTeX', { clear = true })
vim.api.nvim_create_autocmd('BufWrite', {
  group = 'VimTeX',
  buffer = 0,
  command = 'compiler bibertool | lmake!'
})
