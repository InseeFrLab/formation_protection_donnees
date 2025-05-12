#!/bin/sh

# You may use this initialization script to easily setup an Onyxia "vscode-python" service
# https://datalab.sspcloud.fr/launcher/ide/vscode-r-python-julia?name=vscode-formation-protection&version=2.3.5&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode-r-python.sh»

sudo apt update -y
sudo apt install tree -y
sudo apt install cmake -y
sudo apt install zlib1g-dev -y
sudo apt install libglpk-dev -y

#!/bin/bash

# Installation des packages R nécessaires

Rscript -e "if (!requireNamespace('haven', quietly = TRUE)) install.packages('haven', repos='https://cloud.r-project.org')"
Rscript -e "if (!requireNamespace('sdcMicro', quietly = TRUE)) install.packages('sdcMicro', dependencies=TRUE, repos='https://cloud.r-project.org')"
Rscript -e "if (!requireNamespace('GaussSuppression', quietly = TRUE)) install.packages('GaussSuppression', dependencies=TRUE, repos='https://cloud.r-project.org')"
Rscript -e "if (!requireNamespace('cellKey', quietly = TRUE)) install.packages('cellKey', dependencies=TRUE, repos='https://cloud.r-project.org')"

# Installation de la dernière version de rtauargus
Rscript -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes', repos='https://cloud.r-project.org')"
Rscript -e "if (!requireNamespace('rtauargus', quietly = TRUE)) remotes::install_github('InseeFrLab/rtauargus', dependencies = TRUE, build_vignettes = FALSE, upgrade = 'never')"
