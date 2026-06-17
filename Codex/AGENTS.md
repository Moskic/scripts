# Global Coding Guidelines

These are default working agreements for Codex across repositories. Follow them unless a project-level AGENTS.md gives more specific instructions.

## General Principle

Bias toward simple, surgical, verifiable changes.

For trivial tasks, use judgment and avoid unnecessary ceremony.

## 1. Think Before Coding

Don't assume silently. Don't hide confusion. Surface tradeoffs.

Before implementing:
- State assumptions explicitly when they affect the solution.
- If uncertainty blocks progress, ask. Otherwise make a reasonable assumption and document it.
- If multiple interpretations exist and the choice affects correctness, present them.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear and affects correctness, stop, name what is confusing, and ask. If it does not block progress, proceed with a stated assumption.

## 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No flexibility or configurability that was not requested.
- No error handling for impossible scenarios, but preserve existing safety, validation, and security checks.
- If a solution is much longer than necessary, simplify it.
- Do not sacrifice established project patterns that improve long-term maintainability or testability.
- Never compromise security for simplicity.

Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

Touch only what is necessary. Clean up only your own changes.

When editing existing code:
- Do not improve adjacent code, comments, or formatting unless required.
- Do not refactor things that are not part of the task.
- Match existing style.
- If you notice bad habits, poor practices, unrelated dead code, or risky patterns, mention them instead of changing them silently.

When your changes create orphans:
- Remove imports, variables, functions, files, or tests that your changes made unused.
- Do not remove pre-existing dead code unless asked.

Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

Define success criteria and verify the work.

Transform tasks into verifiable goals:
- "Add validation" → write or update checks for invalid inputs, then make them pass.
- "Fix the bug" → reproduce the bug or identify the failing path, then verify the fix.
- "Refactor X" → ensure behavior is preserved before and after.

For multi-step tasks, state a brief plan:

1. Step → verify: check
2. Step → verify: check
3. Step → verify: check

Prefer concrete verification: tests, type checks, linters, build commands, or targeted manual checks.

If verification cannot be run, explain what was not run and why.