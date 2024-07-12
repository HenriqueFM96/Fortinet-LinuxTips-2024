#!/bin/bash

sudo apt-get install net-tools -y
sudo apt-get install docker, python, pip -y
mkdir ./log4shell-PoC
cd ./log4shell-PoC
sudo git clone https://github.com/kozmer/log4j-shell-poc