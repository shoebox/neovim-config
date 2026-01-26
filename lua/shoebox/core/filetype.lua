vim.g.do_filetype_lua = 1

vim.filetype.add({
  extension = {
    ["http"] = "http",
  },
  pattern = {
    -- GitHub workflows
    [".*%.github/workflows/.*%.yml"] = "yaml.githubworkflow",
    [".*%.github/workflows/.*%.yaml"] = "yaml.githubworkflow",

    -- Antora
    [".antora-playbook.yml"] = "yaml_antora",
    [".antora-playbook.yaml"] = "yaml_antora",
    [".antora.yml"] = "yaml_antora",
    [".antora.yaml"] = "yaml_antora",

    ["haproxy.cfg"] = "haproxy",
    [".*/config.d/.*%.cfg"] = "haproxy",
    ["*.feature"] = "gherkin",
  },
})
