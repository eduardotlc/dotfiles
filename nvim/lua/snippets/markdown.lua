-- >> INIT VARS

local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local snippets = {

    s({trig= "du>", dscr= "Programming Code Block"}, fmt(
    [[
    ```{}
    {}
    ```
    ]], {
        i(1, 'Language'), i(0),
    })),

    s({trig= "duwr>", dscr= "Wrap Programming Code Block"}, fmt(
    [[
    ```{}
    {}
    ```
    ]], {
        i(1, 'Language'), f(function(_, snip)
            return snip.env.TM_SELECTED_TEXT or ""
          end, {}),
    })),

    s({trig = "duwrlink", dscr = "Wrap stored line to url link"}, fmt(
    [[
		<a href={}>{}</a>
    ]], {
		    f(function(_, snip)
          return snip.env.TM_SELECTED_TEXT[1] or {}
        end, {}), i(0),
	})),
}

ls.add_snippets("markdown", snippets)
