local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

local function date_and_time()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function infer_type(default)
  if default:match('^".*"$') or default:match("^'.*'$") then
    return "str"
  elseif tonumber(default) then
    return "int"
  elseif default == "True" or default == "False" then
    return "bool"
  elseif default:match("^%[.*%]$") then
    return "list"
  elseif default:match("^{.*}$") then
    return "dict"
  else
    return "type"
  end
end

local function isStringInTable(str, tbl)
  for _, value in pairs(tbl) do
    if value == str then
      return true
    end
  end
  return false
end

local function filter_parameters()
  -- Get the function arguments from the previous line
  local prev_line = vim.api.nvim_buf_get_lines(0, vim.fn.line(".") - 2, vim.fn.line(".") - 1, false)
  [1]
  local args = prev_line:match("def%s+[%w_]+%(([^)]*)%)") or ""
  local args_list = {}
  local processed_args = {}
  local vars_type = { "str", "int", "float", "bool" }
  for arg, arg_type in args:gmatch("([%w_]+)%s*:%s*([%w_%[%],]+)") do
    table.insert(args_list, arg .. " : " .. arg_type)
    table.insert(processed_args, arg)
  end

  for arg, default in args:gmatch("([%w_]+)%s*=%s*([^,%s]+)") do
    if not isStringInTable(arg, processed_args) then
      local inferred_type = infer_type(default)
      table.insert(args_list, arg .. " : " .. inferred_type .. ', default "' .. default .. '"')
      table.insert(processed_args, arg)
      table.insert(processed_args, default)
    end
  end

  for arg in args:gmatch("([%w_]+)") do
    if not isStringInTable(arg, processed_args) and not isStringInTable(string.format('"%s"', arg), processed_args) and not args:match(arg .. "%s*:%s*") and arg ~= "self" and arg ~= "cls" and not isStringInTable(arg, vars_type) then
      table.insert(args_list, arg .. " : type")
      table.insert(processed_args, arg)
    end
  end

  if #args_list == 0 then
    return "None"
  else
    return table.concat(args_list, "\n")
  end
end

local function assign_return_value()
  local prev_line = vim.api.nvim_buf_get_lines(0, vim.fn.line(".") - 2, vim.fn.line(".") - 1, false)
  [1]
  if prev_line:match("->") then
    return prev_line:match("->%s*([%w_%[%],]+)") .. " : Description"
  else
    local current_line = vim.fn.line(".")
    local lines = vim.api.nvim_buf_get_lines(0, current_line, -1, false)
    local function_pattern = "^%s*def%s+[%w_]+%s*%("
    local return_pattern = "^%s*return%s+(%S+)$"
    for _, line in ipairs(lines) do
      if line:match(function_pattern) then
        return "None"
      end
      if line:match(return_pattern) then
        local variable = line:match(return_pattern)
        if variable:match("^['\"].*['\"]$") ~= nil then
          return line:match(return_pattern) .. " : str"
        else
          return variable
        end
      end
    end
    return "None"
  end
end

local function get_bellow_function_name()
  local current_line = vim.fn.line(".")
  local next_line = vim.api.nvim_buf_get_lines(0, current_line, current_line + 1, false)[1]
  local pattern = "^def%s+([%w_]+)%s*%("
  local function_name = next_line:match(pattern)
  return function_name
end

local snippets = {

  s({ trig = "dusubptry", dscr = "Subprocess try/except block" }, {
    t({ "try:", "" }),
    t({ "\tsubprocess.run(", "" }),
    t("\t\t"), i(1, "Command"), t(","),
    t({ "", "\t\ttext=True,", "" }),
    t({ "\t\tcapture_output=True,", "" }),
    t({ "\t\tcheck=True", "" }),
    t({ "\t)", "", "" }),
    t({ "except subprocess.CalledProcessError as e:", "" }),
    t({ '\tprint(f"Return Code: {e.returncode}")', "" }),
    t({ '\tprint(f"Error output: {e.stderr}")', "" }),
    t("\t"), t([[raise RuntimeError(f"Command '{' '.join(]]), rep(1), t(
  [[)}' failed: {e.stderr.strip()}") from e]]),
    t(""),
    i(0),
  }),

  s({ trig = "ducstr", dscr = "Docstrings test" }, {
    t('"""'), i(1, "Summary of the function"), t({ "", "", "" }),
    i(2, "Detailed description of the function"), t({ "", "", "" }),
    t("Parameters"), t({ "", "----------", "" }),
    f(filter_parameters, {}),
    t({ "", "", "" }),
    t("Returns"), t({ "", "-------", "" }),
    f(assign_return_value, {}),
    t({ "", "", "" }),
    t('"""'),
  }),


  s({ trig = "duhdr", dscr = "Initial Signing" }, {
    t({ "#!/usr/bin/env python3", "" }),
    t({ '"""', "" }),
    t("Created on "), t(date_and_time()), t("."),
    t({ "", "", "@author: eduardotc", "" }),
    t({ "@email: eduardotcampos@hotmail.com", "", "" }),
    i(1, "Docstring File Description"),
    t({ "", "" }),
    t({ '"""', "" }),
  }),

  s({ trig = "ducomfn", dscr = "Foldding Comment to functions" }, {
    t("# >>"), c(1, { t(""), t(">>"), t(">>>>"), t(">>>>>>"), }), t(" "), f(get_bellow_function_name,
    {}),
  }),

  s({ trig = "dufold", dscr = "Foldding Level" }, {
    t("# >>"), c(1, { t(""), t(">>"), t(">>>>"), t(">>>>>>"), }), t(" "), i(2, "Fold Name"),
  }),

  s({ trig = "ducolors", dscr = "Terminal escaping codes global vars defs" }, {
    t({ "# >>>> Colors", "" }),
    t({ "RST = \"\\033[0m\"    # Reset ansi escape code", "" }),
    t({ "FGTXT = \"\\033[1;37m\"    # Foreground text color (white or black)", "" }),
    t({ "# >>>>>> DIM<COLOR> - Light colors", "" }),
    t({ "DIMTXT = \"\\033[38;5;245m\"", "" }),
    t({ "# >>>>>> Main colors", "" }),
    t({ "RED = \"\\033[31m\"", "" }),
    t({ "GRN = \"\\033[32m\"", "" }),
    t({ "YLW = \"\\033[33m\"", "" }),
    t({ "BLUE = \"\\033[34m\"", "" }),
    t({ "MGN = \"\\033[35m\"", "" }),
    t({ "CYAN = \"\\033[36m\"", "" }),
    t({ "PRP = \"\\033[38;5;063m\"", "" }),
    t({ "PNK = \"\\033[38;5;171m\"", "" }),
    t({ "# >>>>>> BR<COLOR> - Bright color", "" }),
    t({ "BRCYAN = \"\\033[38;5;051m\"", "" }),
    t({ "# >>>>>> <COLOR>B - Alternative color", "" }),
    t({ "REDB = \"\\033[38;5;197m\"", "" }),
    t({ "BLUEB = \"\\033[38;5;027m\"", "" }),
    t({ "# >>>>>> BG<COLOR> - Background color", "" }),
    t({ "BGRED = \"\\033[48;5;031m\"", "" }),
    t({ "BGGRN = \"\\033[48;5;032m\"", "" }),
    t({ "BGYLW = \"\\033[48;5;033m\"", "" }),
    t({ "BGBLUE = \"\\033[48;5;034m\"", "" }),
    t({ "BGMGN = \"\\033[48;5;035m\"", "" }),
    t({ "BGCYAN = \"\\033[48;5;036m\"", "" }),
    t({ "BGPRP = \"\\033[48;5;063m\"", "" }),
    t({ "BGPNK = \"\\033[48;5;171m\"", "", "" }),
  })
}

ls.add_snippets("python", snippets)
