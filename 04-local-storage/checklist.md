# Week 4 Checklist: Configuring Local Storage

## Status: ✅ Complete — all 3 scenarios run live on AWS, evidence in `course4-evidence.log`

- [x] Scenario 4.1: Live extend under active write load (vgextend, lvextend, xfs_growfs)
- [x] Scenario 4.2: Incomplete LVM setup (mkfs, mount, fstab persistence)
- [x] Scenario 4.3: LVM metadata disaster recovery (vgcfgrestore)

## Sub-topics covered across the 3 scenarios
- [x] PV/VG/LV creation (`pvcreate`, `vgcreate`, `lvcreate`)
- [x] Filesystem creation (`mkfs.xfs`)
- [x] Live volume group/logical volume extension (`vgextend`, `lvextend`)
- [x] Live filesystem growth without unmounting (`xfs_growfs`)
- [x] Persistent mounting via UUID in `/etc/fstab`
- [x] Verifying persistence via `mount -a` and `systemctl daemon-reload`
- [x] LVM metadata backup/archive mechanism (`/etc/lvm/backup/` vs `/etc/lvm/archive/`)
- [x] Metadata recovery (`vgcfgrestore --list`, `vgcfgrestore -f`, `vgchange -ay`)
