-- >> REQUIRES

local vim = vim
local lspkind = require("lspkind")
local ls = require("luasnip")
local cmp = require("cmp")
local noice_lsp = require("noice.lsp")
local cmp_lsp = require("cmp_nvim_lsp")

DuMod = require("du")

cmp_lsp.setup()

DuMod.RequireDir("/home/eduardotc/.config/nvim/lua/snippets")

-- >> CMP

function LspHoverWindowExists()
  local wins = vim.api.nvim_list_wins()
  for _, n in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(n)
    if config.relative == "win" and config.hide == false and config.focusable == true then
      local cur_buf = vim.api.nvim_win_get_buf(n)
      local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = cur_buf })
      if buf_ft == "noice" or buf_ft == "lsp-hover" or buf_ft == "markdown" then
        return true
      end
    end
  end
  return false
end

function LspHoverCurrentWindow()
  local win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(win)
  if config.relative == "win" and config.hide == false and config.focusable == true then
    local cur_buf = vim.api.nvim_get_current_buf()
    local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = cur_buf })
    if buf_ft == "noice" or buf_ft == "lsp-hover" or buf_ft == "markdown" then
      return true
    end
  end
  return false
end

local function get_selection()
  local a_orig = vim.fn.getreg("a")
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    vim.cmd([[normal! gv]])
  end
  vim.cmd([[silent! normal! "aygv]])
  local text = vim.fn.getreg("a")
  vim.fn.setreg("a", a_orig)
  return text
end

---- >> Setup
---@diagnostic disable-next-line: redundant-parameter
cmp.setup({
  snippet = {
    expand = function(args)
      ls.lsp_expand(args.body)
    end,
  },
  preselect = cmp.PreselectMode.Items,
  completion = {
    keyword_length = 2,
    completeopt = "menu,menuone,noselect",
  },
  performance = {
    async_budget = 400,
  },
  mapping = {
    ["<C-o>"] = cmp.mapping(
      function(fallback)
        if cmp.visible_docs() then
          vim.lsp.buf.hover()
        elseif cmp.visible() then
          cmp.open_docs()
        else
          fallback()
        end
      end,
      { "i", "s", "n", "x", "c" }
    ),
    ["<C-m>"] = cmp.mapping(
      function()
        noice_lsp.scroll(4)
      end,
      { "i", "s" }
    ),
    ["<C-d>"] = cmp.mapping(
      function(fallback)
        if cmp.visible_docs() then
          cmp.scroll_docs(4)
        elseif LspHoverWindowExists() then
          noice_lsp.scroll(4)
        else
          fallback()
        end
      end,
      { "i", "s" }
    ),
    ["<C-u>"] = cmp.mapping(
      function(fallback)
        if cmp.visible_docs() then
          cmp.scroll_docs(-4)
        elseif LspHoverWindowExists() then
          noice_lsp.scroll(-4)
        else
          fallback()
        end
      end,
      { "i", "s" }
    ),
    ["<C-a>"] = cmp.mapping(
      function(fallback)
        if ls.choice_active() then
          DuMod.fzf_read_input()
        else
          fallback()
        end
      end,
      { "i", "s" }
    ),
    ["<C-Space>"] = cmp.mapping(
      function(fallback)
        local mode = vim.api.nvim_get_mode().mode
        if mode == "V" then
          vim.api.nvim_command("normal! gnes")
          ls.pre_yank("z")
          vim.api.nvim_command('normal! gv"zs')
          return ls.post_yank("z")
        elseif cmp.visible_docs() then
          cmp.abort()
        elseif LspHoverWindowExists() then
          vim.lsp.buf.signature_help()
          vim.api.nvim_win_close(0, 0)
          cmp.abort()
        elseif cmp.visible() then
          vim.lsp.buf.signature_help()
        else
          fallback()
        end
      end,
      { "n", "i" }
    ),
    ["<C-x>"] = cmp.mapping(
      function(fallback)
        if ls.choice_active() then
          ls.set_choice()
          cmp.confirm({ select = true })
          return ls.choice_popup_close()
        elseif cmp.visible() then
          cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })
        else
          fallback()
        end
      end,
      { "c", "x", "i", "s", "n" }
    ),
    ["<C-j>"] = cmp.mapping(
      function(fallback)
        if ls.choice_active() then
          ls.change_choice(1)
        elseif cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      { "i", "x", "c", "s" }
    ),
    ["<C-k>"] = cmp.mapping(
      function(fallback)
        if ls.choice_active() then
          ls.change_choice(-1)
        elseif cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
      { "i", "x", "c", "s" }
    ),
    ["<C-p>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ls.expand_or_jumpable() then
          ls.expand_or_jump(-1)
        elseif ls.choice_active() then
          ls.change_choice(-1)
        elseif ls.jumpable() then
          ls.jump(-1)
        else
          fallback()
        end
      end,
      { "i", "s" }
    ),
    ["<C-n>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif ls.expand_or_jumpable() then
          ls.expand_or_jump()
        elseif LspHoverWindowExists() then
          vim.lsp.buf.signature_help()
        elseif LspHoverCurrentWindow() then
          vim.api.nvim_command("silent! wincmd p")
          cmp.complete()
          vim.lsp.buf.signature_help()
        elseif cmp.visible_docs() then
          vim.lsp.buf.signature_help()
        else
          fallback()
        end
      end,
      { "i", "s" }
    ),
    ["<C-h>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end,
      { "i", "n" }
    ),
    ["<C-g>"] = cmp.mapping(
      function()
        vim.api.nvim_command("normal! gnes")
        local tst = get_selection()
        vim.cmd("normal! gv\"ws")
        ls.pre_yank("z")
        vim.api.nvim_command('normal! gv"zs')
        print(tst)
        return ls.post_yank("z")
      end,
      { "v", "x", "s", "n", "i", "o" }
    )
  },
  sources = {
    {
      name = "luasnip",
      max_item_count = 6,
      priority = 100
    },
    {
      name = "nvim_lsp",
      max_item_count = 25,
      priority = 150
    },
    {
      name = "diag-codes",
      max_item_count = 10,
      priority = 100,
      option = { in_comment = true }
    },
    {
      name = "cmp_zotcite",
      max_item_count = 5,
      priority = 80
    },
    {
      name = "calc",
      max_item_count = 2,
      priority = 70
    },
    {
      name = "nvim_lua",
      max_item_count = 13,
      priority = 70
    },
    {
      name = "path",
      max_item_count = 10,
      priority = 50
    },
    {
      name = "buffer",
      max_item_count = 10,
      priority = 40
    },
  },
  experimental = {
    ghost_text = false,
  },
  view = {
    entries = {
      ---@type '"custom"'|'"wildmenu"'|'"native"'
      name = "custom",
      ---@alias selection_order '"near_cursor"'|'"top_down"'
      selection_order = "top_down",
      follow_cursor = true,
    },
    docs = {
      auto_open = true,
    }
  },
  window = {
    completion = {
      ---@type '"none"'|'"single"'|'"double"'|'"rounded"'|'"solid"'|'"shadow"'
      border = "rounded",
      winblend = 3,
      zindex = 150,
      scrollbar = true,
      scrolloff = 1,
      col_offset = 10,
      side_padding = 1,
    },
    documentation = {
      zindex = 180,
      winblend = 1,
      border = "solid",
      max_width = 40,
    },
  },
  formatting = {
    fields = {
      cmp.ItemField.Kind,
      cmp.ItemField.Abbr,
      cmp.ItemField.Menu,
    },
    format = lspkind.cmp_format({
      with_text = true,
      ---@type ("'text_symbol'"|"'symbol'")
      mode = "symbol",
      maxwidth = 43,
      ellipsis_char = "...",
      show_labelDetails = true,
    }),
  },
})
---- >> Cmdline

------ >> /
cmp.setup["cmdline"]("/", {
  sources = {
    {
      name = "nvim_lua",
      max_item_count = 10,
      priority = 80,
    },
    {
      name = "path",
      max_item_count = 6,
      priority = 50
    },
    {
      name = "buffer",
      priority = 80,
      max_item_count = 10
    },
    {
      name = "nvim_lsp",
      priority = 100,
      max_item_count = 15
    },
  },
})

------ >> :
cmp.setup["cmdline"](":", {
  mapping = {
    ["<C-j>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      { "i", "c", "t", "l", "n" }
    ),
    ["<C-k>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
      { "i", "c", "t", "l", "n" }
    ),
    ["<C-x>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          vim.api.nvim_command("normal! <CR>")
        end
      end,
      { "i", "c", "t", "l", "n" }
    ),
    ["<C-Space>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.sync()
        else
          cmp.complete()
        end
      end,
      { "i", "n", "c", "t", "l" }
    ),
  },
  sources = {
    {
      name = "path",
      max_imte_count = 5,
      priority = 70
    },
    {
      name = "cmdline",
      max_item_count = 10,
      priority = 100
    },
    {
      name = "cmdline_history",
      max_item_count = 6,
      priority = 80
    },
    {
      name = "nvim_lua",
      max_item_count = 8,
      priority = 80
    },
    {
      name = "buffer",
      max_item_count = 5,
      priority = 50
    },
  },
})
