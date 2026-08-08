# Test report — __FEATURE__

- **Date:** __DATE__
- **Author:** tester (automated + exploratory)

## Verdict line

<!-- The gate greps for this exact line. PASS or FAIL, nothing else. -->

VERDICT: FAIL

## Automated run

<!-- Paste the report folder printed by `./harness verify`. -->

- Report: `test-reports/...`
- Lint / Typecheck / Unit / E2E: <!-- PASS or FAIL each -->

## Exploratory walkthrough

<!-- Paste the report folder printed by `./harness explore <feature> --run`. -->

- Report: `test-reports/test_explore-...`
- Screenshots: <!-- how many -->
- Spec: `e2e/exploratory/....spec.ts`

### What a user would actually experience

<!-- Narrate the flow the way a human tester would report it. Reference the
     numbered screenshots: "003-after-submit.png shows the button still spinning". -->

## Bugs found

| # | Severity | Steps to reproduce | Screenshot | Filed as |
|---|----------|--------------------|------------|----------|
|   |          |                    |            |          |

## Coverage gaps

<!-- What is still untested and why. If a criterion has no test, say so here —
     the reviewer cross-checks this against the implementation report. -->

## Regressions checked

<!-- Which existing flows you re-ran to make sure this feature broke nothing. -->
