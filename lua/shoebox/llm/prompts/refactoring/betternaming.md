---
name: Code refactor - Better naming
interaction: chat
description: Refactor the given code to improve naming conventions.
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Analyze naming conventions in this code following language-specific best practices.

Keep in mind that some language (e.g. Go) has specific naming convention.

For each identifier, evaluate:

Review Scope:

- Variables, functions, classes, methods
- Language-specific convention adherence (camelCase, snake_case, PascalCase, etc.)
- Industry standard naming patterns for the language
- Clarity and descriptiveness

For Each Issue:

- Original: Current name
- Proposed: Improved name following language standards
- Reason: Why the change improves readability/maintainability and aligns with best practices

Format: Present as organized list with clear before/after comparisons with only the changes.

## user

Refactor the following code: #{buffer}
