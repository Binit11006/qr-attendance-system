"""
Run once to create your first admin login:
    python seed_admin.py
"""

import pymysql
from werkzeug.security import generate_password_hash

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",   # same as in app.py
    "database": "qr_attendance",
}

admin = {
    "college_id": "ADMIN001",
    "name": "Default Admin",
    "email": "admin@college.edu",
    "password": "admin123",   # change after first login
    "role": "admin",
}

conn = pymysql.connect(**DB_CONFIG)
try:
    with conn.cursor() as cur:
        cur.execute(
            """INSERT INTO users (college_id, name, email, password_hash, role)
               VALUES (%s, %s, %s, %s, %s)""",
            (
                admin["college_id"],
                admin["name"],
                admin["email"],
                generate_password_hash(admin["password"]),
                admin["role"],
            ),
        )
    conn.commit()
    print(f"Admin created. Login with college_id={admin['college_id']} password={admin['password']}")
finally:
    conn.close()
