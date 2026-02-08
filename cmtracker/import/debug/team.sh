#!/bin/bash
a=$1
mysql -uroot -proot -h127.0.0.1 -P5000 -DFIFA15 -e "select teamid, teamname from teams where teamname like '%$a%';"
