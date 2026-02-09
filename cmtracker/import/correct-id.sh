#!/bin/bash
#!/bin/bash

# Config MySQL
DB_NAME="FIFA15"
DB_USER="root"
DB_PASS="root"
DB_HOST="127.0.0.1"
DB_PORT="5000"

# Tableau OLD→NEW
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
    [239769]=252060
    [240598]=242664
    [240336]=248243
    [240996]=252154
    [230883]=239380
    [239680]=239679
    [229698]=246172

)


# Liste des playerid à libérer (séparés par espace)
PLAYER_IDS="275372 275468 275867 271119 260570 273018 271032 278901 278455 272829 279239 278903 275507 271417 278523"

for OLD_ID in $PLAYER_IDS; do
    # Obtenir le prochain playerid libre >= 50000
    NEW_ID=$(mysql -N -u$DB_USER -p$DB_PASS -h$DB_HOST -P"$DB_PORT" $DB_NAME -e "
        SELECT t1.playerid + 1 AS next_free_playerid
        FROM players t1
        LEFT JOIN players t2 ON t2.playerid = t1.playerid + 1
        WHERE t1.playerid >= 50000 AND t2.playerid IS NULL
        ORDER BY t1.playerid
        LIMIT 1;
    ")

    echo "Remplacement de $OLD_ID par $NEW_ID"

    # Mettre à jour players
    mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P5000 $DB_NAME -e "
        UPDATE players SET playerid = $NEW_ID WHERE playerid = $OLD_ID;
    "

    # Mettre à jour teamplayerlinks
    mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P5000 $DB_NAME -e "
        UPDATE teamplayerlinks SET playerid = $NEW_ID WHERE playerid = $OLD_ID;
    "

    # Mettre à jour playerloans
    mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P5000 $DB_NAME -e "
        UPDATE playerloans SET playerid = $NEW_ID WHERE playerid = $OLD_ID;
    "
done

echo "Mise à jour terminée pour tous les joueurs."



# Liste des tables à modifier
TABLES=(
    players
    teamplayerlinks
    playerloans
)

echo "=== Mise à jour des playerid dans la base $DB_NAME ==="

for OLD_ID in "${!MAP[@]}"; do
    NEW_ID="${MAP[$OLD_ID]}"

    echo "-> $OLD_ID  devient  $NEW_ID"

    for TABLE in "${TABLES[@]}"; do
        mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" "$DB_NAME" -e "
            UPDATE $TABLE SET playerid = $NEW_ID WHERE playerid = $OLD_ID;
        "
    done
done

echo "=== Terminé ==="
