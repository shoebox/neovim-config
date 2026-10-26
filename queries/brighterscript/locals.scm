; Scopes
(function_statement) @scope
(sub_statement) @scope
(class_statement) @scope
(namespace_statement) @scope
(block) @scope
(if_statement) @scope
(for_statement) @scope
(while_statement) @scope
(try_statement) @scope

; Definitions
(parameter
  name: (identifier) @definition)

(function_statement
  name: (identifier) @definition)

(sub_statement
  name: (identifier) @definition)

(variable_declarator
  .
  (identifier) @definition)

(variable_declarator
  (prefix_exp
    .
    (identifier) @definition))

(variable_declarator
  (prefix_exp
    (prefix_exp)
    .
    (identifier) @definition))

(class_field
  name: (identifier) @definition)

(class_method
  .
  (function_statement
    name: (identifier) @definition))

(class_method
  .
  (sub_statement
    name: (identifier) @definition))

(interface_method_signature
  name: (identifier) @definition)

(enum_member
  name: (identifier) @definition)

(const_statement
  name: (identifier) @definition)

(alias_statement
  name: (identifier) @definition)

(type_statement
  name: (identifier) @definition)

; References
(identifier) @reference
