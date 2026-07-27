-- Week 2 update: run this AFTER schema.sql
-- Adds a flag so a teacher can explicitly end a live session
-- (stops the QR from refreshing / being scannable)

USE qr_attendance;

ALTER TABLE sessions ADD COLUMN is_active TINYINT(1) DEFAULT 1;
