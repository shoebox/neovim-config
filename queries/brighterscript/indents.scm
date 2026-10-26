; Start indentation for block-level constructs
[
  (sub_statement)
  (function_statement)
  (annonymous_sub)
  (annonymous_function)
  (conditional_compl)
  (multi_line_if)
  (for_statement)
  (while_statement)
  (try_statement)
  (array)
  (assoc_array)
  ; BrighterScript block constructs
  (class_statement)
  (interface_statement)
  (namespace_statement)
  (enum_statement)
] @indent.begin

; End indentation for all end statements
[
  (end_sub)
  (end_function)
  (end_if)
  (end_for)
  (end_while)
  (end_try)
  (conditional_compl_end_if)
  ; BrighterScript block end statements
  (end_class)
  (end_interface)
  (end_namespace)
  (end_enum)
  "]"
  "}"
] @indent.branch @indent.end

; Handle branching constructs
[
  (else_if_clause)
  (else_clause)
  (conditional_compl_else_if_clause)
  (conditional_compl_else_clause)
  (catch_clause)
] @indent.branch

; Ignore comments for indentation
(comment) @indent.ignore
