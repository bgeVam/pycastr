#!/bin/sh
# Move sources
sudo mkdir /opt/pycastr/
sudo cp -r src/ /opt/pycastr/
sudo cp data/icons/pycastr_* /usr/share/icons/hicolor/256x256/apps/
sudo cp data/icons/pycastr* /usr/share/icons/hicolor/256x256/apps/
sudo cp data/icons/pycastr-* /usr/share/icons/hicolor/scalable/apps/

gtk-update-icon-cache

# Install dependencies
#sudo apt-get update
sudo apt-get -y install vlc
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
pip3 install netdisco
pip3 install kodi-json

# Prepare autostart
cp pycastr.desktop ~/.config/autostart
sudo update-desktop-database