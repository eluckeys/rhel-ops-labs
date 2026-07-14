# Week 1 Checklist: Using Essential Tools

## Status: ✅ Complete — all 5 scenarios run live on AWS, evidence in `course1-evidence.log`

- [x] Scenario A: First-contact recon (shell, users, su/sudo + audit trail)
- [x] Scenario B: Messy shared directory (hard links, symlinks, permissions)
- [x] Scenario C: Live log investigation (grep, pipelines, tee, stdout/stderr)
- [x] Scenario D: SSH key-based auth (ssh-keygen, ssh-copy-id, IdentitiesOnly)
- [x] Scenario E: Backup before risky change (tar, compression, restore verification)

---

Goal: every checkbox = one small, hands-on terminal exercise on the live lab
instance. Do them in order — later ones lean on earlier ones. Record the
whole session with asciinema once, don't need a separate recording per box.

## Module 1: Getting Started with the Linux Shell
- [ ] Explore the shell: `echo $SHELL`, `$0`, difference between login and
      non-login shell (`bash -l` vs plain `bash`)
- [ ] List users: `cat /etc/passwd`, `getent passwd`, filter real users
      (uid >= 1000) with `awk`
- [ ] Change user accounts: `su - username`, `sudo -u username whoami`,
      compare `su` vs `su -` (env difference)

## Module 2: Managing Files and Directories
- [ ] `ls` vs `tree` — compare output, `ls -la`, `ls -lh`, `tree -L 2`
- [ ] List files with different tools: `ls`, `find`, `stat`
- [ ] File types + `find`: `find / -type f -name "*.conf"`,
      `find /etc -type d`, `file <filename>` on a few different file types
- [ ] File operations: `cp`, `mv`, `rm -i`, `mkdir -p`
- [ ] Hard links: create one, `ls -li` to show shared inode, delete original,
      prove content survives
- [ ] Soft/symbolic links: `ln -s`, `ls -l` to see the arrow, break it by
      deleting the target, observe the dangling link

## Module 3: Working with Text and Editing Files
- [ ] Read file content: `cat`, `less`, `head -n`, `tail -n`, `tail -f` on a
      log file while writing to it from another terminal
- [ ] Redirect output: `>` vs `>>` — prove `>` truncates
- [ ] Edit a file in `nano`
- [ ] Edit a file in `vim` — insert mode, save/quit, `dd` to delete a line
- [ ] `grep` filtering: plain match, `-i`, `-v`, `-r` on a directory,
      `-c` to count matches
- [ ] Data streams: stdin/stdout/stderr — redirect each separately
      (`cmd > out.log 2> err.log`)
- [ ] Pipelines: chain 3 commands (e.g. `ps aux | grep ssh | awk '{print $2}'`)
- [ ] `noclobber`: `set -o noclobber`, try to overwrite a file with `>`,
      confirm it refuses, force with `>|`
- [ ] Redirect error output only: `2>`, `2>>`, `2>&1`
- [ ] `tee`: write to a file *and* stdout at the same time, `tee -a` to append

## Module 4: Permissions and Special Access
- [ ] List permissions: `ls -l`, `stat -c "%A %a"`
- [ ] `chmod` symbolic (`u+x`, `g-w`) and numeric (`755`, `644`)
- [ ] SSH client: connect with `ssh user@host`, inspect `~/.ssh/config`
- [ ] Set up key-based auth: `ssh-keygen`, `ssh-copy-id`, confirm password
      login no longer needed, then confirm you can disable password auth
      server-side (just read the `sshd_config` directive, don't apply it on
      a lab box you still need password access to)

## Module 5: Managing Archiving and Documentation
- [ ] Finding help: `man <cmd>`, `<cmd> --help`, `info <cmd>` — compare depth
      of each for the same command
- [ ] Create a backup with `tar -cvf backup.tar /path/to/dir`
- [ ] Use compression with tar: `-czvf` (gzip), `-cjvf` (bzip2), compare
      resulting file sizes with `ls -lh`
- [ ] Extract and verify: `tar -tvf` to list contents before extracting,
      then `tar -xvf` to actually restore

## Not in this week (moved to Week 5 — Operating Running Systems)
These came up when we scoped scenarios but belong to process/log management,
not essential tools:
- ps/kill: find + kill a runaway process
- nice/renice: change priority on a running process
- journalctl: filter by unit, by time, by priority
- Custom log message via the `logger` command
