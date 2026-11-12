# Engineering Principles

## General

- Follow existing project conventions and architecture.
- Prefer simple, readable, and maintainable solutions.
- Apply KISS, DRY, and YAGNI pragmatically.
- Avoid premature abstractions and overengineering.
- Prefer established project patterns over introducing new ones.

## Implementation

- Understand the relevant code before making changes.
- Make the smallest change that fully solves the problem.
- Keep changes focused on the requested task.
- Avoid modifying unrelated code.
- Do not introduce dependencies without a clear justification.
- Prefer explicit, readable code over clever solutions.
- Preserve existing behavior unless a change is requested.

## Code Quality

- Use meaningful names and consistent formatting.
- Avoid unnecessary comments and documentation.
- Handle errors explicitly where appropriate.
- Keep functions and modules focused.
- Remove code made obsolete by your changes.

## Verification

- Run relevant tests, linters, and type checks when available.
- Never claim that checks passed without executing them.
- Report what was verified and what could not be verified.

## Communication

- Be concise and direct.
- Explain important architectural decisions and trade-offs.
- Ask for clarification when ambiguity materially affects implementation.
- Do not present assumptions as established facts.
