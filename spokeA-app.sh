#! /bin/bash
sudo apt-get install net-tools -y
sudo snap install docker
sudo apt-get install python3 -y
sudo wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo mkdir ./log4shell-PoC
cd ./log4shell-PoC
sudo git clone https://github.com/kozmer/log4j-shell-poc
cd ./log4j-shell-poc
pip install -r requirements.txt
#lacking the Java file
echo "installation finished. VM ready to run!"