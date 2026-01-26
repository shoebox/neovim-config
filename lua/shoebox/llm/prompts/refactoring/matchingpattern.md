---
name: Code refactor - Design patterns.
interaction: chat
description: Looks matching patterns into which the given code can be refactor
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Analyze this code for software design patterns that it can be refactored into.
For each pattern found:

Identification:

- Pattern name (Singleton, Factory, Observer, Strategy, etc.)
- Specific code location/lines implementing it

Analysis:

- Pattern's purpose and benefits
- How it's structured in this code
- Implementation quality assessment

Code Examples:

- Reference exact lines/elements
- Show pattern-specific implementation details
- Suggest improvements if applicable

Output: If no patterns found, state "No recognizable design patterns identified" and explain why.

## user

Refactor the following code: #{buffer}
