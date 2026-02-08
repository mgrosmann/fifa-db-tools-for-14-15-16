#!/bin/bash
number=$1
mysql -uroot -proot -h127.0.0.1 -P5000 -DFIFA15 -e "select teamname from teams where teamid = $1"
