#!/usr/bin/env python3
import json
import os
import subprocess
import sys

TERRAFORM_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "terraform", "infra")


def get_terraform_outputs():
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=TERRAFORM_DIR,
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print(f"terraform output failed: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def build_inventory():
    outputs = get_terraform_outputs()

    server_public_ip = outputs["instance_public_ip"]["value"]
    server_private_ip = outputs["instance_private_ip"]["value"]
    agent_public_ips = outputs["agent_public_ips"]["value"]
    runner_public_ip = outputs["runner_public_ip"]["value"]

    hostvars = {
        "k3s_master": {
            "ansible_host": server_public_ip,
            "private_ip": server_private_ip,
        }
    }
    agent_hosts = []
    for i, ip in enumerate(agent_public_ips, start=1):
        name = f"k3s_agent_{i}"
        agent_hosts.append(name)
        hostvars[name] = {"ansible_host": ip}
    hostvars["gitlab_runner_host"] = {"ansible_host": runner_public_ip}
    return {
        "k3s_server": {"hosts": ["k3s_master"]},
        "k3s_agents": {"hosts": agent_hosts},
        "k3s_cluster": {"children": ["k3s_server", "k3s_agents"]},
        "gitlab_runner": {"hosts": ["gitlab_runner_host"]},
        "_meta": {"hostvars": hostvars},
    }

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--list":
        print(json.dumps(build_inventory()))
    elif len(sys.argv) > 1 and sys.argv[1] == "--host":
        print (json.dumps({}))
    else:
        print("usage: --list or --host <name>", file=sys.stderr)
        sys.exit(1)