local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

local snippets = {
  s({ trig = "ducolors", dscr = "Ansi escaped colors variables def"}, {
    t({ "RST := \\033[0m", "" }),
    t({ "RED := \\033[31m", "" }),
    t({ "GRN := \\033[32m", "" }),
    t({ "YLW := \\033[33m", "" }),
    t({ "CYAN := \\033[34m", "" }),
    t({ "MGN := \\033[35m", "" }),
  }),

  s({ trig = "dukey", dscr = "Password key variable def"}, {
    t({ "HEX_KEY ?= $(shell cat /home/eduardotc/.cert/hex32_key.txt)", ""}),
    t({ "DU_PASS ?= $(shell openssl enc -aes-256-cbc -d -salt -pbkdf2 -in /home/eduardotc/.cert/main_pass.enc -pass pass:$(HEX_KEY))", ""}),
  })
}

ls.add_snippets("make", snippets)
