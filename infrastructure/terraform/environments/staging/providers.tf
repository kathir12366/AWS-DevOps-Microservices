variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

# You can omit profile here and use env vars, or hardcode it.
# If you prefer to pin the profile in code, uncomment profile line.
provider "aws" {
  region = var.aws_region
  profile = "q3-dev"
}
