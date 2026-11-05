# ==========================================
# Amazon ECR - Three Microservices
# ==========================================

resource "aws_ecr_repository" "user_service" {
  name                 = "${var.environment}-user-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.common_tags
}

resource "aws_ecr_repository" "product_service" {
  name                 = "${var.environment}-product-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.common_tags
}

resource "aws_ecr_repository" "order_service" {
  name                 = "${var.environment}-order-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.common_tags
}

# ==========================================
# EC2 IAM Role for ECR Access
# ==========================================

resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.environment}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

# ECR Read Only Access

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name

  tags = var.common_tags
}

# ==========================================
# Terraform Outputs
# ==========================================

output "user_service_ecr_url" {
  value = aws_ecr_repository.user_service.repository_url
}

output "product_service_ecr_url" {
  value = aws_ecr_repository.product_service.repository_url
}

output "order_service_ecr_url" {
  value = aws_ecr_repository.order_service.repository_url
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}