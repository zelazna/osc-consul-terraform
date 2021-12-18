#!/bin/bash
set -e

# Dependencies
sudo apt-get install -y software-properties-common
sudo apt-get update
sudo apt-get install -y unzip tree redis-tools jq curl tmux

# Disable the firewall

sudo ufw disable || echo "ufw not installed"

# Script for execute metadata code
sudo mkdir /usr/lib/systemd/system
sudo mv /ops/config/setup_boot.service /usr/lib/systemd/system/setup_boot.service
sudo systemctl enable setup_boot.service

/bin/bash /ops/install/consul_template.sh
/bin/bash /ops/install/consul.sh
/bin/bash /ops/install/docker.sh
/bin/bash /ops/install/nomad.sh
/bin/bash /ops/install/vault.sh
