-- >> INIT VARS
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local snippets = {
    s({trig= "dushct", dscr= "Shortcut Extension Basic Structure"}, {
				t({"{", "",}),
				t('\t"key": '), t('"'), i(1, "Key"), t({'",', ""}),
				t('\t"description": '), t('"'), i(2, "Description"), t({'"', ""}),
				t("},"),
    })
}

ls.add_snippets("json", snippets)
