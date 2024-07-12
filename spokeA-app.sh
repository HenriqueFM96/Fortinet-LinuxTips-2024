#! /bin/bash
sudo apt-get install net-tools -y
sudo snap install docker
sudo apt-get install python3 -y
mkdir ./log4shell-PoC
cd ./log4shell-PoC
sudo python3 -m pip install --upgrade pip setuptools wheel
sudo git clone https://github.com/kozmer/log4j-shell-poc