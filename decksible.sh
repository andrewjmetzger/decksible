#!/bin/bash

################################################################################
# This script can be used prior to Steam Deck initial login in Game mode
# Hold [POWER] and select [Switch to desktop]
#
# Bluetooth is available at the KDE Desktop.
# Install the following Android app on your phone
# "Serverless Bluetooth Keyboard and Mouse (AppGround IO)"
# This allows your device to emulate a Bluetooth keyboard and mouse.
#
# Connect to your phone using the Bluetooth menu (you may need to connect twice)
# You can now enter your Steam credentials using your phone.
################################################################################

## VARIABLES ###################################################################
# SD Card Path under /run/media (usually mmcblk0p1)
sdcard="/run/media/mmcblk0p1"
rsyncdir="${sdcard}/rsync-backups"
workingdir="${sdcard}/playbooks/software-installs"
################################################################################

echo -e "deck\ndeck" | passwd deck
steamos-session-select plasma-persistent
clear

# Ansible

echo -e "Installing Ansible"

export PATH=/home/deck/.local/bin/:$PATH

python -m ensurepip --update
python -m pip install --upgrade pip
pip3 install ansible-core

mkdir "${rsyncdir}"
mkdir -p "${workingdir}/collections"
cd "$workingdir" || exit

ansible-galaxy install -r requirements.yml
ansible-playbook install-flatpaks.yml
ansible-playbook install-deckbrew.yml  --extra-vars='ansible_become_pass=deck'

steamos-session-select gamescope
echo "deck" | sudo -S steamos-reboot
