# rhel-ops-labs

Hands-on RHCSA-track work, rebuilt as client-style scenarios rather than raw
course notes. Each course topic gets its own folder with:

- `theory.md` — the concept in my own words, written before any hands-on work
- `scenario.md` — the client framing, what I did, what I'd do differently
- `scripts/` — the actual idempotent scripts run during the lab
- `recordings/` — asciinema terminal recordings of real runs

Lab environment is provisioned on AWS via Terraform (see `infra/`) —
disposable by design, torn down and rebuilt each session so every run is
done from memory, not by continuing a half-configured box.

## Progress

| # | Course | Status | Scenario |
|---|--------|--------|----------|
| 1 | Using Essential Tools | ✅ Complete — all 5 scenarios run live on AWS with evidence log | [Unfamiliar production box recon](01-essential-tools/scenario.md) |
| 2 | Creating Shell Scripts | 🔲 Not started | |
| 3 | Managing Software | 🔲 Not started | |
| 4 | Configuring Local Storage | 🔲 Not started | |
| 5 | Operating Running Systems | 🟡 In progress — 4/~20 sub-items done live on AWS with log proof | [Runaway process incident](05-operating-running-systems/scenario.md) |
| 6 | Creating and Configuring File Systems | 🔲 Not started | |
| 7 | Deploying, Configuring, and Maintaining Systems | 🔲 Not started | |
| 8 | Managing Basic Networking | 🔲 Not started | |

**Status key:** 🔲 not started/scaffolded only · 🟡 in progress (some items run live with proof) · ✅ complete (all checklist items run live with proof/logs committed)

## Lab infrastructure

See [`infra/aws-ec2-lab`](infra/aws-ec2-lab/README.md) for the Terraform
config used to provision the disposable Rocky Linux 9 lab instance(s) these
scenarios run against.

## Incident writeups

Cross-cutting "broke it on purpose, fixed it" reports live in
`incident-writeups/` as they're added — these map to real production
failure modes (e.g. bad `/etc/fstab` entry causing a failed boot), not just
lab exercises.
