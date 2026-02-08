import pandas as pd

# --- CONFIG ---
INPUT="/mnt/c/github/fifa/cmtracker/import/csv/joueurs_existants_fixed.csv"
#INPUT="/mnt/c/github/fifa/cmtracker/import/csv/joueurs_nouveaux_fixed.csv"
OUTPUT = "/mnt/c/github/fifa/cmtracker/import/csv/exist_player.csv"
#OUTPUT = "/mnt/c/github/fifa/cmtracker/import/csv/new_player.csv"
LOG = "/mnt/c/github/fifa/cmtracker/import/debug/doublons_teamid.log"

# --- Charger CSV ---
df = pd.read_csv(INPUT)

# --- Vérifier colonnes ---
if "info.playerid" not in df.columns:
    raise ValueError("Colonne info.playerid manquante")
if "info.teams.club_team.id" not in df.columns:
    raise ValueError("Colonne info.teams.club_team.id manquante")

# --- Trouver doublons playerid ---
doublons = df[df.duplicated(subset=["info.playerid"], keep=False)]
doublons = doublons.sort_values("info.playerid")

# --- Log ---
log_lines = []

# --- Nouveau dataframe corrigé ---
df_fixed = df.copy()

# --- Traitement des doublons ---
for pid, group in doublons.groupby("info.playerid"):

    teamids = group["info.teams.club_team.id"].unique()

    # === CAS 1 : même teamid → suppression automatique ===
    if len(teamids) == 1:
        # garder seulement la première occurrence
        keep_index = group.index[0]
        for idx in group.index:
            if idx != keep_index:
                df_fixed = df_fixed.drop(idx)

        log_lines.append(
            f"[AUTO] PlayerID {pid} : doublons supprimés automatiquement (teamid identique {teamids[0]})\n"
        )
        continue

    # === CAS 2 : teamid différents → demander à l'utilisateur ===
    print("\n====================================")
    print(f"⚠️  Doublon détecté pour playerid : {pid}")
    print("TeamID différents → choix manuel nécessaire")
    print("====================================")

    for idx, row in group.iterrows():
        print(f"\nOption {idx}:")
        print(f"  playerid : {row['info.playerid']}")
        print(f"  knownas  : {row.get('info.name.knownas', '')}")
        print(f"  teamid   : {row['info.teams.club_team.id']}")
        print(f"  club     : {row.get('info.teams.club_team.name', '')}")

    choix = None
    while choix not in group.index:
        try:
            choix = int(input(f"\n👉 Quel index garder pour playerid {pid} ? "))
        except:
            pass

    log_lines.append(f"[MANUEL] PlayerID {pid} → garder index {choix}\n")

    for idx in group.index:
        if idx != choix:
            df_fixed = df_fixed.drop(idx)

# --- Sauvegarde ---
df_fixed.to_csv(OUTPUT, index=False)

with open(LOG, "w", encoding="utf-8") as f:
    f.writelines(log_lines)

print("\n✅ Correction terminée.")
print(f"→ Fichier corrigé : {OUTPUT}")
print(f"→ Log : {LOG}")

