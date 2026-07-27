USE qr_attendance;

-- 1. Create the 5 new teacher accounts (all use password: teacher123)
INSERT INTO users (college_id, name, email, password_hash, role) VALUES
('TCH002', 'Niraj Pandey', 'niraj.pandey@college.edu', 'scrypt:32768:8:1$ZcUOht88MEPeCUOl$16f8a62ec7aa947bb001b3f102c3759aeb9cd05ab73f1064daa1f7e2d0f45b5fdd72b69a1d5826a25c1e52ff7e1dbbf4777d45ac23e68abc1eb8faeb9366d297', 'teacher'),
('TCH003', 'Priya Yadav', 'priya.yadav@college.edu', 'scrypt:32768:8:1$ZcUOht88MEPeCUOl$16f8a62ec7aa947bb001b3f102c3759aeb9cd05ab73f1064daa1f7e2d0f45b5fdd72b69a1d5826a25c1e52ff7e1dbbf4777d45ac23e68abc1eb8faeb9366d297', 'teacher'),
('TCH004', 'Vivek Maurya', 'vivek.maurya@college.edu', 'scrypt:32768:8:1$ZcUOht88MEPeCUOl$16f8a62ec7aa947bb001b3f102c3759aeb9cd05ab73f1064daa1f7e2d0f45b5fdd72b69a1d5826a25c1e52ff7e1dbbf4777d45ac23e68abc1eb8faeb9366d297', 'teacher'),
('TCH005', 'Priya Tiwari', 'priya.tiwari@college.edu', 'scrypt:32768:8:1$ZcUOht88MEPeCUOl$16f8a62ec7aa947bb001b3f102c3759aeb9cd05ab73f1064daa1f7e2d0f45b5fdd72b69a1d5826a25c1e52ff7e1dbbf4777d45ac23e68abc1eb8faeb9366d297', 'teacher'),
('TCH006', 'Preeti Pandey', 'preeti.pandey@college.edu', 'scrypt:32768:8:1$ZcUOht88MEPeCUOl$16f8a62ec7aa947bb001b3f102c3759aeb9cd05ab73f1064daa1f7e2d0f45b5fdd72b69a1d5826a25c1e52ff7e1dbbf4777d45ac23e68abc1eb8faeb9366d297', 'teacher');

-- 2. Reassign existing theory subjects to the correct real teachers
UPDATE subjects SET teacher_id = (SELECT id FROM users WHERE college_id='TCH002')
WHERE name = 'Artificial Intelligence (AI)';

UPDATE subjects SET teacher_id = (SELECT id FROM users WHERE college_id='TCH003')
WHERE name IN ('Cyber Information and Security (CIS)', 'Software Testing & Quality Assurance (ST & QA)');

UPDATE subjects SET teacher_id = (SELECT id FROM users WHERE college_id='TCH004')
WHERE name = 'Indian Knowledge System (IKS)';

UPDATE subjects SET teacher_id = (SELECT id FROM users WHERE college_id='TCH005')
WHERE name = 'Minor-1: Linux Theory (M-1)';

UPDATE subjects SET teacher_id = (SELECT id FROM users WHERE college_id='TCH006')
WHERE name = 'CEP';

-- 3. Fix "Ethical Hacking" — it's practical-only, relabel and assign Preeti Pandey
UPDATE subjects SET name = 'Ethical Hacking (Practical)', teacher_id = (SELECT id FROM users WHERE college_id='TCH006')
WHERE name = 'Ethical Hacking (VSC)';

-- 4. Add the remaining practical subjects
INSERT INTO subjects (name, class_id, teacher_id) VALUES
('Artificial Intelligence (Practical)', (SELECT id FROM classes WHERE name='TYBSC Computer Science'), (SELECT id FROM users WHERE college_id='TCH002')),
('Cyber Information and Security (Practical)', (SELECT id FROM classes WHERE name='TYBSC Computer Science'), (SELECT id FROM users WHERE college_id='TCH003')),
('Software Testing & Quality Assurance (Practical)', (SELECT id FROM classes WHERE name='TYBSC Computer Science'), (SELECT id FROM users WHERE college_id='TCH003')),
('Linux (Practical)', (SELECT id FROM classes WHERE name='TYBSC Computer Science'), (SELECT id FROM users WHERE college_id='TCH005')),
('Mini Project (Practical)', (SELECT id FROM classes WHERE name='TYBSC Computer Science'), (SELECT id FROM users WHERE college_id='TCH004'));
