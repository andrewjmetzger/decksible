#!/bin/bash

## SETUP ######################################################################
# This script can be used prior to Steam Deck initial login in Game mode
# Hold [POWER] and select [Switch to desktop]
#
# KDE Connect is available at the KDE Desktop.
# This allows your device to emulate a Bluetooth keyboard and mouse.
################################################################################

## VARIABLES ###################################################################
# Either SD Card (usually /run/media/mmcblk0p1), or $HOME (on SSD)
export sdcard="$HOME"
export decksible_path="${sdcard}/.decksible"

mkdir -p "${sdcard}"
mkdir -p "${decksible_path}"

# Version Control
repo="https://github.com/andrewjmetzger/decksible.git" 
################################################################################


git clone "${repo}" "${decksible_path}"
cd "${decksible_path}" && git pull --force

echo -e "deck\ndeck" | passwd deck
echo "deck" | sudo -S systemctl enable sshd.service --now
clear

if ! [ -d ${decksible_path}/.venv ]; then
    python3 -m venv ${decksible_path}/.venv
fi

source ${decksible_path}/.venv/bin/activate


# Ansible

echo -e "Installing Ansible"

export PATH=/home/deck/.local/bin/:$PATH

${decksible_path}/.venv/bin/pip3 install ansible-core 

mkdir -p "${decksible_path}/collections"
cd "${decksible_path}" || exit

ansible-galaxy install -r ${decksible_path}/requirements.yml

ansible-playbook ${decksible_path}/playbooks/configure-ssh.yml --extra-vars='ansible_become_pass=deck'
ansible-playbook ${decksible_path}/playbooks/install-flatpaks.yml
ansible-playbook ${decksible_path}/playbooks/install-decky-loader.yml --extra-vars='ansible_become_pass=deck'
ansible-playbook ${decksible_path}/playbooks/install-emudeck.yml --extra-vars='ansible_become_pass=deck'

deactivate

# echo "deck" | steamos-session-select gamescope

