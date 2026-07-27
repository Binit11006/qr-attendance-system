-- Week 4.5 update: run this AFTER schema_update_week2.sql
-- Distinguishes theory vs practical lectures, since colleges track
-- attendance separately for each.

USE qr_attendance;

ALTER TABLE sessions
    ADD COLUMN session_type ENUM('theory', 'practical') NOT NULL DEFAULT 'theory';
