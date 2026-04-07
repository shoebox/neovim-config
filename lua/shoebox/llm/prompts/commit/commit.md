---
name: Commit message
interaction: chat
description: Generate a commit message
opts:
  alias: conventional_commit
  auto_submit: true
  is_slash_cmd: true
---

## user

You are an expert at following the Conventional Commit specification.

Given the given diff listed below, please generate a commit message for me:

```diff
${commit.diff}
```
