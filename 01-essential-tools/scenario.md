# Scenario: Unfamiliar Production Box Recon

## Client framing
"We're handing you SSH access to a server you've never seen before. Before
you touch anything, get familiar with it — who's on it, what's running,
what's using disk space, and whether anything looks off."

## What I did
1. Provisioned a fresh Rocky Linux 9 lab instance via the Terraform config
   in `infra/aws-ec2-lab/` — deliberately treating it as "unfamiliar."
2. Ran a full manual recon pass first (no script), to prove I could do it
   without tooling:
   - `id`, `who`, `last` — who has access, who's logged in, login history
   - `ls -la /home`, `cat /etc/passwd` — real vs system accounts
   - `df -h`, `du -sh /var/* 2>/dev/null | sort -h` — disk usage by directory
   - `ps aux --sort=-%cpu | head`, `systemctl list-units --failed` — running
     processes and anything already broken
   - `find /var/log -mtime -1` — what changed in the last 24 hours
3. Converted the recon steps into `scripts/system-recon.sh` — an idempotent,
   repeatable version of the same checks, output formatted so it's readable
   at a glance instead of scrollback soup.
4. Recorded the run with asciinema (`recordings/week1-recon.cast`).

## What I'd do differently in a real client engagement
- Add a flag to redact hostnames/IPs before sharing recon output externally.
- Pull `rpm -qa --last | head` too — recently installed/updated packages are
  often the first thing worth checking on an unfamiliar box.
- Log the recon output to a timestamped file automatically rather than only
  printing to stdout, so there's a record of "state at first contact."

## Gotcha encountered
`du -sh /var/* 2>/dev/null` silently swallows permission-denied directories
you don't have access to — good for a quick pass, but worth calling out
explicitly in a real report so it doesn't look like those dirs are empty.
