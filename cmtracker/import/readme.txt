0 correct-id.sh -> assigner bon pid au joueur existant (dans la db sql)
1 debug/new.py separe les csv en 2
2 debug/doublon-pid.py -> supprimer doublon
3 debug/fix-loan.sh -> regle date de pret
4 import-csv.py -> convertir csv cm tracker en fifa15 compatible
4.5 si joueur exitsant -> make-tpl.py crée un tpl.csv pour sql
4.75 -> make-tpl.sh import en sql a partir de tpl.csv puis re envoie en csv en enlevant les joueurs prétés
5 dictionnaire.sh -> s'occuper import de playernames
6 import-cmtracker.sh -> s'occupe de table players et tpl











pour debug:

1 wrong-tid.Py -> genere un log des mauvais teamid
2 check doublon.py -> log pid doublon
3 sql2csv.sh -> exporter une table en csv
4 team.sh -> donne le nom et le teamid

tous les csv dans le dossier csv
