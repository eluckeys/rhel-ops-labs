# RHCSA Lab Infra (AWS / Terraform)

Disposable Rocky Linux 9 lab instance for working through all 8 course topics.
Provisioned as code on purpose — every session starts from a known clean
state, which forces re-doing labs from memory instead of drifting into a
half-remembered, half-manually-patched box.

## What this builds
- 1x Rocky Linux 9 EC2 instance (`t3.micro` by default — covers every lab in
  this repo, including LVM/NFS/systemd work)
- A security group allowing SSH only from your own IP, plus NFS (port 2049)
  between lab instances in the same VPC
- N extra blank EBS volumes (default 3, 5GB each) attached to the instance —
  these are your real block devices for the storage/LVM labs, replacing the
  `losetup`/loop-file approach from the original course material

## Usage

```bash
cd infra/aws-ec2-lab
terraform init

terraform apply \
  -var="key_name=YOUR_EC2_KEY_PAIR_NAME" \
  -var="allowed_ssh_cidr=YOUR_IP/32"
```

Grab your current IP for `allowed_ssh_cidr` with `curl -s ifconfig.me` — never
leave this as `0.0.0.0/0`.

SSH in using the output command:

```bash
terraform output ssh_command
```

## Session discipline (important)

Destroy the lab when you're done for the day. EBS volumes bill even when the
instance is stopped, and the whole point is rebuilding from scratch each
session:

```bash
terraform destroy \
  -var="key_name=YOUR_EC2_KEY_PAIR_NAME" \
  -var="allowed_ssh_cidr=YOUR_IP/32"
```

Set a billing alarm in AWS Budgets before your first `apply` — a forgotten
running instance is the only real risk here.

## Two-instance networking labs (Week 8)

For the NFS client/server scenario, just run `terraform apply` twice with
different `instance_name` values in the same region/VPC (e.g.
`nfs-server-lab` and `nfs-client-lab`). The security group already allows
NFS traffic between same-SG instances via the `self = true` rule.
