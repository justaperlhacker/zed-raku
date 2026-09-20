((comment) @injection.content
 (#set! injection.language "comment"))

((pod) @injection.content
 (#set! injection.language "pod"))

; `s/.../.../e` evaluates the replacement as Raku code
((substitution_regexp
  (replacement) @injection.content
  (substitution_regexp_modifiers) @_modifiers)
  (#match? @_modifiers "e")
  (#not-match? @_modifiers "e.*e")
  (#set! injection.language "raku"))
