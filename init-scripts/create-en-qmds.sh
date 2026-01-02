#!/usr/bin/env bash
# Dupliquer tous les .qmd en .en.qmd, récursivement

# Se placer à la racine du projet Quarto (optionnel mais recommandé)
# cd /chemin/vers/mon/projet

# Parcours récursif de tous les fichiers *.qmd
find . -type f -name "*.qmd" ! -name "*.en.qmd" -print0 |
while IFS= read -r -d '' file; do
  # Construit le nouveau nom : remplacer l'extension .qmd par .en.qmd
  new_file="${file%.qmd}.en.qmd"

  # Si le fichier cible existe déjà, on peut soit passer, soit écraser
  # Ici : ne pas écraser (on saute)
  if [[ -e "$new_file" ]]; then
    echo "Déjà présent, ignoré : $new_file"
    continue
  fi

  # Copie du fichier source vers le nouveau fichier
  cp -- "$file" "$new_file"
  echo "Créé : $new_file"
done
