# Course 5: Operating Running Systems — Theory

## Process management

Every running program on Linux is a process with a PID, a priority, and a
state. `ps` shows what's running right now — `ps aux` for a full snapshot
across all users. When a process misbehaves (runs away with CPU, hangs,
or won't respond), the tools to intervene are:

- `kill -SIGNAL PID` — sends a signal to a process. `SIGTERM` (15) asks it
  to exit cleanly; `SIGKILL` (9) forces it to stop immediately, with no
  chance to clean up.
- `nice`/`renice` — adjusts a process's scheduling priority. Lower nice
  values mean higher priority (range -20 to 19). `renice` changes the
  priority of an already-running process; `nice` sets it at launch time.

The point of `logger` in these scenarios is to leave a durable record of
what was diagnosed and fixed, so the incident is provable after the fact
via `journalctl`, not just something that happened and was forgotten.

## systemd targets vs SysV runlevels

RHEL/Rocky use systemd, which replaces the older SysV runlevel concept
with "targets." A target is a named state the system boots into —
`multi-user.target` (text-mode, networked, no GUI) is the equivalent of
old runlevel 3; `graphical.target` (GUI login) is the equivalent of
runlevel 5.

- `systemctl get-default` shows what target the system boots into by
  default.
- `systemctl set-default TARGET` persists a new default (writes a symlink
  in `/etc/systemd/system/default.target`), so it survives reboot.
- `systemctl isolate TARGET` switches to a target right now, without
  changing what happens on the next boot.

For RHCSA, the distinction between a runtime change (`isolate`) and a
persisted change (`set-default`) is the core trap — a fix that "works"
until the next reboot doesn't count as fixed.

## systemd oneshot services

Most services systemd manages are long-running daemons (`Type=simple` or
`Type=notify`), but some tasks just need to run once and then be done —
a pre-flight check, a one-time migration, a setup script. That's what
`Type=oneshot` is for.

Key directives:
- `Type=oneshot` — tells systemd this unit runs to completion and exits,
  rather than staying resident.
- `RemainAfterExit=yes` — without this, systemd considers the unit
  "inactive" the instant the process exits, even if it succeeded. With
  it, the unit shows as `active (exited)`, which is how you can verify
  after the fact that it ran and finished successfully.
- `WantedBy=multi-user.target` (in `[Install]`) — this is what makes
  `systemctl enable` actually wire the unit into the boot sequence.
  Without it, the service exists but never runs automatically at boot.
- `Before=`/`After=` — controls ordering relative to other units, useful
  when a oneshot task needs to run before dependent services start.

Verification for a oneshot service isn't "is it running" (it won't be,
by design) — it's "did it run, and did it exit successfully." That's
`systemctl status` showing `active (exited)` with `status=0/SUCCESS`,
ideally confirmed across a real reboot, not just a manual `systemctl
start`.

## journald: volatile vs persistent storage

By default on many minimal installs, journald keeps logs only in
`/run/log/journal` — which is tmpfs, wiped on every reboot. This is
"volatile" storage. For any real incident investigation, logs need to
survive a reboot, which means "persistent" storage.

The naive fix — create `/var/log/journal` and restart journald — is
necessary but not sufficient on its own. journald only starts writing
new entries to the persistent location going forward; it doesn't
retroactively migrate what's already buffered in the volatile journal.
`journalctl --list-boots` after a reboot is the tell: if it still shows
only 1 boot, the old data never made it to disk.

The actual fix is `journalctl --flush`, which explicitly flushes the
current volatile journal data to the persistent directory. Only after
that does `--list-boots` correctly show multiple boots across reboots,
proving persistence actually works.

This was a genuine two-step debugging lesson: the "obvious" fix looked
complete but wasn't, and the verification step (`--list-boots` across a
real reboot) is what caught it.

## Root password recovery via rd.break — theory only, not yet run live

If root access is lost with no other privileged path in, RHEL/Rocky
support interrupting the boot process at the kernel command line by
appending `rd.break` in GRUB. This drops the boot process into an
emergency shell before the real root filesystem is mounted read-write
or handed off to systemd, giving access to a system that would otherwise
be locked out.

From there:
1. Remount the real root filesystem read-write.
2. `chroot` into it, so commands run against the actual system instead
   of the initramfs environment.
3. Reset the root password with `passwd`.
4. Before rebooting, force an SELinux relabel (commonly by creating
   `/.autorelabel`) — because password/shadow file changes made from
   this environment won't have the correct SELinux context, and booting
   under enforcing mode with a mislabeled `/etc/shadow` can break login
   entirely.
5. Exit chroot, reboot normally.

This is inherently a single-user, physical/console-access scenario — it
can't be done over a normal SSH session, which is why running it live on
this VM requires `virsh console` access rather than `vagrant ssh`. This
section stays theory-only until it's actually executed with live
evidence, per the repo's rule against marking anything done without
real proof.
