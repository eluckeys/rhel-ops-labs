variable "aws_region" {
  description = "AWS region to build the lab in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance size for the lab box"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair to attach for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the lab (set to your own IP/32, not 0.0.0.0/0)"
  type        = string
}

variable "data_volume_count" {
  description = "Number of extra EBS volumes to attach for storage/LVM labs"
  type        = number
  default     = 3
}

variable "data_volume_size_gb" {
  description = "Size in GB of each extra EBS volume"
  type        = number
  default     = 5
}

variable "instance_name" {
  description = "Name tag for the lab instance"
  type        = string
  default     = "rhcsa-lab"
}
