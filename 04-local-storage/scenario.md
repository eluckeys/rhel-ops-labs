# Scenarios: Configuring Local Storage

All 3 scenarios below were run live on an AWS Rocky Linux 9 lab instance
with 3 attached EBS volumes, using the broken-state → end-state →
constraint → verification formula. Full audit trail is in
`course4-evidence.log`.

## Scenario 4.1 — Live Extend Under Active Write Load

**Client framing:** "Our app's data volume is almost full and we can't take
downtime. Add capacity and extend it live while it's actively being
written to."

| Element | Detail |
|---|---|
| Broken state | 3GB LVM volume (`app_vg/app_lv`), a background process writing a timestamped record every second |
| End state | Volume grown to ~10GB by adding a second disk to the VG, extending the LV, and growing the XFS filesystem — all without unmounting |
| Constraint | No unmount, no interruption to the write loop |
| Verification | `df -h` confirmed capacity increase from 3G to 10G; the write loop (`jobs`, `wc -l` on the log) never stopped and the log grew continuously throughout |

**Key finding:** `xfs_growfs` operates on a live, mounted filesystem — this
is a core reason XFS is the RHEL/Rocky default, since it avoids the
downtime a filesystem needing to be unmounted for resize would require.

## Scenario 4.2 — Incomplete LVM Setup

**Client framing:** "Someone started setting up storage for a new service —
created a logical volume — but never finished. Finish it properly."

| Element | Detail |
|---|---|
| Broken state | `service_lv` existed with no filesystem, no mount point, nothing in `/etc/fstab` |
| End state | Formatted XFS, mounted at `/mnt/servicedata`, persisted via UUID in fstab |
| Constraint | Must survive a reboot, not just work in the current session |
| Verification | Unmounted manually, then `mount -a` remounted purely from the fstab entry; `systemctl daemon-reload` + `findmnt` confirmed systemd's own generated `mnt-servicedata.mount` unit was correctly sourced from fstab |

**Key lesson:** always reference filesystems in fstab by UUID (via
`blkid`), not device path — device names like `/dev/nvme3n1` can shift
between boots, but a filesystem's UUID never changes.

## Scenario 4.3 — LVM Metadata Disaster Recovery

**Client framing:** "Someone ran a destructive command against our volume
group's metadata. Recover it using LVM's own backup mechanism, not a
separate data backup system."

| Element | Detail |
|---|---|
| Broken state | `vgremove -f service_vg` wiped the VG/LV metadata (data blocks on disk untouched, but inaccessible) |
| End state | VG and LV fully restored and remounted, original data intact |
| Constraint | Must use `vgcfgrestore`, not recreate the VG from scratch |
| Verification | A test file (`critical-file.txt`) written before the simulated disaster was still readable, byte-for-byte, after recovery |

**Key finding (a real mistake, kept in the record deliberately):** the
first restore attempt used the wrong archive file
(`service_vg_00000-...`, taken *before* the LV was even created), which
restored the VG but with 0 logical volumes. `vgcfgrestore --list service_vg`
was used to review every archived version's description and timestamp,
which identified the correct one — `service_vg_00001-...`, taken
immediately *before* the `vgremove` command. This is a genuinely useful
practice: never assume the first available restore point is the correct
one, always check the description.

## What I'd do differently in a real client engagement
- For Scenario 4.1, monitor actual I/O latency during the live extend, not
  just confirm the write loop kept running — a real production app might
  be sensitive to brief latency spikes during the LVM operations
- For Scenario 4.2, script the "format + mount + fstab entry" sequence as
  a reusable one-liner, since incomplete setups like this are a common
  handoff issue between team members
- For Scenario 4.3, set up a scheduled `vgcfgbackup` job or at minimum
  document the archive retention policy, since `/etc/lvm/archive/` isn't
  infinite — old entries can be pruned over time
