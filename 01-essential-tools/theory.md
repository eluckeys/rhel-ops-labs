# Theory: Using Essential Tools

## Core concept
This topic is really "can I move around and manipulate a Linux system fast,
without hesitating." Filesystem navigation, permissions (rwx for user/group/
other), text processing (`grep`/`sed`/`awk`), process inspection, and I/O
redirection are the primitives everything else in RHCSA — and every real
troubleshooting session — is built from.

## Why it matters
Every later topic assumes this is automatic. If you have to think about
`chmod` syntax or how a pipe works while you're also trying to debug a full
disk or a crashed service, you're spending your attention budget in the
wrong place. This is the "muscle memory" layer.

## Key commands
- Navigation/permissions: `ls -l`, `chmod`, `chown`, `chgrp`, `find`
- Text processing: `grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, `wc`
- Process/IO: `ps`, `top`, redirection (`>`, `>>`, `<`, `|`), `tar`

## The one gotcha that trips people up
Permissions are not cumulative across user/group/other. If you're the file's
owner, your access is decided entirely by the *user* bits — your group's
permissions don't add anything on top, even if the group bits are more
permissive. This bit me directly in the file-systems module (setting 777 on
a directory that then got mounted over, hiding the permissions you thought
you set).

## How this connects to the previous topic
N/A — this is the foundation everything else sits on.
