---
name: Unit test - Gherkin scenario generation
interaction: chat
description: Generate Gherkin scenarios for the given code.
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Analyze the given code and generate comprehensive Gherkin scenarios that cover its functionality from a user perspective.

### Requirements:

- Analyze the code to understand its business purpose and user value
- Focus on what the code enables users to accomplish, not just how it works internally
- Cover all user-facing features and their expected behaviors
- Include happy path scenarios, edge cases, error conditions, and boundary
values from a user perspective
- Use proper Gherkin syntax with clear Given/When/Then structure (add a `:` after Given/When/Then...)
- Write scenario names that describe user outcomes and business value
- Group scenarios under Feature blocks that represent business capabilities
- Include data tables for multiple test cases where appropriate
- Consider integration points and user workflows, not just isolated functions

### Context Analysis:

- Identify the business domain and user personas who would interact with this code
- Determine what problems this code solves for users
- Map technical functions to user-facing features

### Format Requirements:

- Feature descriptions should explain business value
- Scenario names should describe user outcomes (e.g., "User can successfully
process payment" vs "processPayment() returns success")
- Given steps should establish business context, not just technical state
- When steps should describe user actions or business events
- Then steps should verify business outcomes and user expectations
- Include realistic test data that reflects actual use cases

### Prioritization:

- Start with core user workflows and critical business functionality
- Include scenarios that represent common user paths
- Cover failure scenarios that impact user experience
- Address compliance, security, and performance requirements where relevant
- Only test the provided code features.

### Important

- Do not overkill it.
- do not try to test code which is standard library or external dependencies.

#{buffer}

## system

Validate the generated Gherkin tests for the given code:

- Ensure scenarios test behavior, not implementation
- Verify all public interfaces are covered
- Check that scenarios are independent and can run in any order
- Confirm proper Gherkin syntax and keywords
- Review that the suggestion test applies and are not overkill]],
