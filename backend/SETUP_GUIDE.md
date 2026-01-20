# Setup Backend Schedule List

## 📋 Prerequisites
- XAMPP (Apache + MySQL + PHP)
- Browser untuk test API

---

## 🔧 Step 1: Install XAMPP

1. **Download XAMPP** dari https://www.apachefriends.org/
2. **Install** XAMPP di drive C: (default)
3. **Jalankan XAMPP Control Panel**

---

## 🚀 Step 2: Setup Backend Files

1. **Copy folder `backend`** ke folder `htdocs` XAMPP:
   ```
   C:\xampp\htdocs\schedulelist\
   ```

2. **Struktur folder** harus seperti ini:
   ```
   C:\xampp\htdocs\schedulelist\backend\
   ├── config\
   │   └── database.php
   ├── database\
   │   └── schema.sql
   └── api\
       ├── schedules\
       │   └── index.php
       └── tasks\
           └── index.php
   ```

---

## 💾 Step 3: Setup Database MySQL

1. **Start Apache dan MySQL** di XAMPP Control Panel
2. **Buka phpMyAdmin**: http://localhost/phpmyadmin
3. **Import database**:
   - Klik tab "SQL"
   - Copy isi file `backend/database/schema.sql`
   - Paste di SQL editor
   - Klik "Go"

4. **Verify**: Database `schedulelist_db` dan 2 tabel (`schedules`, `tasks`) sudah terbuat

---

## 🧪 Step 4: Test API Backend

Buka browser dan test endpoint ini:

### Test Schedules API:
```
http://localhost/schedulelist/backend/api/schedules/index.php
```
**Expected Result**: `{"success":true,"data":[]}`

### Test Tasks API:
```
http://localhost/schedulelist/backend/api/tasks/index.php
```
**Expected Result**: `{"success":true,"data":[]}`

---

## 📱 Step 5: Setup Flutter App

### **Untuk Emulator Android:**
File: `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://10.0.2.2/schedulelist/backend/api';
```

### **Untuk Device Fisik:**
1. **Cari IP Address komputer**:
   - Buka Command Prompt
   - Ketik: `ipconfig`
   - Cari "IPv4 Address" (contoh: 192.168.1.100)

2. **Update baseUrl**:
   ```dart
   static const String baseUrl = 'http://192.168.1.100/schedulelist/backend/api';
   ```

3. **Pastikan HP dan Laptop dalam 1 WiFi yang sama**

---

## ✅ Step 6: Install Dependencies Flutter

```powershell
flutter pub get
```

---

## 🎯 Step 7: Run Flutter App

```powershell
flutter run
```

---

## 🔍 Troubleshooting

### ❌ Error: Connection Refused
- Pastikan Apache dan MySQL di XAMPP sudah running
- Cek firewall Windows (allow port 80)

### ❌ Error: Database connection failed
- Pastikan MySQL di XAMPP sudah running
- Cek username/password di `backend/config/database.php`

### ❌ Error: 404 Not Found
- Pastikan folder backend ada di `C:\xampp\htdocs\schedulelist\backend\`
- Cek URL endpoint sudah benar

### ❌ Error: No response from server (dari Flutter)
- Untuk device fisik: Pastikan HP dan laptop 1 WiFi
- Untuk emulator: Gunakan `10.0.2.2` bukan `localhost`
- Test API di browser dulu sebelum run Flutter

---

## 📊 Test Data (Optional)

Insert sample data via phpMyAdmin:

```sql
-- Sample Schedule
INSERT INTO schedules (title, description, date, time, location) 
VALUES ('Kelas PAM', 'Pemrograman Aplikasi Mobile', '2026-01-15', '08:00:00', 'Lab Komputer');

-- Sample Task
INSERT INTO tasks (title, description, deadline, priority, is_completed) 
VALUES ('UAS PAM', 'Buat aplikasi Schedule List', '2026-01-20 23:59:00', 'Critical P0', 0);
```

---

## 🎉 Selesai!

Aplikasi siap digunakan dengan MySQL backend.
