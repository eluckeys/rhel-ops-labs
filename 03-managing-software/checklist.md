# Week 3 Checklist: Managing Software

## Status: ✅ Complete — all 3 scenarios run live on AWS, evidence in `course3-evidence.log`

- [x] Scenario 3.1: Install fails due to disabled repo (diagnosis + fix)
- [x] Scenario 3.2: Rollback via `dnf history undo`
- [x] Scenario 3.3: Version pinning via `dnf versionlock`

## Sub-topics covered across the 3 scenarios
- [x] Repo management (`dnf repolist`, `repolist all`, `config-manager --enable/--disable`)
- [x] Package install/remove (`dnf install`, `dnf remove`)
- [x] DNF transaction history (`history list`, `history info`, `history undo`)
- [x] Version pinning (`versionlock add/list`)
- [x] Diagnostic commands (`dnf provides`, `rpm -q`)

## Not covered this week (optional, lower RHCSA priority)
- [ ] Flatpak remotes/app install — skipped since core DNF skills
      (repo mgmt, rollback, versionlock) cover the higher-value RHCSA
      objectives; can be added later if needed
