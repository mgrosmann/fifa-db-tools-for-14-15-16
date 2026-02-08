import pandas as pd

# --- CONFIG ---
INPUT_EXIST = "/mnt/c/github/fifa/cmtracker/import/csv/exist_player.csv"
INPUT_NEW   = "/mnt/c/github/fifa/cmtracker/import/csv/new_player.csv"

LOG = "/mnt/c/github/fifa/cmtracker/import/loan/joueurs_pretes.log"
OUTPUT_CSV = "/mnt/c/github/fifa/cmtracker/import/loan/playerloans.csv"

# --- Charger les deux CSV ---
df_exist = pd.read_csv(INPUT_EXIST)
df_new   = pd.read_csv(INPUT_NEW)

# Fusionner
df = pd.concat([df_exist, df_new], ignore_index=True)

# Normaliser le champ prêt
df["info.contract.isloanedout"] = (
    df["info.contract.isloanedout"]
    .astype(str)
    .str.lower()
    .isin(["1", "true", "yes"])
)

# Filtrer joueurs prêtés
pretes = df[df["info.contract.isloanedout"] == True]

# --- LOG + CSV prêt ---
loans_rows = []

with open(LOG, "w", encoding="utf-8") as f:

    if pretes.empty:
        f.write("Aucun joueur prêté trouvé.\n")
    else:
        f.write(f"=== LISTE DES JOUEURS PRÊTÉS ({len(pretes)}) ===\n\n")

        for _, row in pretes.iterrows():

            playerid = row["info.playerid"]
            knownas  = row.get("info.name.knownas", "")
            club     = row.get("info.teams.club_team.name", "")
            teamid   = row.get("info.teams.club_team.id", "")

            # --- LOG ---
            f.write(f"PlayerID : {playerid}\n")
            f.write(f"Nom      : {knownas}\n")
            f.write(f"Club     : {club}\n")
            f.write(f"TeamID   : {teamid}\n")
            f.write("-" * 40 + "\n")

            # --- DEMANDER LE TEAMID DU CLUB OÙ IL EST PRÊTÉ ---
            print("\n----------------------------------------")
            print(f"Joueur prêté : {knownas} (playerid {playerid})")
            print(f"Club actuel détecté : {club} (teamid {teamid})")
            print("Vers quel teamid est-il prêté ?")

            new_teamid = input("TeamID prêté : ").strip()

            # Si vide → garder celui du CSV
            if new_teamid == "":
                new_teamid = str(teamid)

            loans_rows.append({
                "playerid": playerid,
                "teamid": new_teamid
            })

# --- Sauvegarde du CSV des prêts ---
loans_df = pd.DataFrame(loans_rows)
loans_df.to_csv(OUTPUT_CSV, index=False, sep=";")

print(f"\n✅ Log généré : {LOG}")
print(f"📄 CSV prêts généré : {OUTPUT_CSV}")

