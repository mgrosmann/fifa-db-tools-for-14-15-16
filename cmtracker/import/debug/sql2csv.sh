#!/bin/bash
sql15="mysql -uroot -proot -h127.0.0.1 -P5000 -DFIFA15"
read -p "entrer le nom de la table a exporter: " table
$sql15 -e "SELECT * FROM $table;" > $table.txt
tr '\t' ';' < $table.txt > $table.csv
rm $table.txt
