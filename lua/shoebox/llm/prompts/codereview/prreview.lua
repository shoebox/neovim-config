return {
  diff = function(args)
    local diff_output = vim.system({ "git", "diff", "--no-ext-diff", "--staged" }, { text = true }):wait().stdout
    -- Escape % and \ characters to prevent gsub interpretation issues
    return (diff_output:gsub("%%", "%%%%"):gsub("\\", "\\\\"))
  end,
}
