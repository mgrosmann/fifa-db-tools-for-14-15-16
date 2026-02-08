import pandas as pd

# --- FICHIERS ---
csv_nouveaux = "/mnt/c/github/fifa/cmtracker/import/debug/joueurs_nouveaux_fixed.csv"
csv_existants = "/mnt/c/github/fifa/cmtracker/import/debug/joueurs_existants_fixed.csv"
csv_teams = "/mnt/c/github/fifa/cmtracker/import/debug/teams.csv"
log_missing_teams = "/mnt/c/github/fifa/cmtracker/import/debug/teamid_manquants.log"

# --- Charger les CSV ---
df_new = pd.read_csv(csv_nouveaux)
df_exist = pd.read_csv(csv_existants)
df_teams = pd.read_csv(csv_teams, sep=";")

# --- Vérification colonnes ---
if "teamid" not in df_teams.columns:
    raise ValueError("La colonne 'teamid' est introuvable dans teams.csv")

# --- Ensemble des teamid FIFA ---
teams_ids = set(df_teams["teamid"].astype(str))

# --- Récupérer tous les teamid des joueurs ---
teamids_joueurs = set()

for df in [df_new, df_exist]:
    if "info.teams.club_team.id" in df.columns:
        for tid in df["info.teams.club_team.id"].dropna().unique():
            teamids_joueurs.add(str(int(tid)))

# --- Comparaison ---
teamids_manquants = sorted(t for t in teamids_joueurs if t not in teams_ids)

# --- Log ---
with open(log_missing_teams, "w") as f:
    for tid in teamids_manquants:
        f.write(f"TeamID manquant : {tid}\n")

print(f"TeamID manquants log → {log_missing_teams}")

