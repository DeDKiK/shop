#!/bin/bash
set -euo pipefail

curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --write-kubeconfig-mode 644 \
  --tls-san ${public_ip}

echo "k3s install finished: $(date)" > /var/log/k3s-install-done.log