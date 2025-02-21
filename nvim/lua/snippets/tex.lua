-- >> INIT VARS

local ls = require('luasnip')
local extras = require("luasnip.extras")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local snippets = {

-- >> Section
    s("dusec", {
        t("\\section{"),
        i(1, "Section Name"),
        t("}"),
        i(0)
    }),

-- >> Subsection
    s("dussec", {
        t("\\subsection{"),
        i(1, "Subsection Name"),
        t("}"),
        i(0)
    }),

 -- >> Table
    s("dutb", {
        t({"\\begin{table}[h]", "\\centering", "\\begin{tabular}{|c|c|}"}),
        t("\\hline"),
        i(1, "Item 1"), t(" & "), i(2, "Item 2"), t(" \\\\ \\hline"),
        i(3, "Item 3"), t(" & "), i(4, "Item 4"), t(" \\\\ \\hline"),
        t({"\\end{tabular}", "\\caption{"}), i(5, "Caption here"), t("}"),
        t({"\\label{"}), i(6, "label here"), t("}", "\\end{table}"),
        i(0)
    }),

-- >> Itemize
    s("duitem", {
        t({"\\begin{itemize}", "\t\\item "}),
        i(1, "First item"),
        t({"", "\t\\item "}),
        i(2, "Second item"),
        t({"", "\\end{itemize}"}),
        i(0)
    }),

-- >> Environment
    s({trig = "duenv", dscr = 'Generic latex begind/end environment'}, fmt(
    [[
    \begin{{{}}}
        {}
    \end{{{}}}
    ]], {
        i(1), i(0), rep(1)
    })),

    s({trig = "duinit", dscr = "Initialization packages and configs settings"}, fmt(
    [[
    \documentclass[
    12pt,
    openright,
    twoside,
    a4paper,
    chapter=TITLE,
    brazil,
    french,
    spanish,
    english,
    % Font, Formatting, encoding
    \usepackage[english]{{babel}}
    \usepackage{{lipsum}}
    \usepackage{{lmodern}}
    \usepackage{{lastpage}}
    \usepackage{{indentfirst}}
    \usepackage[T1]{{fontenc}}
    \usepackage[utf8]{{inputenc}}
    % Images
    \usepackage{{tikz}}
    \usetikzlibrary{{positioning}}
    \usepackage{{graphicx}}
    \usepackage{{svg}}
    % Chemistry
    \usepackage{{chemfig,chemmacros}}
    \usepackage{{chemformula}}
    \usepackage{{mhchem}}
    % Math
    \usepackage{{amsthm}}
    \usepackage{{textgreek}}
    \usepackage{{amsmath}}
    \usepackage{{xfrac}}
    \usepackage{{mathtools}}
    % Environment and elements
    \usepackage{{makeidx}}
    \usepackage{{imakeidx}}
    \usepackage[most]{{tcolorbox}}
    \usepackage{{color, colortbl}}
    \usepackage{{caption}}
    \usepackage[margin=2cm]{{geometry}}
    % Design
    \usepackage{{xcolor}}
    \usepackage{{etoolbox}}
    \usepackage{{makebox}}
    \usepackage[absolute]{{textpos}}
    % Table
    \usepackage{{multicol}}
    \usepackage{{multirow}}
    \usepackage{{longtable}}
    \usepackage{{makecell}}
    \usepackage{{array}}
    \usepackage{{threeparttablex}}
    % Bibliography/Reference
    \usepackage[colorlinks=true, allcolors=blue]{{hyperref}}
    \usepackage{{cleveref}}
    \usepackage[superscript]{{cite}}
    % Unknown
    \usepackage{{eso-pic}}
    \usepackage{{microtype}}
    \usepackage{{pdfpages}}
    \usepackage{{hyphenat}}
    \usepackage{{float}}
    \usepackage{{color}}
    \usepackage{{graphicx}}
    \usepackage{{float}}
    \usepackage{{chemfig,chemmacros}}
    \usepackage{{tikz}}
    \usetikzlibrary{{positioning}}
    \usepackage{{microtype}}
    \usepackage{{pdfpages}}
    \usepackage{{makeidx}}
    \usepackage{{hyphenat}}
    \usepackage[absolute]{{textpos}}
    \usepackage{{eso-pic}}
    \usepackage{{makebox}}
    \usepackage[superscript]{{cite}}
    \usepackage{{textgreek}}
    % ---
    \documentclass{{article}}
    ]], {})),

    s({trig = 'ducolors', dscr = 'Personal colors definition'}, fmt(
    [[
    % Custom Colors
    \definecolor{{blue}}{{RGB}}{{41,5,195}}
    \definecolor{{coverpagecolor}}{{HTML}}{{E6E9F0}}
    \definecolor{{titlecolor}}{{HTML}}{{4564B7}}
    \definecolor{{subtitlecolor}}{{HTML}}{{6E7FC7}}
    \definecolor{{dugreen}}{{HTML}}{{17C395}}
    \definecolor{{dulblue}}{{HTML}}{{8BE2DF}}
    %\definecolor{{dublue}}{{HTML}}{{5682FF}}
    \definecolor{{dublue}}{{HTML}}{{4A5DB1}}
    \definecolor{{duorange}}{{HTML}}{{FFB26E}}
    \definecolor{{dured}}{{HTML}}{{CE2040}}
    \definecolor{{dugreend}}{{HTML}}{{519A62}}
    \definecolor{{LightCyan}}{{rgb}}{{0.88,1,1}}
    \definecolor{{miesslergreen}}{{HTML}}{{008261}}
    \definecolor{{miesslerrow}}{{HTML}}{{E5F0EC}}
    \definecolor{{draculacyan}}{{HTML}}{{8BE9FD}}
    \definecolor{{draculapurple}}{{HTML}}{{BD93F9}}
    \definecolor{{draculaline}}{{HTML}}{{44475A}}
    % Adjust the margins to suit your needs
    ]], {})),

    s({trig = 'duconcepts', dscr = 'Concepts boxes theorems and definitions environment creation'},
    fmt(
    [[
    % Theorems proofs definitions
    \newtcbtheorem[number within=section]{{Theorem}}{{}}{{
            enhanced,
            sharp corners,
            attach boxed title to top left={{
                xshift=-1mm,
                yshift=-5mm,
                yshifttext=-1mm
            }},
            top=1.5em,
            colback=white,
            colframe=blue!75!black,
            fonttitle=\bfseries,
            boxed title style={{
                sharp corners,
                size=small,
                colback=blue!75!black,
                colframe=blue!75!black,
            }}
        }}{{thm}}

    \newtcbtheorem[number within=section]{{Definition}}{{}}{{
            enhanced,
            sharp corners,
            attach boxed title to top left={{
                xshift=-1mm,
                yshift=-5mm,
                yshifttext=-1mm
            }},
            top=1.5em,
            colback=white,
            colframe=blue!75!black,
            coltitle=white,
            fonttitle=\bfseries,
            boxed title style={{
                sharp corners,
                size=small,
                colback=miesslergreen,
                colframe=blue!75!black,
            }}
        }}{{def}}


    \newenvironment{{myTheorem}}[2]{{ \begin{{Theorem}}[adjusted title=#1]{{}}{{#2}}
      \textbf{{Theorem \thetcbcounter.}} }}{{\end{{Theorem}}}}

    % \newenvironment{{myDefinition}}[2]{{ \begin{{Definition}}[adjusted title=#1]{{}}{{#2}}
      % \textbf{{Definition \thetcbcounter.}} }}{{\end{{Definition}}}}

    \newenvironment{{myDefinition}}[2]{{%
        \bigskip% Add space before the box
        \begin{{Definition}}[adjusted title=#1]{{}}{{#2}}%
            \textbf{{Definition $\color{{miesslergreen}}{{\thetcbcounter}}$}}%
    }}{{%
        \end{{Definition}}%
        \bigskip% Add space after the box
    }}
    ]], {})),

    s({trig = "dudef", dscr = 'Personal definition concept box' },  fmt(
      [[
      \begin{{myDefinition}}{{{}}}{{def:{}}}
          {}
      \end{{myDefinition}}
      ]], {
          i(1, 'Title'), i(2, 'Label'), i(0),
      })),

    s({trig = 'dutest', dscr = 'testing' }, fmt(
    [[
    {{{}}}
    ]], {
        c(1, {t("pattern"), t("ecma")}),
    })),
}


-- Load the snippets for tex filetypes
ls.add_snippets("tex", snippets)
