#!/bin/bash
sql15="mysql -uroot -proot -h127.0.0.1 -P5000 -DFIFA15"
read -p "entrer le nom de la table a exporter: " table
#$sql15 -e "select playerid, first.name as prenom, last.name as nom_de_famille, p.nationality as nationid, p.birthdate from players p join playernames first on p.firstnameid = first.nameid join playernames last on p.lastnameid = last.nameid;" > $table.txt
$sql15 -e "SELECT * FROM $table;" > $table.txt
tr '\t' ';' < $table.txt > $table.csv
rm $table.txt
