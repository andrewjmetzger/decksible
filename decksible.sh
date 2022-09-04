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

echo "requesting sudo credentials for cache"
sudo echo "" > /dev/null

# Ansible
echo -e "Installing Ansible"

export PATH=/home/deck/.local/bin/:$PATH
# echo "export PATH=/home/deck/.local/bin/:$PATH" >> ~/.bash_profile
# source ~/.bash_profile

python -m ensurepip --update
python -m pip install --upgrade pip
pip3 install ansible-core

mkdir "${rsyncdir}"
mkdir -p "${workingdir}/collections"
cd "$workingdir" || exit



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
  
  - name: Installing Flatpaks
    community.general.flatpak:
      name:
        - com.github.tchx84.Flatseal
        - net.davidotek.pupgui2
        - net.lutris.lutris
        - io.github.phillipk.boilr
      state: present
      method: user
      remote: flathub
  " > install-flatpaks.yml

echo "
---
- name: Install Deckbrew
  hosts: localhost
  gather_facts: no

  tasks:
  - name: Download Beta Installer
    get_url:
      url: \"https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_prerelease.sh\"
      dest: ./install_prerelease.sh
      mode: u+rwx
  
  - name: Run Beta Installer
    shell: ./install_prerelease.sh
    become: yes

" > install-deckbrew.yml

ansible-galaxy install -r requirements.yml
ansible-playbook install-flatpaks.yml
ansible-playbook install-deckbrew.yml --ask-become-pass
sudo steamos-reboot
