local vim = vim


vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
  group = vim.api.nvim_create_augroup("KittySetVarVimEnter", { clear = true }),
  pattern = "*",
  once = true,
  callback = function()
    io.stdout:write("\x1b]1337;SetUserVar=in_editor=MQo\007")
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("KittySetVarVimLeave", { clear = true }),
  pattern = "*",
  once = true,
  callback = function()
    io.stdout:write("\x1b]1337;SetUserVar=in_editor\007")
  end,
})
--vim.api.nvim_command("silent! !kitten @ set-user-vars in_editor")
--vim.api.nvim_command("silent! !kitten @ load-config")
--vim.api.nvim_command("silent! !kitten @ set-user-vars in_editor=MQo")
