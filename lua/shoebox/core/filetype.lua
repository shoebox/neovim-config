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
    [".*%.feature"] = "gherkin",

    -- Ansible (path-based detection)
    -- Note: Lua patterns don't support `?` quantifier, so we need separate patterns for .yml and .yaml
    -- Using `.*` without trailing `/` allows matching both absolute and relative paths
    [".*playbooks/.*%.yml"] = "yaml.ansible",
    [".*playbooks/.*%.yaml"] = "yaml.ansible",
    [".*playbook/.*%.yml"] = "yaml.ansible",
    [".*playbook/.*%.yaml"] = "yaml.ansible",
    [".*roles/.*/tasks/.*%.yml"] = "yaml.ansible",
    [".*roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
    [".*roles/.*/handlers/.*%.yml"] = "yaml.ansible",
    [".*roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
    [".*roles/.*/defaults/.*%.yml"] = "yaml.ansible",
    [".*roles/.*/defaults/.*%.yaml"] = "yaml.ansible",
    [".*roles/.*/vars/.*%.yml"] = "yaml.ansible",
    [".*roles/.*/vars/.*%.yaml"] = "yaml.ansible",
    [".*roles/.*/meta/.*%.yml"] = "yaml.ansible",
    [".*roles/.*/meta/.*%.yaml"] = "yaml.ansible",
    [".*group_vars/.*%.yml"] = "yaml.ansible",
    [".*group_vars/.*%.yaml"] = "yaml.ansible",
    [".*host_vars/.*%.yml"] = "yaml.ansible",
    [".*host_vars/.*%.yaml"] = "yaml.ansible",
    [".*inventory/.*%.yml"] = "yaml.ansible",
    [".*inventory/.*%.yaml"] = "yaml.ansible",
  },
})
