-- >> REQUIRING

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local vim = vim
local g = vim.g
local todo = require("todo-comments")
local noice = require("noice")
local lspconfig = require("lspconfig")
local nvim_treesitter = require("nvim-treesitter.configs")
local telescope = require("telescope")
local actions = require("telescope.actions")
local lspkind = require("lspkind")
local easypick = require("easypick")
local trouble = require("trouble")
local get_default_branch =
"git rev-parse --symbolic-full-name refs/remotes/origin/HEAD | sed 's!.*/!!'"
local base_branch = vim.fn.system(get_default_branch) or "main"
local glow = require("glow")


-- >> GLOW

glow.setup({
  glow_path = "/home/eduardotc/.local/bin/glow",
  install_path = "/home/eduardotc/.local/bin",
  border = "shadow",
  style = "dark",
  pager = false,
  width = 100,
  height = 110,
  width_ratio = 0.85,
  height_ratio = 0.85,
})


-- >> COPILOT

require("CopilotChat").setup {
  debug = false,
  highlight_headers = false,
  separator = '---',
  error_header = '> [!ERROR] Error',
  window = {
    layout = "replace",  -- 'vertical', 'horizontal', 'float', 'replace'
    width = 0.5,         -- fractional width of parent, or absolute width in columns when > 1
    height = 0.45,       -- fractional height of parent, or absolute height in rows when > 1
    relative = "editor", -- 'editor', 'win', 'cursor', 'mouse'
    border = "rounded",  -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
    row = nil,           -- row position of the window, default is centered
    col = nil,           -- column position of the window, default is centered
    title = "Copilot",   -- title of chat window
    footer = "---",      -- footer of chat window
    zindex = 1,          -- determines if window is on top or below other floating windows
  },
  mappings = {
    complete = {
      detail = "<C-Space>",
      insert = "<C-Space>",
    },
    close = {
      normal = "q",
      insert = "<C-c>"
    },
    reset = {
      normal = "<C-r>",
      insert = "<C-r>"
    },
    submit_prompt = {
      normal = "<c-x>",
      insert = "<C-x>"
    },
    accept_diff = {
      normal = "<C-y>",
      insert = "<C-y>"
    },
    yank_diff = {
      normal = "gy",
    },
    show_diff = {
      normal = "gd"
    },
    show_system_prompt = {
      normal = "gp"
    },
    show_user_selection = {
      normal = "gs"
    },
  },
}

--vim.api.nvim_create_autocmd("BufEnter", {
  --pattern = "copilot-",
  --callback = function()
    --vim.opt_local.relativenumber = true
    ---- C-p to print last response
    --vim.keymap.set("n", "<C-p>", function()
      --print(require("CopilotChat").response())
    --end, { buffer = true, remap = true })
  --end
--})

-- >> TREESITTER

nvim_treesitter.setup({
  ensure_installed = { "markdown_inline", "html", "yaml", "markdown", "lua", "vim", "latex", "python" },
  --ignore_install = {},
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = true,
    incremental_selection = { enable = true},
    textobjects = { enable = true},
  },
  fold = {
    enable = true,
  },
  incremental_selection = {
    disable = {},
    enable = true,
    keymaps = {
      --init_selection = "",
      --scope_incremental = ""
      node_decremental = "[n",
      node_incremental = "]n",
    },
    module_path = "nvim-treesitter.incremental_selection"
  },
  indent = {
    disable = {},
    enable = false,
    module_path = "nvim-treesitter.indent",
  },
})

-- >> LSP

-- >>>> Icons
lspkind.setup()

-- >>>> Texlab
--lspconfig.texlab.setup {
  --filetypes = { "tex", "bib" },
  --cmd = { "texlab" },
  --single_file_support = true,
  --settings = {
    --auxDirectory = ".",
    --bibtexFormatter = "texlab",
    --build = {
      --args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
      --executable = "latexmk",
      --forwardSearchAfter = true,
      --onSave = true,
    --},
    --chktex = {
      --onEdit = false,
      --onOpenAndSave = false
    --},
    --diagnosticsDelay = 1000,
    --formatterLineLength = 100,
    --forwardSearch = {
      --args = {}
    --},
    --latexFormatter = "latexindent",
    --latexindent = {
      --modifyLineBreaks = true,
    --}
  --},
  --capabilities = capabilities,
--}

-- >>>> Sh
lspconfig.bashls.setup {
  filetypes = { "sh", "zsh", "bash" },
  single_file_support = true,
  capabilities = capabilities,
}

-- >>>> Tsls
lspconfig.ts_ls.setup {
  --on_attach = ts_on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  cmd = { "/home/eduardotc/.local/bin/typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  single_file_support = true,
  init_options = {
    hostInfo = "neovim",
    npmLocation = "/usr/bin/npm",
    tsserver = {
      path = "/home/eduardotc/.local/lsp/vscode-json-languageservice/node_modules/typescript/bin/tsserver",
    },
    useSyntaxServer = "auto",
  },
  settings = {
    typescript = {
      format = {
        semicolons = "remove",
        indentsize = 2,
        tabSize = 0,
        convertTabsToSpaces = true,
        baseIndentSize = 2,
        convertTabsToSpaces = true,
        indentSize = 2,
        indentStyle = 'Smart',
        tabSize = 2,
        trimTrailingWhitespace = true,
        quotePreference = "double",
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        ---@type "auto"|"minimal"|"index"|"js"|
        importModuleSpecifierEnding = "auto",
        ---@type "ignore"|"insert"|"remove"
        semicolons = "remove",
      }
    },
    javascript = {
      format = {
        baseIndentSize = 2,
        convertTabsToSpaces = true,
        indentSize = 2,
        indentStyle = 'Smart',
        tabSize = 2,
        trimTrailingWhitespace = true,
        quotePreference = "double",
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        ---@type "auto"|"minimal"|"index"|"js"|
        importModuleSpecifierEnding = "auto",
        ---@type "ignore"|"insert"|"remove"
        semicolons = "remove",
      },
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        ---@type "none"|"literals"|"all"
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
        showOnAllFunctions = true,
      },
    },
  },
  implicitProjectConfiguration = {
    checkJs = true,
    experimentalDecorators = true,
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
    .make_client_capabilities()),
}


-- >>>> Jedi
lspconfig.jedi_language_server.setup({
  filetypes = { "python", "markdown" },
  cmd = { "/home/eduardotc/miniforge3/envs/nvim/bin/jedi-language-server" },
  single_file_support = true,
  initializationOptions = {
    codeAction = {
      nameExtractVariable = "jls_extract_var",
      nameExtractFunction = "jls_extract_def",
      refactorInline = "refactori_inline",
    },
    completion = {
      disableSnippets = false,
      resolveEagerly = true,
      ignorePatterns = {
        "**/tests/**",
        "**/__**__/**",
        "**/.bzr/**",
        "**/.direnv/**",
        "**/.eggs/**",
        "**/.git/**",
        "**/.git-rewrite/**",
        "**/.hg/**",
        "**/.ipynb_checkpoints/**",
        "**/.mypy_cache/**",
        "**/.nox/**",
        "**/.pants.d/**",
        "**/.pyenv/**",
        "**/.jukit/**",
        "**/.pytest_cache/**",
        "**/.pytype/**",
        "**/.ruff_cache/**",
        "**/.svn/**",
        "**/.tox/**",
        "**/.venv/**",
        "**/.vscode/**",
        "**/__pypackages__/**",
        "**/_build/**",
        "**/buck-out/**",
        "**/dist/**",
        "**/node_modules/**",
      },
    },
    diagnostics = {
      enable = true,
      didOpen = true,
      didChange = true,
      didSave = true,
    },
    hover = {
      enable = true,
      disable = {
        class = {
          all = false,
          names = {},
          fullNames = {},
        },
        functions = {
          all = false,
        },
        instance = {
          all = false,
          names = {},
          fullNames = {},
        },
        module = {
          all = false,
          names = {},
          fullNames = {},
        },
        param = {
          all = false,
          names = {},
          fullNames = {},
        },
        path = {
          all = false,
          names = {},
          fullNames = {},
        },
        property = {
          all = false,
          names = {},
          fullNames = {},
        },
        statement = {
          all = false,
          names = {},
          fullNames = {},
        },
      },
    },
    jediSettings = {
      autoImportModules = {
        "numpy",
        "numpydoc",
        "subprocess",
        "pandas",
        "os",
        "re",
        "typing",
        "sys",
      },
      caseInsensitiveCompletion = true,
      debug = false,
    },
    markupKindPreferred = "markdown",
    workspace = {
      extraPaths = {
        "/home/eduardotc/.local/kitty",
        "/home/eduardotc/Programming/python/my_modules",
      },
      symbols = {
        ignoreFolders = {
          ".nox",
          ".git",
          ".jukit",
          ".pycache",
          ".tox",
          ".venv",
          "__pycache__",
          "venv",
        },
        maxSymbols = 30,
      }
    },
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
    .make_client_capabilities()),
})

-- >>>> Ruff
require("lspconfig").ruff.setup({
  filetypes = { "python" },
  single_file_support = true,
  init_options = {
    settings = {
      exclude = {
        "**/tests/**",
        "**/__**__/**",
        "**/.bzr/**",
        "**/.direnv/**",
        "**/.eggs/**",
        "**/.git/**",
        "**/.git-rewrite/**",
        "**/.hg/**",
        "**/.ipynb_checkpoints/**",
        "**/.mypy_cache/**",
        "**/.nox/**",
        "**/.pants.d/**",
        "**/.pyenv/**",
        "**/.jukit/**",
        "**/.pytest_cache/**",
        "**/.pytype/**",
        "**/.ruff_cache/**",
        "**/.svn/**",
        "**/.tox/**",
        "**/.venv/**",
        "**/.vscode/**",
        "**/__pypackages__/**",
        "**/_build/**",
        "**/buck-out/**",
        "**/dist/**",
        "**/node_modules/**",
      },
      lineLength = 100,
      logLevel = "debug",
      logFile = "/home/eduardotc/Programming/logs/ruff.log",
      configuration = "/home/eduardotc/.config/nvim/ruff.toml",
      fixAll = true,
      ---@type "editorOnly"|"filesystemFirst"|"editorFirst"
      configurationPreference = "editorOnly",
      organizeImports = true,
      showSyntaxErrors = true,
      codeAction = {
        disableRuleComment = {
          enable = true,
        },
        fixViolation = {
          enable = true,
        },
      },
      format = {
        preview = true,
      },
      check = {
        enable = true,
      },
      --"D201",   -- No blank lines allowed before function docstring (found(num_lines))
      --"D202",   -- No blank lines allowed after function docstring (found {num_lines})
      --"D203",   -- 1 blank line required before class docstring
      --"D204",   -- 1 blank line required after class docstring
      --"D211",   -- No blank lines allowed before class docstring
      lint = {
        enable = true,
        preview = true,
        select = {
          "E",      -- Pycodestyle
          "W",      -- Warning
          "F",      -- Pyflakes
          "N",      -- Pep8-naming
          "UP",     -- Pyupgrade
          "B",      -- Flake8-bugbear
          "ANN",    -- Flake8-annotations
          "ASYNC",  -- Flake8-assync
          "A",      -- Flake8-builtins
          "COM",    -- Flake8-commas
          "C4",     -- Flake8-comprehensions
          "SIM",    -- Flake8-simplify
          "TC",     -- Flake8-type-checking
          "ARG",    -- Flake8-unused-arguments
          "TD",     -- Flake8-todos
          "FIX",    -- Flake8-fixme
          "PD",     -- Pandas-vet
          "PL",     -- Pylint
          "PLE",    -- Error
          "PLW",    -- Warning
          "NPY",    -- Numpy-specific-rules
          "PERF",   -- Perflint
          "RUF",    -- Ruff
          "EM",     -- Flake8-errmsg
          "I",      -- Isort
          "Q",      -- Flake8-quotes
          "D100",   -- Missing docstring in public module
          "D101",   -- Missing docstring in public class
          "D102",   -- Missing docstring in public method
          "D103",   -- Missing docstring in public function
          "D104",   -- Missing docstring in public package
          "D105",   -- Missing docstring in magic method
          "D106",   -- Missing docstring in public nested class
          "D107",   -- Missing docstring in __init__
          "D200",   -- One-line docstring should fit on one line
          "D205",   -- 1 blank line required between summary line and description
          "D206",   -- Docstring should be indented with spaces, not tabs
          "D207",   -- Docstring is under-indented
          "D208",   -- Docstring is over-indented
          "D209",   -- Multi-line docstring closing quotes should be on a separate line
          "D210",   -- No whitespaces allowed surrounding docstring text
          "D213",   -- Multi-line docstring summary should start at the second line
          "D214",   -- Section is over-indented ("{name}")
          "D215",   -- Section underline is over-indented ("{name}")
          "D300",   -- Use triple double quotes """
          "D301",   -- Use r""" if any backslashes in a docstring
          "D400",   -- First line should end with a period
          "D401",   -- First line of docstring should be in imperative mood: "{first_line}"
          "D402",   -- First line should not be the function's signature
          "D403",   -- First word of the docstring should be capitalized: {} -> {}
          "D404",   -- First word of the docstring should not be "This"
          "D405",   -- Section name should be properly capitalized ("{name}")
          "D406",   -- Section name should end with a newline ("{name}")
          "D407",   -- Missing dashed underline after section ("{name}")
          "D408",   -- Section underline should be in the line following the section's name ("{name}")
          "D409",   -- Section underline should match the length of its name ("{name}")
          "D410",   -- Missing blank line after section ("{name}")
          "D411",   -- Missing blank line before section ("{name}")
          "D412",   -- No blank lines allowed between a section header and its content ("{name}")
          "D414",   -- Section has no content ("{name}")
          "D415",   -- First line should end with a period, question mark, or exclamation point
          "D416",   -- Section name should end with a colon ("{name}")
          "D418",   -- Function decorated with @overload shouldn't contain a docstring
          "D419",   -- Docstring is empty
        },
        ignore = {
          "D212",   -- Multi-line docstring summary should start at the first line
          "D413",   -- Missing blank line after last section ("{name}")
          "PLR",    -- Refactor
          "D417",   -- Missing argument description in the docstring for {definition}: {name}
        },
      },
    }
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
})

-- >>>> Harper_ls
lspconfig.harper_ls.setup {
  filetypes = { "gitcommit", "html", "markdown", "latex", "pandoc", "tex", "text", "plaintext" },
  cmd = {"harper-ls", "--stdio"},
  single_file_support = true,
  settings = {
    ["harper-ls"] = {
      userDictPath = "~/.harper/dict.txt",
      fileDictPath = "~/.harper/",
      root_dir = vim.fn.getcwd(),
      diagnosticSeverity = "hint",
      linters = {
        spell_check = true,
        spelled_numbers = false,
        an_a = true,
        sentence_capitalization = true,
        unclosed_quotes = true,
        wrong_quotes = false,
        long_sentences = true,
        repeated_words = true,
        spaces = true,
        matcher = true,
        correct_number_suffix = true,
        number_suffix_capitalization = true,
        multiple_sequential_pronouns = true,
        linking_verbs = false,
        avoid_curses = true,
        terminating_conjunctions = true
      },
      codeActions = {
        forceStable = true
      }
    }
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

-- >>>> Lua Ls
lspconfig.lua_ls.setup({
  cmd = { "/home/eduardotc/.local/lsp/lua-language-server/bin/lua-language-server" },
  filetypes = { "lua" },
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        enable = true,
        globals = { "vim" },
      },
      hint = {
        enable = true,
      },
      workspace = {
        ibrary = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.stdpath('config') .. '/lua'] = true,
        },
        maxPreload = 10000,
        preloadFileSize = 1500,
        checkThirdParty = true,
        --library = vim.api.nvim_get_runtime_file("", true),
      },
       telemetry = {
        enable = true, -- Disable telemetry
      },
      codeLens = {
        enable = true,
      },
      completion = {
        enable = true,
        showParams = true,
      },
      hover = {
        enable = true,
        expandAlias = true,
        previewFields = true,
      },
      signatureHelp = {
        enable = true,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "4",
          quote_style = "double",
          continuation_indent_size = "4",
          max_line_length = "100",
        }
      },
    },
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
    .make_client_capabilities()),
})

-- >>>> jsonls
lspconfig.jsonls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      validate = { enable = true },
      allowComments = true,
      schemas = require("schemastore").json.schemas(),
      format = { enable = true },
    },
  },
  flags = {
    debounce_text_changes = 150,
  },
})

-- >> MARKDOWN

-- >>>> Preview
g.mkdp_auto_start = 0
g.mkdp_auto_close = 1
g.mkdp_refresh_slow = 0
g.mkdp_command_for_global = 0
g.mkdp_open_to_the_world = 0
g.mkdp_open_ip = ""
g.mkdp_browser = "/home/eduardotc/.local/floorp/obj-x86_64-pc-linux-gnu/dist/bin/floorp -P Du --name Floorp --new-tab"
g.mkdp_echo_preview_url = 0
g.mkdp_browserfunc = ""

g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  uml = {},
  maid = {},
  disable_sync_scroll = 0,
  sync_scroll_type = "middle",
  hide_yaml_meta = 1,
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,
  disable_filename = 0,
  toc = {}
}

g.mkdp_page_title = "「${name}」"
g.mkdp_images_path = "/home/eduardotc/Pictures/.markdown_images"
g.mkdp_filetypes = { "markdown" }
g.mkdp_theme = "dark"
g.mkdp_combine_preview = 0
g.mkdp_combine_preview_auto_refresh = 1


-- >>>> Render
require("render-markdown").setup({
  enabled = true,
  max_file_size = 20.0,
  debounce = 100,
  ---@type "'lazy'"|"'obsidian'"|"'none'"
  preset = "none",
  log_level = "error",
  file_types = { "markdown", "copilot-chat" },
  injections = {
    gitcommit = {
      enabled = true,
      query = [[
        ((message) @injection.content
            (#set! injection.combined)
            (#set! injection.include-children)
            (#set! injection.language "markdown"))
        ]],
    },
  },
  render_modes = { "n", "c" },
  anti_conceal = {
    enabled = true,
    ignore = {
      code_background = true,
      sign = true,
    },
    above = 0,
    below = 0,
  },
  latex = {
    enabled = true,
    converter = "latex2text",
    highlight = "RenderMarkdownMath",
    top_pad = 0,
    bottom_pad = 0,
  },
  on = {
    attach = function() end,
  },
  heading = {
    enabled = true,
    sign = true,
    ---@type "'inline'"|"'overlay'"
    position = "inline",
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    signs = { "󰫎 " },
    ---@type "'block'"|"'full'"
    width = "full",
    left_margin = 0,
    left_pad = 0,
    right_pad = 0,
    min_width = 0,
    border = false,
    border_prefix = false,
    above = "▄",
    below = "▀",
    backgrounds = {
      "RenderMarkdownH1Bg",
      "RenderMarkdownH2Bg",
      "RenderMarkdownH3Bg",
      "RenderMarkdownH4Bg",
      "RenderMarkdownH5Bg",
      "RenderMarkdownH6Bg",
    },
    foregrounds = {
      "RenderMarkdownH1",
      "RenderMarkdownH2",
      "RenderMarkdownH3",
      "RenderMarkdownH4",
      "RenderMarkdownH5",
      "RenderMarkdownH6",
    },
  },
  paragraph = {
    enabled = true,
    left_margin = 0,
    min_width = 0,
  },
  code = {
    enabled = true,
    sign = true,
    ---@type "full"|"language"|"normal"|"none"
    style = "full",
    position = "left",
    language_pad = 0,
    disable_background = { "diff" },
    width = "full",
    left_margin = 0,
    left_pad = 0,
    right_pad = 0,
    min_width = 0,
    ---@type "thin"|"thick"
    border = "thin",
    above = "▄",
    below = "▀",
    ---@type "RenderMarkdownCode"|"ColorColumn"
    highlight = "RenderMarkdownCode",
    highlight_inline = "RenderMarkdownCodeInline",
    highlight_language = nil,
  },
  dash = {
    enabled = true,
    icon = "─",
    ---@type integer|"full"
    width = "full",
    highlight = "RenderMarkdownDash",
  },
  bullet = {
    enabled = true,
    icons = { "●", "○", "◆", "◇" },
    left_pad = 0,
    right_pad = 0,
    highlight = "RenderMarkdownBullet",
  },
  checkbox = {
    enabled = true,
    ---@type "inline"|"overlay"
    position = "inline",
    unchecked = {
      --󰄱
      icon = " ",
      highlight = "RenderMarkdownUnchecked",
    },
    checked = {
      --󰱒
      icon = " ",
      highlight = "RenderMarkdownChecked",
    },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
    },
  },
  quote = {
    enabled = true,
    icon = "▋",
    repeat_linebreak = false,
    highlight = "RenderMarkdownQuote",
  },
  pipe_table = {
    enabled = true,
    ---@type "heavy"|"double"|"round"|"none"
    preset = "round",
    ---@type "none"|"normal"|"full"
    style = "full",
    ---@type "overlay"|"raw"|"padded"
    cell = "padded",
    alignment_indicator = "━",
    border = {
      "┌", "┬", "┐",
      "├", "┼", "┤",
      "└", "┴", "┘",
      "│", "─",
    },
    head = "RenderMarkdownTableHead",
    row = "RenderMarkdownTableRow",
    filler = "RenderMarkdownTableFill",
  },
  callout = {
    abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
    attention = { raw = "[!ATTENTION]", rendered = "󰀪 Attention", highlight = "RenderMarkdownWarn" },
    bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
    caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
    check = { raw = "[!CHECK]", rendered = "󰄬 Check", highlight = "RenderMarkdownSuccess" },
    cite = { raw = "[!CITE]", rendered = "󱆨 Cite", highlight = "RenderMarkdownQuote" },
    debug = { raw = "[!DEBUG]", rendered = "  Debug", highlight = "#DFD26E" },
    danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
    done = { raw = "[!DONE]", rendered = "󰄬 Done", highlight = "RenderMarkdownSuccess" },
    error = { raw = "[!ERROR]", rendered = "󱐌 Error", highlight = "RenderMarkdownError" },
    example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
    fail = { raw = "[!FAIL]", rendered = "󰅖 Fail", highlight = "RenderMarkdownError" },
    failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
    faq = { raw = "[!FAQ]", rendered = "󰘥 Faq", highlight = "RenderMarkdownWarn" },
    fix = { raw = "[!FIX]", rendered = "  Fix", highlight = "#F1FA8C" },
    hack = { raw = "[!HACK]", rendered = "󰈸  Hack", highlight = "#E70F54" },
    help = { raw = "[!HELP]", rendered = "󰘥 Help", highlight = "RenderMarkdownWarn" },
    hint = { raw = "[!HINT]", rendered = "󰌶 Hint", highlight = "RenderMarkdownSuccess" },
    info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
    important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
    missing = { raw = "[!MISSING]", rendered = "󰅖 Missing", highlight = "RenderMarkdownError" },
    note = { raw = "[!NOTE]", rendered = "󱓧  Note", highlight = "#3EEF91" },
    perf = { raw = "[!PERF]", rendered = "󱑆  Performance", highlight = "#C071CA" },
    question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
    quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
    success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
    summary = { raw = "[!SUMMARY]", rendered = "󰨸 Summary", highlight = "RenderMarkdownInfo" },
    test = { raw = "[!TEST]", rendered = "󰸠  Test", highlight = "#52CDCF" },
    tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
    tldr = { raw = "[!TLDR]", rendered = "󰨸 Tldr", highlight = "RenderMarkdownInfo" },
    todo = { raw = "[!TODO]", rendered = "  Todo", highlight = "#7f75ef" },
    warning = { raw = "[!WARNING]", rendered = "  Warning", highlight = "RenderMarkdownWarn" },
    --note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
    --todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
    --warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
    -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
  },
  link = {
    enabled = true,
    image = "󰥶 ",
    hyperlink = "󰌹 ",
    highlight = "RenderMarkdownLink",
    custom = {
      web = { pattern = "^http[s]?://", icon = "󰖟 ", highlight = "RenderMarkdownLink" },
    },
  },
  sign = {
    enabled = true,
    highlight = "RenderMarkdownSign",
  },
  indent = {
    enabled = false,
    per_level = 2,
    skip_level = 1,
    skip_heading = false,
  },
  win_options = {
    conceallevel = {
      default = vim.api.nvim_get_option_value("conceallevel", {}),
      rendered = 3,
    },
    concealcursor = {
      default = vim.api.nvim_get_option_value("concealcursor", {}),
      rendered = "",
    },
  },
  overrides = {
    buftype = {
      nofile = { sign = { enabled = false } },
    },
    filetype = {},
  },
  custom_handlers = {},
})
vim.treesitter.language.register("markdown", "vimwiki")

---Tree sitter .py files type special highlighting for jukit like files
---@parm bufnr number Number of the python running buffer
---Function to define custom highlights for r"""°°° blocks in Python
local function highlight_special_python_block(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local start_pattern = 'r"""\194\176\194\176\194\176'
  local end_pattern = '\194\176\194\176\194\176"""'
  local triple_str = '"""'
  local is_highlighting = false
  local str_is_highlighting = false
  StartLine = nil

  for line_num, line_content in ipairs(lines) do
    if line_content:find(start_pattern) then
      -- Start highlighting the block
      is_highlighting = true
      StartLine = line_num - 1 -- Line numbers in Neovim are 0-indexed
    elseif line_content:find(triple_str) then
      str_is_highlighting = true
      str_StartLine = line_num - 1 -- Line numbers in Neovim are 0-indexed
    elseif line_content:find(triple_str) and str_is_highlighting then
      vim.api.nvim_buf_add_highlight(bufnr, -1, "TestePy", str_StartLine, 0, -1)
      vim.api.nvim_buf_add_highlight(bufnr, -1, "TestePy", line_num - 1, 0, -1)
      str_is_highlighting = false
    elseif line_content:find(end_pattern) and is_highlighting then
      -- End highlighting the block
      vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonBlockBg", StartLine, 0, -1)
      vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonBlockBg", line_num - 1, 0, -1)
      is_highlighting = false
    elseif is_highlighting then
      -- Apply background color to all lines in the block
      vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonBlockBg", line_num - 1, 0, -1)

      -- Header level highlights based on number of `#` characters
      if line_content:find("^###") then
        vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonHeaderLevel3", line_num - 1, 0, -1)
      elseif line_content:find("^##") then
        vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonHeaderLevel2", line_num - 1, 0, -1)
      elseif line_content:find("^#") then
        vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonHeaderLevel1", line_num - 1, 0, -1)

        -- List items that begin with `-`
      elseif line_content:find("^%s*%-") then
        vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonList", line_num - 1, 0, -1)

        -- Regular lines inside the block
      else
        vim.api.nvim_buf_add_highlight(bufnr, -1, "SpecialPythonBlock", line_num - 1, 0, -1)
      end
    end
  end
end

--Hook the function to Python filetype
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    highlight_special_python_block(bufnr)
  end,
})

vim.cmd [[
  highlight SpecialPythonBlock guifg=#d7dae6 guibg=#3e3258
  highlight SpecialPythonList guifg=#e66793 gui=italic guibg=#3e3258
  highlight SpecialPythonBlockBg guibg=#3e3258 guibg=#3e3258
  highlight SpecialPythonHeaderLevel1 guifg=#28dff3 guibg=#3e3258
  highlight SpecialPythonHeaderLevel2 guifg=#9d14ff guibg=#3e3258
  highlight SpecialPythonHeaderLevel3 guifg=#87CEEB guibg=#3e3258
  highlight SpecialPythonHeader guifg=#71ff3d guibg=#3e3258
  highlight TestePy guifg=#c439eb
]]

vim.cmd [[highlight SpecialPythonBlock guifg=#7c7eff guibg=#fff189]]

-- >> NOICE

noice.setup({
  cmdline = {
    enabled = true,         -- enables the Noice cmdline UI
    view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
    opts = {},              -- global options for the cmdline. See section on views
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "󰽥 ", lang = "lua" },
      help = { pattern = { "^:%s*he?l?p?%s+", "^:%s*He?l?p?%s+" }, icon = " " },
      input = {}, -- Used by input()
    },
  },
  format = {
    level = {
      icons = {
        error = " ",
        warn = " ",
        hint = "󰛩 ",
        info = " ",
        other = "󰌕 ",
      },
    },
  },
  messages = {
    enabled = true,               -- enables the Noice messages UI
    view = "notify",              -- default view for messages
    view_error = "notify",        -- view for errors
    view_warn = "notify",         -- view for warnings
    view_history = "virtualtext", -- view for :messages
    view_search = false,          -- view for search count messages. Set to `false` to disable
  },
  popupmenu = {
    enabled = true,  -- enables the Noice popupmenu UI
    ---@type 'nui'|'cmp'
    backend = "cmp", -- backend to use to show regular cmdline completions
    kind_icons = true,
  },
  redirect = {
    view = "popup",
    filter = { event = "msg_show" },
  },
  commands = {
    history = {
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp",      kind = "message" },
        },
      },
    },
    -- :Noice last
    last = {
      view = "popup",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp",      kind = "message" },
        },
      },
      filter_opts = { count = 1 },
    },
    -- :Noice errors
    errors = {
      --options for the message history that you get with `:Noice`
      view = "popup",
      opts = { enter = true, format = "details" },
      filter = { error = true },
      filter_opts = { reverse = true },
    },
    all = {
      -- options for the message history that you get with `:Noice`
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {},
    },
  },
  notify = {
    enabled = true,
    view = "notify",
  },
  lsp = {
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30, -- frequency to update lsp progress message
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    hover = {
      enabled = true,
      silent = true, -- set to true to not show a message if hover is not available
      view = nil,    -- when nil, use defaults from documentation
      opts = {},     -- merged with defaults from documentation
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
        throttle = 50,  -- Debounce lsp signature help request by 50ms
      },
      view = "hover",   -- when nil, use defaults from documentation
      opts = {
        lang = "markdown",
        replace = true,
        render = "markdown_inline",
        win_options = { concealcursor = "n", conceallevel = 3 },
      },
    },
    message = {
      enabled = true,
      view = "notify",
      opts = {},
    },
    documentation = {
      view = "hover",
      opts = {
        lang = "markdown",
        replace = true,
        ---@type "plain"|"markdown_inline"
        render = "markdown_inline",
        format = { "{message}" },
        win_options = { concealcursor = "n", conceallevel = 3 },
      },
    },
  },
  markdown = {
    hover = {
      ["|(%S-)|"] = vim.cmd.help,                       -- vim help links
      ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
    },
    highlights = {
      ["|%S-|"] = "@text.reference",
      ["@%S+"] = "@parameter",
      ["^%s*(Parameters:)"] = "text.title",
      ["^%s*(Return:)"] = "@text.title",
      ["^%s*(See also:)"] = "@text.title",
      ["{%S-}"] = "@parameter",
    },
  },
  health = {
    checker = true,
  },
  smart_move = {
    enabled = true, -- you can disable this behaviour here
    --excluded_filetypes = { "markdown", "noice" },
  },
  presets = {
    bottom_search = false,         -- use a classic bottom cmdline for search
    command_palette = false,       -- position the cmdline and popupmenu together
    long_message_to_split = false, -- long messages will be sent to a split
    inc_rename = true,             -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true,         -- add a border to hover docs and signature help
  },
  routes = {
    {
      view = "split",
      filter = { event = "msg_show", min_height = 20 },
    },
    {
      filter = { event = "msg_show", kind = "search_count" },
      opts = { skip = true },
    },
    {
      filter = {
        event = "msg_show",
        min_height = 10,
        ["not"] = { kind = { "search_count", "echo" } },
      }
    }
  }
})


-- >> TODO

todo.setup({
  signs = true,
  sign_priority = 1000,
  keywords = {
    FIX   = {
      icon = " ",
      color = "#F1FA8C",
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO  = { icon = " ", color = "#7f75ef" },
    HACK  = { icon = "󰈸 ", color = "#e2e787" },
    WARN  = { icon = " ", color = "#e70f54", alt = { "WARNING", "XXX" } },
    PERF  = { icon = "󱑆 ", color = "#c071ca", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE  = { icon = "󱓧 ", color = "#3eef91", alt = { "INFO" } },
    TEST  = { icon = "󰸠 ", color = "#52cdcf", alt = { "TESTING", "PASSED", "FAILED" } },
    DEBUG = { icon = " ", color = "#dfd26e", alt = { "PRINT", "DELETE", "REMOVE" } },
    CHECK = { icon = "󱓧 ", color = "#ecc5a6", alt = { "CONFIRM", "SEE", "ASSERT" } },

  },
  gui_style = {
    fg = "NONE", -- The gui style to use for the fg highlight group.
    bg = "BOLD", -- The gui style to use for the bg highlight group.
  },
  merge_keywords = true,
  highlight = {
    multiline = true,
    multiline_pattern = "^.",
    multiline_context = 10,
    before = "",
    keyword = "wide",
    after = "fg",
    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
    comments_only = true,
    max_line_len = 400,
    exclude = {}, -- list of file types to exclude highlighting
  },
  colors = {
    error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
    warning = { "DiagnosticWarn", "WarningMsg", "#F1FA8C" },
    info = { "DiagnosticInfo", "#8BE9FD" },
    hint = { "DiagnosticHint", "#BD93F9" },
    default = { "Identifier", "#BD93F9" },
    test = { "Identifier", "#FF79C6" }
  },
  search = {
    command = "rg",
    args = {
      "--color=always",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
    },
    pattern = [[\b(KEYWORDS):]], -- ripgrep regex
  },
})


-- >> EASYPICKS

easypick.setup({
  pickers = {
    {
      name = "ls",
      command = "ls",
      previewer = easypick.previewers.default()
    },
    {
      name = "changed_files",
      command = "git diff --name-only $(git merge-base HEAD " .. base_branch .. " )",
      previewer = easypick.previewers.branch_diff({ base_branch = base_branch })
    },
    {
      name = "conflicts",
      command = "git diff --name-only --diff-filter=U --relative",
      previewer = easypick.previewers.file_diff()
    },
    {
      name = "LaTeX",
      command =
      "fd -t f -e .tex -d 3 --search-path '/home/eduardotc/Programming/LaTeX' --base-directory '/home/eduardotc/Programming/LaTeX' .",
      previewer = easypick.previewers.default()
    },
    {
      name = "ttt",
      command = "fd -t f -e .tex -d 3 --base-directory '/home/eduardotc/Programming/LaTeX'",
      previewer = easypick.previewers.default()
    },
  }
})


-- >> TROUBLE

trouble.setup({
  auto_refresh = true,
  focus = true,
  follow = true,
  indent_guides = true,
  max_items = 200,
  pinned = true,

  position = "right", -- position of the list can be: bottom, top, left, right
  height = 13,        -- height of the trouble list when position is top or bottom
  restore = true,
  max_itens = 100,
  width = 150, -- width of the list when position is left or right
  icons = {
    indent        = {
      top         = "│ ",
      middle      = "├╴",
      last        = "└╴",
      fold_open   = " ",
      fold_closed = " ",
      ws          = "  ",
    },
    folder_closed = " ",
    folder_open   = " ",
    kinds         = {
      Array         = " ",
      Boolean       = " ",
      Class         = " ",
      Constant      = " ",
      Constructor   = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = "󱐋",
      Field         = " ",
      File          = "",
      Function      = "󰊕 ",
      Interface     = "",
      Key           = "󰀬 ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮",
      Null          = "󰟢 ",
      Number        = " ",
      Object        = " ",
      Operator      = "",
      Package       = " ",
      Property      = " ",
      String        = " ",
      Struct        = " ",
      TypeParameter = "󰰤 ",
      Variable      = "󰀫 ",
    },
  },
})


-- >> HARPOON

require("harpoon").setup({
  save_on_toggle = true,
  save_on_change = true,
  enter_on_sendcmd = true,
  tmux_autoclose_windows = false,
  excluded_filetypes = { "harpoon" },
  mark_branch = false,
  tabline = true,
  tabline_prefix = "󰛢",
  tabline_suffix = "",
})


-- >> TELESCOPE

---- >> Defaults
telescope.setup({
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_mru = true,
      mappings = {
        i = {
          ["<a-d>"] = "delete_buffer",
        },
      },
    },
  },
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "normal",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "cursor",
    use_less = true,
    set_env = { COLORTERM = "truecolor", ... },
    color_devicons = true,
    marks = require("telescope.builtin").marks,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "smart" },
    winblend = 5,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    layout_config = {
      bottom_pane = {
        height = 0.30,
        preview_cutoff = 120,
        prompt_position = "top"
      },
      center = {
        height = 0.55,
        preview_cutoff = 40,
        prompt_position = "top",
        width = 0.65
      },
      cursor = {
        height = 0.75,
        preview_cutoff = 35,
        width = 0.80,
        prompt_position = "bottom",
        mirror = false
      },
      horizontal = {
        height = 0.9,
        preview_cutoff = 10,
        preview_width = 0.6,
        prompt_position = "bottom",
        width = 0.85
      },
      vertical = {
        height = 0.9,
        preview_cutoff = 40,
        prompt_position = "bottom",
        width = 0.8,
        mirror = false
      }
    },
    mappings = {
      i = {
        -- for insert mode
        ["<C-d>"] = "preview_scrolling_down",
        ["<C-u>"] = "preview_scrolling_up",
        ["<A-S-h>"] = "preview_scrolling_left",
        ["<A-S-l>"] = "preview_scrolling_right",
        ["<C-j>"] = {
          actions.move_selection_next,
          type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<C-n>"] = {
          actions.move_selection_next,
          type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<C-k>"] = {
          actions.move_selection_previous,
          type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<C-p>"] = {
          actions.move_selection_previous,
          type = "action",
          opts = { nowait = true, silent = true }
        },
      },
      n = {
        -- for normal mode
        ["h"] = "preview_scrolling_left",
        ["l"] = "preview_scrolling_right",
        ["<C-d>"] = "preview_scrolling_down",
        ["<C-x>"] = { "<cmd>lua DuMod.delete_mark()<CR>", type = "command" },
        ["<C-0>"] = { "<cmd> delm!<CR>", type = "command" },
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-h>"] = { "<cmd> Telescope<CR>", type = "command" },
        ["k"] = "move_selection_previous",
        ["j"] = "move_selection_next",
        ["<C-c>"] = require("telescope.actions").close,
      },
    },
  },
})

---- >> Extensions
telescope.load_extension("harpoon")
telescope.load_extension("file_browser")
telescope.load_extension("fzf")
telescope.load_extension("media_files")
telescope.load_extension("menu")
telescope.load_extension("notify")
telescope.load_extension("ui-select")
telescope.load_extension("recent_files")
telescope.load_extension("ui-select")
telescope.load_extension("noice")

telescope.setup({
  extensions = {
    cheatsheets = {
      bundled_cheetsheets = {
        enabled = { "default" },
        disabled = { "nerd-fonts", "file-vim", "search-vim", "navigation-vim", "text-manipulation-vim" },
      },
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
        codeactions = true,
      },
    },
    -- du_preview = {},
    file_browser = {},
    thesaurus = {
      provider = "datamuse",
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    media_files = {
      filetypes = { "png", "jpg", "pdf", "svg" },
      find_cmd = "fd"
    },
    recent_files = {},
  },
  extensions_list = { "themes", "terms" },
})

telescope.register_extension("harpoon")
telescope.register_extension("ui-select")
telescope.register_extension("file_browser")
telescope.register_extension("fzf")
telescope.register_extension("media_files")
telescope.register_extension("menu")
telescope.register_extension("notify")
telescope.register_extension("recent_files")
telescope.register_extension("noice")
