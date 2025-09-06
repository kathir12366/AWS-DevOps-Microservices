#!/usr/bin/env python3
"""
Dynamic inventory script for Ansible that reads Terraform outputs
"""

import json
import subprocess
import sys
import os

def get_terraform_outputs():
    """Get outputs from Terraform state"""
    terraform_dir = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        '../../terraform/environments/staging'
    )
    
    try:
        # Change to terraform directory and get outputs
        result = subprocess.run(
            ['terraform', 'output', '-json'],
            cwd=terraform_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error getting Terraform outputs: {e}", file=sys.stderr)
        return {}
    except json.JSONDecodeError as e:
        print(f"Error parsing Terraform outputs: {e}", file=sys.stderr)
        return {}

def generate_inventory():
    """Generate Ansible inventory from Terraform outputs"""
    outputs = get_terraform_outputs()
    
    inventory = {
        'web_servers': {
            'hosts': [],
            'vars': {
                'ansible_user': 'ec2-user'
            }
        },
        '_meta': {
            'hostvars': {}
        }
    }
    
    # Add web server if it exists in outputs
    if 'web_server_public_ip' in outputs:
        public_ip = outputs['web_server_public_ip']['value']
        public_dns = outputs.get('web_server_public_dns', {}).get('value', '')
        instance_id = outputs.get('web_server_instance_id', {}).get('value', '')
        
        if public_ip:
            host_name = f"web-server-{instance_id}" if instance_id else "web-server"
            inventory['web_servers']['hosts'].append(host_name)
            inventory['_meta']['hostvars'][host_name] = {
                'ansible_host': public_ip,
                'public_dns': public_dns,
                'instance_id': instance_id
            }
    
    return inventory

def main():
    """Main function"""
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        inventory = generate_inventory()
        print(json.dumps(inventory, indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        # Return empty dict for specific host (all vars in _meta)
        print(json.dumps({}))
    else:
        print("Usage: %s --list or %s --host <hostname>" % (sys.argv[0], sys.argv[0]))
        sys.exit(1)

if __name__ == '__main__':
    main()