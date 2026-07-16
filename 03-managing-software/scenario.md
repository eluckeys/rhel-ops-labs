# Scenarios: Managing Software

All 3 scenarios below were run live on an AWS Rocky Linux 9 lab instance,
using the broken-state → end-state → constraint → verification formula.
Full audit trail is in `course3-evidence.log`.

## Scenario 3.1 — Install Fails, Repo Disabled

**Client framing:** "A package install is failing with 'unable to find a
match' — but we're pretty sure this package should be available."

| Element | Detail |
|---|---|
| Broken state | The `appstream` repo was disabled; `dnf install htop` failed with `No match for argument: htop` |
| Diagnosis | `dnf repolist all` revealed `appstream` as `disabled` — the real clue, not visible in the default `dnf repolist` |
| End state | Repo re-enabled with `dnf config-manager --enable appstream` |
| Constraint | Fix the repo config, don't manually download/install an RPM |
| Verification | Retested with `nginx` (confirmed via `dnf list` to actually live in appstream) — installed cleanly with all dependencies resolved |

**Key finding / trap avoided:** the first verification attempt used `htop`,
which doesn't exist in `appstream` at all (it needs EPEL) — `dnf provides
htop` confirmed this was unrelated to the repo fix, preventing a false
"the fix didn't work" conclusion.

## Scenario 3.2 — Bad Change, Rollback via DNF History

**Client framing:** "We need to revert a package change — properly, using
the package manager's own history, not a manual reinstall."

| Element | Detail |
|---|---|
| Broken state | `nginx` removed (`dnf remove -y nginx`, transaction 7) |
| End state | Exact same package set and version restored via `dnf history undo 7` (transaction 8) |
| Constraint | Used history-based rollback, not `dnf install nginx` from scratch |
| Verification | `nginx -v` and `rpm -q nginx` both confirmed the exact same build (`1.20.1-28.el9_8.2.rocky.0.1`) was restored, and `dnf history list` showed transaction 8 correctly reversing transaction 7 |

**Key lesson:** `dnf history undo` reconstructs the precise prior state —
a manual reinstall could silently pull a newer version if the repo has
updated since removal.

## Scenario 3.3 — Version Pinning to Prevent Unwanted Updates

**Client framing:** "Our app depends on this exact nginx version. Lock it
so routine patching never bumps it."

| Element | Detail |
|---|---|
| Broken state | `nginx` had no protection — any `dnf update` could upgrade it |
| End state | `dnf versionlock add nginx` locks it at `1.20.1-28.el9_8.2.rocky.0.1` |
| Constraint | Used the versionlock plugin properly, not manual repo exclusion |
| Verification | Ran a real system update covering 188 packages (13 installs, 175 upgrades) — `nginx` and its dependencies were completely absent from the plan, confirmed via `grep -i nginx` on the update output returning nothing |

**Key lesson:** versionlock is scoped precisely — it blocked updates to one
package while a genuinely large system update (188 packages) proceeded
normally for everything else.

## What I'd do differently in a real client engagement
- Document exactly which packages are versionlocked and why, in a
  maintained list — an unexplained lock found months later is confusing
  for whoever inherits the system
- Set up an automated check (e.g. a script run after every `dnf update`)
  that reports which packages are currently locked, so locks don't get
  forgotten
- For the repo-disabled scenario, check `/etc/yum.repos.d/*.repo` files
  directly in addition to `dnf repolist all`, since some environments
  manage repo state via config management rather than `dnf config-manager`
