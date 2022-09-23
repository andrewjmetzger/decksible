#!/bin/bash

## SETUP ######################################################################
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
repo="https://gist.github.com/4360acfdae7fb8c189e365efac96f944.git" 
repodest="${sdcard}/decksible"
################################################################################



if ! git clone "${repo}" "${repodest}" 2>/dev/null && [ -d "${repodest}" ] ; then
    echo "Clone failed because the folder ${repodest} exists"
    echo "Pulling changes, please wait ..."
    cd "${repodest}" && git pull --force
fi

sleep 3

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
ansible-playbook install-deckbrew.yml --extra-vars='ansible_become_pass=deck'
ansible-playbook install-emudeck.yml --extra-vars='ansible_become_pass=deck'

# echo "deck" | steamos-session-select gamescope
