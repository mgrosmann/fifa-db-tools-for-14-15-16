#!/bin/bash
# 🔐 Mot de passe MySQL
DB="FIFA14"
cmd="mysql --local-infile=1 -uroot -proot -h127.0.0.1 -D $DB -P5000 -A"
TABLE2="teamplayerlinks"
TABLE3="playernames"
TABLE4="playerloans"
OUTFILE2="tpl.txt"
OUTFILE3="pn.txt"
OUTFILE4="pl.txt"
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

add_column_if_missing $DB teams leftfreekicktakerid "INT DEFAULT 0"
add_column_if_missing $DB teams rightfreekicktakerid "INT DEFAULT 0"

# ✅ Export des deux tables fixes
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE2\`;" > "$OUTFILE2"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE3\`;" > "$OUTFILE3"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE4\`;" > "$OUTFILE4"
if [ $? -eq 0 ]; then
    echo "✅ Export terminé : $OUTFILE2"
else
    echo "❌ Erreur lors de l'export"!
    exit 1
fi

# 📦 Conversion vers format DB Master
bash /mnt/c/github/fifa/15/player15.sh $DB
iconv -f UTF-8 -t UTF-16LE players_fifa15_format.txt > players.txt
bash /mnt/c/github/fifa/15/team15.sh $DB
iconv -f UTF-8 -t UTF-16LE teams_fifa15_format.txt > teams.txt
iconv -f UTF-8 -t UTF-16LE "$OUTFILE2" > teamplayerlinks.txt
iconv -f UTF-8 -t UTF-16LE "$OUTFILE3" > playernames.txt
iconv -f UTF-8 -t UTF-16LE "$OUTFILE4" > playerloans.txt
mkdir -p /mnt/c/github/fifa/15/imported_files_14/
cp /mnt/c/github/txt/FIFA14/leagueteamlinks.txt /mnt/c/github/fifa/15/imported_files_14/
cp /mnt/c/github/txt/FIFA14/leagues.txt /mnt/c/github/fifa/15/imported_files_14/
mv playerloans.txt /mnt/c/github/fifa/15/imported_files_14/
mv playernames.txt /mnt/c/github/fifa/15/imported_files_14/
mv teamplayerlinks.txt /mnt/c/github/fifa/15/imported_files_14/
mv players.txt /mnt/c/github/fifa/15/imported_files_14/players.txt
mv teams.txt /mnt/c/github/fifa/15/imported_files_14/teams.txt

