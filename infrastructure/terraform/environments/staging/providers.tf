variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-south-1"
}

provider "aws" {
  region  = var.aws_region
  profile = "sabariadmin"
}