#!/usr/bin/env python3
import boto3
import json

def get_ec2_instances():
    ec2 = boto3.resource('ec2')
    instances = ec2.instances.filter(Filters=[
        {'Name': 'instance-state-name', 'Values': ['running']}
    ])
    inventory = {
        '_meta': {'hostvars': {}},
        'monitor-server': {'hosts': [], 'vars': {}},
        'tomcat-server': {'hosts': [], 'vars': {}}
    }
    for instance in instances:
        tags = {t['Key']: t['Value'] for t in instance.tags or []}
        for name in tags.get('Name', '').split(','):
            public_ip = instance.public_ip_address
            private_ip = instance.private_ip_address
            if name:
                inventory.setdefault(name, {'hosts': [], 'vars': {}})
                inventory[name]['hosts'].append(public_ip)
                inventory[name]['vars']['private_ip'] = private_ip
                inventory['_meta']['hostvars'][public_ip] = {
                    'ansible_user': 'ubuntu',
                    'ansible_ssh_private_key_file': 'tool.pem'
                }
    return inventory

def main():
    inventory = get_ec2_instances()
    print(json.dumps(inventory))

if __name__ == '__main__':
    main()
