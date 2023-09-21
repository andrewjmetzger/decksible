#!/bin/bash

## SETUP ######################################################################
# This script can be used prior to Steam Deck initial login in Game mode
# Hold [POWER] and select [Switch to desktop]
#
# KDE Connect is available at the KDE Desktop.
# This allows your device to emulate a Bluetooth keyboard and mouse.
################################################################################

## VARIABLES ###################################################################
# SD Card Path under /run/media (usually mmcblk0p1)
sdcard="/run/media/mmcblk0p1"

rsyncdir="${sdcard}/rsync-backups"
workingdir="${sdcard}/decksible"

# Version Control
repo="https://github.com/andrewjmetzger/decksible.git" 
repodest="${sdcard}/decksible"
################################################################################


git clone "${repo}" "${repodest}"
cd "${repodest}" && git pull --force

echo -e "deck\ndeck" | passwd deck
echo "deck" | sudo -S systemctl enable sshd.service --now
clear

# Ansible

echo -e "Installing Ansible"

export PATH=/home/deck/.local/bin/:$PATH

python -m ensurepip
python -m pip install --upgrade pip
pip3 install ansible-core

mkdir "${rsyncdir}"
mkdir -p "${workingdir}/collections"
cd "$workingdir" || exit

ansible-galaxy install -r requirements.yml

ansible-playbook install-flatpaks.yml
ansible-playbook install-decky-loader.yml --extra-vars='ansible_become_pass=deck'
ansible-playbook install-emudeck.yml --extra-vars='ansible_become_pass=deck'
ansible-playbook ssh-authorized_keys.yml --extra-vars='ansible_become_pass=deck'

# echo "deck" | steamos-session-select gamescope
