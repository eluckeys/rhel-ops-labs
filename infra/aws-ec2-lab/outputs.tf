output "instance_public_ip" {
  description = "Public IP of the lab instance"
  value       = aws_instance.lab.public_ip
}

output "ssh_command" {
  description = "Ready-to-paste SSH command"
  value       = "ssh rocky@${aws_instance.lab.public_ip}"
}

output "attached_data_devices" {
  description = "Device names attached for the storage labs (use these with lsblk/parted/pvcreate)"
  value       = [for a in aws_volume_attachment.lab_data_attach : a.device_name]
}
