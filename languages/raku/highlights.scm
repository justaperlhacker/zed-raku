; Raku syntax highlighting for Zed.
;
; Ported from acrion/tree-sitter-raku's Helix queries
; (queries/highlights.scm) and adapted for Zed capture names, with additions
; from tree-sitter-perl/zed-perl.

; --- Comments & POD ---------------------------------------------------------
(comment) @comment
(pod) @comment
(data_section) @comment
(eof_marker) @preproc

; --- Keywords ---------------------------------------------------------------
[ "use" "no" "require" ] @keyword.include
[ "package" "class" "role" "grammar" "but" ] @keyword
[ "token" "rule" "regex" ] @keyword

[ "if" "elsif" "else" "unless" "given" "when" "default" ] @keyword.conditional
[ "while" "until" "for" "foreach" "do" ] @keyword.repeat
[ "try" "catch" "finally" ] @keyword.exception
[ "return" ] @keyword.return
[ "sub" "method" "submethod" "async" "extended" "multi" "proto" "only" ] @keyword.function

[
  "my" "our" "local" "state" "field"
  "last" "next" "redo" "goto"
  "defer" "eval" "has" "constant" "subset" "where"
] @keyword

[ "undef" ] @constant.builtin

(phaser_statement phase: _ @keyword.phaser)
(class_phaser_statement phase: _ @keyword.phaser)

; --- Operators --------------------------------------------------------------
(_ operator: _ @operator)
"\\" @operator

[
  "or" "xor" "and"
  "eq" "ne" "cmp" "lt" "le" "ge" "gt"
  "isa"
] @keyword.operator

; --- Numbers & constants ----------------------------------------------------
[(number) (version)] @number

; --- Strings ----------------------------------------------------------------
[
  (string_literal)
  (interpolated_string_literal)
  (quoted_word_list)
  (command_string)
  (heredoc_content)
  (replacement)
  (transliteration_content)
] @string

[(heredoc_token) (command_heredoc_token) (heredoc_end)] @label
[(escape_sequence) (escaped_delimiter)] @string.escape
(_ modifiers: _ @character.special)

[(quoted_regexp) (match_regexp) (regexp_content)] @string.regex

(autoquoted_bareword) @string.special

; --- Variables --------------------------------------------------------------
(scalar) @variable.scalar
(scalar_deref_expression ["$" "*"] @variable.scalar)
[(array) (arraylen)] @variable.array
(array_deref_expression ["@" "*"] @variable.array)
(hash) @variable.hash
(hash_deref_expression ["%" "*"] @variable.hash)

(array_element_expression array: (_) @variable.array)
(slice_expression array: (_) @variable.array)
(keyval_expression array: (_) @variable.array)

(hash_element_expression hash: (_) @variable.hash)
(slice_expression hash: (_) @variable.hash)
(keyval_expression hash: (_) @variable.hash)

; --- Functions, types & attributes ------------------------------------------
(use_statement (package) @type)
(package_statement name: (package) @type)
(class_statement name: (package) @type)
(role_statement name: (package) @type)
(require_expression (bareword) @type)

(subroutine_declaration_statement name: (_) @function)
(method_declaration_statement name: (_) @method)
(attrlist (attribute) @attribute)

; Parameter and return type constraints
(mandatory_parameter type: (bareword) @type)
(optional_parameter type: (bareword) @type)
(named_parameter type: (bareword) @type)
(slurpy_parameter type: (bareword) @type)
(_ returns: (bareword) @type)

(has_declaration type: (bareword) @type)
(has_declaration trait: (bareword) @attribute)
"is" @keyword

; User-defined operator definitions: `sub infix:<+> { ... }`
[ "infix" "prefix" "postfix" "circumfix" "postcircumfix" "term" ] @keyword
(operator) @operator

; Reduction metaoperator: `[+]`, `[~]`, `[max]`
(reduction_expression operator: _ @operator)

; Zip/cross and hyper metaoperators: `Z`, `X`, `Z+`, `>>+<<`
(zip_cross_expression operator: _ @operator)
(hyper_expression operator: _ @operator)

(subset_declaration name: (bareword) @type)
(subset_declaration base: (bareword) @type)
(constant_declaration name: (bareword) @constant)

; Raku's Whatever star
(whatever) @variable.special

(label) @label
(statement_label label: _ @label)

(relational_expression operator: "isa" right: (bareword) @type)

(function) @function
(function_call_expression (function) @function.call)
(method_call_expression (method) @method.call)
(method_call_expression invocant: (bareword) @type)

(func0op_call_expression function: _ @function.builtin)
(func1op_call_expression function: _ @function.builtin)

; --- Punctuation ------------------------------------------------------------
[ "=>" "," ";" "->" ] @punctuation.delimiter
[ "[" "]" "{" "}" "(" ")" ] @punctuation.bracket

(ERROR) @error
