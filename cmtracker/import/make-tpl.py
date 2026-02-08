#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd

INPUT_CSV = "/mnt/c/github/fifa/cmtracker/import/csv/exist_player.csv"
OUTPUT_TPL = "/mnt/c/github/fifa/cmtracker/import/tpl.csv"

def main():
    df = pd.read_csv(INPUT_CSV)

    # Vérification des colonnes obligatoires
    required = [
        "info.playerid",
        "info.teams.club_team.id",
        "info.contract.isloanedout"
    ]

    for col in required:
        if col not in df.columns:
            raise SystemExit(f"❌ Colonne manquante : {col}")

    # Extraction des colonnes
    out = pd.DataFrame()
    out["playerid"] = df["info.playerid"].astype(str).str.strip()
    out["teamid"] = df["info.teams.club_team.id"].astype(str).str.strip()

    # Normalisation du flag prêt
    raw_loan = df["info.contract.isloanedout"].astype(str).str.strip().str.lower()
    out["isloaned"] = raw_loan.isin(["1", "true", "yes"]).astype(int)

    # Export
    out.to_csv(OUTPUT_TPL, sep=";", index=False)
    print(f"✅ tpl.csv généré : {OUTPUT_TPL} ({len(out)} lignes)")

if __name__ == "__main__":
    main()

