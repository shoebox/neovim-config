---
name: Code review - SOLID
interaction: chat
description: Review the code and provide feedback
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Review the provided code to apply SOLID principles pragmatically, focusing on meaningful improvements without overengineering.

### Analysis:
- Identify clear SOLID violations that actually impact code quality
- Highlight coupling issues and reusability barriers that matter in practice
- Focus on violations that cause real maintenance pain
- Ignore logging if it uses the default logger for the language (e.g. slog or log for Golang)

Remember: Good code emerges from real needs, not from blindly following principles.


### Success Criteria: The recommedndation should make the code:

- Easier to understand and modify than the original
- More testable without being overly complex
- Genuinely more reusable, not just theoretically better
- Still recognizable as solving the same problem

## user

The code to review is: #{buffer}
