# Week 2 Checklist: Creating Shell Scripts

## Status: ✅ Complete — all 3 scenarios run live on AWS, evidence in `scripts/course2-evidence.log`

- [x] Scenario 2.1: Cron-silent PATH bug (health-check.sh + notify-helper.sh)
- [x] Scenario 2.2: Silent success on bad arguments (process-file.sh)
- [x] Scenario 2.3: Silent deploy failure (deploy.sh)

## Sub-topics covered across the 3 scenarios
- [x] Variables, argument handling (`$1`, `$#`)
- [x] Conditionals / input validation (`[ -z ]`, `[ -f ]`)
- [x] Exit codes — setting, checking, and propagating them meaningfully
- [x] Environment differences between interactive shells and cron/systemd
- [x] Redirecting error messages to stderr (`>&2`)
- [x] Diagnosing a script that "looks" successful but silently fails
