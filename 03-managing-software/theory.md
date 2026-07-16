# Theory: Managing Software

## Core concept
Package management on RHEL/Rocky isn't just "install/remove" — it's about
controlling *which* repos a package can come from, being able to precisely
reverse a change, and pinning versions that matter to a client's app. DNF
tracks every transaction it performs, which is what makes real rollback
possible (not guesswork, an actual recorded history).

## Why it matters
A disabled repo produces a confusing "package not found" error that looks
like the package doesn't exist — when actually the source it lives in was
just switched off. A bad update needs a *precise* reversal, not a manual
remove+reinstall that might pull a different version than what was there
before. And some packages (an app's specific web server version, for
example) must never move during routine patching.

## Key commands / concepts
- Repo management: `dnf repolist`, `dnf repolist all`, `dnf config-manager --enable/--disable`
- Rollback: `dnf history list`, `dnf history info <ID>`, `dnf history undo <ID>`
- Version pinning: `dnf versionlock add/list/delete`
- Diagnosis: `dnf provides`, `rpm -q`

## The one gotcha that trips people up
A "package not found" error doesn't always mean the package doesn't exist —
it can mean the repo it lives in is disabled. Always check
`dnf repolist all` (not just `dnf repolist`) before concluding a package is
unavailable, since the plain `repolist` only shows *enabled* repos.

## How this connects to the previous topic
Shell Scripting was about a script telling the truth about its own success;
this week is about the package manager telling the truth about system
state — and using its built-in history instead of manual guesswork to
reverse a change.
