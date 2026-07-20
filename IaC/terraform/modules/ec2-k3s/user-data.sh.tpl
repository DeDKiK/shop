#!/bin/bash
set -euo pipefail

echo "Instance ready for Ansible provisioning: $(date)" > /var/log/cloud-init-custom-done.log