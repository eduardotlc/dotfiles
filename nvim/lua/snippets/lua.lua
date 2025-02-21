-- >> INIT VARS

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

local snippets = {

-- >>>> Function comment
  s({ trig = "dufnc", dscr = "Lua-ls function commenting descriptions" }, {
    t({ "---"}),
    i(1, "Description"),
    t({ "", "---@" }), i(2, ""),
  }),

  s({ trig = "duhkm", dscr = "Which key shortcuts multiple lines basic format" }, {
    t("\""), i(1, "Keys"), t("\","), t({"", ""}),
    t("\"<cmd> "), i(2, "Command"), t({"<CR>\",", ""}),
    t("desc = \""), i(3, "Desc"), t({"\",", ""}),
    t("group = \""), i(4, "Group"), t({"\",", ""}),
    t({"noremap = true,", ""}),
    t({"silent = true,", ""}),
    t("icon = { icon = \""), i(5, "Icon"), t("\", color = \""),
    c(6, {
      t("azure"),
      t("blue"),
      t("cyan"),
      t("green"),
      t("grey"),
      t("orange"),
      t("purple"),
      t("red"),
      t("yellow"),
    }), t({"\" },", ""}),
    t("mode = { "), i(7, "Modes (n i v x s o c t)"), t({" },", ""}),
  }),

  s({ trig = "duchk", dscr = "Which key shortcuts single line basic format" }, {
    t("\""), i(1, "Keys"), t("\", "), t("\"<cmd> "), i(2, "Command"), t("<CR>\", "),
    t("desc = \""), i(3, "Desc"), t("\", "), t("group = \""), i(4, "Group"), t("\", "),
    t("noremap = true, "), t("silent = true, "), t("icon = { icon = \""), i(5, "Icon"), t("\", color = \""),
    c(6, {
      t("azure"),
      t("blue"),
      t("cyan"),
      t("green"),
      t("grey"),
      t("orange"),
      t("purple"),
      t("red"),
      t("yellow"),
    }), t("\" }, "), t("mode = { "), i(7, "Modes (n i v x s o c t)"), t({" },", ""}),
  }),

  s({ trig = "duntf", dscr = "Notify log levels options" }, {
    t("notify(\""), i(1, "Message"), t("\", "), c(2, {
      t("\"normal\""),
      t("\"debug\""),
      t("\"warn\""),
      t("\"error\""),
      t("\"info\""),
      t("\"trace\""),
      t("\"off\""),
    }), t(", { title: \""), i(3, "string"), t("\", icon: \""), i(4, "string"), t("\", timeout: "),
    i(5, "(number | boolean)"), t(" })")
  }),
}

ls.add_snippets("lua", snippets)
