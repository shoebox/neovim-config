; Keywords
[
  (sub_start)
  (function_start)
  (end_sub)
  (end_function)
] @keyword.function

[
  (class_start)
  (end_class)
  (extends)
  (implements)
] @keyword

[
  (interface_start)
  (end_interface)
] @keyword

[
  (namespace_start)
  (end_namespace)
] @keyword

[
  (enum_start)
  (end_enum)
] @keyword

[
  (if_start)
  (end_if)
  (then)
  (conditional_compl_end_if)
] @keyword.conditional

[
  (for_start)
  (for_each)
  (for_in)
  (for_to)
  (for_step)
  (end_for)
  (continue_for_statement)
] @keyword.repeat

[
  (try_start)
  (try_catch)
  (throw)
  (end_try)
] @keyword.exception

(return) @keyword.return
(new) @keyword
(import) @keyword.import
(const) @keyword
(as) @keyword
(or) @keyword.operator
(not) @keyword.operator
(and) @keyword.operator
(mod) @keyword.operator
(super) @variable.builtin
(override) @keyword

; Access modifiers
[
  (public)
  (private)
  (protected)
] @keyword

; Special identifiers
(m) @variable.builtin

; Function/Sub declarations
(function_statement
  name: (identifier) @function)

(sub_statement
  name: (identifier) @function)

; Class declarations
(class_statement
  name: (identifier) @type)

(class_heritage
  superclass: (identifier) @type)

; Interface declarations
(interface_statement
  name: (identifier) @type)

; Namespace declarations
(namespace_statement
  name: (dotted_identifier) @module)

; Enum declarations
(enum_statement
  name: (identifier) @type)

(enum_member
  name: (identifier) @constant)

; Const declarations
(const_statement
  name: (identifier) @constant)

; Parameters
(parameter
  name: (identifier) @variable.parameter)

; Type specifiers
(type_specifier) @type

; Annotations
(annotation
  "@" @attribute
  name: (identifier) @attribute)

; Function calls
(function_call
  function: (prefix_exp
    (identifier) @function.call))

; new expression
(new_expression
  class: (dotted_identifier) @type)

; Class fields
(class_field
  name: (identifier) @variable.member)

; Class methods (name is on the inner function_statement/sub_statement)
(class_method
  (function_statement
    name: (identifier) @function.method))

(class_method
  (sub_statement
    name: (identifier) @function.method))

; Interface fields
(interface_field
  name: (identifier) @variable.member)

; Import statements

; Operators
[
  "="
  "<>"
  "+"
  "-"
  "*"
  "/"
  "??"
  "@."
] @operator

; Literals
(boolean) @boolean
(number) @number
(string) @string
(string_contents) @string
(invalid) @constant.builtin

; Template strings
(template_string) @string
(template_literal) @string
(template_interpolation) @punctuation.special

; Comments
(comment) @comment @spell

; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

; Print
(print) @function.builtin

; Arrays
(array) @constructor
(assoc_array) @constructor

; Dotted identifiers (namespaced types)
(dotted_identifier) @type

; Alias and type statements
(alias) @keyword
(type) @keyword

(alias_statement
  name: (identifier) @type.definition)

(type_statement
  name: (identifier) @type.definition)

(type_union) @type

; Source literals
(source_literal) @constant.builtin

; Regex literals
(regex_literal) @string.regex
(regex_pattern) @string.regex
(regex_flags) @string.regex

; Tagged template strings
(tagged_template_string
  tag: (identifier) @function.call)
