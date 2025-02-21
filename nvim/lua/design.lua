-- >> INITING

local notify = require("notify")
local todos_component = require("todos-lualine").component()
local M = {}
vim.opt.termguicolors = true
vim.opt.cursorline = true
local g = vim.g


-- >> FUNCTIONS

---Substitutes strings from table values, by given strings replacements.
---@param strings_list table Table containing strings in its values, and don't have index keys.
---@param replacements_table table Table with the new elements that should be updated/substituted.
---@return table result_tbl Table with changed elements that are present in both parameters tables,
---matching the values off the first one, with the keys of the second one, and if they match, substitute
---the value on the first table by the key value on the second table
local function substitute_specific_strings(strings_list, replacements_table)
  local result = {}
  for _, str in ipairs(strings_list) do
    local replaced = false
    for match, replacement in pairs(replacements_table) do
      if str == match then
        table.insert(result, replacement)
        replaced = true
        break
      end
    end
    if not replaced then
      table.insert(result, str)
    end
  end
  return result
end

---Get a table key, giving the associated value from it.
---@param tbl table Main table to search for the key, based on known values.
---@param value (string | number) Value from one the tables keys, to obtain its index/element.
---@returns (string | number | list | table | nil)
local function get_key_by_value(tbl, value)
  for key, val in pairs(tbl) do
    if val == value then
      return key
    end
  end
  return nil -- Return nil if no matching key is found
end

--- Get All available colorschemes through neovim command completion of it.
---@return table colorscheme Table containing all th fetched colorschemes.
function M.get_all_colorschemes()
  local colorschemes = vim.fn.getcompletion("", "color")
  return colorschemes
end

--- Set a random colorscheme, from a table obtained with the above function
---@returns string random_colorscheme One of the colorschemes names from the obtained table.
function M.set_random_colorscheme()
  local colorschemes = M.get_all_colorschemes()
  local random_index = math.random(1, #colorschemes)
  local random_colorscheme = colorschemes[random_index]
  vim.cmd("colorscheme " .. random_colorscheme)
  return random_colorscheme
end

function M.set_config(options)
  options = options or {
    "termguicolors",
    "colorscheme",
    "variants",
    "setup",
    "random",
    "all",
  }
  local types_list = {
    termguicolors = "boolean",
    colorscheme = "command",
    variants = "theme_name",
    setup = "yes_no",
    random = "yes_no",
    all = "option",
    tokyogogh = "style",
    modus = "variant",
  }
  local replacements = {
    ["termguicolors"] = "󰄛  TermguiColors",
    ["colorscheme"] = "  Colorscheme",
    ["variants"] = "󰘸  Variants",
    ["setup"] = "  Setup",
    ["random"] = "  Random",
    ["all"] = "  All",
  }
  local variants_list = {
    nebulous = { "night", "twilight", "midnight", "fullmoon", "nova", "quasar" },
    tokyogogh = { "storm", "night" },
    modus = { "default", "tinted", "deuteranopia", "tritanopia" },
  }
  local all_colorschemes = M.get_all_colorschemes()
  local display_notebooks = {}
  for _, str in ipairs(options) do
    table.insert(display_notebooks, str)
  end
  local update_strings = substitute_specific_strings(display_notebooks, replacements)
  vim.ui.select(update_strings, {
    cursorline = true,
    prompt = "  Select an Option :",
  }, function(choice)
    if choice then
      local value = get_key_by_value(replacements, choice)
      local type = types_list[value]
      if type == "string" then
        vim.ui.input({ prompt = string.format("Enter New %s", value) }, function(input)
          if input then
            vim.api.nvim_set_option_value(string.format("%s", value), input, {})
            vim.cmd("echo " .. string.format("'%s Set to %s'", value, input))
            return
          end
        end)
      elseif value == "all" then
        vim.ui.select(all_colorschemes, { prompt = "Choose Colorscheme", cursorline = true },
          function(choice)
            if choice then
              vim.cmd("colorscheme " .. choice)
              notify(string.format("Colorscheme %s Enabled.", choice), "normal",
                { title = "All", icon = " ", cursorline = true })
              return
            end
          end)
      elseif type == "command" then
        vim.ui.input({ prompt = string.format("Enter a %s: ", value) }, function(command_input)
          if command_input then
            vim.cmd(string.format("%s %s", value, command_input))
            vim.cmd("echo " .. string.format("'%s runned with %s'", value, command_input))
            return
          end
        end)
      elseif type == "boolean" then
        vim.ui.select({ "true", "false" }, { prompt = string.format("Choose %s Value: ", value) },
          function(boolean_choice)
            if boolean_choice then
              if boolean_choice == "true" then
                ResultBool = true
              elseif boolean_choice == "false" then
                ResultBool = false
              end
              vim.api.nvim_set_option_value(string.format("%s", value), ResultBool, {})
              vim.cmd("echo " .. string.format("'%s set to %s'", value, ResultBool))
            end
          end)
      elseif type == "theme_name" then
        type = types_list[vim.g.colors_name] or nil
        local variant_options = variants_list[vim.g.colors_name] or {}
        vim.ui.select(variant_options,
          { cursorline = true, prompt = string.format("Choose %s Value: ", value) },
          function(variant_choice)
            if variant_choice then
              if vim.g.colors_name == "nebulous" then
                require("nebulous.functions").set_variant(variant_choice)
              elseif type then
                require(vim.g.colors_name).setup({ type = variant_choice })
              end
              notify(string.format("%s set to %s", value, variant_choice), "normal",
                { title = "Colorscheme", icon = " " })
            else
              notify(
                string.format("Current colorscheme %s don't have configured variants!",
                  vim.g.colors_name), "error", { title = "Error" })
            end
          end)
      elseif type == "yes_no" then
        vim.ui.select({ "Yes", "No" }, { cursorline = true, prompt = "Choose Y/N:" },
          function(yesno_choice)
            if yesno_choice then
              if value == "setup" and yesno_choice == "Yes" then
                vim.api.nvim_command("lua DuDesign.setup(" .. vim.g.colors_name .. ")")
                notify(string.format("%s Theme Setupped.", vim.g.colors_name), "normal",
                  { title = "Setup", icon = " " })
              elseif value == "random" and yesno_choice == "Yes" then
                local random_theme = M.set_random_colorscheme()
                notify(string.format("%s Rando Colorscheme Chosen.", random_theme), "normal",
                  { title = "Random", icon = " " })
              else
                notify(string.format("%s Theme setup aborted!.", vim.g.colors_name), "warn",
                  { title = "Setup", icon = " " })
              end
            end
          end)
      end
    end
  end)
end

local function search_count()
  local result = vim.fn.searchcount({ maxcount = 0 })
  if result.total > 0 then
    return "S:" .. result.current .. "/" .. result.total
  end
  return ""
end

local function count_todos()
  local todo_count = 0
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, line in ipairs(lines) do
    local _, count = line:gsub("TODO", "")
    todo_count = todo_count + count
  end

  if todo_count > 0 then
    return "%#LualineTodo# " .. todo_count .. "%*"
  end
  return ""
end

local function lsp_diagnostics()
  local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local hints = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  local infos = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  local todos = count_todos()

  local result = {}
  if #errors > 0 then
    table.insert(result, "%#LualineError# " .. #errors .. "%*")
  end
  if #warnings > 0 then
    table.insert(result, "%#LualineWarning# " .. #warnings .. "%*")
  end
  if #hints > 0 then
    table.insert(result, "%#LualineHint#󰈸 " .. #hints .. "%*")
  end
  if #infos > 0 then
    table.insert(result, "%#LualineInfo# " .. #infos .. "%*")
  end
  if todos ~= "" then
    table.insert(result, todos)
  end

  return table.concat(result, " ")
end

local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 }) -- Get clients attached to the current buffer
  if next(clients) == nil then
    return ""
  end

  local active_clients = {}
  for _, client in ipairs(clients) do
    table.insert(active_clients, client.name)
  end

  return table.concat(active_clients, ", ")
end


-- >> LUALINE

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "du",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,
    refresh = {
      statusline = 10000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  tabline = {
    lualine_a = {
      { "location" },
      { "mode" },
      { "searchcount", "selectioncount", cond = function() return search_count() ~= "" end },
    },
    lualine_b = {
      {
        "tabs",
        tab_max_length = 60,            -- Maximum width of each tab. The content will be shorten dynamically (example: apple/orange -> a/orange)
        max_length = vim.o.columns / 2, -- Maximum width of tabs component.
        --max_length = 15,
        mode = 2,                       -- 0: Shows tab_nr 1: Shows tab_name 2: Shows tab_nr + tab_name
        --path = 0,                   -- 0: just shows the filename 1: shows the relative path and shorten $HOME to ~
        -- 2: shows the full path 3: shows the full path and shorten $HOME to ~
        use_mode_colors = true,
        tabs_color = {},
        show_modified_status = false, -- Shows a symbol next to the tab name if the file has been modified.
        symbols = {
          modified = "󰎜 ", -- Text to show when the file is modified.
        },
        function()
          return vim.t[vim.api.nvim_get_current_tabpage()].tabname or
          string.format("Tab %s", vim.api.nvim_get_current_tabpage())
        end
      }
    },
    lualine_c = {
      {
        "buffers",
        show_filename_only = true,
        hide_filename_extension = true,
        show_modified_status = true,
        mode = 2,                       -- 0: Shows buffer name 1: Shows buffer index 2: Shows buffer name +
        -- buffer index 3: Shows buffer number 4: Shows buffer name + buffer number
        max_length = vim.o.columns / 2, -- Maximum width of buffers component, it can also be
        --max_length = 15,
        filetype_names = {
          TelescopePrompt = "󰭎 ",
          startify = " ",
          dashboard = "Dashboard",
          packer = "Packer",
          fzf = "FZF",
          alpha = "Alpha"
        }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
        use_mode_colors = true,
        buffers_color = {},
        symbols = {
          modified = "", -- Text to show when the buffer is modified
          alternate_file = " ", -- Text to show to identify the alternate file
          directory = " ", -- Text to show when the buffer is a directory
        },
      }
    },
    lualine_x = { lsp_diagnostics },
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = { lsp_status },
  },
  sections = {},
  inactive_sections = {},
  extensions = { "quickfix", "symbols-outline", "nerdtree", "toggleterm", "trouble" },
})

-- TODO teste
-- >> DEFAULT OPTIONS

local default_options = {
  transparent = true,
  italic_comments = false,
  hide_fillchars = false,
  borderless_telescope = true,
  terminal_colors = true,

  theme = {
    variant = "auto",
    colors = {},
    highlights = {},
  },

  extensions = {
    alpha = false,
    cmp = true,
    dashboard = false,
    fzflua = true,
    gitpad = false,
    gitsigns = false,
    grapple = false,
    grugfar = false,
    heirline = false,
    hop = false,
    indentblankline = true,
    kubectl = false,
    lazy = false,
    leap = false,
    markdown = true,
    markview = true,
    mini = true,
    noice = true,
    notify = true,
    rainbow_delimiters = true,
    telescope = true,
    trouble = true,
    whichkey = true,
  },
}


-- >> MARKDOWN



-- >> HIGHLIGHTING PLUGIN

require("nvim-highlight-colors").setup {
  render = "background",
  virtual_symbol = "■",
  enable_named_colors = true,
  enable_tailwind = true,
  custom_colors = {
    { label = "%-%-theme%-primary%-color",   color = "#0f1219" },
    { label = "%-%-theme%-secondary%-color", color = "#5a5d64" },
  }
}
require("nvim-highlight-colors").turnOn()



-- >> HIGHLIGHT GROUPS

-- >>>> Basics
--vim.cmd([[
--highlight TabLineFill                   guibg=NONE    guifg=yellow
--highlight FoldColumn                    guibg=#BD93F9 guifg=#000000
--highlight Folded                        guibg=#8BE9FD guifg=#F1FA8C
--highlight Cursor                        guibg=#F1FA8C guifg=#000000 gui=bold
--highlight TermCursor                    guibg=#F1FA8C guifg=#000000 gui=bold
--highlight CursorIM                      guibg=#F1FA8C guifg=#000000 gui=bold cterm=bold
--highlight lCursor                       guibg=#F1FA8C guifg=#000000 gui=bold cterm=bold
--highlight CursorLineNr                  guibg=NONE    guifg=#5B3AFF gui=italic
--highlight ColorColum                    guibg=#252f5b guifg=#F1FA8C
--]])


function M.SetHighlight()
  -- >>>> Telescope
  vim.cmd([[
    highlight TelescopeSelection            guibg=#44475A guifg=#F8F8F2
    highlight TelescopeSelectionCaret       guibg=#44475A guifg=#F8F8F2
    highlight TelescopeMultiSelection       guibg=#44475A guifg=#FFFFFF
    highlight TelescopeNormal               guibg=#282A36 guifg=#F8F8F2
    highlight TelescopePreviewNormal        guibg=#282A36 guifg=#F8F8F2
    highlight TelescopePromptNormal         guibg=#282A36 guifg=#F8F8F2
    highlight TelescopePromptNormal         guibg=#282A36 guifg=#F8F8F2
    highlight TelescopeResultsNormal        guibg=#282A36 guifg=#F8F8F2
    highlight TelescopeBorder               guifg=#BD93F9 guibg=#282A36
    highlight TelescopePromptBorder         guifg=#FF79C6 guibg=#282A36
    highlight TelescopeResultsBorder        guifg=#8BE9FD guibg=#282A36
    highlight TelescopePreviewBorder        guifg=#BD93F9 guibg=#282A36
    highlight TelescopeTitle                guifg=#50FA7B guibg=#282A36
    highlight TelescopePromptTitle          guifg=#50FA7B guibg=#282A36
    highlight TelescopeResultTitle          guifg=#8BE9FD guibg=#282A36
    highlight TelescopePreviewTitle         guifg=#8BE9FD guibg=#282A36
    highlight TelescopePromptCounter        guifg=#FFB86C guibg=#282A36
    highlight TelescopeMatching             guifg=#BD93F9 guibg=#44475A
    highlight TelescopePromptPrefix         guifg=#FF79C6 guibg=#282A36
    highlight TelescopePreviewLine          guifg=#BD93F9 guibg=#282A36
    highlight TelescopePreviewMatch         guifg=#50FA7B guibg=#282A36
    highlight TelescopePreviewPipe          guifg=#8BE9FD guibg=#282A36
    highlight TelescopePreviewCharDev       guifg=#F1FA8C guibg=#282A36
    highlight TelescopePreviewDirectory     guifg=#BD93F9 guibg=#282A36
  ]])


  -- >>>> Trouble
  vim.cmd([[
    highlight TroubleBasename               guifg=#8BE9FD
    highlight TroubleFilename               guifg=#f8f487
    highlight TroubleIconNumber             guifg=#57f89a
    highlight TroubleCount                  guifg=#c62d5b
    highlight TroubleIndent                 guifg=#4530e5
    highlight TroubleDirectory              guifg=#c259e5
    highlight TroubleCode                   guifg=#80e575
    highlight TroubleIconArray              guifg=#7787f4
  ]])

  -- >>>> Python
  vim.cmd([[
    highlight PythonTripleQuotes            guibg=NONE    guifg=#d451c9
    highlight PythonAttribute               guibg=NONE    guifg=#45d4b5
  ]])


  local highlights = {
    { "TabLineFill",        { bg = "NONE", fg = "yellow" } },
    { "FoldColumn",         { bg = "#45d4b5", fg = "#000000" } },
    { "Folded",             { bg = "#8BE9FD", fg = "#F1FA8C" } },
    { "Cursor",             { bg = "#F1FA8C", fg = "#000000", bold = true } },
    { "TermCursor",         { bg = "#F1FA8C", fg = "#000000", bold = true } },
    { "CursorIM",           { bg = "#F1FA8C", fg = "#000000", bold = true } },
    { "lCursor",            { bg = "#F1FA8C", fg = "#000000", bold = true } },
    { "CursorLineNr",       { bg = "NONE", fg = "#5B3AFF", italic = true } },
    { "ColorColumn",        { bg = "#2e2944", fg = "NONE" } },
    { "RenderMarkdownH1Bg", { bg = "#7DCFFF", fg = "#000000" } },
    { "RenderMarkdownH2Bg", { bg = "#7AA2F7", fg = "#1B1E2B" } },
    { "RenderMarkdownH3Bg", { bg = "#73DACA", fg = "NONE" } },
    { "LualineError",       { fg = "#FF5555", bg = "NONE", bold = true } },
    { "LualineWarning",     { fg = "#F1FA8C", bg = "NONE", bold = true } },
    { "LualineHint",        { fg = "#8BE9FD", bg = "NONE", bold = true } },
    { "LualineInfo",        { fg = "#50FA7B", bg = "NONE", bold = true } },
    { "LualineTodo",        { fg = "#7F75EF", bg = "NONE", bold = true } },
    { "WhichKeyGroup",      { fg = "#8a82ff", bg = "NONE", bold = true } },
  }

  for _, highlight in ipairs(highlights) do
    vim.api.nvim_set_hl(0, highlight[1], highlight[2])
  end
end

-- >> NOTIFY

notify.setup({
  fps = 60,
  timeout = 1500,
  background_colour = "#282A36",
  foreground_color = "#BD93F9",
  minimum_width = 5,
})


-- >> SETUP

-- >>>> Onenord
function M.onenordConfig()
  require("onenord").setup({
    theme = "dark",
    borders = true,
    fade_nc = false, -- Fade non-current windows, making them more distinguishable
    -- Style that is applied to various groups: see `highlight-args` for options
    styles = {
      comments = "NONE",
      strings = "NONE",
      keywords = "NONE",
      functions = "NONE",
      variables = "NONE",
      diagnostics = "underline",
    },
    disable = {
      background = true,
      float_background = false, -- Disable setting the background color for floating windows
      cursorline = true,
      eob_lines = true,         -- Hide the end-of-buffer lines
    },
    -- Inverse highlight for different groups
    inverse = {
      match_paren = false,
    },
    --custom_highlights = {}, -- Overwrite default highlight groups
    --custom_colors = {}, -- Overwrite default colors
  })
end

-- >>>> Nightfox
function M.nightfoxConfig()
  require("nightfox").setup({
    options = {
      compile_path = vim.fn.stdpath("cache") .. "/nightfox",
      compile_file_suffix = "_compiled",
      transparent = true,
      terminal_colors = true,
      dim_inactive = false, -- Non focused panes set to alternative background
      module_default = true,
      colorblind = {
        enable = false,
        simulate_only = false,
        severity = {
          protan = 0,
          deutan = 0,
          tritan = 0,
        },
      },
      styles = {           -- Style to be applied to different syntax groups
        comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
        conditionals = "NONE",
        constants = "NONE",
        functions = "NONE",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
      },
      inverse = { -- Inverse highlight for different types
        match_paren = false,
        visual = false,
        search = false,
      },
    },
  })
end

-- >>>> Mellow
function M.mellowConfig()
  ---Mellow theme has extras files for config kitty terimanl colors
  vim.g.mellow_transparent = true
end

-- >>>> Bluloco
function M.blulocoConfig()
  require("bluloco").setup({
    style       = "dark",
    transparent = true,
    italics     = true,
    terminal    = vim.fn.has("gui_running") == 1,
    guicursor   = true,
  })
end

-- >>>> Poimandres
function M.poimandresConfig()
  require("poimandres").setup {
    bold_vert_split = false,
    dim_nc_background = false,
    disable_background = false,
    disable_float_background = false,
    disable_italics = false,
  }
  return "poimandres"
end

-- >>>> Nordic
function M.nordicConfig()
  require("nordic").setup({
    on_palette = function(palette) end,
    after_palette = function(palette) end,
    on_highlight = function(highlights, palette) end,
    bold_keywords = false,
    italic_comments = true,
    transparent = {
      bg = true,
      float = true,
    },
    bright_border = false,
    reduced_blue = true,
    swap_backgrounds = false,
    cursorline = {
      bold = false,
      bold_number = true,
      theme = "dark",
      blend = 0.85,
    },
    noice = {
      ---@type ("classic" | "flat")
      style = "classic",
    },
    telescope = {
      ---@type ("classic" | "flat")
      style = "flat",
    },
    leap = {
      dim_backdrop = false,
    },
    ts_context = {
      dark_background = true,
    }
  })
end

-- >>>> Palenightfall
function M.palenightfallConfig()
  require("palenightfall").setup({
    transparent = true,
  })
end

function M.noctisConfig()
  vim.cmd [[
    syntax on
  ]]
end

-- >>>> Nebulous
function M.nebulousConfig()
  require("nebulous").setup {
    ---@type("night" | "twilight" | "midnight" | "fullmoon" | "nova" | "quasar")
    variant = "midnight",
    disable = {
      background = true,
      endOfBuffer = false,
      terminal_colors = false,
    },
    italic = {
      comments  = false,
      keywords  = true,
      functions = false,
      variables = true,
    },
    --custom_colors = { -- this table can hold any group of colors with their respective values
    --LineNr = { fg = "#5BBBDA", bg = "NONE", style = "NONE" },
    --CursorLineNr = { fg = "#E1CD6C", bg = "NONE", style = "NONE" },
    -- it is possible to specify only the element to be changed
    --TelescopePreviewBorder = { fg = "#A13413" },
    --LspDiagnosticsDefaultError = { bg = "#E11313" },
    --TSTagDelimiter = { style = "bold,italic" },
    --}
  }
  return "nebulous"
end

-- >>>> Tokyogogh
function M.tokyogoghConfig()
  require("tokyogogh").setup {
    ---@type("storm"  | "night")
    style = "night",
    term_colors = true,
    ---- Change code styles
    diagnostics = {
      undercurl = true, -- use undercurl instead of underline
      background = true,
    },
    code_styles = {
      strings = { italic = false, bold = false },
      comments = { italic = true, bold = false },
      functions = { italic = false, bold = false },
      variables = { italic = false, bold = false },
    },
    -- Customization
    colors = {},
    highlight = {},
  }
end

-- >>>> Modus
function M.modusConfig()
  require("modus-themes").setup({
    style = "auto",
    ---@type("default" | "tinted" | "deuteranopia" | "tritanopia")
    variant = "default",
    transparent = true,
    dim_inactive = false,            -- "non-current" windows are dimmed
    hide_inactive_statusline = true, -- Hide statuslines on inactive windows. Works with the standard **StatusLine**, **LuaLine** and **mini.statusline**
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
    },
    ---@param colors ColorScheme
    on_colors = function(colors) end,
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors) end,
  })
end

-- >>>> Abyss
function M.abyssConfig()
  require("abyss").setup({
    italic_comments = true,
    italic = false,
    bold = false,
    transparent_background = true,
    treesitter = true,
    overrides = {},
  })
  return "abyss"
end

-- >>>> Penumbra
function M.penumbraConfig()
  require("penumbra").setup({
    italic_comment = false,
    transparent_bg = true,
    show_end_of_buffer = false,
    lualine_bg_color = nil,
    light = false,
    ---@type(nil | "plus" | "plusplus")
    contrast = "plus",
    -- customize colors
    colors = {
      sun_p = "#FFFDFB",
      sun = "#FFF7ED",
      sun_m = "#F2E6D4",
      sky_p = "#BEBEBE",
      sky = "#8F8F8F",
      sky_m = "#636363",
      shade_p = "#3E4044",
      shade = "#303338",
      shade_m = "#24272B",
      red = "#CA736C",
      orange = "#BA823A",
      yellow = "#8D9741",
      green = "#47A477",
      cyan = "#00A2AF",
      blue = "#5794D0",
      purple = "#9481CC",
      magenta = "#BC73A4",
    },
    overrides = {
    },
  })
end

-- >>>> Catppuccin
function M.catppuccinConfig()
  require("catppuccin").setup({
    highlight_overrides = {
      all = function(colors)
        return {
          background = { fg = "none", bg = "none"},
        }
      end,
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
    transparent_background = true,
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = {
      enabled = false, -- dims the background color of inactive window
      shade = "dark",
      percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false,
    no_bold = false,
    no_underline = false,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {
      backgroun = "none",
    },
    custom_highlights = {},
    default_integrations = true,
  })
  return "cattppuccin"
end

-- >>>> Kyotonight
function M.kyotonightConfig()
  g.kyotonight_bold = 1
  g.kyotonight_underline = 1
  g.kyotonight_italic = 0
  g.kyotonight_italic_comments = 0
  g.kyotonight_uniform_status_lines = 0
  g.kyotonight_bold_vertical_split_line = 0
  g.kyotonight_cursor_line_number_background = 0
  g.kyotonight_uniform_diff_background = 0
  g.kyotonight_lualine_bold = 1
  return "kyotonight"
end

-- >>>> Dracula
function M.draculaConfig()
  require("dracula").setup({
    colors = {
      bg = none,
      fg = "#f8f8f2",
      selection = "#44475a",
      comment = "#6270a4",
      red = "#ff5555",
      orange = "#ffb86c",
      yellow = "#f1fa8c",
      green = "#50fa7b",
      purple = "#bd93f9",
      cyan = "#8be9fd",
      pink = "#ff79c6",
      bright_red = "#ff6e6e",
      bright_green = "#69ff94",
      bright_yellow = "#ffffa5",
      bright_blue = "#d6acff",
      bright_magenta = "#ff92df",
      bright_cyan = "#a4ffff",
      bright_white = "#ffffff",
      menu = "#21222c",
      visual = "#3e4452",
      gutter_fg = "#4b5263",
      nontext = "#3b4048",
      white = "#abb2bf",
      black = "#191a21",
    },
    show_end_of_buffer = true,
    transparent_bg = true,
    lualine_bg_color = "#44475a",
    italic_comment = true,
    overrides = {},
  })
end

function M.setup(colorscheme, auto_lualine)
  colorscheme = colorscheme or nil
  AvailableScheme = vim.fn.getcompletion("", "color")
  local curr_func = loadstring("return '" .. colorscheme .. "Config" .. "'")()
  if type(M[curr_func]) == "function" then
    FuncResult = M[curr_func]()
  else
    return false
  end
  auto_lualine = auto_lualine or FuncResult
  if type(auto_lualine) == "str" then
    require("lualine").setup {
      options = {
        theme = auto_lualine
      }
    }
  elseif auto_lualine == true then
    require("lualine").setup {
      options = {
        theme = "auto"
      }
    }
  end
end

return M

--for _, n in pairs(available_schemes) do
--if colorscheme ~= nil and colorscheme == n then
--vim.api.nvim_command("silent! colorscheme " .. n)
--return pcall(func, ...)
    --lualine_x = {
      --{
        --"diagnostics",
        --sources = { "nvim_lsp" },
        ----sources = { "nvim_workspace_diagnostic" },
        --sections = { "todo", "debug", "trace", "info", "hint", "error", "warn" },
        --symbols = { debug = " ", trace = " ", TODO = " ", todo = " ", error = " ", warn = " ", info = " ", hint = "󰈸 " },
        ----symbols = { debug = " ", trace = " ", todo = " ", error = "󱄊 ", warn = " ", info = "", hint = "󱇗 " },
        --colored = true,
        --update_in_insert = true,
        --always_visible = false,
      --},
    --},
    --lualine_x = { "lsp_diagnostics" },
    --lualine_z = { "lsp_status" },
