# Week 1 — Setup, Schema & Login

## What's in here
- `schema.sql` — full database schema (users, classes, subjects, sessions, attendance)
- `app.py` — Flask app: DB connection + role-based login (student/teacher/admin)
- `seed_admin.py` — creates your first admin login
- `templates/login.html`, `templates/dashboard.html` — basic UI
- `requirements.txt`

## Setup steps

1. **Install MySQL** if you don't have it, then create the database:
   ```
   mysql -u root -p < schema.sql
   ```

2. **Install Python dependencies:**
   ```
   pip install -r requirements.txt
   ```

3. **Set your DB password** in `app.py` and `seed_admin.py` (the `DB_CONFIG["password"]` field — currently blank, matching a fresh MySQL install with no root password. Update if yours is different).

4. **Create your first admin login:**
   ```
   python seed_admin.py
   ```
   This prints a college ID + password you can log in with.

5. **Run the app:**
   ```
   python app.py
   ```
   Visit http://127.0.0.1:5000 — log in with the admin credentials from step 4.

## What's working right now
- Full DB schema
- Login with role-based redirect (student / teacher / admin land on different dashboards)
- Session handling + logout
- Password hashing (Werkzeug) — no plaintext passwords stored

## What's NOT built yet (by design — later weeks)
- Adding students/teachers via the admin panel (you'll insert test data manually via SQL for now — sample inserts below)
- QR generation (Week 2)
- QR scanning (Week 3)
- Attendance % calculation and dashboards (Week 4)
- Admin CRUD + reports (Week 5)

## Sample test data (run in MySQL after schema.sql)

```sql
INSERT INTO classes (name, year) VALUES ('TE Comp A', '2025-26');

-- password for both below: "test123" — generate the hash via Python:
-- from werkzeug.security import generate_password_hash
-- print(generate_password_hash("test123"))

INSERT INTO users (college_id, name, email, password_hash, role)
VALUES ('STU001', 'Test Student', 'stu001@college.edu', '<paste hash here>', 'student');

INSERT INTO users (college_id, name, email, password_hash, role)
VALUES ('TCH001', 'Test Teacher', 'tch001@college.edu', '<paste hash here>', 'teacher');

INSERT INTO student_class (student_id, class_id) VALUES (
  (SELECT id FROM users WHERE college_id='STU001'), 1
);

INSERT INTO subjects (name, class_id, teacher_id) VALUES (
  'Data Structures', 1,
  (SELECT id FROM users WHERE college_id='TCH001')
);
```

## Next: Week 2
QR code generation for a lecture session, with 30–60 second expiry.
