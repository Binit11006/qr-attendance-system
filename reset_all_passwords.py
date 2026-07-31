"""
Resets EVERY user's password to a new, unique, randomly generated password.

WHAT THIS DOES:
    1. Connects to your Aiven MySQL database (same credentials as app.py)
    2. Generates a fresh random password for every single user (students,
       teachers, admin - everyone)
    3. Updates the database with the new (hashed) password for each user
    4. Writes a file called new_passwords.csv with a plain-text list of
       college_id, name, role, and new password - so you can print/share
       this with your class

HOW TO RUN THIS (on your own PC, in VS Code terminal):
    1. Fill in your Aiven connection details below (DB_HOST, DB_PORT,
       DB_USER, DB_PASSWORD, DB_NAME) - same values you used in Render's
       Environment tab.
    2. Run: python reset_all_passwords.py
    3. Open the new new_passwords.csv file it creates - print it or share
       it securely with your class.
    4. IMPORTANT: delete new_passwords.csv from your PC afterwards (or at
       least don't upload it anywhere, including GitHub - it's already in
       .gitignore as *.csv, but double check before committing).
"""

import csv
import os
import random

import pymysql
from werkzeug.security import generate_password_hash

# ---- Reads connection details from environment variables ----
# Never hardcode real credentials directly into this file - it goes into git.
#
# On Windows (Command Prompt), set these before running the script, e.g.:
#   set DB_HOST=your-aiven-host
#   set DB_PORT=12345
#   set DB_USER=avnadmin
#   set DB_PASSWORD=your-aiven-password
#   set DB_NAME=qr_attendance
#   python reset_all_passwords.py
#
# On Windows (PowerShell), use $env: instead, e.g.:
#   $env:DB_HOST="your-aiven-host"
#   $env:DB_PORT="12345"
#   $env:DB_USER="avnadmin"
#   $env:DB_PASSWORD="your-aiven-password"
#   $env:DB_NAME="qr_attendance"
#   python reset_all_passwords.py

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", ""),
    "port": int(os.environ.get("DB_PORT", 3306)),
    "user": os.environ.get("DB_USER", "avnadmin"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "database": os.environ.get("DB_NAME", "qr_attendance"),
    "cursorclass": pymysql.cursors.DictCursor,
    "ssl": {"ssl": {}},  # Aiven requires SSL
}


def generate_random_password(length=8):
    """Generates an easy-to-read random password (letters + digits, no
    confusing characters like 0/O or 1/l)."""
    alphabet = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789"
    return "".join(random.choice(alphabet) for _ in range(length))


def main():
    if not DB_CONFIG["host"] or not DB_CONFIG["password"]:
        print("ERROR: DB_HOST and/or DB_PASSWORD environment variables are not set.")
        print("See the instructions in the comments near the top of this file.")
        return

    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT id, college_id, name, role FROM users ORDER BY role, name")
            all_users = cur.fetchall()

            if not all_users:
                print("No users found - is DB_CONFIG filled in correctly?")
                return

            rows_for_csv = []
            for user in all_users:
                new_password = generate_random_password()
                hashed = generate_password_hash(new_password)

                cur.execute(
                    "UPDATE users SET password_hash = %s WHERE id = %s",
                    (hashed, user["id"]),
                )

                rows_for_csv.append({
                    "college_id": user["college_id"],
                    "name": user["name"],
                    "role": user["role"],
                    "new_password": new_password,
                })

            conn.commit()

        with open("new_passwords.csv", "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["college_id", "name", "role", "new_password"])
            writer.writeheader()
            writer.writerows(rows_for_csv)

        print(f"Done! Updated {len(rows_for_csv)} passwords.")
        print("New passwords saved to new_passwords.csv in this folder.")
        print("Remember: don't commit or upload this CSV anywhere - hand it out securely and then delete it.")

    finally:
        conn.close()


if __name__ == "__main__":
    main()
