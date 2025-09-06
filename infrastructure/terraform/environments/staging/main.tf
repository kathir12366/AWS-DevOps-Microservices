# --- Guard + identity output ---
data "aws_caller_identity" "current" {}

resource "null_resource" "ensure_right_account" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == "520943650922"
      error_message = "🚨 Wrong AWS account! Expected 520943650922."
    }
  }
}

output "whoami" {
  value = {
    account = data.aws_caller_identity.current.account_id
    arn     = data.aws_caller_identity.current.arn
  }
}

# --- VPC Module ---
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
  environment          = var.environment
  aws_region           = var.aws_region
  common_tags          = var.common_tags
}

# --- SSH Key Pair Generation ---
resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.environment}-ec2-key"
  public_key = tls_private_key.ec2_ssh_key.public_key_openssh
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-key"
    }
  )
}

resource "local_file" "private_key" {
  content  = tls_private_key.ec2_ssh_key.private_key_pem
  filename = "${path.module}/${var.environment}-ec2-key.pem"
  file_permission = "0600"
}

# --- EC2 Module ---
module "web_server" {
  source = "../../modules/ec2"
  
  instance_name       = "web-server"
  instance_type       = "t2.large"
  subnet_id          = module.vpc.public_subnet_ids[0]
  vpc_id             = module.vpc.vpc_id
  environment        = var.environment
  common_tags        = var.common_tags
  
  associate_public_ip = true
  create_key_pair    = false
  existing_key_name  = aws_key_pair.ec2_key.key_name
  
  ssh_cidr_blocks = ["0.0.0.0/0"]
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from ${var.environment} environment!</h1>" > /var/www/html/index.html
  EOF
}
