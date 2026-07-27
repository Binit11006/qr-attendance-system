-- Adds the ability to designate one teacher as "Class Head" for a class.
-- A Class Head can view (but not edit) the defaulter report for just their own class.

USE qr_attendance;

ALTER TABLE classes ADD COLUMN head_teacher_id INT NULL;
ALTER TABLE classes ADD CONSTRAINT fk_head_teacher
    FOREIGN KEY (head_teacher_id) REFERENCES users(id) ON DELETE SET NULL;
