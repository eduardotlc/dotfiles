local M = {}
local pickers = require'telescope.pickers'
local finders = require'telescope.finders'
local previewers = require'telescope.previewers'
local conf = require'telescope.config'.values
local action_state = require'telescope.actions.state'
local actions = require'telescope.actions'
local Path = require('plenary.path')
local previewers = require('telescope.previewers')
local find_files = require('telescope.builtin').find_files
function M.TelescopeMd()

  local base_path = vim.fn.expand("~/Programação/markdown")
  local cmd = string.format("fd --type f '.md$' %s", vim.fn.shellescape(base_path))

  local files = vim.fn.systemlist(cmd)

  if vim.v.shell_error > 0 then
    print("Error listing files. Command output:", table.concat(files, "\n"))
    return
  end

  local options = {}

  for _, file_path in ipairs(files) do
    local relative_path = file_path:sub(#base_path + 2) -- '+2' to remove the base path and the leading '/'
    table.insert(options, {relative_path, file_path})
  end

  pickers.new({}, {
    layout_config = {
        horizontal = {
          height = 0.9,
          mirror = false,
          preview_cutoff = 120,
          preview_width = 0.55,
          prompt_position = "bottom",
          width = 0.85,
          },
        },
    prompt_title = 'Markdown',

    finder = finders.new_table {
      results = options,

      entry_maker = function(entry)
        return {
          value = entry[2], -- full path for actions
          display = entry[1], -- relative path for display
          ordinal = entry[1], -- relative path for sorting and searching
        }
      end,
    },

    sorter = conf.generic_sorter({}),

    previewer = previewers.new_termopen_previewer({
      get_command = function(entry)
        return {"bat", "-l=markdown", "--color=always", "--theme=Dracula", "-p", entry.value}
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd('edit ' .. vim.fn.fnameescape(selection.value)) -- Edit in neovim
        vim.fn.system('floorp --new-tab') -- Open floorp browser new tab
        vim.cmd('MarkdownPreview') -- Execute MarkdownPreview
      end)
      return true
    end,
  }):find()
end

function M.TelescopeDucmd()
  -- Loading Telescope modules


  -- Defining base_path and finder command
  vim.fn.system("bash ~/Programação/bash/ducommandsdir.sh")
  local base_path = vim.fn.expand("~/Programação/bash/ducommandsdir")
  local cmd = string.format("fd --type f '' %s", vim.fn.shellescape(base_path))
  -- Returning the finder command
  local files = vim.fn.systemlist(cmd)

  -- Case vimm shell return execution error
  if vim.v.shell_error > 0 then
    print("Error listing files. Command output:", table.concat(files, "\n"))
    return
  end

  -- Initing telescope picker options
  local options = {}

  -- Iterating over the finder command results
  for _, file_path in ipairs(files) do
    -- Getting relative path (removing what comes before the markdown folder)
    local relative_path = file_path:sub(#base_path + 2) -- '+2' to remove the base path and the leading '/'

    -- Getting second line of readed file, removing the bash highlight and blank white spaces
    local search_str = vim.fn.system('sed -n 2p ' .. file_path .. '|sed -r "s/\\x1B\\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed -r "s/[[:blank:]]*$//"')

    -- Inseting in the options table the relative and the full path from each file
    table.insert(options, {relative_path, file_path, search_str})
  end


  -- STARTING NEW PICKER
  pickers.new({}, {
    layout_config = {
      horizontal = {
        height = 0.9,
        mirror = false,
        preview_cutoff = 120,
        preview_width = 0.75,
        prompt_position = "bottom",
        width = 0.85,
        },
      },

    -- Defining telescope prompt title
    prompt_title = 'Ducommands',

    -- Starting new finders table
    finder = finders.new_table {
      -- Making the finder results to be the options table, defined above with file relative and full path
      results = options,

      -- Starting telescope entry maker function
      entry_maker = function(entry)
        return {
          value = entry[2], -- full path for actions
          display = entry[1], -- relative path for display
          ordinal = entry[1], -- relative path for sorting and searching
          strcmd = entry[3]
        }
      end,
    },

    -- Defining picker sorter
    sorter = conf.generic_sorter({}),

    -- Defining picker previewer
    previewer = previewers.new_termopen_previewer({
      get_command = function(entry)
        -- executing bat to display in the previewer, with language markdown, always
        -- displaying olor, the Dracula theme, and plain style
        return {"bat", "--color=always", "--theme=Dracula", "-p", entry.value}
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd('edit ~/Programação/bash/ducommands')
        vim.cmd('/' .. selection.strcmd)
      end)
      return true
    end,
  }):find()
end


-- Function to insert the selected value
local function insert_value(entry)
  vim.api.nvim_put({entry}, '', false, true)
end

-- Submenu picker function with dynamic options
local function submenu_picker(entry)

  -- Determine submenu options based on initial selection
  local submenu_options = {}
  if entry == "Dracula" then
    submenu_options = {
      {"Background",       "#282a36", "40 42 54"},
      {"Current Line",     "#44475a", "68 71 90"},
      {"Selection",        "#44475a", "68 71 90"},
      {"Foreground",       "#f8f8f2", "248 248 242"},
      {"Comment",          "#6272a4", "98 114 164"},
      {"Cyan",             "#8be9fd", "139 233 253"},
      {"Green",            "#50fa7b", "80 250 123"},
      {"Orange",           "#ffb86c", "255 184 108"},
      {"Pink",             "#ff79c6", "255 121 198"},
      {"Purple",           "#bd93f9", "189 147 249"},
      {"Red",              "#ff5555", "255 85 85"},
      {"Yellow",           "#f1fa8c", "241 250 140"},
    }
  elseif entry == "Sioyek" then
    submenu_options = {
      {"Normal",           "#19ffaf", "26 255 176"},
      {"Important",        "#c654ff", "199 84 255"},
      {"Definition",       "#5682ff", "87 130 255"},
      {"Explanation",      "#ff6b87", "255 107 135"},
      {"Really Important", "#ffb782", "255 184 130"},
      {"Study",            "#d8d656", "217 214 87"},
    }
  end

  pickers.new({}, {
    prompt_title = 'Select Value',
    finder = finders.new_table({
      results = submenu_options,
      entry_maker = function(entry)
        return {
          value = entry[1],
          display = entry[1],
          ordinal = entry[1],
          hex = entry[2],
          rgb = entry[3]
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        insert_value(selection.hex)
        --insert_value(selection.rgb)
      end)
      return true
    end,
  }):find()
end

-- Main menu picker function
function M.TelescopeClrSch()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values

  pickers.new({}, {
    prompt_title = 'Select Option',
    finder = finders.new_table({
      results = {"Dracula", "Sioyek"},
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        submenu_picker(selection.value)
      end)
      return true
    end,
  }):find()
end
function M.SearchTexFiles()
  local previewers = require'telescope.previewers'
  local telescope = require('telescope')
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require'telescope.actions'
  local Path = require('plenary.path')
  local previewers = require('telescope.previewers')
  local find_files = require('telescope.builtin').find_files
  find_files({
    prompt_title = "Search .tex Files",
    cwd = '/home/eduardotc/Programação/LaTeX',  -- Specify the directory containing .tex files
    find_command = {'find', '.', '-type', 'f', '-name', '*.tex'},
    previewer = previewers.vim_buffer_vimgrep.new,
  })
end

function M.TelescopeClrTst()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values

  pickers.new({}, {
    prompt_title = 'Select Option',
    find_command = {'find', '.', '-type', 'f', '-name', '*.tex'},
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        submenu_picker(selection.value)
      end)
      return true
    end,
  }):find()
end
return M
