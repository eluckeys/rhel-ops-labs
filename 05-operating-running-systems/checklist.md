# Course 5: Operating Running Systems — Checklist

**Overall status:** IN PROGRESS (4 of 5 scenarios run live; 1 documented-only)

## Sub-topics covered

- [x] Process management — `ps`, `kill`, `nice`/`renice` (Scenario 5.1)
- [x] Boot targets — `systemctl get-default`, `systemctl set-default`,
      multi-user.target vs graphical.target (Scenario 5.2)
- [ ] Root password recovery — `rd.break`, chroot, SELinux relabel
      (Scenario 5.3 — documented only, not run live)
- [x] Custom systemd units — `Type=oneshot`, `RemainAfterExit`,
      `WantedBy`, verified across a real reboot (Scenario 5.4)
- [x] journald persistence — `/var/log/journal`, `journalctl --flush`,
      `journalctl --list-boots` (Scenario 5.5, bonus)

## Evidence status

- [x] `course5-evidence.log` captured with all 3 tags:
      `incident-wrong-boot-target`, `incident-custom-systemd-service`,
      `incident-journald-volatile`
- [x] `incident-runaway-proc.log` captured separately (Scenario 5.1,
      partially on AWS)
- [ ] No evidence log for Scenario 5.3 — not run live, notes only

## Before marking Course 5 fully ✅ Complete

- [ ] Run Scenario 5.3 live (requires `virsh console` access, currently
      skipped) — until then, Course 5 stays IN PROGRESS, not Complete,
      per repo rule: no marking complete without live evidence for every
      scenario
