
ignore = {
  "631",    -- max_line_length
}
globals = {
  "vim",
  "Snacks",
}
read_globals = {
  "describe",
  "it",
  "assert"
}
files['tests'] = {
  ignore = {
    '121',        -- Setting a read-only global variable.
    '122',        -- Setting a read-only field of a global variable.
  }
}
