---
name: Code refactor - SOLID - planning
interaction: chat
description: Propose a SOLID refactoring plan of the given code
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Refactor the provided code to apply SOLID principles pragmatically, focusing on
meaningful improvements without overengineering.

### Analysis:
- Identify clear SOLID violations that actually impact code quality
- Highlight coupling issues and reusability barriers that matter in practice
- Focus on violations that cause real maintenance pain

### Refactoring Strategy:
- Apply SOLID principles only where they provide clear value
- Prioritize changes that solve actual problems, not theoretical ones
- Keep interfaces simple and avoid unnecessary abstractions
- Use dependency injection judiciously  only where it improves testability or flexibility
- Maintain code readability and simplicity as primary goals
- Skip logger/logging implementation details

### Implementation Guidelines:
- Each method should have a single, clear responsibility
- Prefer composition over complex inheritance hierarchies
- Create abstractions only when you have multiple implementations or clear extension points
- Keep the public API intuitive and minimal
- Avoid premature optimization and overabstraction

### Deliverables:
1. Pragmatic refactored code with clear, focused responsibilities
2. Brief explanation of which SOLID principles were applied and why
3. Simple usage examples showing improved flexibility

### Success Criteria: The refactored code should be:
- Easier to understand and modify than the original
- More testable without being overly complex
- Genuinely more reusable, not just theoretically better
- Still recognizable as solving the same problem

Remember: Good design emerges from real needs, not from blindly following principles.

## user

The code to refactor is: #{buffer}

Do not do any code changes, just propose a refactoring plan.
