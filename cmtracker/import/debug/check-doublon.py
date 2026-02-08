import pandas as pd

# --- CONFIG ---
#INPUT = "/mnt/c/github/fifa/cmtracker/import/csv/joueurs_existants.csv"
#INPUT = "/mnt/c/github/fifa/cmtracker/import/csv/nouveaux_joueurs.csv"
INPUT = "/mnt/c/github/fifa/cmtracker/import/debug/new_player.csv"
#INPUT = "/mnt/c/github/fifa/cmtracker/import/csv/exist_player.csv"
LOG = "/mnt/c/github/fifa/cmtracker/import/debug/doublons_playerid.log"

# --- Charger CSV ---
df = pd.read_csv(INPUT)


# --- Colonnes à afficher ---
cols_to_show = [
    "info.playerid",
    "info.contract.isloanedout",
    "info.name.knownas",
    "info.teams.club_team.name"
]

# Vérifier que les colonnes existent
cols_presentes = [c for c in cols_to_show if c in df.columns]

# --- Détection des doublons ---
doublons = df[df.duplicated(subset=["info.playerid"], keep=False)].sort_values("info.playerid")

# --- Écriture du log ---
with open(LOG, "w", encoding="utf-8") as f:
    if doublons.empty:
        f.write("Aucun doublon trouvé.\n")
    else:
        f.write(f"=== DOUBLONS SUR {"info.playerid"} ===\n")
        for pid, group in doublons.groupby("info.playerid"):
            f.write(f"\n--- PlayerID {pid} : {len(group)} occurrences ---\n")
            f.write(group[cols_presentes].to_string(index=False))
            f.write("\n")

print(f"Analyse terminée. Log généré → {LOG}")

