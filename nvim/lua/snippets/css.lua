-- >> INIT VARS

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

local function line_length(args)
  local text = args[1][1] or ""
  return string.rep("=", #text)
end

local function sub_line_length(args)
  local text = args[1][1] or ""
  return string.rep("-", #text)
end


local snippets = {

-- >>>> Function comment

  s({ trig = "ducsshdr", dscr = "Css line comments header section" }, {
    t("/*"), f(line_length, {1}), t({"", ""}),
    i(1, "Title"), t({"", ""}),
    f(line_length, {1}), t("*/"),
    t({"", ""}),
  }),

  s({ trig = "ducsssubhdr", dscr = "Css line comments sub header section" }, {
    t("/*"), f(sub_line_length, {1}), t({"", ""}),
    i(1, "Title"), t({"", ""}),
    f(sub_line_length, {1}), t("*/"),
    t({"", ""}),
  }),

}

ls.add_snippets("css", snippets)
