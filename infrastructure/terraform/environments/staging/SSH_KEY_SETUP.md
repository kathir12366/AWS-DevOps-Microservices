# SSH Key Setup for EC2 Instances

## Overview
The SSH key pair is now **automatically generated** by Terraform when you deploy the infrastructure. No manual key creation is needed!

## How It Works

1. **Automatic Key Generation**: Terraform generates a 4096-bit RSA key pair
2. **AWS Upload**: The public key is uploaded to AWS as a key pair
3. **Local Storage**: The private key is saved locally as `staging-ec2-key.pem`
4. **Permissions**: The private key file is automatically set to 0600 (read/write for owner only)

## Deployment Steps

1. **Initialize Terraform** (if not done already):
   ```bash
   terraform init
   ```

2. **Deploy Infrastructure**:
   ```bash
   terraform apply
   ```

3. **Get SSH Connection Info**:
   ```bash
   # Get the SSH command
   terraform output ssh_connection_command
   
   # Get just the public IP
   terraform output web_server_public_ip
   ```

4. **Connect to EC2**:
   ```bash
   # Use the output command directly
   ssh -i staging-ec2-key.pem ec2-user@<PUBLIC_IP>
   ```

## Key File Location
- **Private Key**: `./staging-ec2-key.pem` (in the current terraform directory)
- **Key Name in AWS**: `staging-ec2-key`

## Ansible Integration
The Ansible configuration is already set up to use the generated key:
- Location: `infrastructure/ansible/ansible.cfg`
- Key path: `../terraform/environments/staging/staging-ec2-key.pem`

## Security Notes
- The private key is stored locally and should **never** be committed to git
- Add `*.pem` to your `.gitignore` file
- The key has restricted permissions (0600) automatically
- For production, consider using AWS Systems Manager Session Manager instead

## Troubleshooting

### Permission Denied
If you get a permission denied error:
```bash
chmod 600 staging-ec2-key.pem
```

### Key Not Found
If the key file doesn't exist:
1. Run `terraform apply` to generate it
2. Check if it was created: `ls -la *.pem`

### Connection Timeout
- Verify the security group allows SSH (port 22) from your IP
- Check if the instance is in a public subnet with a public IP
- Ensure the Internet Gateway is attached to the VPC

## Clean Up
When destroying the infrastructure:
```bash
terraform destroy
```
This will also remove the key pair from AWS. The local .pem file will remain and should be deleted manually if no longer needed.