# Review report — __FEATURE__

- **Date:** __DATE__
- **Author:** reviewer

> The reviewer does not edit code. It reads, runs, and judges. If something is
> wrong, it says so here and the feature goes back to the implementer.

## Verdict line

<!-- The gate greps for this exact line. PASS or FAIL, nothing else. -->

VERDICT: FAIL

## Acceptance criteria

| Criterion | Met | Evidence |
|-----------|-----|----------|
|           |     |          |

## Five-axis review

### Correctness
<!-- Does it do what the spec says, including edge cases and failure paths? -->

### Architecture
<!-- Dependency direction, layering, business logic outside the UI, no circular deps. -->

### Readability
<!-- Naming, function size, file size, dead code, comment density matching the repo. -->

### Security
<!-- Input validation, secrets, authz on every entry point, injection, logging of sensitive data. -->

### Tests
<!-- Do the tests actually prove the behaviour, or do they only prove the code runs?
     Mutation thinking: invert a boolean, flip a comparison, delete an assignment.
     If the suite stays green, coverage is theatre. -->

## Blocking findings

| # | File:line | Problem | Why it blocks |
|---|-----------|---------|---------------|
|   |           |         |               |

## Non-blocking suggestions

<!-- Worth doing, not worth blocking on. -->
