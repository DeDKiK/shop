#!/bin/bash
set -euo pipefail

curl -sfL https://get.k3s.io | K3S_URL=https://${server_ip}:6443 K3S_TOKEN=${token} sh -

echo "k3s agent joined: $(date)" > /var/log/k3s-agent-join-done.log