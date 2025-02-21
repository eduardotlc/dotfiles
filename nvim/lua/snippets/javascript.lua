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
  s({ trig = "ducomfnc", dscr = "Ts-ls function descriptions" }, {
    t({ "/**", " * " }),
    i(1, "functionName"),
    t({ "", " * " }),
    i(2, "Brief description"), -- Insert node for description
    t({ "", " * @param {" }),
    c(3, {
      t("string"),
      t("number"),
      t("boolean"),
      t("object"),
      t("Array"),
      t("any"),
      t("void"),
    }), t("}"),
    t({ "", " */" }),
  }),

-- >>>> Variable comment
  s({ trig = "ducomvar", dscr = "Ts-ls varibles commenting" }, {
    c(3, {
      t("string"),
      t("number"),
      t("boolean"),
      t("object"),
      t("Array"),
      t("any"),
      t("void"),
    }),
    t("} "), i(4, "paramName"), t(" - "), i(5, "Parameter description"), -- Insert node for parameter name and description
    t({ "", " * @returns {" }),
    t({ "", " */" }),
  }),

-- >>>> Class comment
  s({ trig = "ducomcls", dscr = "Ts-ls class commenting" }, {
    c(6, {
      t("string"),
      t("number"),
      t("boolean"),
      t("object"),
      t("Array"),
      t("any"),
      t("void"),
    }),
    t("} "), i(7, "Return description"), -- Insert node for return description
    t({ "", " */" }),
  }),

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

ls.add_snippets("javascript", snippets)
