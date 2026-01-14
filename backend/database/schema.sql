-- Create Database
CREATE DATABASE IF NOT EXISTS schedulelist_db;
USE schedulelist_db;

CREATE TABLE IF NOT EXISTS schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(255) DEFAULT NULL,
    color VARCHAR(20) NOT NULL DEFAULT '#2563eb',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    deadline DATETIME NOT NULL,
    priority VARCHAR(50) NOT NULL DEFAULT 'sedang',
    status ENUM('belum_mulai','berjalan','selesai') NOT NULL DEFAULT 'belum_mulai',
    progress TINYINT UNSIGNED NOT NULL DEFAULT 0 CHECK (progress <= 100),
    is_completed TINYINT(1) DEFAULT 0,
    image_path VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index untuk performa
CREATE INDEX idx_schedule_date ON schedules(date);
CREATE INDEX idx_schedule_date_time ON schedules(date, start_time);
CREATE INDEX idx_task_deadline ON tasks(deadline);
CREATE INDEX idx_task_priority ON tasks(priority);
CREATE INDEX idx_task_completed ON tasks(is_completed);
CREATE INDEX idx_task_status ON tasks(status);
