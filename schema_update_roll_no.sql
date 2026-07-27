-- Adds a roll number field for students (1-60 per class typically)
-- Nullable since it doesn't apply to teachers/admins

USE qr_attendance;

ALTER TABLE users ADD COLUMN roll_no INT NULL;
