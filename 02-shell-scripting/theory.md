# Theory: Creating Shell Scripts

## Core concept
A shell script isn't just "commands in a file" — it's a program that needs
to behave predictably in environments where no human is watching: cron,
systemd timers, CI/CD pipelines. The core skill isn't syntax, it's making a
script fail loudly and correctly instead of failing silently.

## Why it matters
Every one of this week's scenarios was the same root problem in different
clothes: a script *looked* like it worked (clean output, exit code 0) while
actually failing. In production, a script that lies about its own success is
worse than one that crashes — it hides real outages behind a green checkmark.

## Key commands / concepts
- Argument handling: `$1`, `$#`, `[ -z "$VAR" ]`, `[ -f "$FILE" ]`
- Exit codes: `$?`, `exit N`, distinct codes per failure type
- Environment isolation: `env -i`, cron's minimal `$PATH`
- Redirecting errors: `>&2` for error messages, so they don't pollute stdout

## The one gotcha that trips people up
Testing a script by running it directly in your interactive shell proves
almost nothing about how it'll behave under cron or systemd — those don't
source `.bashrc`, don't inherit your `$PATH` additions, and don't have a
terminal. `env -i /bin/bash script.sh` is the fastest way to catch this
class of bug before it reaches production.

## How this connects to the previous topic
Essential Tools (grep, pipes, tee, redirection) are the raw ingredients;
this week is about assembling them into something that runs unattended and
tells the truth about whether it worked.
