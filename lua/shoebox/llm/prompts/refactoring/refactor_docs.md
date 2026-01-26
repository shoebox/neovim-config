---
name: Code refactor - Documentation
interaction: chat
description: Refactor the given code and add missing documentation
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Analyze the following code and review its documentation.
For each exported type, function, method, or package-level variable/constant:

- Add missing doc comments following the programming language best-practices (e.g. for Go: https://go.dev/doc/effective_go)
- Correct any incorrect, outdated, or misleading existing documentation.
- Only document exported identifiers, unless an unexported item has complex or non-obvious logic.
- Do not add comments to struct fields, local variables, or simple unexported identifiers.
- Avoid redundant parameter/return sections unless needed for clarity.
- Ensure all comments are clear, concise, and follow the programming language best practices.
- Do not modify the code structure or logic, focus only on documentation.]],

#{buffer}
