/**
 * Exploratory walkthrough — __FEATURE__
 *
 * This is the "manual" test, automated. The tester-manual agent writes the
 * steps a human would actually perform, and `shot()` captures the screen at
 * every meaningful moment. The point is NOT to assert everything: it is to
 * produce a visual record a human can skim in thirty seconds.
 *
 * Run it:
 *     ./harness explore __FEATURE__ --run
 *
 * Output lands in test-reports/test_explore-__FEATURE___<date>/
 *   screenshots/001-....png, 002-....png, ...
 *   report.md   ← every screenshot embedded, in order
 */
import { test, expect, type Page } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';

const reportDir = process.env.HARNESS_REPORT_DIR ?? path.resolve('test-reports/adhoc');
const shotsDir = path.join(reportDir, 'screenshots');
let stepCounter = 0;

/** Capture the current screen into the run's report folder. */
async function shot(page: Page, name: string): Promise<void> {
  fs.mkdirSync(shotsDir, { recursive: true });
  stepCounter += 1;
  const slug = name.replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '').toLowerCase();
  const file = path.join(shotsDir, `${String(stepCounter).padStart(3, '0')}-${slug}.png`);
  await page.screenshot({ path: file, fullPage: true });
  test.info().annotations.push({ type: 'screenshot', description: path.basename(file) });
}

/** Collect console errors so the walkthrough fails on a silently broken page. */
function watchConsole(page: Page): string[] {
  const errors: string[] = [];
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text());
  });
  page.on('pageerror', (err) => errors.push(String(err)));
  return errors;
}

test.describe('exploratory — __FEATURE__', () => {
  test('walkthrough', async ({ page }) => {
    const consoleErrors = watchConsole(page);

    await page.goto('/');
    await shot(page, 'landing');

    // ------------------------------------------------------------------
    // TODO(tester-manual): replace this with the real flow for __FEATURE__.
    // Drive it the way a user would, and call shot() after each step that
    // changes what is on screen. Prefer getByRole/getByText over CSS.
    //
    //   await page.getByRole('button', { name: 'Start' }).click();
    //   await shot(page, 'after-start');
    // ------------------------------------------------------------------

    await shot(page, 'final-state');

    expect(consoleErrors, `console errors:\n${consoleErrors.join('\n')}`).toHaveLength(0);
  });
});
