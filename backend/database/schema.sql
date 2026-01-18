-- Create Database
CREATE DATABASE IF NOT EXISTS schedulelist_db;
USE schedulelist_db;

-- Table: users (User Authentication)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: schedules (Jadwal Harian - Sesuai dengan Schedule model)
CREATE TABLE IF NOT EXISTS schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activity VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(255) DEFAULT NULL,
    color VARCHAR(20) NOT NULL DEFAULT '#2563eb',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: tasks (Tugas - Sesuai dengan Task model)
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    deadline DATETIME NOT NULL,
    status ENUM('belum_mulai','berjalan','selesai') NOT NULL DEFAULT 'belum_mulai',
    priority VARCHAR(50) NOT NULL DEFAULT 'sedang',
    progress TINYINT UNSIGNED NOT NULL DEFAULT 0 CHECK (progress <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index untuk performa
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_schedule_user ON schedules(user_id);
CREATE INDEX idx_schedule_date ON schedules(date);
CREATE INDEX idx_schedule_date_time ON schedules(date, start_time);
CREATE INDEX idx_task_user ON tasks(user_id);
CREATE INDEX idx_task_deadline ON tasks(deadline);
CREATE INDEX idx_task_priority ON tasks(priority);
CREATE INDEX idx_task_status ON tasks(status);
CREATE INDEX idx_task_subject ON tasks(subject);

-- Sample Data User
INSERT INTO users (name, email, password) 
VALUES ('John Doe', 'john@example.com', MD5('password123'));

-- Sample Data Jadwal (Schedule)
INSERT INTO schedules (user_id, activity, description, date, start_time, end_time, location, color) 
VALUES 
(1, 'Kelas PAM', 'Pemrograman Aplikasi Mobile', '2026-01-18', '08:00:00', '10:00:00', 'Lab Komputer', '#2563eb'),
(1, 'Kelas Basis Data', 'Relational Database Management', '2026-01-18', '10:30:00', '12:30:00', 'Lab Komputer', '#7c3aed'),
(1, 'Kelas Web Dev', 'Web Development Fundamentals', '2026-01-19', '13:00:00', '15:00:00', 'Ruang 201', '#06b6d4'),
(1, 'Praktikum Jaringan', 'Networking Lab', '2026-01-20', '08:00:00', '11:00:00', 'Lab Jaringan', '#ec4899');

-- Sample Data Tugas (Task)
INSERT INTO tasks (user_id, title, description, subject, deadline, status, priority, progress)
VALUES 
(1, 'UAS PAM', 'Buat aplikasi Schedule List lengkap dengan backend', 'Pemrograman Aplikasi Mobile', '2026-01-25 23:59:00', 'berjalan', 'critical', 45),
(1, 'Laporan Basis Data', 'Buat laporan normalisasi database', 'Basis Data', '2026-01-22 23:59:00', 'belum_mulai', 'tinggi', 0),
(1, 'Quiz Web Dev', 'Quiz online HTML/CSS/JavaScript', 'Web Development', '2026-01-19 15:00:00', 'selesai', 'sedang', 100),
(1, 'Dokumentasi API', 'Lengkapi dokumentasi REST API', 'Pemrograman Aplikasi Mobile', '2026-01-23 23:59:00', 'berjalan', 'tinggi', 60),
(1, 'Presentasi Proyek', 'Presentasi final project PAM', 'Pemrograman Aplikasi Mobile', '2026-01-26 10:00:00', 'belum_mulai', 'critical', 0);
