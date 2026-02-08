#!/bin/bash
cmd="mysql -uroot -proot -h127.0.0.1 -P5000 -Dtest"
$cmd -e " drop table tpl;"
$cmd -e "CREATE TABLE tpl (
    playerid INT NOT NULL,
    teamid INT NOT NULL,
    isloaned TINYINT(1) NOT NULL,
    PRIMARY KEY (playerid)
);
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/mnt/c/github/fifa/cmtracker/import/tpl.csv'
INTO TABLE tpl
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(playerid, teamid, isloaned);"
$cmd -e \
"SELECT teamid, playerid FROM tpl WHERE isloaned = 0" \
| sed 's/\t/;/g' \
> /mnt/c/github/fifa/cmtracker/import/csv/teamplayerlinks.csv
wc -l /mnt/c/github/fifa/cmtracker/import/csv/teamplayerlinks.csv
