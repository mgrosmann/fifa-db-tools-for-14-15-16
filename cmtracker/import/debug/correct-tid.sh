#!/bin/bash

# Fichiers d'entrée
EXISTANTS="/mnt/c/github/fifa/cmtracker/import/joueurs_existants.csv"
NOUVEAUX="/mnt/c/github/fifa/cmtracker/import/nouveaux_joueurs.csv"

# Fichiers de sortie
EXISTANTS_OUT="/mnt/c/github/fifa/cmtracker/import/joueurs_existants_fixed.csv"
NOUVEAUX_OUT="/mnt/c/github/fifa/cmtracker/import/nouveaux_joueurs_fixed.csv"

# Copier les fichiers avant modification
cp "$EXISTANTS" "$EXISTANTS_OUT"
cp "$NOUVEAUX" "$NOUVEAUX_OUT"

# Remplacements teamid
sed -i \
    -e "s/,101047,/,130015,/g" \
    -e "s/,110711,/,111592,/g" \
    -e "s/,110908,/,111592,/g" \
    -e "s/,112908,/,111592,/g" \
    -e "s/,115841,/,46,/g" \
    -e "s/,115845,/,39,/g" \
    -e "s/,131681,/,47,/g" \
    -e "s/,131682,/,44,/g" \
    -e "s/,131798,/,111592,/g" \
    -e "s/,211,/,130017,/g" \
    "$EXISTANTS_OUT" "$NOUVEAUX_OUT"

echo "TeamID corrigés dans :"
echo " → $EXISTANTS_OUT"
echo " → $NOUVEAUX_OUT"
