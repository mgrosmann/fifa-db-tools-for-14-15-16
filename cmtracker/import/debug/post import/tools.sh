#!/bin/bash

# =========================================================
#  FIFA TOOLS — MENU INTERACTIF
# =========================================================

DB="FIFA15"
MYSQL="mysql -u root -proot $DB -h127.0.0.1 -P5000 -N -s -A"

clear

while true; do
    echo "==============================================="
    echo "              FIFA TOOLS — MENU"
    echo "==============================================="
    echo "1) Joueurs dupliqués (doublon-player)"
    echo "2) Noms inutilisés (unused-name)"
    echo "3) Joueurs avec 2 clubs (doublon-club)"
    echo "4) Export CSV des doublons (export-doublon)"
    echo "5) Info complète d’un playerid"
    echo "6) Recherche par nom"
    echo "7) Effectif d’une équipe (par nom)"
    echo "8) Effectif d’une équipe (par teamid)"
    echo "9) Quitter"
    echo "-----------------------------------------------"
    read -p "Choix : " CHOICE
    echo

    case "$CHOICE" in

# ---------------------------------------------------------
# 1) DOUBLON PLAYER
# ---------------------------------------------------------
    1)
        $MYSQL -e "
        SELECT CONCAT(fn.name, ' ', ln.name) AS fullname,
               p.birthdate,
               p.nationality,
               GROUP_CONCAT(p.playerid ORDER BY p.playerid) AS ids,
               COUNT(*) AS count_ids
        FROM players p
        LEFT JOIN playernames fn ON p.firstnameid = fn.nameid
        LEFT JOIN playernames ln ON p.lastnameid = ln.nameid
        WHERE ln.name NOT LIKE '%new player%'
        GROUP BY fn.name, ln.name, p.birthdate, p.nationality
        HAVING COUNT(*) > 1
        ORDER BY fullname;
        "
        ;;

# ---------------------------------------------------------
# 2) UNUSED NAME
# ---------------------------------------------------------
    2)
        $MYSQL -e "
        SELECT pn.nameid, pn.name
        FROM playernames pn
        LEFT JOIN players p1 ON p1.firstnameid = pn.nameid
        LEFT JOIN players p2 ON p2.lastnameid = pn.nameid
        LEFT JOIN players p3 ON p3.commonnameid = pn.nameid
        WHERE p1.firstnameid IS NULL
          AND p2.lastnameid IS NULL
          AND p3.commonnameid IS NULL;
        "
        ;;

# ---------------------------------------------------------
# 3) DOUBLON CLUB
# ---------------------------------------------------------
    3)
        $MYSQL -e "
        SELECT p.playerid,
               CONCAT(fn.name, ' ', ln.name) AS fullname,
               GROUP_CONCAT(DISTINCT t.teamname ORDER BY t.teamname) AS clubs,
               COUNT(DISTINCT t.teamid) AS club_count
        FROM teamplayerlinks tpl
        JOIN players p ON tpl.playerid = p.playerid
        LEFT JOIN playernames fn ON p.firstnameid = fn.nameid
        LEFT JOIN playernames ln ON p.lastnameid = ln.nameid
        JOIN teams t ON tpl.teamid = t.teamid
        JOIN leagueteamlinks ltl ON tpl.teamid = ltl.teamid
        WHERE ltl.leagueid NOT IN (78)
          AND t.teamname NOT LIKE '%adidas%'
          AND t.teamname NOT LIKE '%world%'
          AND t.teamname NOT LIKE '%All stars%'
        GROUP BY p.playerid, fullname
        HAVING COUNT(DISTINCT t.teamid) > 1
        ORDER BY fullname;
        "
        ;;

# ---------------------------------------------------------
# 4) EXPORT CSV DOUBLON
# ---------------------------------------------------------
    4)
        $MYSQL -e "
        SELECT x.playerid,
               CONCAT(fn.name, ' ', ln.name) AS fullname,
               t1.teamname AS club1,
               t2.teamname AS club2,
               x.teamid1,
               x.teamid2
        FROM (
            SELECT tpl.playerid,
                   MIN(t.teamid) AS teamid1,
                   MAX(t.teamid) AS teamid2
            FROM teamplayerlinks tpl
            JOIN teams t ON tpl.teamid = t.teamid
            JOIN leagueteamlinks ltl ON tpl.teamid = ltl.teamid
            WHERE ltl.leagueid <> 78
              AND t.teamname NOT LIKE '%adidas%'
              AND t.teamname NOT LIKE '%world%'
              AND t.teamname NOT LIKE '%All stars%'
            GROUP BY tpl.playerid
            HAVING COUNT(DISTINCT t.teamid) = 2
        ) AS x
        JOIN players p ON x.playerid = p.playerid
        LEFT JOIN playernames fn ON p.firstnameid = fn.nameid
        LEFT JOIN playernames ln ON p.lastnameid = ln.nameid
        JOIN teams t1 ON t1.teamid = x.teamid1
        JOIN teams t2 ON t2.teamid = x.teamid2
        ORDER BY fullname
        INTO OUTFILE '/tmp/export.csv'
        FIELDS TERMINATED BY ';'
        OPTIONALLY ENCLOSED BY '\"'
        LINES TERMINATED BY '\n';
        "
        echo "Export créé : /tmp/export.csv"
        ;;

# ---------------------------------------------------------
# 5) INFO PLAYERID
# ---------------------------------------------------------
    5)
        read -p "PlayerID : " PID
        $MYSQL -e "
        SELECT p.commonnameid, p.playerid, p.overallrating,
               tpl.teamid, t.teamname,
               CONCAT(pn_first.name, ' ', pn_last.name) AS fullname,
               pn_first.nameid, pn_last.nameid
        FROM players p
        JOIN playernames pn_first ON p.firstnameid = pn_first.nameid
        JOIN playernames pn_last  ON p.lastnameid  = pn_last.nameid
        JOIN teamplayerlinks tpl ON p.playerid = tpl.playerid
        JOIN teams t ON tpl.teamid = t.teamid
        WHERE p.playerid = $PID;
        "
        ;;

# ---------------------------------------------------------
# 6) RECHERCHE PAR NOM
# ---------------------------------------------------------
    6)
        read -p "Nom (partiel) : " NAME
        $MYSQL -e "
        SELECT p.playerid,
               CONCAT(pn_first.name, ' ', pn_last.name) AS fullname
        FROM players p
        JOIN playernames pn_first ON p.firstnameid = pn_first.nameid
        JOIN playernames pn_last  ON p.lastnameid  = pn_last.nameid
        WHERE CONCAT(pn_first.name, ' ', pn_last.name) LIKE '%$NAME%';
        "
        ;;

# ---------------------------------------------------------
# 7) EFFECTIF PAR NOM D'ÉQUIPE
# ---------------------------------------------------------
    7)
        read -p "Nom équipe : " TEAM
        $MYSQL -e "
        SELECT p.playerid, tpl.position, p.overallrating AS gen, p.potential AS pot,
               t.teamname, pn_first.name AS fn, pn_last.name AS ln, pn_common.name AS cn
        FROM teamplayerlinks tpl
        JOIN teams t ON tpl.teamid = t.teamid
        JOIN players p ON tpl.playerid = p.playerid
        JOIN playernames pn_common ON p.commonnameid = pn_common.nameid
        JOIN playernames pn_first ON p.firstnameid = pn_first.nameid
        JOIN playernames pn_last  ON p.lastnameid  = pn_last.nameid
        WHERE t.teamname LIKE '%$TEAM%'
        ORDER BY tpl.position;
        "
        ;;

# ---------------------------------------------------------
# 8) EFFECTIF PAR TEAMID
# ---------------------------------------------------------
    8)
        read -p "TeamID : " TID
        $MYSQL -e "
        SELECT p.playerid, tpl.position, p.overallrating AS gen, p.potential AS pot,
               t.teamname, pn_first.name AS fn, pn_last.name AS ln, pn_common.name AS cn
        FROM teamplayerlinks tpl
        JOIN teams t ON tpl.teamid = t.teamid
        JOIN players p ON tpl.playerid = p.playerid
        JOIN playernames pn_common ON p.commonnameid = pn_common.nameid
        JOIN playernames pn_first ON p.firstnameid = pn_first.nameid
        JOIN playernames pn_last  ON p.lastnameid  = pn_last.nameid
        WHERE t.teamid = $TID
        ORDER BY tpl.position;
        "
        ;;

# ---------------------------------------------------------
# 9) QUITTER
# ---------------------------------------------------------
    9)
        exit 0
        ;;

    *)
        echo "Choix invalide."
        ;;
    esac

    echo
    read -p "Appuie sur Entrée pour continuer..."
    clear
done
