# Scenarios: Creating Shell Scripts

All 3 scenarios below were run live on an AWS Rocky Linux 9 lab instance,
using the broken-state → end-state → constraint → verification formula.
Full audit trail is in `scripts/course2-evidence.log`.

## Scenario 2.1 — Cron-Silent PATH Bug (health-check.sh)

**Client framing:** "Our health-check script works fine when we test it
manually, but alerts aren't reaching us when it's actually scheduled."

| Element | Detail |
|---|---|
| Broken state | Script called a helper (`notify-helper.sh`) by bare name, resolvable only because `.bashrc` had appended it to `$PATH` |
| End state | Script calls the helper by absolute path, works in any environment |
| Constraint | Fix the actual bug, don't rewrite the script |
| Verification | `env -i /bin/bash script.sh` (simulates cron's minimal environment) — failed with exit 127 before the fix, exit 0 after |

**Key lesson:** manual testing in an interactive shell tells you almost
nothing about how a script behaves under cron/systemd, since those don't
source `.bashrc` or inherit shell-level PATH changes.

## Scenario 2.2 — Silent Success on Bad Arguments (process-file.sh)

**Client framing:** "This script is supposed to process a file, but when
someone runs it wrong, it either errors confusingly or does nothing useful
— and still reports success."

| Element | Detail |
|---|---|
| Broken state | No validation on `$1` — missing argument or bad file path leaked raw bash errors (`ambiguous redirect`, `No such file or directory`) but still exited 0 |
| End state | Script validates input first, gives a clear usage message, and returns a distinct non-zero exit code per failure type |
| Constraint | Must still work normally for a valid file |
| Verification | Tested 3 cases — no arg (exit 1), missing file (exit 2), valid file (exit 0, correct line count) |

**Key lesson:** an exit code of 0 is a promise to anything downstream (cron,
monitoring, CI) that the operation truly succeeded. Never let a script reach
its "success" line without actually verifying its inputs first.

## Scenario 2.3 — Silent Deploy Failure (deploy.sh)

**Client framing:** "Our deploy script always says 'Deployment successful,'
but yesterday the service was actually down for 10 minutes after a deploy."

| Element | Detail |
|---|---|
| Broken state | Script ran `cp` and `systemctl restart` without checking either's exit code, then unconditionally printed "Deployment successful" |
| End state | Script checks each critical step's real exit code and fails immediately with a specific error and distinct exit code if any step fails |
| Constraint | Identify which step failed rather than wrapping everything in a blind `exit 1` |
| Verification | Broke the config path and the service name on purpose — script correctly stopped at the first failure (exit 1) instead of reaching the success line; then fixed both and confirmed the happy path still reports success (exit 0) |

**Key lesson:** "fail fast" isn't just a nice phrase — it means checking the
actual exit status of every step that could fail, not assuming success and
hoping for the best.

## What I'd do differently in a real client engagement
- Add `set -euo pipefail` as a baseline safety net across all scripts, in
  addition to explicit checks — belt and suspenders
- Wire these scripts into an actual monitoring system that alerts on
  non-zero exit codes, rather than relying on someone reading logs
- Add a `--dry-run` flag to `deploy.sh` so risky steps can be previewed
  before actually executing them
