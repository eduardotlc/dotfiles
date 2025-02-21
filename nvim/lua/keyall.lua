-- >> INITIAL CONFIGS
local M = {}
local g = vim.g
local o = vim.o
TSU = require("nvim-treesitter.ts_utils")
local wk = require("which-key")


g.mapleader = " "
g.maplocalleader = ","

vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "kj", "<Esc>", { noremap = true, silent = true })

o.timeoutlen = 300

-- >> CONFIGS
wk.setup({
  ---@type false | "helix" | "classic" | "modern"
  preset = "modern",
  notify = true,
  delay = 400,
  filter = function(mapping)
    if mapping.icon ~= "" and mapping.desc ~= "" then
      return string.format("%s %s", mapping.icon, mapping.desc)
    elseif mapping.group ~= "" then
      return "AAAA"
    end
  end,
  plugins = {
    marks = true,     -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20,
    },
    presets = {
      motions = true,
      text_objects = true,
      windows = true, -- default bindings on <c-w>
      nav = true,
      z = true,       -- bindings for folds, spelling and others prefixed with z
      g = true,       -- bindings for prefixed with g
    },
  },
  icons = {
    breadcrumb = "󰄾 ", -- symbol used in the command line area that shows your active key combo
    separator = " ", -- symbol used between a key and it's label
    group = "󰌕 ", -- symbol prepended to a group
    keys = {
      Left = "󰌍 ",
    },
    colors = true,
  },
  layout = {
    height = { min = 4, max = 7 },  -- min and max height of the columns
    width = { min = 40, max = 40 }, -- min and max width of the columns
    col = 5,
    row = 40,
    spacing = 4,      -- spacing between columns
    align = "center", -- align columns left, center or right
    sort = {
      "local",
      "order",
      "group",
      "alphanum",
      "mod",
    },
    expand = 3,       -- expand groups when <= n mappings
  },
  replace = {
    key = {
      function(key)
        return require("which-key.view").format(key)
      end,
    },
    desc = {
      { "<Space>",          "SPC" },
      { "<Plug>%(?(.*)%)?", "%1" },
      { "^%+",              "" },
      { "<[cC]md>",         "" },
      { "<[cC][rR]>",       "" },
      { "<[sS]ilent>",      "" },
      { "^lua%s+",          "" },
      { "^call%s+",         "" },
      { "^:%s*",            "" },
    },
  },
  show_help = true, -- show a help message in the command line for using WhichKey
  show_keys = true, -- show the currently pressed key and its label as a message in the command line
  --triggers = "auto", -- automatically setup triggers
  --triggers = {"<leader>", "]", "[", "<localleader>", "z", "`", '"', "q", "@"},
  triggers = {
    { "<leader>",      mode = { "n", "v", "x" } },
    { "<localleader>", mode = { "n", "v" } },
    { "z",             mode = { "n", "o" } },
    { "g",             mode = { "n", "o" } },
    { "<C-?>",         mode = "nxsot" },
    { "@",             mode = "nxsot" },
    { "`",             mode = "nxsot" },
    { '"',             mode = "nxsot" },
    { "]",             mode = "nxsot" },
    { "[",             mode = "nxsot" },
  },
  colors = true,
  disable = {
    buftypes = {},
    filetypes = {},
  },
  debug = false,
  win = {
    no_overlap = true,
    width = { min = 105, max = 105 },
    height = { min = 10, max = 18 },
    col = 15,
    row = 40,
    border = "none",
    padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
    title = true,
    title_pos = "center",
    zindex = 100,
    bo = {},
    wo = {
      winblend = 20, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    },
  },
})


-- >> DELETING

vim.api.nvim_del_keymap("n", "gra")
vim.api.nvim_del_keymap("n", "grn")
vim.api.nvim_del_keymap("n", "grr")
vim.api.nvim_del_keymap("n", "gri")
vim.api.nvim_del_keymap("n", "gcc")

wk.add({
  { "<leader>dda",     hidden = true, remap = true },
  { "<leader>ddo",     hidden = true, remap = true },
  { "<leader>rpd",     hidden = true, remap = true },
  { "<leader>rht",     hidden = true, remap = true },
  { "<leader>pd",      hidden = true, remap = true },
  { "<leader>pos",     hidden = true, remap = true },
  { "<leader>os",      hidden = true, remap = true },
  { "<leader>od",      hidden = true, remap = true },
  { "<leader>ohs",     hidden = true, remap = true },
  { "<leader>ohd",     hidden = true, remap = true },
  { "<leader>s",       hidden = true, remap = true },
  { "<leader>j",       hidden = true, remap = true },
  { "<leader>J",       hidden = true, remap = true },
  { "<leader><space>", hidden = true, remap = true },
  { "<leader>k",       hidden = true, remap = true },
  { "<leader>K",       hidden = true, remap = true },
})


-- >> FUNCTIONS

-- Operator command function
function ExecuteBufferCommandWithCount(command)
  -- Retrieve the count provided before the command, defaulting to 1 if none
  local count = vim.v.count > 0 and vim.v.count or 1
  local isDirectCmd = count > 1 and
      count <=
      vim.fn.bufnr("$") -- Change condition based on your use case

  if isDirectCmd then
    -- If count is within the buffer range, interpret it as a buffer number to jump to
    vim.cmd(count .. command)
  else
    -- Otherwise, execute the provided command 'count' times
    for _ = 1, count do
      vim.cmd(command)
    end
  end
end

-- >> LOCAL LEADER

-- >>>> Plug
wk.add({
  {
    "<localleader>P",
    mode = "n",
    group = "Plug",
    remap = false,
    noremap = true,
  },
  { "<localleader>Pi", "<cmd> PlugInstall<CR>", desc = "Install" },
  { "<localleader>Pu", "<cmd> PlugUpdate<CR>",  desc = "Update" },
  { "<localleader>Pc", "<cmd> PlugClean<CR>",   desc = "Clean" },
  { "<localleader>Ph", "<cmd> checkhealth<CR>", desc = "Health" },

  -- >>>> Movement
  {
    "<localleader>]",
    "<cmd> lua TSU.goto_node(TSU.get_next_node(TSU.get_node_at_cursor()))<CR>",
    mode = { "n", "o" },
    noremap = true,
    silent = true,
    desc = "TS Next Node",
  },
  {
    "<localleader>[",
    "<cmd> lua TSU.goto_node(TSU.get_previous_node(TSU.get_node_at_cursor()))<CR>",
    mode = { "n", "o" },
    noremap = true,
    silent = true,
    desc = "TS Prev Node",
  },

  -- >>>> Toggle
  {
    "<localleader>s",
    "<cmd> lua DuMod.toggle_statusline()<CR>",
    desc = "Toggle Statusline",
  },
  {
    mode = { "n" },
    "<localleader>Z",
    "<cmd>ToggleSignCol<CR>",
    desc = "Toggle sign column",
    noremap = true,
  },

})


-- >> BASIC REMAPING

wk.add({
  mode = "n",

  -- >>>> Ai
  {
    "<leader>a",
    group = "AI",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "green" },
    mode = { "n", "v" },
    { "<leader>Ac", "<cmd> CopilotChatOpen<CR>",    desc = "Copilot Chat Open" },
    { "<leader>Ae", "<cmd> CopilotChatExplain<CR>", desc = "Copilot Explain" },
    { "<leader>Af", "<cmd> CopilotChatFix<CR>",     desc = "Copilot Fix" },
  },

  -- >>>> Anki
  {
    "<leader>A",
    group = "Anki",
    noremap = true,
    silent = true,
    icon = { icon = "󰘸 ", color = "purple" },
    { "<leader>aa", "<cmd> call AnkimyCreateNotes()<CR>",  desc = "Create Notes" },
    { "<leader>aA", "<cmd> !apy add-from-file %<CR>",      desc = "Add Current File To Anki" },
    { "<leader>ai", "<cmd> call AnkimyPrepareImage()<CR>", desc = "Prepare Image" },
    { "<leader>aI", "<cmd> call AnkimyViewImage()<CR>",    desc = "View Image" },
    { "<leader>ay", "<cmd> !apy<CR>",                      desc = "Apy" },
  },

  -- >>>> Buffers
  {
    "<leader>B",
    "<cmd> lua DuMod.jump_to_buffer()<CR>",
    desc = "Buffer Jump",
    noremap = true,
    silent = true,
  },
  {
    "<leader><C-space>",
    group = "buffers",
    expand = function()
      return require("which-key.extras").expand.buf()
    end,
  },
  {
    "<leader>b",
    "<cmd> lua require('which-key').show({keys = '<leader>ZZ', loop = true})<CR>",
    desc = "Hydra Buffers",
  },

  -- >>>> Code Formatting
  {
    "<leader>c",
    group = "Code Formatting",
    noremap = true,
    silent = true,
    icon = { icon = "󰚔 ", color = "orange" },
    mode = { "n", "v", "o" },
  },
  {
    "<leader>c<Space>",
    "<cmd> call nerdcommenter#Comment('y', 'toggle')<CR>",
    desc = "NerdCommenter",
  },
  { "<leader>cd", "<cmd> GenerateDocstring<CR>",                desc = "Numpy Docstrings" },
  { "<leader>cf", "<cmd> lua DuMod.format_folding_lines()<CR>", desc = "Folding Lines" },
  {
    "<leader>cg",
    '<cmd> lua require("cmp_vimtex.search").perform_search({ engine = "google_scholar", })<CR>',
    desc = "Vimtex Search Scholar",
  },
  { "<leader>cr", "<cmd> CopilotChatReview<CR>", desc = "Copilot Review" },
  { "<leader>cs", "<cmd> CmpStatus<CR>",         desc = "Cmp Status" },
  {
    "<leader>cv",
    '<cmd> lua require("cmp_vimtex.search").search_menu()<CR>',
    desc = "Vimtex Cmp Menu",
  },

  -- >>>> Dbee
  {
    "<leader>D",
    group = "Dbee",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "yellow" },
  },
  { "<leader>D<Space>", '<cmd> lua require("dbee").toggle()<CR>',                   desc = "Toggle" },
  { "<leader>DJ",       '<cmd> lua require("dbee").api.ui.result_page_last()<CR>',  desc = "Last Page" },
  { "<leader>DK",       '<cmd> lua require("dbee").api.ui.result_page_first()<CR>', desc = "First Page" },
  { "<leader>Dd",       '<cmd> lua require("dbee").api.ui.drawer_show()<CR>',       desc = "Drawer Show" },
  { "<leader>De",       '<cmd> lua require("dbee").api.ui.editor_show()<CR>',       desc = "Editor Show" },
  { "<leader>Dj",       '<cmd> lua require("dbee").api.ui.result_page_next()<CR>',  desc = "Next Page" },
  { "<leader>Dk",       '<cmd> lua require("dbee").api.ui.result_page_prev()<CR>',  desc = "Prev Page" },
  { "<leader>Do",       '<cmd> lua require("dbee").open()<CR>',                     desc = "Open" },
  { "<leader>Dq",       '<cmd> lua require("dbee").execute(query)<CR>',             desc = "Query" },
  {
    "<leader>Dr",
    '<cmd> lua require("dbee").api.ui.result_page_current()<CR>',
    desc = "Result Page",
  },
  { "<leader>Du", '<cmd> lua require("dbee").api.ui.result_show()<CR>', desc = "Result Show" },
  { "<leader>Dx", '<cmd> lua require("dbee").close()<CR>',              desc = "Close" },

  -- >>>> Telescope
  {
    "<leader>f",
    group = "Telescope",
    noremap = true,
    silent = true,
    icon = { icon = "󰭎 ", color = "blue" },
  },
  { "<leader>fa", "<cmd> Telescope live_grep<CR>", desc = "Live Grep", icon = " " },
  { "<leader>fb", "<cmd> Telescope file<CR>", desc = "File", icon = " " },
  { "<leader>fc", [[<cmd> lua vim.api.nvim_command(string.format("TodoTelescope cwd=%s", vim.fn.expand("%:p:h")))<CR>]], desc = "Todo Comments", icon = " " },
  { "<leader>fB", "<cmd> Telescope buffers<CR>", desc = "Buffers", icon = " " },
  { "<leader>fd", "<cmd> lua DuMod.fzf_kitty_choose()<CR>", desc = "FZF Kitty Choices" },
  { "<leader>ff", "<cmd> lua ServDu.duTelescope()<CR>", desc = "Telescope Complete" },
  { "<leader>fF", "<cmd> Telescope find_files theme=dropdown<CR>", desc = "Find Files" },
  { "<leader>fh", "<cmd> Telescope marks<CR>", desc = "Marks", icon = "󰸱 " },
  { "<leader>fy", "<cmd> PyTelescope<CR>", desc = "Python Browse", icon = { icon = " ", color = "yellow" } },
  { "<leader>fm", "<cmd> MdTelescope<CR>", desc = "Notes Browse", icon = " " },
  { "<leader>fn", "<cmd> Telescope noice<CR>", desc = "Noice" },
  { "<leader>fo", "<cmd> Telescope<CR>", desc = "Telescope" },
  { "<leader>fp", "<cmd> Telescope papis<CR>", desc = "Papis" },
  { "<leader>fq", "<cmd> lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = "Harpoon Quick Menu" },
  { "<leader>fs", "<cmd> Telescope thesaurus lookup<CR>", desc = "Thesaurus Synonims", icon = "󰬴 " },
  { "<leader>ft", "<cmd> TodoTelescope<CR>", desc = "Todo", icon = " " },
  { "<leader>fT", "<cmd> TodoTrouble<CR>", desc = "Todo Trouble", icon = " " },

  -- >>>> Grammar
  {
    "<leader>g",
    group = "Grammar",
    noremap = true,
    silent = true,
    icon = "📖",
  },
  {
    "<leader>gi",
    "<cmd> lua DuMod.trans_interactive('pt-BR')<CR>",
    desc = "Br Interactive Translation",
  },
  {
    "<leader>gI",
    "<cmd> lua DuMod.trans_interactive('en')<CR>",
    desc = "En Interactive Translation",
  },

  -- >>>> Highlights/Marks
  {
    "<leader>h",
    group = "Highlights/Marks ",
    noremap = true,
    silent = true,
    icon = { icon = "󰸱 ", color = "yellow" },
  },
  { "<leader>h+", "<cmd> lua require('harpoon.mark').add_file()<CR>", desc = "Harpoon add file", icon = { icon = "󰛢", color = "cyan" } },
  { "<leader>ho", "<cmd> lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = "Harpoon quick menu", icon = { icon = "󰛢", color = "cyan" } },
  { "<leader>hj", "<cmd> lua require('harpoon.ui').nav_next()<CR>", desc = "next mark harpoon", icon = { icon = "󰵵 ", color = "blue" } },
  { "<leader>hk", "<cmd> lua require('harpoon.ui').nav_prev()<CR>", desc = "prev mark harpoon", icon = { icon = "󰁭 ", color = "orange" } },
  { "<leader>h<Space>", "<cmd> lua DuMod.quick_checkpoint_mark()<CR>", desc = "Checkpoint Mark", icon = { icon = "󰙒 ", color = "purple" } },
  { "<leader>hD", "<cmd> delm!<CR>", desc = "Delete all lower-case marks", icon = { icon = " ", color = "red" } },
  { "<leader>hd", "<cmd> lua DuMod.delete_mark()<CR>", desc = "Input delete mark", icon = { icon = " ", color = "red" } },
  { "<leader>hh", "<cmd> lua DuMod.input_mark()<CR>", desc = "Input Mark", icon = { icon = "󰄾 ", color = "yellow" } },
  { "<leader>hl", "<cmd> MarksLocal<CR>", desc = "Show local marks", icon = { icon = "󰱼 ", color = "green" } },
  { "<leader>hm", "<cmd> Telescope marks<CR>", desc = "Telescope marks", icon = { icon = "󰭎 ", color = "blue" } },
  { "<leader>h/", "<cmd> nohlsearch<CR>", desc = "Cancel search", icon = { icon = " ", color = "red" } },

  -- >>>> Startify
  { "<leader>H", "<cmd> Startify<CR>", desc = "Startify Home", remap = false, icon = { icon = " ", color = "blue" } },

  -- >>>> Html
  {
    "<leader>i",
    group = "HTML ",
    noremap = true,
    silent = true,
    icon = { icon = "󰖟 ", color = "blue" },
  },
  { "<leader>ia", "<cmd>!ckb-next -m Dracula<CR>",             desc = "CKB test" },
  {
    "<leader>ic",
    '<Cmd> lua require("cmp").complete({ config = { sources = { { name = "buffer" } } } })<CR>',
    desc = "cmp test",
  },
  { "<leader>ii", "<cmd> lua DuMod.serve_and_open_html()<cr>", desc = "Start Server and Open" },

  -- >>>> Line Formatting
  {
    "<leader>L",
    group = "Line Formatting",
    noremap = true,
    silent = true,
    icon = { icon = "󰚔 ", color = "orange" },
  },
  { "<leader>LL", "<cmd> s/\\(.\\{120\\}\\)/\\1\\r/g<CR>", desc = "Separate line in 120 chars" },
  { "<leader>L[", "<cmd> m -2<CR>", desc = "Move Current Line Up  " },
  { "<leader>L]", "<cmd> m +1<CR>", desc = "Move Current Line Down  " },
  { "<leader>Ll", "<cmd> s/\\(.\\{79\\}\\)/\\1\\r/g<CR>", desc = "Separate line in 79 chars" },

  -- >>>> Markdown
  {
    "<leader>m",
    group = "Markdown",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "blue" },
  },
  { "<leader>m<leader>", "<cmd> PrintPythonCodeBlock<CR>",                      desc = "Exec Py Code Block" },
  { "<leader>m+",        "<cmd> lua require('render-markdown').expand()<CR>",   desc = "Increase anti-conceal margin" },
  { "<leader>m-",        "<cmd> lua require('render-markdown').contract()<CR>", desc = "Decrease anti-conceal margin" },
  {
    "<localleader>C",
    "<cmd> lua DuMod.comment_markdown_code_block()<CR>",
    desc = "Comment md code block",
    icon = { icon = "󰉶 ", color = "orange" },
    mode = { "n", "v" },
  },
  {
    "<localleader>J",
    "<cmd> CommentMdBlock<CR>",
    desc = "Comment md code block",
    icon = { icon = "󰉶 ", color = "orange" },
    mode = { "n", "v" },
  },
  {
    "<leader>ma",
    "<cmd> lua DuMod.create_notebook_note('/home/eduardotc/Notes')<CR>",
    desc = "Add Note",
    icon = { icon = " ", color = "green" },
  },
  { "<leader>mb", "<cmd> NERDTree /home/eduardotc/Notes<CR>", desc = "Notes Folder", icon = " " },
  { "<leader>md", "<cmd> lua DuMod.daily_note()<CR>", desc = "Daily Note", icon = "󰬤 " },
  {
    "<leader>mD",
    "<cmd> NERDTree /home/eduardotc/Notes/daily<CR>",
    desc = "Dated Notes",
    icon = "󰢧 ",
  },
  {
    "<leader>me",
    "<cmd> lua DuMod.markdown_choose('/home/eduardotc/Notes')<CR>",
    desc = "Edit Note",
    icon = "󱞁 ",
  },
  {
    "<leader>mg",
    "<cmd> lua DuMod.glow_choose('/home/eduardotc/Notes')<CR>",
    desc = "Glow Choose",
    icon = { icon = "󰬎 ", color = "yellow" },
  },
  { "<leader>mG", "<cmd> lua DuMod.glow_input()<CR>", desc = "Glow Input", icon = "󰬎 " },
  { "<leader>mm", "<cmd> MarkdownPreview<CR>", desc = "Preview" },
  { "<leader>mM", "<cmd> Glow %<CR>", desc = "Glow current file" },
  {
    "<leader>mn",
    "<cmd> lua DuMod.markdown_notebooks('/home/eduardotc/Notes')<CR>",
    desc = "Notebooks",
    icon = { icon = "󰠮 ", color = "orange" },
  },
  { "<leader>mo", "<cmd> JukitOut conda activate<CR>", desc = "Ipython Preview" },
  {
    "<leader>mp",
    "<cmd> lua DuMod.markdown_notebooks('/home/eduardotc/.local/share/nvim/plugged')<CR>",
    desc = "Plugins READMES",
  },
  { "<leader>mr", "<cmd> lua require('render-markdown').toggle() <CR>", desc = "Toggle Render" },
  { "<leader>my", "<cmd> lua DuMod.yesterday_note()<CR>", desc = " Yesterday Note", icon = "󰬥 " },

  --{ "<leader>M", "<cmd> messages<CR>", desc = "Messages", remap = false, icon = { icon = " ", color = "green" } },

  {
    "<leader>M",
    group = "Macros",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "green" },
  },
  { "<leader>M<leader>", "<cmd> RecordMacro<CR>",                desc = "Record Macro" },

  -- >>>> New
  {
    "<leader>n",
    group = "New Instances",
    remap = false,
    icon = { icon = " ", color = "green" },
  },
  { "<leader>nb",        [[<cmd> enew<CR><cmd> Startify<CR>]],   desc = "new buffer" },
  { "<leader>nt",        [[<cmd> tabnew<CR><cmd> Startify<CR>]], desc = "new tab" },

  -- >>>> Noice
  {
    "<leader>N",
    group = "Noice",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "blue" },
  },
  { "<leader>NN", "<cmd> Notifications<CR>", desc = "Notifications", icon = " " },
  {
    "<leader>Nx",
    "<cmd> lua require('notify').dismiss({ silent = true, pending = true })",
    desc = "Dismiss Notification",
    icon = " ",
  },
  { "<leader>Ne", "<cmd> NoiceErrors<CR>", desc = "Errors", icon = " " },
  { "<leader>Nh", "<cmd> NoiceHistory<CR>", desc = "History", icon = " " },
  { "<leader>Nl", "<cmd> NoiceLast<CR>", desc = "Last" },
  { "<leader>Nn", "<cmd> Noice", desc = "Noice<CR>" },
  { "<leader>Nt", "<cmd> NoiceTelescope<CR>", desc = "Telescope", icon = "󰭎 " },
  {
    "<leader>Nf",
    "<cmd> windo 1<CR>",
    group = "Noice",
    desc = "Focus Message (Change win)",
    noremap = true,
    silent = true,
    icon = { icon = " ", color = "green" },
    mode = { "n" },
  },

  -- >>>> Fzf
  {
    "<leader>R",
    group = "FZF",
    remap = false,
    icon = { icon = " ", color = "purple" },
  },
  {
    "<leader>R<Space>",
    "<cmd> FZF<CR>",
    desc = "FZF",
  },
  {
    "<leader>Rt",
    "<cmd> lua DuDesign.set_config()<CR>",
    desc = "Color Schemes Managing Widget",
    icon = { icon = " ", color = "green" },
  },

  -- >>>> Lsp
  {
    "<leader>l",
    group = "LSP",
    noremap = true,
    icon = { icon = " ", color = "yellow" },
    silent = true,
    mode = { "n", "v" },
  },
  { "<leader>la", "<cmd> lua DuMod.ToggleLspCli('harper_ls')<CR>", desc = "Harper-Ls Toggle", icon = { icon = "󰗊 ", color = "red" } },
  { "<leader>lD", "<cmd>ToggleDiagnostics<CR>", desc = "Toggle Diagnostics" },
  { "<leader>lt", "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>", desc = "Toggle Diagnostic" },
  { "<leader>lq", "<cmd>Trouble qflist toggle focus=false filter.buf=0<cr>", desc = "Qflist Toggle" },
  { "<leader>ll", "<cmd>Trouble loclist toggle focus=false filter.buf=0<cr>", desc = "Loclist Toggle" },
  { "<leader>lg", "<cmd>Trouble lsp toggle filter.buf=0 focus=false win.position=right<cr>", desc = "Definitions + Refs" },
  { "<leader>lG", "<cmd>Trouble symbols toggle filter.buf=0 focus=false<cr>", desc = "Symbols" },
  { "<leader>lH", "<cmd>Trouble symbols toggle pinned=true win.relative=win win.position=right", desc = "Toggle Document Symbols Sync" },
  {
    "<leader>lf",
    "<cmd> lua vim.lsp.buf.format({ async = true, formatting_options = {insertSpaces = true, trimTrailingWhitespace = true, } })<CR>",
    desc = "Format",
    icon = { icon = "󰝔", color = "orange" },
  },
  { "<leader>li", "<cmd> LspInfo<CR>", desc = "Info", icon = " " },
  {
    "<leader>lL",
    "<cmd> lua require('luasnip.loaders').reload_file('/home/eduardotc/.config/nvim/lua/snippets')<CR>",
    desc = "Reload LuaSnips",
    icon = "",
  },
  { "<leader>lo", "<cmd> lua vim.diagnostic.open_float()<CR>", desc = "Diagnostics Float" },
  { "<leader>lr", "<cmd> lua vim.lsp.buf.rename()<CR>", desc = "Rename Buffer" },
  { "<leader>ls", "<cmd> LspStart<CR>", desc = "Start", icon = " " },
  { "<leader>lS", "<cmd> lua vim.lsp.buf.signature_help()<CR>", desc = "Signature", icon = " " },
  { "<leader>lw", "<cmd>lua require('luasnip.extras.otf').on_the_fly(\"w\")<cr>", desc = "otf", mode = { "v", "x", "s", "o" } },
  { "<leader>lx", "<cmd> LspStop<CR>", desc = "Stop", icon = " " },

  -- >>>> Sessions
  {
    "<leader>S",
    group = "Sessions",
    remap = false,
    icon = { icon = " ", color = "cyan" },
  },
  { "<leader>S<Space>", "<cmd> Sessions<CR>",                                desc = "FZF Sessions", remap = false },
  { "<leader>Sd",       "<cmd> DeleteSession<CR>",                           desc = "Delete",       remap = false },
  { "<leader>So",       "<cmd> OpenSession<CR>",                             desc = "Open",         remap = false },
  { "<leader>Sl",       "<cmd> SList<CR>",                                   desc = "List",         remap = false },
  { "<leader>Ss",       "<cmd> SSave<CR>",                                   desc = "Save",         remap = false },
  { "<leader>Sx",       [[<cmd>SClose<CR><cmd>q<CR>]],                       desc = "Close",        remap = false },
  { "<leader>SX",       [[<cmd>SClose<CR><cmd>CloseBuffer<CR><cmd>qa!<CR>]], desc = "Force Close",  remap = false },

  -- >>>> Tabs
  {
    "<leader>t",
    group = "Tabs",
    remap = false,
    icon = { icon = " ", color = "purple" },
  },
  { "<leader>tr", "<cmd> ReopenLastFile<CR>",          desc = "Reopen Closed Buffer)" },
  { "<leader>tn", "<cmd>  lua DuMod.RenameTab()<CR>",  desc = "Rename Tab" },
  { "<leader>T",  "<cmd> lua DuMod.jump_to_tab()<CR>", desc = "Change Tab With Letters" },

  -- >>>> Windows
  {
    "<leader>w",
    group = "Windows",
    remap = false,
    icon = { icon = " ", color = "purple" },
  },
  { "<leader>w+", "<cmd> resize +10<CR>",                   desc = "Resize +10" },
  { "<leader>w-", "<cmd> resize -10<CR>",                   desc = "Resize -10" },
  { "<leader>wh", "<cmd> lua DuMod.split_horizontal()<CR>", desc = "Split Horizontally" },
  { "<leader>wv", "<cmd> lua DuMod.split_vertical()<CR>",   desc = "Split Vertically" },
  {
    "<leader>w<leader>",
    "<cmd> lua require('which-key').show({keys = '<leader>ZW', loop = true})<CR>",
    desc = "Hydra Windows",
  },

  -- >>>> Close
  {
    "<leader>x",
    group = "Close",
    remap = false,
    icon = { icon = " ", color = "red" },
  },
  { "<leader>xa", "<cmd> q! <cr>",                           desc = "close all" },
  { "<leader>xb", "<cmd> StoreCurrentFile<CR><cmd> bw <CR>", desc = "Close Buffer" },
  { "<leader>xd", "<cmd> bdelete <cr>",                      desc = "close buffer" },
  { "<leader>xt", "<cmd> tabclose <cr>",                     desc = "close tab" },
  { "<leader>xx", "<cmd> CloseBuffer <CR>",                  desc = "Close Buffer" },

  -- >>>> Yank
  {
    "<leader>y",
    group = "Yank",
    remap = false,
    icon = { icon = " ", color = "yellow" },
  },
  { "<leader>yf", "<cmd> CopyFile <CR>",     desc = "Copy file content" },
  { "<leader>yp", "<cmd> CopyFilePath <CR>", desc = "Copy current file path" },
})


-- >>>> Visual
wk.add({
  mode = { "v" },
  remap = false,
  {
    "<leader>L",
    group = "Line Formatting",
  },
  { "<leader>LL", "<cmd> s/\\(.\\{120\\}\\)/\\1\\r/g<CR>", desc = "Separate line in 120 chars" },
  { "<leader>L[", "<cmd> m -2<CR>",                        desc = "Move Current Line Up" },
  { "<leader>L]", "<cmd> m +1<CR>",                        desc = "Move Current Line Down" },
  { "<leader>Ll", "<cmd> s/\\(.\\{79\\}\\)/\\1\\r/g<CR>",  desc = "Separate line in 79 chars" },

  { "<leader>p",  '"*p<CR>',                               desc = "Yank *" },

  {
    "<leader>v",
    group = "Visual line commands",
    icon = " ",
  },
  { "<leader>va", "<cmd> lua DuMod.AppendSelectionToRegister()<CR>", desc = "Append to Buffer +" },
  { "<leader>vp", "<cmd> lua DuMod.PasteTmp()<CR>",                  desc = "Paste Clear Temporary Yank" },
  { "<leader>vy", "<cmd> lua DuMod.CopyTmp()<CR>",                   desc = "Temporary Yank" },
  { "<leader>vc", "<cmd> lua DuMod.CleanSelectionToRegister()<CR>",  desc = "Clean Buffer +" },
  { "<leader>y",  '"*y<CR>',                                         desc = "Yank *" },
})


-- >> NO LEADER KEYS

wk.add({
  mode = { "n" },
  noremap = true,
  silent = true,

  -- >>>> Backward
  {
    "[",
    group = "Backward Movement",
    icon = "󰁭 ",
    noremap = true,
    silent = true,
    mode = { "n", "o" },
  },
  { "[b", '<cmd> lua ExecuteBufferCommandWithCount("bp")<CR>',          desc = "Previous Buffer" },
  { "[B", "<cmd> 0bp<CR>",                                              desc = "First Buffer" },
  { "[c", '<cmd> lua require("todo-comments").jump_prev()<CR>',         desc = "Previous Todo Comment" },
  { "[d", "<cmd> lua vim.diagnostic.goto_prev()<CR>",                   desc = "Previous Diagnostic" },
  { "[h", "<cmd> lua require('harpoon.ui').nav_prev()<CR>",             desc = "Harpoon Prev" },
  { "[t", '<cmd> lua ExecuteBufferCommandWithCount("tabprevious")<CR>', desc = "Previous Tab" },
  { "[T", "<cmd> 0tabprevious<CR>",                                     desc = "First Tab" },
  {
    "[[",
    "<cmd> lua TSU.goto_node(TSU.get_previous_node(TSU.get_node_at_cursor()))<CR>",
    desc = "Treesitter Previous Node",
    remap = true
  },
  {
    "[G",
    "<cmd> lua TSU.goto_node(TSU.get_previous_node(TSU.get_node_at_cursor()))<CR>",
    desc = "Treesitter Previous node"
  },

  -- >>>> Forward
  {
    "]",
    group = "Forward Movement",
    icon = "󰵵	",
    noremap = true,
    silent = true,
    mode = { "n", "o" },
  },
  { "]b", '<cmd> lua ExecuteBufferCommandWithCount("bn")<CR>',       desc = "Next Buffer" },
  { "]B", "<cmd> $bn<CR>",                                           desc = "Last Buffer" },
  { "]c", '<cmd> lua require("todo-comments").jump_next()<CR>',      desc = "Next Todo Comment" },
  { "]d", "<cmd> lua vim.diagnostic.goto_next()<CR>",                desc = "Next Diagnostic" },
  { "]h", "<cmd> lua require('harpoon.ui').nav_next()<CR>",          desc = "Harpoon Next" },
  { "]t", '<cmd> lua ExecuteBufferCommandWithCount("+tabnext")<CR>', desc = "Next Tab" },
  { "]T", "<cmd> $tabnext<CR>",                                      desc = "Last Tab" },
  {
    "]]",
    "<cmd> lua TSU.goto_node(TSU.get_next_node(TSU.get_node_at_cursor()))<CR>",
    desc = "Treesitter Next Node",
    remap = true
  },
  {
    "]G",
    "<cmd> lua TSU.goto_node(TSU.get_next_node(TSU.get_node_at_cursor()))<CR>",
    desc = "Treesitter Next Node"
  },

  -- >>>> Folding
  {
    "z",
    group = "Folding",
    icon = " ",
    noremap = true,
    silent = true,
    mode = { "n", "o" },
  },
  { "zG",       "<cmd> GoToEndFoldGroup<CR>",          desc = "End Of Current Folding Block" },
  { "zJ",       "<cmd> GoToNextFoldSameLevel<CR>",     desc = "Next Folding With Same Level" },
  { "zK",       "<cmd> GoToPreviousFoldSameLevel<CR>", desc = "Previous Folding With Same Level" },
  { "zT",       "zg<CR>",                              desc = "Add word to spell list" },
  { "zg",       "<cmd> GoToStartFoldGroup<CR>",        desc = "Start Of Current Folding Block" },
  { "ze",       "<cmd> call smoothie#do('ze')<CR>",    desc = "Right This Line" },
  { "zs",       "<cmd> call smoothie#do('zs')<CR>",    desc = "Left This Line" },
  { "zz",       "<cmd> call smoothie#do('zz')<CR>",    desc = "Center This Line" },
  { "zt",       "<cmd> call smoothie#do('zt')<CR>",    desc = "Top This Line" },
  { "zb",       "<cmd> call smoothie#do('zb')<CR>",    desc = "Bottom This Line" },
  { "z+",       "<cmd> call smoothie#do('z+')<CR>",    desc = "z+" },
  { "z-",       "<cmd> call smoothie#do('z-')<CR>",    desc = "z-" },
  { "z^",       "<cmd> call smoothie#do('z^')<CR>",    desc = "z^" },
  { "z.",       "<cmd> call smoothie#do('z.')<CR>",    desc = "z." },
  { "z0",       "<cmd> set foldlevel=0<CR>",           desc = "0 Fold level" },
  { "z1",       "<cmd> set foldlevel=1<CR>",           desc = "1 Fold level" },
  { "z2",       "<cmd> set foldlevel=2<CR>",           desc = "2 Fold level" },
  { "z3",       "<cmd> set foldlevel=3<CR>",           desc = "3 Fold level" },
  { "z<space>", "<cmd> ToggleFold<CR>",                desc = "Toggle fold" },

  -- >>>> Delete
  {
    "d",
    group = "Delete",
    icon = " ",
    noremap = true,
    silent = true,
    hidden = true,
    mode = { "n", "o" },
  },
  { "dd",     "dd",                                               desc = "Delete Line" },
  { "db",     "db",                                               desc = "Delete Back Word" },
  { "dw",     "dw",                                               desc = "Delete Forward Word" },
  { "d<A-l>", "<cmd> lua vim.api.nvim_command('normal! d$')<CR>", desc = "Delete Till End Line" },
  { "d<A-h>", "<cmd> lua vim.api.nvim_command('normal! d0')<CR>", desc = "Delete Till Start Line" },

  -- >>>> Go
  {
    "g",
    group = "Go",
    icon = "󰄾 ",
    noremap = true,
    silent = true,
    mode = { "n", "o" },
  },
  { "gd",          "<cmd> lua vim.lsp.buf.definition()<CR>",     desc = "GoTo Definition" },
  { "gD",          "<cmd> lua vim.lsp.buf.declaration()<CR>",    desc = "GoTo Declaration" },
  { "gi",          "<cmd> lua vim.lsp.buf.implementation()<CR>", desc = "Implementation" },
  { "gr",          "<cmd> lua vim.lsp.buf.references()<CR>",     desc = "GoTo Reference" },

  -- >>>> Plugins
  { "o",           "<cmd> NERDTree <CR>",                        desc = "NERDTree",        hidden = true },
  { "<A-Space>",   "<cmd> Telescope<CR>",                        desc = "Telescope",       hidden = true },
  { "<A-S-Space>", "<cmd> FzfLua<CR>",                           desc = "FZF Lua",         hidden = true },
  {
    "<C-D>",
    '<cmd> call smoothie#do("\\<C-D>")<CR>',
    desc = "Scroll down",
    hidden = true,
    mode = { "n", "i", "v", "c", },
  },
  {
    "<C-U>",
    '<cmd> call smoothie#do("\\<C-U>")<CR>',
    desc = "Scroll up",
    hidden = true,
    mode = { "n", "i", "v", "c", },
  },
  {
    "<C-F>",
    '<cmd> call smoothie#do("\\<C-F>")<CR>',
    desc = "Scroll Down",
    hidden = true,
    mode = { "n", "i", "v", "c", },
  },
  {
    "<C-B>",
    '<cmd> call smoothie#do("\\<C-B>")<CR>',
    desc = "Scroll Up",
    hidden = true,
    mode = { "n", "i", "v", "c", },
  },
  -- >>>> Word Movement
  { "<C-n>",   "n",      desc = "Next",     hidden = true,                     mode = { "n", "i", "v", "c", } },
  { "<C-A-n>", "N",      desc = "Previous", hidden = true,                     mode = { "n", "i", "v", "c", } },
  { "<A-l>",   "<End>",  desc = "End",      hidden = true,                     noremap = true,                mode = { "n", "i", "v", "c", "o" }, },
  { "<A-h>",   "<Home>", hidden = true,     mode = { "n", "i", "v", "c", "o" } },
  { "W",       "3w",     desc = "Word",     hidden = true,                     mode = { "n", "v", "o" } },
  { "B",       "3b",     desc = "Back",     hidden = true,                     mode = { "n", "v", "o" } },

  -- >>>> Tabs/Windows Movement
  --{
    --"<C-h>",
    --"<cmd> lua DuMod.prev_tab()<CR>",
    --desc = "Previous window",
    --hidden = true,
    --noremap = true,
    --remap = false,
    --mode = { "n", "i", "v", "c" },
  --},
  --{
    --"<C-l>",
    --"<cmd> lua DuMod.next_tab()<CR>",
    --desc = "Next window",
    --hidden = true,
    --noremap = true,
    --remap = false,
    --mode = { "n", "v", "c", "i" },
  --},
  {
    "<C-j>",
    "<C-w>j",
    desc = "Window Down",
    hidden = true,
    mode = { "n", "i", "v", "c" },
  },
  {
    "<C-k>",
    "<C-w>k",
    desc = "Window Up",
    hidden = true,
    mode = { "n", "i", "v", "c" },
  },
  {
    "<localleader>PP",
    "<cmd> !cd %:p:h<CR> <bar> <cmd> NERDTree %<CR>",
    desc = "NERDTree Current File",
    hidden = true,
  },
  { "<C-s>",   "<cmd> write<CR>", desc = "Save",               hidden = true },
  {
    "<C-Space>",
    "<cmd> lua require('cmp').complete()<CR>",
    desc = "Cmp Complete",
    noremap = true,
    hidden = true,
    mode = { "n", "i", "v", "c" },
  },
  {
    "Y",
    'gV"+ygn',
    desc = "Linux Buffer Yank",
    hidden = true,
    noremap = true,
    silent = false,
    remap = false,
    mode = { "v" },
  },
  {
    "<C-S-l>",
    "<cmd> bn<CR>",
    desc = "Next Buffer",
    hidden = true
  },
  {
    "<C-S-h>",
    "<cmd> bp<CR>",
    desc = "Previous Buffer",
    hidden = true,
    mode = { "n", "i" }
  },
  {
    "<C-S-A-l>",
    "<cmd> tabnext<CR>",
    desc = "Next tab",
    hidden = true,
    mode = { "n", "i" }
  },
  {
    "<C-S-A-h>",
    "<cmd> tabprevious<CR>",
    desc = "Previous tab",
    hidden = true,
    mode = { "n", "i" }
  },


  -- >>>> Formatting
  { "n",       "o",               desc = "New Line",           hidden = true },
  { "N",       "o<Esc>0",         desc = "New Line + Esc",     hidden = true },
  { "<C-.>",   "i<Enter><Esc>k",  desc = "New Line Up",        hidden = true },
  { "<C-S-.>", "o<Esc>",          desc = "New Line Down",      hidden = true },
  { "<A-.>",   "i<Space><Esc>",   desc = "Blank Space Before", hidden = true },
  { "<A-S-.>", "li<Space><Esc>",  desc = "Blank Space After",  hidden = true },
})

-- >>>> Insert mode
wk.add({
  mode = { "i" },
  noremap = true,
  silent = true,
  hidden = true,
  --{ "jk",      "<Esc>",   desc = "Esc" },
  --{ "kj",      "<Esc>",   desc = "Esc" },
  { "<Enter>", "<Enter>", desc = "Enter", hidden = true, remap = true, mode = { "i", "c" }, },
})

-- >>>> Command mode
wk.add({
  mode = { "i", "c" },
  noremap = true,
  silent = true,
  hidden = true,
  { "<C-x>", "<CR>", desc = "Enter", hidden = true, remap = true, silent = true },
})


-- >> FILETYPE SPECIFIC KEYMAPS
-- >>>> Markdown
function M.markdownMaps()
  wk.add({
    mode = { "n" },
    silent = true,
    noremap = true,
    remap = false,
    {
      "<leader>lf",
      "<cmd> !prettier -w --parser markdown --print-width 100 % <CR>",
      desc = "Prettier Format",
      icon = "󰉶 ",
      remap = true,
    },
    { "<C-=>",       "<cmd> Telescope thesaurus lookup <CR>", desc = "Synonims" },
    { "<C-A-Space>", "<cmd> Telescope spell_suggest<CR>",     desc = "Telescope Spell Suggest" },
    {
      "<C-A-p>",
      "<cmd> lua require('trouble').prev({skip_groups = true, jump = true })<CR>",
      desc = "LtEx Previous",
      icon = "󰬴 ",
    },
    {
      "<C-S-G>",
      "<cmd> lua require('trouble').last({skip_groups = true, jump = true })<CR>",
      desc = "Last",
    },
    {
      "<C-a>",
      "<cmd> lua vim.lsp.buf.code_action()<CR>",
      desc = "Telescope Preview",
    },
    {
      "<C-e>",
      "<cmd> Trouble diagnostics win.position=bottom <CR>",
      desc = "LtEx Spell Check",
      icon = "󰬴 ",
    },
    { "<C-g>", "<cmd> lua require('trouble').first({skip_groups = true, jump = true })<CR>" },
    {
      "<C-p>",
      "<cmd> lua require('trouble').next({skip_groups = true, jump = true })<CR>",
      desc = "LtEx Next",
      icon = "󰬴 ",
    },
    {
      "<localleader>f",
      "<cmd> !prettier -w --parser markdown --print-width 100 % <CR>",
      desc = "Prettier Format",
      icon = "󰉶 ",
    },
    --    {
    --      "<localleader>F",
    --      "nvim --headless -u NONE -c "luafile script.lua" -c "qa"

    { "<C-S-R>", "<cmd> lua require('trouble').refresh()<CR>", desc = "Refresh Ltex" },
    { "<C-t>", "<cmd> lua DuMod.thesaurus_query() <CR>", desc = "Thesaurus Query" },
    { "<C-x>", "<cmd> lua require('trouble').close()<CR>", desc = "LtEx Close", icon = "󰬴 " },
  })
end

-- >>>> html
function M.htmlMaps()
  wk.add({
    {
      "<localleader>r",
      "<cmd> !prettier -w --parser html --print-width 100 % <CR>",
      desc = "Prettier Format",
      icon = "󰉶 ",
    }
  })
end

-- >>>> css
function M.cssMaps()
  wk.add({
    {
      "<localleader>r",
      "<cmd> !prettier -w --parser css --print-width 100 % <CR>",
      desc = "Prettier Format",
      icon = "󰉶 ",
    }
  })
end

-- >>>> Lua
function M.luaMaps()
  wk.add({
    {
      "<localleader>",
      group = "Lua ommands",
      noremap = true,
      remap = true,
      silent = false,
      icon = "󰽥 ",
      mode = { "n" },
    },
    {
      "<C-S-J>",
      "<cmd> call jukit#splits#out_hist_scroll(1)<CR>",
      desc = "Scroll Output History 1",
    },
    {
      "<C-S-K>",
      "<cmd> call jukit#splits#out_hist_scroll(0)<CR>",
      desc = "Scroll Output History 0",
    },
    {
      "<C-a>",
      "<cmd> lua vim.lsp.buf.code_action()<CR>",
      desc = "Telescope Preview",
    },
    { "<localleader><C-Space>", "<cmd> call jukit#send#section(0)<CR>",               desc = "JuKit Send " },
    { "J",                      "<cmd> call jukit#cells#jump_to_next_cell()<CR>",     desc = "JuKit Jump Next Cell" },
    { "K",                      "<cmd> call jukit#cells#jump_to_previous_cell()<CR>", desc = "JuKit Jump Previous Cell" },
    {
      "<localleader>0",
      '<cmd> call jukit#send#send_to_split("reset -f")<CR>',
      desc = "Reset Kernel",
      icon = " ",
    },
    {
      "<localleader>C",
      "<cmd> call jukit#cells#create_above(0)<CR>",
      desc = "Create Code Cell Above",
      icon = " ",
    },
    {
      "<localleader>H",
      "<cmd> call jukit#splits#close_history()<CR>",
      desc = "Close History Output",
    },
    {
      "<localleader>J",
      "<cmd> call jukit#cells#move_down()<CR>",
      desc = "Move Cell Down",
      icon = " "
    },
    { "<localleader>K", "<cmd> call jukit#cells#move_up()<CR>", desc = "Move Cell Up", icon = " " },
    {
      "<localleader>M",
      "<cmd> call jukit#cells#create_above(1)<CR>",
      desc = "Create Markdown Cell Above",
      icon = " ",
    },
    { "<localleader>o", "<cmd> JukitOut ilua<CR>", desc = "Split Output in ilua", icon = " " },
    { "<localleader>O", "<cmd> JukitNewWindow<CR>", desc = "New Window", icon = " " },
    {
      "<localleader>X",
      "<cmd> call jukit#splits#close_output_split()<CR>",
      desc = "Close Output Split",
      icon = " ",
    },
    { "<localleader>S", "<cmd> call jukit#cells#split()<CR>", desc = "Split Cell", icon = " " },
    {
      "<localleader>a",
      "<cmd> call jukit#cells#delete_outputs(0)<CR>",
      desc = "Delete Output",
      icon = " ",
    },
    {
      "<localleader>c",
      "<cmd> call jukit#cells#create_below(0)<CR>",
      desc = "Create Code Cell Below",
      icon = " ",
    },
    {
      "<localleader>j",
      "<cmd> call jukit#cells#merge_below()<CR>",
      desc = "Merge Cell Below",
      icon = " ",
    },
    {
      "<localleader>k",
      "<cmd> call jukit#cells#merge_above()<CR>",
      desc = "Merge Cell Above",
      icon = " ",
    },
    { "<localleader>l", "<cmd> luafile %:p<CR>", desc = "Exec Luafile", icon = "󰽥 " },
    {
      "<localleader>m",
      "<cmd> call jukit#cells#create_below(1)<CR>",
      desc = "Create Markdown Cell Below",
      icon = " ",
    },
    {
      "<localleader>q",
      "<cmd> call jukit#kitty#splits#close_output_split()<CR>",
      desc = "Close Output Split",
    },
    {
      "<localleader>h",
      "<cmd> call jukit#splits#output_and_history()<CR>",
      desc = "Split Output+History",
      icon = "",
    },
    { "<localleader>x", "<cmd> call jukit#cells#delete()<CR>", desc = "Delete Cell", icon = " " },
  })
end

-- >>>> Python
function M.pythonMaps()
  wk.add({
    {
      "<localleader>",
      group = "Python Commands",
      noremap = true,
      silent = true,
      icon = { icon = " ", color = "yellow" },
      mode = { "n" },
    },
    {
      "<localleader>+",
      "<cmd> call jukit#send#send_to_split('!kitten @action resize_window 100')<CR>",
      desc = "Increase Window",
      mode = { "n", "v", "o", "x" },
    },
    {
      "<localleader>-",
      '<cmd> lua vim.api.nvim_command("!kitten @action --match=neighbor:right resize_window +100")<CR>',
      desc = "Decrease Window",
      mode = { "n", "v", "o", "x" },
    },
    {
      "<localleader>0",
      '<cmd> call jukit#send#send_to_split("reset -f")<CR>',
      desc = "Reset Kernel",
      icon = " ",
    },
    {
      "<localleader>8",
      "<cmd> !autopep8 --in-place --aggressive --aggressive %:p<CR>",
      desc = "Autopep 8",
      icon = "󰉶 ",
    },
    {
      "<localleader>C",
      "<cmd> call jukit#cells#create_above(0)<CR>",
      desc = "Create Code Cell Above",
      icon = " ",
    },
    {
      "<localleader>e",
      "<cmd> lua DuMod.JukitCondaEnv()<CR>",
      desc = "Conda Env Split Output",
      icon = "󱔎 ",
    },
    {
      "<localleader>H",
      "<cmd> call jukit#splits#close_history()<CR>",
      desc = "Close History Output",
    },
    {
      "<localleader>J",
      "<cmd> call jukit#cells#move_down()<CR>",
      desc = "Move Cell Down",
      icon = " ",
    },
    { "<localleader>K", "<cmd> call jukit#cells#move_up()<CR>", desc = "Move Cell Up", icon = " " },
    {
      "<localleader>M",
      "<cmd> call jukit#cells#create_above(1)<CR>",
      desc = "Create Markdown Cell Above",
      icon = " ",
    },
    { "<localleader>O", "<cmd> JukitNewWindow<CR>", desc = "New Window", icon = " " },
    {
      "<localleader>X",
      "<cmd> call jukit#splits#close_output_split()<CR>",
      desc = "Close Output Split",
      icon = " ",
    },
    { "<localleader>S", "<cmd> call jukit#cells#split()<CR>", desc = "Split Cell", icon = " " },
    {
      "<localleader>a",
      "<cmd> call jukit#cells#delete_outputs(0)<CR>",
      desc = "Delete Output",
      icon = " ",
    },
    { "<localleader>b", "<cmd> !black %:p<CR>", desc = "Black formatter", icon = "󰉶 " },
    {
      "<localleader>c",
      "<cmd> call jukit#cells#create_below(0)<cr>",
      desc = "create code cell below",
      icon = " ",
    },
    {
      "<localleader>u",
      "<cmd> !kitty @ scroll-window --match=neighbor:right 1p-<CR>",
      desc = "Scroll up Ipython",
      icon = " ",
    },
    {
      "<localleader>d",
      "<cmd> !kitty @ scroll-window --match=neighbor:right 1p+<CR>",
      desc = "Scroll down Ipython",
      icon = " ",
    },
    {
      "<localleader>gg",
      "<cmd> !kitty @ scroll-window --match=neighbor:right start<cr>",
      desc = "go to ipython start",
      icon = " ",
    },
    {
      "<localleader>G",
      "<cmd> !kitty @ scroll-window --match=neighbor:right end<cr>",
      desc = "go to ipython end",
      icon = " ",
    },
    {
      "<localleader>f",
      group = "Formatting",
      noremap = true,
      silent = true,
      icon = "󰉶 ",
      mode = { "n" },
    },
    {
      "<localleader>fd",
      "<cmd> !docformatter --in-place --recursive --wrap-summaries 100 --wrap-descriptions 100 %<CR>",
      desc = "Docstrings Format",
    },
    {
      "<localleader>h",
      '<cmd> call jukit#convert#save_nb_to_file(0,1,"html")<CR>',
      desc = "Convert to Html",
      icon = "󰖟 ",
    },
    { "<localleader>i", "<cmd> !isort %:p<CR>", desc = "Isort Formatter", icon = "󰉶 " },
    {
      "<localleader>j",
      "<cmd> call jukit#cells#merge_below()<CR>",
      desc = "Merge Cell Below",
      icon = " ",
    },
    {
      "<localleader>k",
      "<cmd> call jukit#cells#merge_above()<CR>",
      desc = "Merge Cell Above",
      icon = " ",
    },
    { "<localleader>l", "<cmd> luafile %:p<CR>", desc = "Exec Luafile", icon = "󰽥 " },
    {
      "<localleader>m",
      "<cmd> call jukit#cells#create_below(1)<CR>",
      desc = "Create Markdown Cell Below",
      icon = " ",
    },
    {
      "<localleader>n",
      [[<cmd> call jukit#convert#notebook_convert("jupyter-notebook")]],
      desc = "Convert Notebook",
      icon = "󰠮 ",
    },
    {
      "<localleader>o",
      [[<cmd> call jukit#kitty#splits#output("mamba activate nvim")<CR>]],
      desc = "Split Output",
      icon = " ",
    },
    {
      "<localleader>p",
      '<cmd> call jukit#convert#save_nb_to_file(1,1,"PDF")<CR>',
      desc = "Convert to PDF",
      icon = "󰈦 ",
    },
    {
      "<localleader>q",
      "<cmd> call jukit#kitty#splits#close_output_split()<CR>",
      desc = "Close Output Split",
    },
    {
      "<localleader>r",
      "<cmd> lua DuMod.format_with_ruff()<CR>",
      desc = "Ruff Formatter",
      icon = "󰉶 ",
    },
    {
      "<localleader>h",
      "<cmd> call jukit#splits#output_and_history()<CR>",
      desc = "Split Output+History",
      icon = "",
    },
    { "<localleader>x", "<cmd> call jukit#cells#delete()<CR>", desc = "Delete Cell", icon = " " },

    {
      "<localleader>y",
      "<cmd> call jukit#send#send_to_split(\"%copy_terminal_output\")<CR>",
      desc = "Yank last Stdout/Hist",
      noremap = true,
      mode = { "n" },
    },

    { "<C-=>", "<cmd> Telescope thesaurus lookup <CR>", desc = "Synonims" },
    { "<C-A-Space>", "<cmd> Telescope spell_suggest<CR>", desc = "Telescope Spell Suggest" },
    {
      "<C-A-p>",
      "<cmd> lua require('trouble').prev({skip_groups = true, jump = true })<CR>",
      desc = "Trouble Previous",
      icon = "󰬴 ",
    },
    {
      "<C-S-G>",
      "<cmd> lua require('trouble').last({skip_groups = true, jump = true })<CR>",
      desc = "Last",
    },
    {
      "<C-a>",
      "<cmd> lua require('actions-preview').code_actions()<CR>",
      desc = "Telescope Preview",
    },
    {
      "<C-e>",
      "<cmd> Trouble diagnostics win.position=bottom <CR>",
      desc = "Diagnostic Check",
      icon = "󰬴 ",
      silent = true,
    },
    {
      "<C-S-E>",
      "<cmd> FzfLua diagnostics <CR>",
      desc = "Diagnostic FzfLua",
      icon = "󰬴 ",
      silent = true,
    },
    { "<C-g>", "<cmd> lua require('trouble').first({skip_groups = true, jump = true })<CR>" },
    {
      "<C-p>",
      "<cmd> lua require('trouble').next({skip_groups = true, jump = true })<CR>",
      desc = "Trouble Next",
      icon = "󰬴 ",
    },
    { "<C-S-R>", "<cmd> lua require('trouble').refresh()<CR>", desc = "Refresh Ltex" },
    { "<C-t>", "<cmd> lua DuMod.thesaurus_query() <CR>", desc = "Thesaurus Query" },
    { "<C-x>", "<cmd> lua require('trouble').close()<CR>", desc = "Trouble Close", icon = "󰬴 " },
    {
      "<C-S-J>",
      "<cmd> call jukit#splits#out_hist_scroll(1)<CR>",
      desc = "Scroll Output History 1",
    },
    {
      "<C-S-K>",
      "<cmd> call jukit#splits#out_hist_scroll(0)<CR>",
      desc = "Scroll Output History 0",
    },
    { "<localleader><C-Space>", "<cmd> call jukit#send#section(0)<CR>",               desc = "JuKit Send " },
    { "J",                      "<cmd> call jukit#cells#jump_to_next_cell()<CR>",     desc = "JuKit Jump Next Cell" },
    { "K",                      "<cmd> call jukit#cells#jump_to_previous_cell()<CR>", desc = "JuKit Jump Previous Cell" },
  })
end

-- >>>> LaTeX
function M.texMaps()
  wk.add({
    mode = { "n" },
    remap = false,
    noremap = true,
    silent = true,
    { "<localleader>C", "<cmd> VimtexContextMenu<CR>",         desc = "Context Menu" },
    { "<localleader>F", "<cmd> call vimtex#fzf#run()<CR>",     desc = "FZF" },
    { "<localleader>I", "<cmd> !latexindent -w %<CR>",         desc = "LatexIndent" },
    { "<localleader>L", "<cmd> VimtexCompileSelected<CR>",     desc = "Compile Selected" },
    { "<localleader>T", "<cmd> VimtexTocToggle<CR>",           desc = "TOC Toggle" },
    { "<localleader>c", "<cmd> VimtexClean<CR>",               desc = "Clean" },
    { "<localleader>e", "<cmd> VimtexErrors<CR>",              desc = "Errors" },
    { "<localleader>f", '<cmd> call vimtex#fzf#run("cl")<CR>', desc = "FZF Cl" },
    { "<localleader>i", "<cmd> VimtexInfo<CR>",                desc = "Info" },
    { "<localleader>l", "<cmd> VimtexCompile<CR>",             desc = "Compile" },
    { "<localleader>m", "<cmd> VimtexToggleMain<CR>",          desc = "Toggle Main" },
    { "<localleader>r", "<cmd> VimtexInverseSearch<CR>",       desc = "Inverse Search" },
    { "<localleader>t", "<cmd> VimtexTocOpen<CR>",             desc = "TOC Open" },
    { "<localleader>v", "<cmd> VimtexView<CR>",                desc = "View" },
    { "<localleader>$", "<plug>(vimtex-i$)<CR>",               desc = "i$" },
    { "<localleader>+", "<plug>(vimtex-im)<CR>",               desc = "im" },
    { "<localleader>,", "<plug>(vimtex-aP)<CR>",               desc = "aP" },
    { "<localleader>-", "<plug>(vimtex-am)<CR>",               desc = "am" },
    { "<localleader>.", "plug>(vimtex-iP)<CR>",                desc = "iP" },
    { "<localleader>0", "<plug>(vimtex-a$)<CR>",               desc = "a$" },
    { "<localleader><", "<plug>(vimtex-ae)<CR>",               desc = "ae" },
    { "<localleader>>", "<plug>(vimtex-ie)<CR>",               desc = "ie" },
    { "<localleader>[", "<plug>(vimtex-ac)<CR>",               desc = "ac" },
    { "<localleader>]", "<plug>(vimtex-ic)<CR>",               desc = "ic" },
    { "<localleader>{", "<plug>(vimtex-ad)<CR>",               desc = "ad" },
    { "<localleader>}", "<plug>(vimtex-id)<CR>",               desc = "id" },

    {
      "<localleader>X",
      group = "Change",
    },
    { "<localleader>Xc", "<plug>(vimtex-cmd-change)<CR>",        desc = "Cmd Change" },
    { "<localleader>Xe", "<plug>(vimtex-env-change)<CR>",        desc = "Env Change" },
    { "<localleader>Xm", "<plug>(vimtex-delim-change-math)<CR>", desc = "Delim Math Change" },

    {
      "<localleader>a",
      group = "Toggle",
    },
    { "<localleader>aS", "<plug>(vimtex-env-toggle-star)<CR>",  desc = "Env Star" },
    { "<localleader>ab", "<plug>(vimtex-env-toggle-break)<CR>", desc = "Env Break" },
    { "<localleader>af", "<plug>(vimtex-cmd-toggle-frac)<CR>",  desc = "Frac" },
    { "<localleader>am", "<plug>(vimtex-env-toggle-math)<CR>",  desc = "Env Math" },
    { "<localleader>as", "<plug>(vimtex-cmd-toggle-star)<CR>",  desc = "Cmd Star" },
    {
      "<localleader>r",
      "<cmd>!latexindent -w %<CR>",
      icon = "󰉶 ",
      desc = "Format latex",
    },
    {
      "<localleader>x",
      group = "Delete",
    },
    { "<localleader>xc", "<plug>(vimtex-cmd-delete)<CR>",   desc = "Command Delete" },
    { "<localleader>xe", "<plug>(vimtex-env-delete)<CR>",   desc = "Env Delete" },
    { "<localleader>xm", "<plug>(vimtex-delim-delete)<CR>", desc = "Delim Delete" },

    { "[M",              "<plug>(vimtex-[M)<CR>",           desc = "[M" },
    { "[N",              "<plug>(vimtex-[N)<CR>",           desc = "[N" },
    { "[R",              "<plug>(vimtex-[R)<CR>",           desc = "[R" },
    { "[m",              "<plug>(vimtex-[m)<CR>",           desc = "[m" },
    { "[n",              "<plug>(vimtex-[n)<CR>",           desc = "[n" },
    { "[r",              "<plug>(vimtex-[r)<CR>",           desc = "[r" },
    { "]M",              "<plug>(vimtex-]M)<CR>",           desc = "]M" },
    { "]N",              "<plug>(vimtex-]N)<CR>",           desc = "]N" },
    { "]R",              "<plug>(vimtex-]R)<CR>",           desc = "]R" },
    { "]m",              "<plug>(vimtex-]m)<CR>",           desc = "]m" },
    { "]n",              "<plug>(vimtex-]n)<CR>",           desc = "]n" },
    { "]r",              "<plug>(vimtex-]r)<CR>",           desc = "]r" },
  })
end

-- >>>> Nerdtree
function M.nerdtreeMaps()
  wk.add({
    mode = { "n" },
    noremap = true,
    silent = true,
    {
      "<localleader><localleader>",
      group = "browse",
      icon = " ",
    },
    {
      "<localleader><localleader>c",
      "<cmd> NERDTree /home/eduardotc/.config <CR>",
      desc = ".config",
      icon = " ",
    },
    {
      "<localleader><localleader><leader>",
      [[<cmd> lua vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))<CR>]],
      desc = "CWD"
    },
    { "<localleader><localleader>d", "<cmd> NERDTree /home/eduardotc/Downloads <CR>", desc = "Downloads" },
    { "<localleader><localleader>m", "<cmd> NERDTree /home/eduardotc/Notes <CR>", desc = "Notes", icon = " " },
    {
      "<localleader><localleader>n",
      "<cmd> NERDTree /home/eduardotc/.config/nvim <CR>",
      desc = "Nvim",
      icon = " ",
    },
    {
      "<localleader><localleader>h",
      "<cmd> NERDTree /home/eduardotc <CR>",
      desc = "NERDTree Home",
      icon = " ",
    },
    {
      "<localleader><localleader>l",
      "<cmd> NERDTree /home/eduardotc/.local <CR>",
      desc = "Local",
      icon = " ",
    },
    {
      "<localleader><localleader>p",
      "<cmd> NERDTree /home/eduardotc/Programming <CR>",
      desc = "Programming",
      icon = " ",
    },
    {
      "<localleader><localleader>y",
      "<cmd> NERDTree /home/eduardotc/Programming/python <CR>",
      desc = "Python",
      icon = { icon = " ", color = "yellow" },
    },
    {
      "<localleader><localleader>L",
      "<cmd> NERDTree /home/eduardotc/Programming/LaTeX <CR>",
      desc = "LaTeX",
      icon = " ",
    },
    { "<localleader>a", "<cmd> call NERDTreeAddNode()<CR>", desc = "Add", icon = " " },
    { "<localleader>y", "<cmd> call NERDTreeCopyPath()<CR>", desc = "Copy Path" },
    { "<localleader>x", "<cmd> call NERDTreeDeleteNode()<CR>", desc = "Delete Node", icon = "󰆴 " },
    { "<localleader>m", "<cmd> call NERDTreeMoveNode()<CR>", desc = "Move Node", icon = "󰄾 " },
    { "<localleader>Y", "<cmd> call NERDTreeCopyNode()<CR>", desc = "Copy Node" },
    { "<localleader>E", "<cmd> call NERDTreeExecFile()<CR>", desc = "Exec File" },
    {
      "<localleader>l",
      "<cmd> call NERDTreeExecuteFileLinux()<CR>",
      desc = "Linux Exec",
      icon = "	",
    },
    { "o", "<cmd> NERDTree<CR>", desc = "Nerdtree Startify" },
  })
  vim.api.nvim_command("silent! Startified setlocal cursorline")
end

-- >>>> Startify
function M.startifyMaps()
  wk.add({
    mode = { "n" },
    noremap = true,
    silent = true,
    {
      "<localleader><localleader>",
      group = "browse",
      icon = " ",
    },
    {
      "<localleader><localleader>c",
      "<cmd> NERDTree /home/eduardotc/.config <CR>",
      desc = ".config",
      icon = " ",
    },
    {
      "<localleader><localleader><leader>",
      [[<cmd> lua vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))<CR>]],
      desc = "CWD"
    },
    { "<localleader><localleader>d", "<cmd> NERDTree /home/eduardotc/Downloads <CR>", desc = "Downloads" },
    { "<localleader><localleader>m", "<cmd> NERDTree /home/eduardotc/Notes <CR>", desc = "Notes", icon = " " },
    {
      "<localleader><localleader>n",
      "<cmd> NERDTree /home/eduardotc/.config/nvim <CR>",
      desc = "Nvim",
      icon = " ",
    },
    {
      "<localleader><localleader>l",
      "<cmd> NERDTree /home/eduardotc/.local <CR>",
      desc = "Local",
      icon = " ",
    },
    {
      "<localleader><localleader>p",
      "<cmd> NERDTree /home/eduardotc/Programming <CR>",
      desc = "Programming",
      icon = " ",
    },
    {
      "<localleader><localleader>y",
      "<cmd> NERDTree /home/eduardotc/Programming/python <CR>",
      desc = "Python",
      icon = { icon = " ", color = "yellow" },
    },
    {
      "<localleader><localleader>L",
      "<cmd> NERDTree /home/eduardotc/Programming/LaTeX <CR>",
      desc = "LaTeX",
      icon = " ",
    },
    { "<localleader>a", "<cmd> call NERDTreeAddNode()<CR>", desc = "Add", icon = " " },
    { "<localleader>y", "<cmd> call NERDTreeCopyPath()<CR>", desc = "Copy Path" },
    { "<localleader>x", "<cmd> call NERDTreeDeleteNode()<CR>", desc = "Delete Node", icon = "󰆴 " },
    { "<localleader>m", "<cmd> call NERDTreeMoveNode()<CR>", desc = "Move Node", icon = "󰄾 " },
    { "<localleader>Y", "<cmd> call NERDTreeCopyNode()<CR>", desc = "Copy Node" },
    { "<localleader>E", "<cmd> call NERDTreeExecFile()<CR>", desc = "Exec File" },
    {
      "<localleader>l",
      "<cmd> call NERDTreeExecuteFileLinux()<CR>",
      desc = "Linux Exec",
      icon = "	",
    },
    { "o", "<cmd> NERDTree<CR>", desc = "Nerdtree Startify" },
  })
  vim.api.nvim_command("silent! Startified setlocal cursorline")
end

-- >>>> Wincmd/Nofile
function M.nofileMaps()
  wk.add({
    mode = { "n" },
    noremap = true,
    silent = true,
    {
      "<C-x>",
      "i<CR>",
      hidden = true,
      noremap = true,
      silent = false,
      remap = false,
      icon = "󰿄",
      mode = { "v", "x", "x", "s", "n", "c" },
    },
  })
end

-- >>>> Executin ft map

function M.setup(curr_ft)
  curr_ft = curr_ft or ""
  local curr_func = loadstring("return '" .. curr_ft .. "Maps" .. "'")()
  if curr_ft ~= "" then
    M[curr_func]()
  end
end

vim.cmd[[
  Highlight WhichKeyGroup guifg=#8a82ff
]]

return M
-- vim:ft=lua
