1 freeid.sh -> libérer des id pour les futurs joueurs avec ces meme pid
2 correct-id.sh -> assigner bon pid au joueur existant
3 import-csv.py -> convertir csv cm tracker en fifa15 compatible
4 dictionnaire.sh -> s'occuper import de playernames
5 import-cmtracker.sh -> s'occupe de table players et tpl

tous les csv dans le dossier csv

dans debug:

wrong_tid.py -> scan les csv et repere les teamid absent dans la database
correct-tid.sh -> affecte les bon teamid
sql2csv.sh -> facilite l'export des tables sql en csv