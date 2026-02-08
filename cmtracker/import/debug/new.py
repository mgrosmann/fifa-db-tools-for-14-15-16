import pandas as pd
import glob
import os
from datetime import datetime, timedelta
import Levenshtein

# --- CONFIG ---
base_dir = "/mnt/c/github/csv/"
folders = ["wonderkid", "old wonderkid", "very old", "update"]

fifa_players_csv = "/mnt/c/github/fifa/cmtracker/import/debug/players.csv"

output_new_file = "/mnt/c/github/fifa/cmtracker/import/csv/joueurs_nouveaux.csv"
output_existing_file = "/mnt/c/github/fifa/cmtracker/import/csv/joueurs_existants.csv"

# --- Conversion dates FIFA ---
BASE_ID = 157499
BASE_DATE = datetime(2014, 1, 1)

def fifa_to_date(days):
    try:
        delta = int(days) - BASE_ID
        return (BASE_DATE + timedelta(days=delta)).strftime("%Y-%m-%d")
    except:
        return None

def cmtracker_to_date(date_str):
    try:
        return datetime.fromisoformat(date_str.replace("Z", "")).strftime("%Y-%m-%d")
    except:
        return None

def similar(a, b, threshold=0.85):
    if not a or not b:
        return False
    return Levenshtein.ratio(a.lower(), b.lower()) >= threshold

# --- Charger DB FIFA ---
players = pd.read_csv(fifa_players_csv, sep=";")

# Normalisation noms FIFA
players["firstname"] = players["firstname"].astype(str).str.lower().str.strip()
players["lastname"] = players["lastname"].astype(str).str.lower().str.strip()
players["fullname"] = (players["firstname"] + " " + players["lastname"]).str.strip()

# Conversion date FIFA
players["birthdate_real"] = players["birthdate"].apply(fifa_to_date)
players["nationid"] = players["nationid"].astype(str)

# Index rapides
fifa_ids = set(players["playerid"].astype(str))

# --- Résultats ---
existants = []
nouveaux = []

# --- Parcourir CM Tracker ---
for folder in folders:
    for file in glob.glob(os.path.join(base_dir, folder, "*.csv")):
        df = pd.read_csv(file, sep=",", quotechar='"')

        required = {
            "info.playerid",
            "info.name.firstname",
            "info.name.lastname",
            "info.birthdate",
            "info.nation.id"
        }
        if not required.issubset(df.columns):
            print(f"⚠️ Colonnes manquantes dans {file}")
            continue

        for _, row in df.iterrows():
            pid = str(row["info.playerid"]).strip()
            firstname = str(row["info.name.firstname"]).lower().strip()
            lastname = str(row["info.name.lastname"]).lower().strip()
            fullname = f"{firstname} {lastname}".strip()
            birth_cm = cmtracker_to_date(row["info.birthdate"])
            nation_cm = str(row["info.nation.id"]).strip()

            # 1. Match playerid
            if pid in fifa_ids:
                existants.append(row)
                continue

            # 2. Match strict fullname + birthdate + nation
            match = players[
                (players["fullname"] == fullname) &
                (players["birthdate_real"] == birth_cm) &
                (players["nationid"] == nation_cm)
            ]
            if not match.empty:
                existants.append(row)
                continue

            # 3. Match tolérant : nom similaire + birthdate identique
            match = players[
                (players["birthdate_real"] == birth_cm) &
                (players["fullname"].apply(lambda x: similar(x, fullname)))
            ]
            if not match.empty:
                existants.append(row)
                continue

            # 4. Match tolérant : fullname strict + birthdate ± 1 jour
            try:
                d = datetime.strptime(birth_cm, "%Y-%m-%d")
                birth_plus = (d + timedelta(days=1)).strftime("%Y-%m-%d")
                birth_minus = (d - timedelta(days=1)).strftime("%Y-%m-%d")
            except:
                birth_plus = birth_minus = None

            match = players[
                (players["fullname"] == fullname) &
                (players["birthdate_real"].isin([birth_cm, birth_plus, birth_minus]))
            ]
            if not match.empty:
                existants.append(row)
                continue

            # Sinon → nouveau joueur
            nouveaux.append(row)

# --- Export ---
pd.DataFrame(nouveaux).to_csv(output_new_file, index=False)
pd.DataFrame(existants).to_csv(output_existing_file, index=False)

