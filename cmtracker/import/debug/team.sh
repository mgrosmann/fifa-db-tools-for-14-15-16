#!/bin/bash
a=$1
#query="where teamname like '%$a%'"
query="where teamid = $a"
mysql -uroot -proot -h127.0.0.1 -P5000 -DFIFA15 -e "select teamid, teamname from teams $query ;"
