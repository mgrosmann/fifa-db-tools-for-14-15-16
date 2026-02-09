#!/bin/bash
# 🔐 Mot de passe MySQL
DB="FIFA16"
cmd="mysql --local-infile=1 -uroot -proot -h127.0.0.1 -D $DB -P5000 -A"
TABLE1="players"
TABLE2="teamplayerlinks"
TABLE3="playernames"
TABLE4="playerloans"
OUTFILE1="p.txt"
OUTFILE2="tpl.txt"
OUTFILE3="pn.txt"
OUTFILE4="pl.txt"

drop_column_if_exists() {
    local db="$1"
    local table="$2"
    local column="$3"

    exists=$($cmd -N -s -e "
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA='${db}'
          AND TABLE_NAME='${table}'
          AND COLUMN_NAME='${column}';
    ")

    if [ -n "$exists" ]; then
        echo "→ DROP COLUMN ${column} dans ${table}"
        $cmd -e "ALTER TABLE ${db}.${table} DROP COLUMN ${column};"
    else
        echo "→ ${column} n'existe pas dans ${table}"
    fi
}
$cmd -e "delete from ${DB}.players where gender=1"
drop_column_if_exists $DB players gender
drop_column_if_exists $DB players emotion
drop_column_if_exists $DB teamplayerlinks leaguegoalsprevmatch
drop_column_if_exists $DB teamplayerlinks leaguegoalsprevthreematches
# ✅ Export des deux tables fixes
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE1\`;" > "$OUTFILE1"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE2\`;" > "$OUTFILE2"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE3\`;" > "$OUTFILE3"
$cmd --batch --column-names -e "SELECT * FROM \`$TABLE4\`;" > "$OUTFILE4"

if [ $? -eq 0 ]; then
    echo "✅ Export terminé : $OUTFILE1,$OUTFILE2 et $OUTFILE3"
else
    echo "❌ Erreur lors de l'export"
    exit 1
fi

# 📦 Conversion vers format DB Master
bash /mnt/c/github/fifa/15/ltl15.sh $DB
iconv -f UTF-8 -t UTF-16LE leagueteamlinks_fifa15_format.txt > leagueteamlinks.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE1 > players.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE2 > teamplayerlinks.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE3 > playernames.txt
iconv -f UTF-8 -t UTF-16LE $OUTFILE4 > playerloans.txt
mkdir -p /mnt/c/github/fifa/15/imported_files_16/
cp /mnt/c/github/txt/FIFA16/leagues.txt /mnt/c/github/fifa/15/imported_files_16/
cp /mnt/c/github/txt/FIFA16/teams.txt /mnt/c/github/fifa/15/imported_files_16/
mv playerloans.txt /mnt/c/github/fifa/15/imported_files_16/
mv playernames.txt /mnt/c/github/fifa/15/imported_files_16/
mv players.txt /mnt/c/github/fifa/15/imported_files_16/
mv teamplayerlinks.txt /mnt/c/github/fifa/15/imported_files_16/
mv leagueteamlinks.txt /mnt/c/github/fifa/15/imported_files_16/

