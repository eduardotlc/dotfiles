-- >> BASICS
vim.opt_local.spell = true
vim.opt.spelllang = "en_us"
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.fn.setenv("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json")
vim.g.vimtex_syntax_enabled = 1


-- >> TOC

vim.g.vimtex_toc_enabled = 1
vim.g.vimtex_toc_todo_labels = { TODO = { "TODO: ", "-TODO: "}, FIXME = {"FIXME: ", "-FIXME: "} }
vim.g.vimtex_toc_show_preamble = 1


-- >> COMPILER

vim.g.vimtex_compiler_enabled = 1
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
    aux_dir = "",
    out_dir = "",
    callback = 1,
    continuous = 0,
    executable = "latexmk",
    hooks = {},
    options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
    },
}


-- >> VIEW

vim.g.vimtex_view_method = "sioyek"
vim.g.vimtex_view_general_viewer = "sioyek"
vim.g.vimtex_view_sioyek_exe = "/home/eduardotc/.local/sioyek/build/sioyek"


-- >> CITATION

---@alias vim.g.vimtex_parser_bib_backend "bibtex" | "vim" | "lua" | "bibparse" | "bibtexparser"
vim.g.vimtex_parser_bib_backend = "lua"
vim.g.vimtex_complete_ref = {
  custom_patterns = { "\\figref\\*\\?{[^}]*$" }
}


-- >> CONCEAL

vim.g.tex_conceal = "abdmg"


-- >> COMPLETE

vim.g.vimtex_complete_cites = "smart"
vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_complete_ignore_case = 1
vim.g.vimtex_complete_close_braces = 0


-- >> FOLD

vim.g.vimtex_fold_enabled = 1
vim.g.vimtex_fold_levelmarker = "*"
vim.g.vimtex_fold_bib_enabled = 1
vim.g.vimtex_fold_manual = 1


-- >> QUICKFIX

vim.g.vimtex_quickfix_auToclose_after_keystrokes = 1
vim.g.vimtex_quickfix_enabled =  1
vim.g.vimtex_quickfix_method = "pplatex"


-- >> DELIMS

vim.g.vimtex_delim_list = {
  mods = {
    name = {
      {"\\left", "\\right"},
      {"\\mleft", "\\mright"},
      {"\\bigl", "\\bigr"},
      {"\\Bigl", "\\Bigr"},
      {"\\biggl", "\\biggr"},
      {"\\Biggl", "\\Biggr"},
      {"\\big", "\\big"},
      {"\\Big", "\\Big"},
      {"\\bigg", "\\bigg"},
      {"\\Bigg", "\\Bigg"},
    }
  }
}

vim.g.vimtex_delim_toggle_mod_list = {
  {"\\left", "\\right"},
  {"\\mleft", "\\mright"},
}

vim.api.nvim_set_keymap("i", "<C-a>", ":VimtexView<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-a>", ":VimtexView<CR>", { noremap = true, silent = true })


-- >> REFERENCES

--vim.g.vimtex_format_enabled = 1
--vim.g.vimtex_loaded_netrw = 1
--vim.g.vimtex_loaded_netrwPlugin = 1
