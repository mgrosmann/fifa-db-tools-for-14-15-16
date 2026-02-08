#!/bin/bash

DB="FIFA15"
USER="root"
PASS="root"
cmd="mysql -u $USER -p$PASS -h127.0.0.1 -P5000 $DB"
$cmd -e "
    DELETE tpl FROM teamplayerlinks tpl
    JOIN playerloans pl
        ON tpl.playerid = pl.playerid
    WHERE tpl.teamid = pl.teamidloanedfrom;
"

echo "✔ Correction terminée : les clubs d'origine des joueurs prêtés ont été supprimés de teamplayerlinks."

$cmd -e "UPDATE FIFA15.playerloans
SET loandateend = 162062
WHERE loandateend < 161728;"
echo "reglage date pret"

$cmd -e "DELETE pl
FROM playerloans pl
JOIN teamplayerlinks tpl ON pl.playerid = tpl.playerid
WHERE pl.teamidloanedfrom = tpl.teamid;"
echo "supprimer pret a soi meme"