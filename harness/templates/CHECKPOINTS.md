# Checkpoints — what "correct final state" means here

> The reviewer and the testers check against this file. If a rule is not
> written here, it is not enforced — add it rather than assuming it.

## Definition of done

A feature is done only when **all** of these hold:

- [ ] Acceptance criteria in `feature_list.json` are each proven by a test
- [ ] `progress/impl_<feature>.md` exists and lists files touched + gaps
- [ ] `progress/review_<feature>.md` exists with `VERDICT: PASS`
- [ ] `progress/test_<feature>.md` exists with `VERDICT: PASS`
- [ ] `./harness verify` is green **and newer than the last source change**
- [ ] An exploratory walkthrough ran and its screenshots were looked at
- [ ] Documentation affected by the change was updated
- [ ] `./harness gate <feature>` exits 0

The last one is mechanical: `./harness feature done <id>` runs it and refuses
to write `done` when it fails.

## Code checkpoints

<!-- Adjust these to the project. The defaults come from DEVELOPER.md. -->

- No secrets in code, logs, or fixtures
- All external input validated at the boundary
- Business logic outside UI components
- Dependencies point inward: core ← domain ← application ← features ← ui
- No circular dependencies
- Functions ≤ 20 lines, files ≤ 300 lines
- No `any`, no `@ts-ignore`, no blanket lint disables
- No `console.log` in committed code
- New dependency = explicit approval, with alternatives considered

## Test checkpoints

- Unit tests for every command, use case, domain entity, business rule
- Integration tests wherever two modules meet
- E2E test for every user-facing flow
- Mutation thinking applied: invert a boolean, flip a comparison, delete an
  assignment. If the suite stays green, the coverage is fake — say so.

## Exploratory checkpoints

The automated suite proves the paths someone thought of. The walkthrough looks
for the rest:

- Does it look right, or merely not throw?
- What happens on a slow network, a narrow screen, a double click?
- Are there console errors nobody asserted on?
- Does the back button, refresh, or resume do something sensible?
- Would a first-time user understand what to do next?

Every finding gets a screenshot number and a row in the bug table.

## Escalation

Stop and ask a human when the task requires deciding on:

architecture · security posture · database schema · external API contracts ·
authentication · authorization · infrastructure · anything irreversible
