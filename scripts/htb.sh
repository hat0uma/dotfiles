#!/usr/bin/env bash

# Script for HTB

# Description:
#   This script automates the process of connecting to the HTB VPN and setting up a workspace.

# Usage:
#   Before running this script, execute the following commands:
#   1. Create a new group named 'htb':
#      sudo groupadd htb
#   2. Add the user to the 'htb' group:
#      sudo usermod -a -G htb $(whoami)
#   3. Edit the sudoers file to allow running OpenVPN without password prompt:
#      echo '%htb ALL=(root) NOPASSWD: /usr/sbin/openvpn' | sudo EDITOR='tee -a' visudo
#   4. Provide the path to the OpenVPN configuration file by setting the environment variable OVPN.

set -o errexit
set -o nounset
set -o pipefail

declare -r ovpn_config="${1}"
declare -r session_name="htb"
declare -r nic="tun0"

# Check if session exists and attach if it does
if tmux has-session -t "${session_name}" &>/dev/null; then
	tmux attach-session -t "${session_name}"
	exit
fi

# Start tmux session
tmux new-session -d -s "${session_name}"
tmux rename-window -t "${session_name}" "openvpn"
tmux send-keys -t "${session_name}" "sudo openvpn ${ovpn_config}" Enter

# Wait for VPN to start
printf "Waiting for VPN to start"
while ! ip link show dev "${nic}" &>/dev/null; do
	printf "."
	sleep 1
done
printf "\n"

# Get local IP address
MYIP="$(ip --json address show "${nic}" | jq -r '.[].addr_info[] | select(.family == "inet") | .local')"

# Open workspace
tmux new-window -t "${session_name}" -n "workspace"
tmux send-keys -t "${session_name}:workspace" "export MYIP=${MYIP}" Enter "export BOXIP="

# Attach to tmux session
tmux attach-session -t "${session_name}"
