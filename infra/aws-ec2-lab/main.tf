terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Rocky Linux 9 official AMI (free, no marketplace subscription needed).
# Data source pulls the latest Rocky 9 image so this doesn't rot over time.
data "aws_ami" "rocky9" {
  most_recent = true
  owners      = ["792107900819"] # Rocky Linux official AWS account

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "lab_sg" {
  name        = "${var.instance_name}-sg"
  description = "Lab SG: SSH from my IP only, plus NFS between lab nodes"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # NFSv4 - week 8 networking scenario. Only needed if you spin up a
  # second instance in the same VPC for client/server NFS testing.
  ingress {
    description = "NFSv4 within the VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "lab" {
  ami                    = data.aws_ami.rocky9.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}

# Extra blank EBS volumes for the storage/LVM labs (week 4 + 6).
# These stand in for the loop-device disk0/disk1 files from the course
# transcripts - real block devices instead of losetup files.
resource "aws_ebs_volume" "lab_data" {
  count             = var.data_volume_count
  availability_zone = aws_instance.lab.availability_zone
  size              = var.data_volume_size_gb
  type              = "gp3"

  tags = {
    Name = "${var.instance_name}-data-${count.index}"
  }
}

resource "aws_volume_attachment" "lab_data_attach" {
  count       = var.data_volume_count
  device_name = "/dev/sd${element(["f", "g", "h", "i", "j"], count.index)}"
  volume_id   = aws_ebs_volume.lab_data[count.index].id
  instance_id = aws_instance.lab.id
}
