#!/bin/sh

# You may use this initialization script to easily setup an Onyxia "vscode-python" service
# https://datalab.sspcloud.fr/launcher/ide/vscode-r-python-julia?name=vscode-formation-protection&version=2.3.5&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode-r-python.sh»

sudo apt update -y
sudo apt install tree -y
# sudo apt install cmake -y
# sudo apt install zlib1g-dev -y
# sudo apt install libglpk-dev -y

# Clônage du projet
cd ~/work/
git clone https://github.com/InseeFrLab/formation_protection_donnees.git
cd ~/work/formation_protection_donnees/

# Récupération du nom de code Ubuntu (ex: focal, jammy)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    UBUNTUNAME="$VERSION_CODENAME"
else
    UBUNTUNAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
fi

# Construction de l'URL du dépôt
REPOSITR="https://packagemanager.posit.co/cran/__linux__/${UBUNTUNAME}/latest/"

# Installation des packages R nécessaires
Rscript -e "install.packages('tidyverse', repos='${REPOSITR}', dependencies=TRUE)"
Rscript -e "install.packages('sdcMicro', repos='${REPOSITR}', dependencies=TRUE)"
Rscript -e "install.packages('GaussSuppression', repos='${REPOSITR}', dependencies=TRUE)"
Rscript -e "install.packages('cellKey', repos='${REPOSITR}', dependencies=TRUE)"

# Installation de la dernière version de rtauargus
Rscript -e "install.packages('remotes', repos='${REPOSITR}')"
Rscript -e "remotes::install_github('InseeFrLab/rtauargus', dependencies = TRUE, build_vignettes = FALSE, upgrade = 'never')"
