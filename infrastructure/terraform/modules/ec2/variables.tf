# EC2 Module Variables

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.Small"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If not provided, uses latest Amazon Linux 2"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for the key pair (required if create_key_pair is true)"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing key pair to use (required if create_key_pair is false)"
  type        = string
  default     = ""
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "enable_volume_encryption" {
  description = "Whether to enable volume encryption"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile" {
  description = "IAM instance profile attached to EC2"
  type        = string
  default     = ""
}