---
name: Code review - General code review
interaction: chat
description: Perform a general code review for quality, structure, and improvements on current code.
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Review this code for quality, structure, and improvements.
Analyze:

Technical Areas:

- Code quality & readability
- Performance bottlenecks
- Architecture & maintainability
- SOLID, DRY, YAGNI, KISS adherence

Provide:

- Specific issues with line references
- Actionable improvement suggestions
- Alternative approaches with trade-offs

Keep in mind we are using the latest language features and best practices.
e.g. closure capture in Go are being solved in Go 1.18+.

Output: If no issues found, respond only "LGTM!" Otherwise, provide structured
feedback with clear reasoning.

#{buffer}
