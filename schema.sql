-- QR-Based Smart Attendance Management System
-- Week 1: Core Schema

CREATE DATABASE IF NOT EXISTS qr_attendance;
USE qr_attendance;

-- ============================================
-- USERS (students, teachers, admins share login)
-- ============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    college_id VARCHAR(30) UNIQUE NOT NULL,      -- login ID for students/teachers
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CLASSES (e.g. "TE Comp A", "SE IT B")
-- ============================================
CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    year VARCHAR(20)                              -- e.g. "2025-26"
);

-- Link students to a class
CREATE TABLE student_class (
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    PRIMARY KEY (student_id, class_id),
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

-- ============================================
-- SUBJECTS
-- ============================================
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class_id INT NOT NULL,
    teacher_id INT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- SESSIONS (one row per lecture where a QR is generated)
-- ============================================
CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    session_date DATE NOT NULL,
    start_time DATETIME NOT NULL,
    qr_token VARCHAR(64) NOT NULL,                -- random token embedded in QR
    qr_expires_at DATETIME NOT NULL,               -- server-side expiry check
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- ATTENDANCE (one row per student per session)
-- ============================================
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    student_id INT NOT NULL,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('present', 'edited_present', 'edited_absent') DEFAULT 'present',
    UNIQUE KEY unique_attendance (session_id, student_id),  -- prevents duplicate scans
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- Seed a default admin (change password after first login)
-- Password below is a placeholder hash; generate real ones via app.py
-- ============================================
-- INSERT INTO users (college_id, name, email, password_hash, role)
-- VALUES ('ADMIN001', 'Default Admin', 'admin@college.edu', '<hash>', 'admin');
