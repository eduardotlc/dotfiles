-- >> INITING


local o = vim.o
local vim = vim
local opt = vim.opt
local g = vim.g
local Plug = vim.fn["plug#"]



-- >> PLUGINS
vim.call("plug#begin", "/home/eduardotc/.local/share/nvim/plugged")

-- >>>> Color Shcemes plugins

-- >>>>>> Dependencies
Plug "rktjmp/lush.nvim"
Plug("akinsho/toggleterm.nvim", { ["tag"] = "*" })
Plug "typicode/bg.nvim"

-- >>>>>> Schemes
Plug "AlexvZyl/nordic.nvim"
Plug "Allianaab2m/penumbra.nvim"
Plug "amit-chaudhari1/karma.nvim"
Plug "antonk52/lake.nvim"
Plug "barrientosvctor/abyss.nvim"
Plug "b0o/lavi.nvim"
Plug "bluz71/vim-nightfly-colors"
Plug "catppuccin/nvim"
Plug("cesaralvarod/tokyogogh.nvim", { ["branch"] = "main" })
Plug "dgox16/oldworld.nvim"
Plug "echasnovski/mini.nvim"
Plug "EdenEast/nightfox.nvim"
Plug "Enonya/yuyuko.vim"
Plug "ellisonleao/glow.nvim"
Plug "fynnfluegge/monet.nvim"
Plug "jim-at-jibba/ariake.nvim"
Plug "JoosepAlviste/palenightfall.nvim"
Plug "joshdick/onedark.vim"
Plug "kabouzeid/nvim-jellybeans"
Plug "kaicataldo/material.vim"
Plug "kartikp10/noctis.nvim"
Plug "lfv89/norse.nvim"
Plug "mellow-theme/mellow.nvim"
Plug "miikanissi/modus-themes.nvim"
Plug "Mofiqul/dracula.nvim"
Plug "nyoom-engineering/nyoom.nvim"
Plug "olivercederborg/poimandres.nvim"
Plug "pineapplegiant/spaceduck"
Plug "rmehri01/onenord.nvim"
Plug "rockyzhang24/arctic.nvim"
Plug "scottmckendry/cyberdream.nvim"
Plug "shaunsingh/moonlight.nvim"
Plug "shaunsingh/nord.nvim"
Plug "shrikecode/kyotonight.vim"
Plug "tiagovla/tokyodark.nvim"
Plug "uloco/bluloco.nvim"
Plug "vermdeep/darcula_dark.nvim"
Plug "Yazeed1s/oh-lucy.nvim"
Plug "Yagua/nebulous.nvim"

-- >>>> Utilities
Plug "honza/vim-snippets"
Plug "ibhagwan/fzf-lua"
Plug("junegunn/fzf", { ["dir"] = "/home/eduardotc/.fzf", ["do"] = "./install --all" })
Plug "junegunn/vim-easy-align"
Plug "kana/vim-operator-user"
Plug("L3MON4D3/LuaSnip", { ["do"] = "make install_jsregexp" })
Plug "mhinz/vim-startify"
Plug "MeanderingProgrammer/markdown.nvim"
Plug "nvim-lualine/lualine.nvim"
Plug "arkav/lualine-lsp-progress"
Plug "nvim-lua/plenary.nvim"
Plug "nvim-tree/nvim-web-devicons"
Plug "psliwka/vim-smoothie"
Plug "Shougo/unite.vim"
Plug("Shougo/vimproc.vim", { ["do"] = "make" })
Plug "vijaymarupudi/nvim-fzf"
Plug "williamboman/mason.nvim"
Plug "williamboman/mason-lspconfig.nvim"

-- >>>> Nerdtree
Plug "preservim/nerdtree"
Plug "PhilRunninger/nerdtree-visual-selection"
Plug "ryanoasis/vim-devicons"
Plug "tiagofumo/vim-nerdtree-syntax-highlight"

-- >>>> Coding
Plug "NeogitOrg/neogit"
Plug "zbirenbaum/copilot.lua"
Plug("CopilotC-Nvim/CopilotChat.nvim", { ["branch"] = "main" })
Plug "kkharji/sqlite.lua"
Plug "luk400/vim-jukit"
Plug "preservim/nerdcommenter"

-- >>>> Telescope
Plug "adoyle-h/telescope-extension-maker.nvim"
Plug "axkirillov/easypick.nvim"
Plug "dawsers/telescope-firefox.nvim"
Plug "folke/noice.nvim"
Plug "MunifTanjim/nui.nvim"
Plug "rcarriga/nvim-notify"
Plug "nvim-telescope/telescope.nvim"
Plug "nvim-telescope/telescope-bibtex.nvim"
Plug "nvim-telescope/telescope-file-browser.nvim"
Plug("nvim-telescope/telescope-fzf-native.nvim",
  {
    ["do"] =
    "cmake -S . -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
  })
Plug "nvim-telescope/telescope-media-files.nvim"
Plug "nvim-telescope/telescope-ui-select.nvim"
Plug "nvim-lua/popup.nvim"
Plug "octarect/telescope-menu.nvim"
Plug "OliverChao/telescope-picker-list.nvim"
Plug "rafi/telescope-thesaurus.nvim"
Plug "smartpde/telescope-recent-files"
Plug "ThePrimeagen/harpoon"

-- >>>> Visualization
Plug("iamcco/markdown-preview.nvim", { ["do"] = "cd app && yarn install" })
Plug "lervag/vimtex"
Plug "rafaqz/citation.vim"

-- >>>> Configuration
Plug "folke/which-key.nvim"

-- >>>> LSP
Plug "aznhe21/actions-preview.nvim"
Plug "folke/trouble.nvim"
Plug "hrsh7th/cmp-buffer"
Plug "hrsh7th/cmp-calc"
Plug "hrsh7th/cmp-cmdline"
Plug "dmitmel/cmp-cmdline-history"
Plug "hrsh7th/cmp-nvim-lsp"
Plug "hrsh7th/cmp-nvim-lua"
Plug "hrsh7th/cmp-copilot"
Plug "jalvesaq/zotcite"
Plug "jalvesaq/cmp-zotcite"
Plug "hrsh7th/cmp-path"
Plug "prabirshrestha/vim-lsp"
Plug "dmitmel/cmp-vim-lsp"
Plug "JMarkin/cmp-diag-codes"
Plug "hrsh7th/nvim-cmp"
Plug "saadparwaiz1/cmp_luasnip"
Plug "lervag/cmp-vimtex"
Plug "linrongbin16/fzfx.nvim"
Plug "neovim/nvim-lspconfig"
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })
Plug "onsails/diaglist.nvim"
Plug "onsails/lspkind.nvim"
Plug "Shougo/deol.nvim"
Plug "b0o/schemastore.nvim"

-- >>>> Appearance
Plug "brenoprata10/nvim-highlight-colors"
Plug "bezhermoso/todos-lualine.nvim"
Plug "folke/todo-comments.nvim"
Plug "ntpeters/vim-better-whitespace"

vim.call("plug#end")


-- >> OPTS

-- >>>> General
opt.autochdir = true
opt.background = "dark"
opt.backupdir = "/home/eduardotc/Backup"

-- >>>> Title
opt.title = true
opt.titlestring = "nvim %{expand('%:t')}"
opt.titlelen = 0

-- >>>> Context
opt.colorcolumn = "100"
opt.number = true
opt.relativenumber = false
opt.termsync = true
opt.scrolloff = 4
opt.scrollback = 2500
opt.signcolumn = "yes"
opt.laststatus = 3
opt.completeopt = { "menu", "menuone", "noselect" }

-- >>>> Filetypes
opt.encoding = "utf8"
opt.fileencoding = "utf8"
opt.filetype = "ON"
opt.syntax = "ON"

-- >>>> Search
opt.ignorecase = true -- bool: Ignore case in search patterns
opt.smartcase = true  -- bool: Override ignorecase if search contains capitals
opt.incsearch = true  -- bool: Use incremental search
opt.hlsearch = true   -- bool: Highlight search matches

-- >>>> Whitespace
opt.shiftwidth = 4    -- num:  Size of an indent
opt.softtabstop = 4   -- num:  Number of spaces tabs count for in insert mode
opt.tabstop = 4       -- num:  Number of spaces tabs count for
opt.autoindent = false

-- >>>> Splits
opt.splitright = true -- bool: Place new window to right of current one
opt.splitbelow = true -- bool: Place new window below the current one

-- >>>> Folding
opt.foldminlines = 1
opt.foldenable = false
opt.foldmethod = "expr"
opt.foldlevelstart = 0
opt.foldnestmax = 10
opt.foldcolumn = "1"
opt.fillchars = { fold = " " }
opt.cursorline = true
opt.cursorlineopt = { "both" }


-- >> GLOBALS

-- >>>> Programming
g.loaded_ruby_provider = 1
--g.loaded_perl_provider = "/usr/bin/perl"
g.python3_host_prog = "/home/eduardotc/miniforge3/envs/nvim/bin/python"
g.markdown_folding = 0
g.markdown_fenced_languages = { "html", "python", "bash=sh" }
--g.python_highlight_all = 1
--vim.g.markdown_recommended_style = 0

-- >>>> General
---@type ("last" | "buffer" | "current" | string)
g.browsedir = "current"


-- >> PLUGIN SETTINGS

-- >>>> Webdev
g.webdevicons_enable_airline_statusline = 1
g.webdevicons_enable_airline_tabline = 1
g.webdevicons_enable_nerdtree = 1
g.webdevicons_enable = 1
g.mkdp_port = "8228"
g.mkdp_highlight_css = "/home/eduardotc/Documents/themes/markdown/highlight_du.css"
g.mkdp_markdown_css = "/home/eduardotc/Documents/themes/markdown/markdown_du.css"
g.webdevicons_enable_unite = 1
g.webdevicons_enable_startify = 1

-- >>>> Formatting
g.strip_whitespace_on_save = 1
g.better_whitespace_enabled = 1
g.html_font = "FiraCode Nerd Font Mono"
g.html_number_lines = 1

-- >>>> NERDTree | Comment
g.NERDTreeWinSize = 45
g.NERDTreeShowLineNumbers = 1
g.NERDTreeHighlightCursorline = 1
g.NERDTreeShowBookmarks = 0
g.NERDTreeMarkBookmarks = 1
g.NERDTreeRemoveDirCmd = "rm -rf "
g.NERDTreeSortOrder = {
  "main.tex",
  "\\.py$",
  "\\.tex$",
  "\\.zsh$",
  "\\.md$", "*", "[[timestamp]]" }
g.NERDTreeAutoDeleteBuffer = 0

-- >>>> Movement
g.smoothie_no_default_mappings = true

-- >> LSP

g.lsp_auto_enable = 1
g.lsp_diagnostics_enabled = 1
g.lsp_use_native_client = 1
g.lsp_diagnostic_highlights_enabled = 1
g.lsp_document_highlight_enabled = 1
g.lsp_preview_max_width = 60
g.lsp_peek_alignment = "bottom"
g.lsp_preview_max_height = 40
g.lsp_float_max_width = 60
g.lsp_float_max_height = 40
g.lsp_preview_height = 40
g.lsp_preview_width = 55
g.lsp_signature_help_enabled = 1
g.lsp_signature_help_delay = 100
g.lsp_document_highlight_delay = 200
g.lsp_document_code_action_signs_delay = 200
g.lsp_document_code_action_signs_enabled = 1
g.lsp_completion_documentation_enabled = 1
g.lsp_insert_text_enabled = 1
g.lsp_text_edit_enabled = 1
g.lsp_use_lua = 1
g.lsp_fold_enabled = 0
g.dictionary_api_key = "cc5ad200-706f-4467-b2d9-44bf3d1eb379"

print = require("notify")

-- >> CMP

g.cmp_menu = "markdown_inline"
g.cmp_docs = "markdown_inline"

-- >> REQUIREMENTS

--telescopeDu = require('telescopedu')
DuDesign = require("design")
KeyDu = require("keyall")
ServDu = require("servbuf")
DuMod = require("du")
DuStart = require("startify.startify_init")
require("telescopedu")
require("fzfx").setup()
require("cmp_snip")
require("fzf")
require("autocmd")

-- >> ENVIRONMENT

if type(vim.fn.getenv("NVIM_THEME")) == "string" then
  vim.api.nvim_command("silent! colorscheme " .. vim.fn.getenv("NVIM_THEME"))
  DuDesign.setup(string.format("%s", vim.fn.getenv("NVIM_THEME")))
else
  DuDesign.set_random_colorscheme()
end

vim.fn.setenv("PATH", "/home/eduardotc/miniforge3/envs/nvim/bin:" .. vim.fn.getenv("PATH"))
DuDesign.SetHighlight()
