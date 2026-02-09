#!/bin/bash
# 🔐 Mot de passe MySQL
DB="FIFA15"
cmd="mysql --local-infile=1 -uroot -proot -h127.0.0.1 -D $DB -P5000 -A"
TABLE3="playerloans"
OUTFILE3="pl.txt"
TABLE4="playernames"
OUTFILE4="pn.txt"

add_column_if_missing() {
    local db="$1"
    local table="$2"
    local column="$3"
    local definition="$4"

    exists=$($cmd -N -e "
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA='${db}'
          AND TABLE_NAME='${table}'
          AND COLUMN_NAME='${column}';
    ")

    if [ -z "$exists" ]; then
        echo "→ Ajout de ${column} dans ${table}"
        $cmd -e "ALTER TABLE ${db}.${table} ADD COLUMN ${column} ${definition};"
    else
        echo "→ ${column} existe déjà"
    fi
}
add_column_if_missing $DB players gender "INT DEFAULT 0"
add_column_if_missing $DB players emotion "INT DEFAULT 1"
add_column_if_missing $DB teamplayerlinks leaguegoalsprevmatch "INT DEFAULT 0"
add_column_if_missing $DB teamplayerlinks leaguegoalsprevthreematches "INT DEFAULT 0"

# ✅ Export des deux tables fixes
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE3\`;" > "$OUTFILE3"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE4\`;" > "$OUTFILE4"


if [ $? -eq 0 ]; then
    echo "✅ Export terminé : $OUTFILE3 ainsi que $OUTFILE4"
else
    echo "❌ Erreur lors de l'export"
    exit 1
fi

# 📦 Conversion vers format DB Master
bash /mnt/c/github/fifa/16/tpl16.sh $DB
iconv -f UTF-8 -t UTF-16LE teamplayerlinks_fifa16_format.txt > teamplayerlinks.txt
bash /mnt/c/github/fifa/16/ltl16.sh $DB
iconv -f UTF-8 -t UTF-16LE leagueteamlinks_fifa16_format.txt > leagueteamlinks.txt
bash /mnt/c/github/fifa/16/player16.sh $DB
iconv -f UTF-8 -t UTF-16LE players_fifa16_format.txt > players.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE3 > playerloans.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE4 > playernames.txt
mkdir -p /mnt/c/github/fifa/16/imported_files_15/
cp /mnt/c/github/txt/FIFA15/leagues.txt /mnt/c/github/fifa/16/imported_files_15/
cp /mnt/c/github/txt/FIFA15/teams.txt /mnt/c/github/fifa/16/imported_files_15/
mv playerloans.txt /mnt/c/github/fifa/16/imported_files_15/
mv playernames.txt /mnt/c/github/fifa/16/imported_files_15/
mv players.txt /mnt/c/github/fifa/16/imported_files_15/
mv teamplayerlinks.txt /mnt/c/github/fifa/16/imported_files_15/
mv leagueteamlinks.txt /mnt/c/github/fifa/16/imported_files_15/