# Course 5: Operating Running Systems — Scenarios

## Scenario 5.1 — Runaway process incident

**Client framing:** A client reports a process is consuming abnormal CPU and
slowing down other services on a shared box.

**Broken state:** A runaway process is running at default priority, starving
other work.

**End state:** Process identified, priority corrected via renice (or killed
if unrecoverable), system load returns to normal.

**Constraint:** Must not simply reboot the box — needs to be resolved live,
without disrupting other running services.

**Verification:** `ps`, `logger` entry documenting the incident, confirmed
via `journalctl`.

**Status:** ✅ Done (partially on AWS, tag: incident-runaway-proc)

---

## Scenario 5.2 — Wrong boot target (graphical vs multi-user)

**Client framing:** A minimal server VM was mistakenly left defaulting to a
graphical target, wasting resources and creating unnecessary attack surface
on a headless box.

**Broken state:** `systemctl get-default` returns `graphical.target` on a
server with no GUI requirement.

**End state:** Default target corrected to `multi-user.target`.

**Constraint:** Must survive reboot — not just a runtime `isolate`, but a
persisted default target.

**Verification:** `systemctl get-default` confirmed `multi-user.target`
after a real reboot; logged via `logger -t incident-wrong-boot-target`,
confirmed via `journalctl`.

**Status:** ✅ Done, live evidence captured 2026-07-22

---

## Scenario 5.3 — Root password recovery via rd.break / chroot

**Client framing:** A client has lost the root password on a system with no
other privileged access and needs it recovered without reinstalling.

**Broken state:** Root password unknown, no working privileged session.

**End state:** Root password reset via kernel command-line edit
(`rd.break`), chroot into the real root, password reset, SELinux
relabel triggered on next boot, system boots normally with new
credentials.

**Constraint:** No reinstall, no data loss, must not skip the SELinux
relabel step (or the system won't boot cleanly under enforcing mode).

**Verification:** Successful root login with new password after reboot.

**Status:** 📝 Documented only — NOT yet run live. Requires `virsh console`
access to interrupt boot on this VM, which was skipped for now. Notes saved
in `scenario-5.3-root-recovery-notes.md`. Do not mark this scenario ✅ until
actually executed with real evidence.

---

## Scenario 5.4 — Custom systemd oneshot service

**Client framing:** A client needs a lightweight pre-flight disk check to
run once at boot, before application services start, without needing a
long-running daemon.

**Broken state:** No automated pre-flight check exists; disk state is
unverified before app services start.

**End state:** Custom `preflight-check.service` unit
(`Type=oneshot`, `RemainAfterExit=yes`, `Before=multi-user.target`,
`WantedBy=multi-user.target`) running `/usr/local/bin/preflight-check.sh`
on every boot.

**Constraint:** Must survive reboot (persisted via systemd enable, not a
manual one-off run), must complete before multi-user.target.

**Verification:** `systemctl is-enabled preflight-check.service` →
`enabled`; `systemctl status` shows `active (exited)`, `status=0/SUCCESS`
after a real reboot; logged via
`logger -t incident-custom-systemd-service`, confirmed via `journalctl`.

**Status:** ✅ Done, live evidence captured 2026-07-22

---

## Bonus Scenario 5.5 — journald volatile vs persistent storage

**Client framing:** A client complains that journal logs disappear across
reboots, making incident investigation impossible after a crash.

**Broken state:** journald running volatile-only (no `/var/log/journal`
directory) — logs lost on every reboot.

**End state:** journald persists logs across reboots.

**Constraint:** Must survive a real reboot, not just a service restart.

**Verification:** Creating `/var/log/journal` and restarting journald alone
was **not** sufficient — `journalctl --list-boots` still showed only 1 boot
after a reboot. Fix required `journalctl --flush` as well. Verified with a
second real reboot showing 2 boots in `--list-boots`. Logged via
`logger -t incident-journald-volatile`, confirmed via `journalctl`.

**Status:** ✅ Done, discovered as a genuine 2-step debugging story while
working 5.2/5.4
