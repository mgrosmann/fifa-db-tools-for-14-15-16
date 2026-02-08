#!/bin/bash

DB_USER="root"
DB_PASS="root"
DB_HOST="127.0.0.1"
DB_PORT="5000"
DB_NAME="FIFA15"

declare -A MAP=(
    [241468]=258966
    [241505]=243627
    [241859]=242816
    [239889]=239892
    [212406]=73562
    [220168]=255654
    [237957]=242434
    [207967]=238216
    [225679]=253004
    [240235]=246174
    [266578]=265578
    [242148]=256261
    [273025]=273018
    [234233]=271032
    [241268]=272505
    [241358]=243014
    [240336]=248243
)

TABLES=(players teamplayerlinks playerloans)

echo "=== Mise à jour des playerid dans la base $DB_NAME ==="

for OLD_ID in "${!MAP[@]}"; do
    NEW_ID="${MAP[$OLD_ID]}"

    echo ""
    echo "----------------------------------------"
    echo "Ancien ID : $OLD_ID"
    echo "Nouveau ID : $NEW_ID"

    # Vérifier si NEW_ID existe déjà
    EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" --skip-column-names -e "
        SELECT COUNT(*) FROM players WHERE playerid = $NEW_ID;
    ")

    if [ "$EXISTS" -eq 1 ]; then
        echo "⚠️  Le NEW_ID existe déjà dans players !"

        # Récupérer noms
        OLD_NAME=$(mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" --skip-column-names -e "
            SELECT CONCAT(fn.name,' ',ln.name)
            FROM players p
            LEFT JOIN playernames fn ON p.firstnameid = fn.nameid
            LEFT JOIN playernames ln ON p.lastnameid = ln.nameid
            WHERE p.playerid = $OLD_ID;
        ")

        NEW_NAME=$(mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" --skip-column-names -e "
            SELECT CONCAT(fn.name,' ',ln.name)
            FROM players p
            LEFT JOIN playernames fn ON p.firstnameid = fn.nameid
            LEFT JOIN playernames ln ON p.lastnameid = ln.nameid
            WHERE p.playerid = $NEW_ID;
        ")

        echo "OLD_ID ($OLD_ID) = $OLD_NAME"
        echo "NEW_ID ($NEW_ID) = $NEW_NAME"
        echo ""
        echo "Que veux‑tu faire ?"
        echo "1 = garder OLD_ID"
        echo "2 = garder NEW_ID"
        echo "s = skip"
        read -p "> " CHOICE

        case "$CHOICE" in
            1)
                echo "➡️ Remplacement : NEW_ID → OLD_ID"
                TARGET=$OLD_ID
                SOURCE=$NEW_ID
                ;;
            2)
                echo "➡️ Remplacement : OLD_ID → NEW_ID"
                TARGET=$NEW_ID
                SOURCE=$OLD_ID
                ;;
            s|S)
                echo "⏭️  Skip"
                continue
                ;;
            *)
                echo "❌ Choix invalide, skip"
                continue
                ;;
        esac

        # Appliquer le remplacement
        for TABLE in "${TABLES[@]}"; do
            mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" -e "
                UPDATE $TABLE SET playerid = $TARGET WHERE playerid = $SOURCE;
            "
        done

    else
        echo "✔️ NEW_ID n'existe pas, remplacement direct OLD → NEW"
        for TABLE in "${TABLES[@]}"; do
            mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" -e "
                UPDATE $TABLE SET playerid = $NEW_ID WHERE playerid = $OLD_ID;
            "
        done
    fi
done

echo "=== Terminé ==="
