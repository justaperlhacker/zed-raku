(package_statement
  "package" @context
  name: (package) @name) @item

(class_statement
  "class" @context
  name: (package) @name) @item

(role_statement
  "role" @context
  name: (package) @name) @item

(subroutine_declaration_statement
  "sub" @context
  name: (bareword) @name) @item

(method_declaration_statement
  "method" @context
  name: (bareword) @name) @item
