# EC2 Instance Module

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
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
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-${var.instance_name}-key"
    }
  )
}

resource "aws_security_group" "instance" {
  name        = "${var.environment}-${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Microservices ports
  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "User Service"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Product Service"
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Order Service"
    from_port   = 3003
    to_port     = 3003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3004
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Gateway"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-${var.instance_name}-sg"
    }
  )
}

resource "aws_instance" "main" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name              = var.create_key_pair ? aws_key_pair.main[0].key_name : var.existing_key_name
  
  associate_public_ip_address = var.associate_public_ip
  
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.enable_volume_encryption
    
    tags = merge(
      var.common_tags,
      {
        Name = "${var.environment}-${var.instance_name}-root"
      }
    )
  }
  
  user_data = var.user_data
  
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.instance_name}"
      Environment = var.environment
    }
  )
  
  lifecycle {
    ignore_changes = [ami]
  }
}