# Formation à la protection des données statistiques publiques 

<!-- badges: start -->
[![status: experimental](https://github.com/GIScience/badges/raw/master/status/experimental.svg)](https://github.com/GIScience/badges#experimental)
![R](https://img.shields.io/badge/language-R-276DC3?logo=r&logoColor=white)
![Quarto](https://img.shields.io/badge/format-quarto-blue)
![Last commit](https://img.shields.io/github/last-commit/InseeFrLab/formation_protection_donnees)
[![SSPcloud](https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational?logo=R)](https://datalab.sspcloud.fr/launcher/ide/rstudio?name=rstudio-formation-protection&version=2.3.1&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Frstudio.sh»)
<!-- badges: end -->



## :one: Objectifs

Le site a vocation à contenir un ensemble de supports et de matériels de formation et d'auto-formation à la protection des données statistiques publiques. 
Il est réalisé par des statisticiens de l'Insee et il est destiné principalement aux statisticiens du service statistique public en charge de la diffusion, auprès du public, de données respectueuses de la vie privée.
Les statisticiens intéressés y trouveront des présentations sur les principaux concepts, enjeux et problèmes liés à la gestion de la confidentialité. 
Les méthodes les plus courantes seront détaillées et des fiches pratiques auront vocation à faciliter la prise en main de ces méthodes. 

## :two: Contribuer au projet depuis le SSP Cloud

### Un service RStudio avec installation automatique des packages R

Cette option installe préalablement les principaux packages R relatifs à la protection des données statistiques.

- [Ouvrir un service RStudio](https://datalab.sspcloud.fr/launcher/ide/rstudio?name=rstudio-formation-protection&version=2.3.1&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Frstudio.sh»)

### Un service vscode avec installation automatique des packages R

Cette option installe préalablement les principaux packages R relatifs à la protection des données statistiques. Cela prend entre 3 et 4 minutes.

- [Ouvrir un service vscode R-Python](https://datalab.sspcloud.fr/launcher/ide/vscode-r-python-julia?name=vscode-formation-protection&version=2.3.5&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode-r-python.sh»)

### Un service vscode sans installation des packages 

Avec cette option, le service est plus rapidement disponible mais les packages R relatifs à la protection des données statistiques devront être installés au cas par cas ensuite.

- [Ouvrir un service vscode R-Python dans une version allégée](https://datalab.sspcloud.fr/launcher/ide/vscode-r-python-julia?name=vscode-formation-protection-light&version=2.3.5&s3=region-ec97c721&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2FInseeFrLab%2Fformation_protection_donnees%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode-r-python-light.sh»)


## :three: Pour contribuer

- `quarto render`
- `quarto preview`
- `git add, commit, push`: fichiers qmd et le dossier `_freeze` (pour récupérer les résultats des chunks `R` ou `python`) mais pas le dossier `_site`
