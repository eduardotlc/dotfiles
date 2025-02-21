((string) @custom_comment
  (#match? @custom_comment "^r\"\"\"°°°")
  (#set! @custom_comment hl "CustomHighlightGroup"))
