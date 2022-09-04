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

# First, set the password for the desktop user (username 'deck')
# 1. Open Konsole, type 'passwd deck', press enter
# 2. Type the password 'deck', press enter,
# 3. Type the same password 'deck' again, press enter
################################################################################

## VARIABLES ###################################################################
# SD Card Path under /run/media (usually mmcblk0p1)
sdcard="/run/media/mmcblk0p1"
rsyncdir="${sdcard}/rsync-backups"
workingdir="${sdcard}/playbooks/software-installs"
################################################################################

# Ansible
echo -e "Installing Ansible"

python -m ensurepip --update
~/.local/bin/pip3 install ansible-core

mkdir "${rsyncdir}"
mkdir -p "${workingdir}/collections"
cd "$workingdir" || exit

export PATH=/home/deck/.local/bin/:$PATH

echo "[defaults]
collections_paths = ./collections/
" >ansible.cfg

echo "---
collections:
  - name: community.general
    version: 4.8.1
" >requirements.yml

echo "
---
- name: Install flatpaks from flathub
  hosts: localhost
  gather_facts: no

  tasks:
  - name: Add the flathub flatpak repository remote to the user installation
    community.general.flatpak_remote:
      name: flathub
      flatpakrepo_url: https://dl.flathub.org/repo/flathub.flatpakrepo
      state: present
      method: user

  - name: Installing Flatseal
    community.general.flatpak:
      name: com.github.tchx84.Flatseal
      state: present
      method: user
      remote: flathub
  " > install-flatpaks.yml

  echo "---
  - name: Install Deckbrew Beta
  hosts: localhost
  gather_facts: no

  tasks:
  - name: Run command to install Deckbrew
    shell: curl -L 'https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_prerelease.sh' | sudo sh
" > install-deckbrew.yml

ansible-galaxy install -r requirements.yml
ansible-playbook install-flatpaks.yml --ask-become-pass
# ansible-playbook install-deckbrew.yml --ask-become-pass

