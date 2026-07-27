USE qr_attendance;

-- Add an explicit flag instead of relying on subject names containing "(Practical)"
ALTER TABLE subjects ADD COLUMN is_practical TINYINT(1) NOT NULL DEFAULT 0;

-- Backfill existing subjects based on their current names
UPDATE subjects SET is_practical = 1 WHERE name LIKE '%Practical%';
