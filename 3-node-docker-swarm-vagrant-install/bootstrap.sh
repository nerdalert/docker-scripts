#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y linux-generic-lts-wily netcat iproute2 apt-transport-https ca-certificates curl software-properties-common python-software-properties
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download-stage.docker.com/linux/ubuntu $(lsb_release -cs) test"
sudo apt-get update
sudo apt-get -y install docker-ce
sudo usermod -aG docker vagrant
sudo reboot
