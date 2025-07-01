#!/bin/sh

# You may use this initialization script to easily setup an Onyxia "vscode-python" service
# https://datalab.sspcloud.fr/launcher/ide/rstudio?name=rstudio-formation-protection&version=2.3.1&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Frstudio.sh»

sudo apt update -y
# sudo apt install tree -y
# sudo apt install cmake -y
# sudo apt install zlib1g-dev -y
# sudo apt install libglpk-dev -y

# Téléchargement de toutes les fiches de la formation
mkdir -p ~/work/formation_protection_donnees/pratique/fiches
mkdir -p ~/work/formation_protection_donnees/pratique/R

# Téléchargement du fichier DESCRIPTION.md du dépôt GitHub
cd ~/work/formation_protection_donnees/
curl -O https://raw.githubusercontent.com/InseeFrLab/formation_protection_donnees/main/DESCRIPTION

# Téléchargement de tous les fichiers .qmd depuis le dossier fiches du dépôt GitHub
cd ~/work/formation_protection_donnees/pratique/fiches/
gh_api_url="https://api.github.com/repos/InseeFrLab/formation_protection_donnees/contents/pratique/fiches"
for file_url in $(curl -s "$gh_api_url" | grep '"download_url":' | grep '.qmd"' | cut -d '"' -f 4); do
    curl -O "$file_url"
done

# Téléchargement de tous les fichiers .qmd depuis le dossier R du dépôt GitHub
cd ~/work/formation_protection_donnees/pratique/R/
gh_api_url="https://api.github.com/repos/InseeFrLab/formation_protection_donnees/contents/pratique/R"
for file_url in $(curl -s "$gh_api_url" | grep '"download_url":' | grep '.R"' | cut -d '"' -f 4); do
    curl -O "$file_url"
done

# Installation des packages R nécessaires
cd ~/work/formation_protection_donnees/

# Récupération du nom de code Ubuntu (ex: focal, jammy)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    UBUNTUNAME="$VERSION_CODENAME"
else
    UBUNTUNAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
fi

REPOSITR="https://packagemanager.posit.co/cran/__linux__/${UBUNTUNAME}/latest/"

Rscript -e "install.packages('remotes', repos='${REPOSITR}')"
Rscript -e "remotes::install_deps(upgrade = 'always', repos='${REPOSITR}')"
