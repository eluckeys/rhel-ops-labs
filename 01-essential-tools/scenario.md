# Scenarios: Using Essential Tools

All 5 scenarios below were run live on an AWS Rocky Linux 9 lab instance.
Full command output/audit trail is in `course1-evidence.log`.

## Scenario A — Unfamiliar Production Box Recon

**Client framing:** "We're handing you SSH access to a server you've never
seen before. Get familiar with it before touching anything."

- Explored shell basics (`$SHELL`, `$0`, login vs non-login shell)
- Listed real users vs system accounts (`/etc/passwd`, `awk` filter on UID)
- Confirmed `sudo` works and pulled its audit trail via `journalctl`

**Key finding:** only one real login account (`rocky`, UID 1000) — everything
else is a system/service account with `/sbin/nologin`, which is expected and
not a red flag.

## Scenario B — Messy Shared Directory Cleanup

**Client framing:** "A junior admin left `/opt/shared` a mess — duplicate
files, a broken symlink, wrong permissions. Clean it up."

- Built a hard link (`app.conf` / `app.conf.bak`) and proved they share the
  same inode with `ls -li`
- Built a symlink, broke it on purpose, diagnosed the breakage via `cat`
  failing even though `ls -l` still showed the link
- Removed the broken symlink and the redundant hard-link "backup," fixed
  permissions to `644`

**Key lesson:** a hard link is not a real backup — it's the same data under
a second name. If the original is corrupted, so is the "backup."

## Scenario C — Live Log Investigation

**Client framing:** "The app is throwing intermittent errors. Investigate
without stopping it."

- Simulated a live-writing log with a background loop, watched it grow with
  `tail -f`
- Filtered errors with `grep` (plain, `-c`, `-B/-A` context, `-i`)
- Used `tee` to save matches to a file while still viewing them on screen
- Separated stdout/stderr explicitly and proved the difference by forcing a
  real stderr error (missing file)

**Key finding:** errors occurred on exactly every 7th request — a periodic
pattern, not random noise, which is a stronger finding to hand to a dev team
than "some timeouts happened."

## Scenario D — SSH Key-Based Auth Before Going Live

**Client framing:** "This server is about to go into production. Disable
password login risk by enforcing key-based auth."

- Verified `~/.ssh` (700) and `authorized_keys` (600) permissions were
  already correct on both client and server
- Generated a new keypair, hit a real `ssh-copy-id` false-negative
  ("already exists"), forced the copy, and verified with
  `ssh -o IdentitiesOnly=yes` to isolate exactly which key was being used
- Read (but did not apply) the `sshd_config` directive needed to fully
  disable password auth, to avoid locking myself out of a shared lab box

**Key lesson:** a commented-out directive in `sshd_config` means "use the
compiled default," not "disabled" — `#PasswordAuthentication yes` still
means password auth is on.

## Scenario E — Backup Before a Risky Change

**Client framing:** "Take a backup before a config change, in case
something breaks."

- Created a plain `tar` archive, then gzip and bzip2 compressed versions
- Hit a real bzip2 failure (binary not installed on the minimal image),
  diagnosed it, installed `bzip2`, and re-ran successfully
- Listed archive contents with `tar -tvf` before ever extracting anything
- Simulated a real break (deleted `app.conf`), restored it into an isolated
  test directory, and verified the restored file matched the original

**Key lesson:** always list a tar archive's contents before extracting, and
always verify a restore actually works before trusting a backup process.

## What I'd do differently in a real client engagement
- Redact hostnames/IPs before sharing any of this recon or evidence log
  externally
- Actually apply the `PasswordAuthentication no` change on a dedicated
  (non-lab) box, with a tested rollback plan in case it locks anyone out
- Automate the log-error pattern detection (every-Nth-request) rather than
  spotting it by eye — e.g. a small script that flags periodicity in error
  timestamps
