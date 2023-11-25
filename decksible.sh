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

export PATH=/home/deck/.local/bin/:$PATH

git clone "${repo}" "${decksible_path}"
cd "${decksible_path}" && git pull --force

echo -e "deck\ndeck" | passwd deck
echo "deck" | sudo -S systemctl enable sshd.service --now

clear

if ! [ -d ${decksible_path}/.venv ]; then
    python3 -m venv ${decksible_path}/.venv
fi

source ${decksible_path}/.venv/bin/activate

echo -e "Installing Ansible"
${decksible_path}/.venv/bin/pip3 install ansible-core 

mkdir -p "${decksible_path}/collections"
cd "${decksible_path}" || exit

ansible-galaxy install -r ${decksible_path}/requirements.yml
ansible-playbook ${decksible_path}/playbooks/main.yml --extra-vars='ansible_become_pass=deck'

deactivate

kwriteconfig5 --file "/home/deck/.config/plasma-org.kde.plasma.desktop-appletsrc" \
--group 'Containments' --group '1' --group 'Wallpaper' \
--group 'org.kde.image' --group 'General' --key 'Image' \
"/usr/share/wallpapers/Steam Deck Logo 5.jpg" \
&& echo "deck" | steamos-session-select plasma

echo -e "DONE: Steam Deck is configured!"
echo -e "You may now run EmuDeck setup, or return to Gamesope mode."

# Session switch commands
# echo "deck" | steamos-session-select gamescope
# echo "deck" | steamos-session-select plasma
