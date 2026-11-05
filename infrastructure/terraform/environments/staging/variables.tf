# Staging Environment Variables

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the staging environment"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)

  default = {
    Environment = "staging"
    ManagedBy   = "terraform"
    Project     = "ecommerce"
  }
}

variable "ec2_key_name" {
  description = "Name of existing EC2 key pair for SSH access"
  type        = string
  default     = ""
}