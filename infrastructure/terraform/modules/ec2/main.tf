# EC2 Instance Module

# Latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.environment}-${var.instance_name}-key"
  public_key = var.public_key

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.instance_name}-key"
  })
}

resource "aws_security_group" "instance" {
  name        = "${var.environment}-${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from authorized IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "Public HTTP for Nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana from authorized IP only"
    from_port   = 3004
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.instance_name}-sg"
  })
}

resource "aws_instance" "main" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]

  key_name = var.create_key_pair ? aws_key_pair.main[0].key_name : var.existing_key_name

  associate_public_ip_address = var.associate_public_ip

  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.enable_volume_encryption

    tags = merge(var.common_tags, {
      Name = "${var.environment}-${var.instance_name}-root"
    })
  }

  user_data = var.user_data

  tags = merge(var.common_tags, {
    Name        = "${var.environment}-${var.instance_name}"
    Environment = var.environment
  })

  lifecycle {
    ignore_changes = [ami]
  }
}