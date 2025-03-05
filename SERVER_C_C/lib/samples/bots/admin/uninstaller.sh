#!/bin/bash

USER="admin_bot"
APP_DIR="/home/$USER/pet_app"
SERVICE_NAME="pet_app"

echo 'Stopping and disabling service...'
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload

echo 'Waiting for 10 seconds before removing the user...'
sleep 10

echo 'Removing Rails application...'
sudo rm -Rf $APP_DIR

echo 'Uninstalling rbenv and Ruby versions...'
sudo rm -rf /home/$USER/.rbenv
sudo sed -i '/rbenv/d' /home/$USER/.bashrc

echo 'Removing user $USER...'
sudo userdel -r $USER
sudo rm -f /etc/sudoers.d/$USER

echo 'Cleaning up dependencies...'
sudo apt autoremove -y

(sleep 3; rm -- "$0") &
