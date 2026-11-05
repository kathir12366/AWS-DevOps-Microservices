# --- Guard + Identity Output ---

data "aws_caller_identity" "current" {}

resource "null_resource" "ensure_right_account" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == "240571106446"
      error_message = "Wrong AWS account! Expected 240571106446."
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
  environment           = var.environment
  aws_region            = var.aws_region
  common_tags           = var.common_tags

  depends_on = [null_resource.ensure_right_account]
}

# --- SSH Key Pair Generation ---

resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.environment}-ec2-key"
  public_key = tls_private_key.ec2_ssh_key.public_key_openssh

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ec2-key"
  })

  depends_on = [null_resource.ensure_right_account]
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2_ssh_key.private_key_pem
  filename        = "${path.module}/${var.environment}-ec2-key.pem"
  file_permission = "0600"
}

# --- EC2 Module ---

module "web_server" {
  source = "../../modules/ec2"

  instance_name = "web-server"
  instance_type = "t3.small"

  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_id    = module.vpc.vpc_id

  environment = var.environment
  common_tags = var.common_tags

  associate_public_ip = true
  create_key_pair     = false
  existing_key_name   = aws_key_pair.ec2_key.key_name

  # EC2 IAM Instance Profile for ECR image pulling
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # SSH access - verify this IP before deployment
  ssh_cidr_blocks = ["103.144.232.7/32"]

  # Ubuntu 24.04 Docker + Docker Compose + AWS CLI setup
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y ca-certificates curl gnupg git unzip

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc

    chmod a+r /etc/apt/keyrings/docker.asc

    . /etc/os-release

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update

    apt-get install -y docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin

    systemctl enable --now docker

    usermod -aG docker ubuntu

    # Install AWS CLI v2
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o "/tmp/awscliv2.zip"

    unzip -q /tmp/awscliv2.zip -d /tmp

    /tmp/aws/install

    docker --version
    docker compose version
    aws --version
    git --version
  EOF

  depends_on = [
    null_resource.ensure_right_account,
    module.vpc,
    aws_key_pair.ec2_key,
    aws_iam_instance_profile.ec2_profile,
    aws_iam_role_policy_attachment.ecr_readonly
  ]
}