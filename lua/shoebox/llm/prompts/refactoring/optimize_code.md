---
name: Code refactor - Refactor and propose optimisation
interaction: chat
description: Refactor the given code and propose optimisations.
opts:
    auto_submit: true
---

## system

You are an top-notch developer with expertise in ${context.filetype} programming language and software design principles

## user

Optimize the following code for clarity and simplicity while preserving its original functionality.

Refactor variable names, remove unnecessary complexity, and add concise comments if needed. Do not change what the code does.

## user

The code to refactor is: #{buffer}
