"""Génère une fois les secrets initiaux locaux du laboratoire CyberCorp."""

import csv
import secrets
import string
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACCOUNTS = ROOT / "config" / "comptes.csv"
OUTPUT = ROOT / "secrets" / "initial-passwords.csv"
SYMBOLS = "!@#%_-+"
ALPHABET = string.ascii_letters + string.digits + SYMBOLS


def make_password() -> str:
    parts = [
        secrets.choice(string.ascii_lowercase),
        secrets.choice(string.ascii_uppercase),
        secrets.choice(string.digits),
        secrets.choice(SYMBOLS),
    ]
    parts.extend(secrets.choice(ALPHABET) for _ in range(20))
    secrets.SystemRandom().shuffle(parts)
    return "".join(parts)


def main() -> None:
    with ACCOUNTS.open(newline="", encoding="utf-8") as source:
        accounts = list(csv.DictReader(source))
    if not accounts or len({row["identifiant"] for row in accounts}) != len(accounts):
        raise ValueError("Inventaire des comptes vide ou identifiants en double")

    OUTPUT.parent.mkdir(exist_ok=True)
    # 'x' évite d'écraser des secrets déjà utilisés sur les VM.
    with OUTPUT.open("x", newline="", encoding="utf-8") as destination:
        writer = csv.writer(destination)
        writer.writerow(["identifiant", "service", "mot_de_passe_initial"])
        for row in accounts:
            writer.writerow([row["identifiant"], row["service"], make_password()])
    print(f"{len(accounts)} secrets générés dans {OUTPUT} (fichier ignoré par Git)")


if __name__ == "__main__":
    main()
