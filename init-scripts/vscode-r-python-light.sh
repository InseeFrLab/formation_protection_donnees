#!/bin/sh

# You may use this initialization script to easily setup an Onyxia "vscode-python" service
# https://datalab.sspcloud.fr/launcher/ide/vscode-r-python-julia?name=vscode-formation-protection&version=2.3.5&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode-r-python-light.sh»

sudo apt update -y
sudo apt install tree -y
# sudo apt install cmake -y
# sudo apt install zlib1g-dev -y
# sudo apt install libglpk-dev -y

# Clônage du projet
cd ~/work/
git clone https://github.com/InseeFrLab/formation_protection_donnees.git
cd ~/work/formation_protection_donnees/
