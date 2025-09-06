# VPC Module Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of database subnets"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# EC2 Module Outputs
output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.instance_public_ip
}

output "web_server_public_dns" {
  description = "Public DNS of the web server"
  value       = module.web_server.instance_public_dns
}

output "web_server_instance_id" {
  description = "Instance ID of the web server"
  value       = module.web_server.instance_id
}

# SSH Key Outputs
output "ssh_private_key_path" {
  description = "Path to the generated SSH private key file"
  value       = local_file.private_key.filename
}

output "ssh_key_name" {
  description = "Name of the SSH key pair in AWS"
  value       = aws_key_pair.ec2_key.key_name
}

output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${module.web_server.instance_public_ip}"
}