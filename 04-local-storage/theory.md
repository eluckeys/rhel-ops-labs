# Theory: Configuring Local Storage

## Core concept
LVM adds a flexible layer between physical disks and filesystems: Physical
Volume (PV) → Volume Group (VG) → Logical Volume (LV). The whole point of
this layer is that capacity can grow (add a disk, extend the VG, extend the
LV, grow the filesystem) without ever unmounting or interrupting whatever is
actively using that storage.

## Why it matters
Real storage problems are rarely "create a volume from scratch" — they're
"this is full and we can't take downtime," "someone half-finished this
setup," or "the metadata got wiped by accident." All three are things LVM
is specifically designed to handle gracefully, if you know the right
commands.

## Key commands / concepts
- Build: `pvcreate`, `vgcreate`, `lvcreate`, `mkfs.xfs`
- Live extend: `vgextend`, `lvextend -l +100%FREE`, `xfs_growfs` (no unmount needed)
- Persistence: `blkid` (get UUID), `/etc/fstab` entries by UUID (not device path), `systemctl daemon-reload`
- Metadata recovery: `vgcfgrestore --list`, `vgcfgrestore -f <archive>`, `vgchange -ay`

## The one gotcha that trips people up
`/etc/lvm/backup/<vgname>` is a **single file that's constantly overwritten**
with the latest state — it is NOT a history. `/etc/lvm/archive/` is where
the actual timestamped history lives, one file per change, each with a
description of what it was taken *before*. Restoring from `backup/` after a
disaster often restores the disaster itself, not the last-good state.
Always check `vgcfgrestore --list <vg>` and read the descriptions before
picking a file.

## How this connects to the previous topic
Managing Software was about DNF's own history mechanism for precise
rollback; this week is the same idea one layer down — LVM has its own
history mechanism (archive vs backup), and using it correctly (not
guessing) is what makes disaster recovery actually reliable.
