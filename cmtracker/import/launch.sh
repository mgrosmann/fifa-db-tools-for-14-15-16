#!/bin/bash
# 1 pour exist, 2 pour new

# --- Étape pré-import ---
read -p "Étape pré-import accomplie ? (1 = oui, 2 = non) : " pre

if [ "$pre" -eq 1 ]; then
    echo "OK, on passe à la suite."

elif [ "$pre" -eq 2 ]; then
    bash debug/correct-id.sh
    bash debug/fix-loan.sh
    python3 debug/new.py
    bash debug/correct-tid.sh
    python3 debug/doublon-pid.py 1
    python3 debug/doublon-pid.py 2

else
    echo "Usage: $0 [1|2]"
    exit 1
fi

# --- Import principal ---
if [ "$1" -eq 1 ]; then
    python3 import-csv.py 1
    python3 make-tpl.py
    bash make-tpl.sh
    bash dictionnaire.sh
    bash import-cmtracker.sh

elif [ "$1" -eq 2 ]; then
    python3 import-csv.py 2
    bash dictionnaire.sh
    bash import-cmtracker.sh

else
    echo "Usage: $0 [1] pour exist, [2] pour new"
    exit 1
fi
