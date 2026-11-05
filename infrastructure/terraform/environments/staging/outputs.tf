# VPC Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

# EC2 Outputs

output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.instance_public_ip
}

output "web_server_public_dns" {
  description = "Public DNS of the web server"
  value       = module.web_server.instance_public_dns
}

output "web_server_instance_id" {
  description = "EC2 instance ID"
  value       = module.web_server.instance_id
}

# SSH Key Outputs

output "ssh_private_key_path" {
  description = "Path to generated SSH private key"
  value       = local_file.private_key.filename
}

output "ssh_key_name" {
  description = "AWS SSH key pair name"
  value       = aws_key_pair.ec2_key.key_name
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${module.web_server.instance_public_ip}"
}
