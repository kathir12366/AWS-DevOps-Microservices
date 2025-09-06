# Ansible Configuration for EC2 Instance Setup

This Ansible configuration sets up Git and clones a GitHub repository on EC2 instances.

## Prerequisites

1. **Deploy EC2 instance with Terraform:**
   ```bash
   cd ../terraform/environments/staging
   terraform init
   terraform apply
   ```

2. **Configure SSH key:**
   - Update `ansible.cfg` with your SSH key path
   - Or update `inventory/staging.ini` with your key path

3. **Install Ansible:**
   ```bash
   pip install ansible
   ```

## Configuration Files

- `ansible.cfg` - Main Ansible configuration
- `inventory/staging.ini` - Static inventory file (update with EC2 IP)
- `inventory/dynamic_inventory.py` - Dynamic inventory from Terraform outputs
- `playbooks/setup-git.yml` - Playbook to install Git and clone repository
- `playbooks/deploy-microservices.yml` - Playbook to install Docker and deploy microservices
- `playbooks/test-microservices.yml` - Playbook to test microservices health and functionality

## Usage

### Option 1: Using Static Inventory
1. Get EC2 public IP from Terraform:
   ```bash
   cd ../terraform/environments/staging
   terraform output web_server_public_ip
   ```

2. Update `inventory/staging.ini` with the EC2 public IP

3. Run the playbook:
   ```bash
   ansible-playbook playbooks/setup-git.yml
   ```

### Option 2: Using Dynamic Inventory
1. Test dynamic inventory:
   ```bash
   ./inventory/dynamic_inventory.py --list
   ```

2. Run playbooks with dynamic inventory:
   ```bash
   # Setup Git and clone repository
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/setup-git.yml
   
   # Deploy microservices with Docker
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/deploy-microservices.yml
   
   # Test microservices
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/test-microservices.yml
   ```

## Full Deployment Workflow

1. **Setup Application Code:**
   ```bash
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/setup-git.yml
   ```

2. **Deploy Microservices:**
   ```bash
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/deploy-microservices.yml
   ```

3. **Test Services:**
   ```bash
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/test-microservices.yml
   ```

4. **All in one command:**
   ```bash
   ansible-playbook -i inventory/dynamic_inventory.py playbooks/setup-git.yml playbooks/deploy-microservices.yml playbooks/test-microservices.yml
   ```

## Customization

Update these variables in `playbooks/setup-git.yml`:
- `git_repo_url`: Your GitHub repository URL
- `git_repo_dest`: Destination path on EC2 instance
- `git_branch`: Branch to clone

## Testing Connection

Test Ansible connectivity:
```bash
# With static inventory
ansible web_servers -m ping

# With dynamic inventory
ansible -i inventory/dynamic_inventory.py web_servers -m ping
```

## Additional Playbooks

You can create additional playbooks for:
- Installing Docker
- Setting up Node.js/Python environments
- Configuring web servers
- Database setup
- Application deployment