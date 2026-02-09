#!/bin/bash

CSV="export.csv"
OUT="delete.sql"

# On vide le fichier au début
echo "-- Suppressions générées automatiquement" > "$OUT"

clean() {
    local v="$1"
    v="${v#\"}"
    v="${v%\"}"
    echo "$v"
}

echo "=== LECTURE CSV ==="

while IFS=';' read -r playerid fullname club1 club2 teamid1 teamid2; do

    fullname=$(clean "$fullname")
    club1=$(clean "$club1")
    club2=$(clean "$club2")

    echo "---------------------------------------------"
    echo "Joueur : $fullname"
    echo "PlayerID : $playerid"
    echo "Clubs : $club1 / $club2"
    echo "TeamIDs : $teamid1 / $teamid2"
    echo

    # IMPORTANT : lire depuis le clavier
    read -p "TeamID à supprimer pour ce joueur : " REMOVE_ID < /dev/tty

    if [[ "$REMOVE_ID" == "$teamid1" || "$REMOVE_ID" == "$teamid2" ]]; then
        SQL="DELETE FROM teamplayerlinks WHERE playerid=$playerid AND teamid=$REMOVE_ID;"
        echo "$SQL" >> "$OUT"
        echo "➡️  Ajouté dans $OUT"
    else
        echo "TeamID invalide, aucune requête générée."
    fi

    echo
done < "$CSV"

echo "=== FIN ==="
echo "Les requêtes SQL sont dans : $OUT"

