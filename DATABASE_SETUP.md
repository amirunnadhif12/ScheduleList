# Setup Database untuk ScheduleList

## Langkah 1: Setup MySQL Database

1. **Jalankan XAMPP**
   - Buka XAMPP Control Panel
   - Start Apache dan MySQL

2. **Import Database Schema**
   - Buka browser dan akses: `http://localhost/phpmyadmin`
   - Klik tab "SQL"
   - Copy dan paste isi file `backend/database/schema.sql`
   - Klik "Go" untuk execute

   ATAU gunakan command line:
   ```bash
   mysql -u root -p < backend/database/schema.sql
   ```

3. **Verifikasi Database**
   - Database `schedulelist_db` harus sudah ter-create
   - Harus ada 3 tabel: `users`, `schedules`, `tasks`

## Langkah 2: Konfigurasi Backend

File `backend/config/database.php` sudah dikonfigurasi dengan setting default XAMPP:
```php
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASS = '' (kosong)
DB_NAME = 'schedulelist_db'
```

Jika MySQL Anda menggunakan password, edit file tersebut.

## Langkah 3: Test API Backend

1. **Test Registration**
   Buka Postman atau browser, kirim POST request ke:
   ```
   http://localhost/schedulelist/backend/api/auth/register.php
   ```
   
   Body (JSON):
   ```json
   {
     "name": "Test User",
     "email": "test@example.com",
     "password": "password123"
   }
   ```

2. **Test Login**
   POST request ke:
   ```
   http://localhost/schedulelist/backend/api/auth/login.php
   ```
   
   Body (JSON):
   ```json
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

## Langkah 4: Konfigurasi Flutter App

File `lib/config/api_config.dart` sudah dikonfigurasi otomatis:

- **Android Emulator**: `http://10.0.2.2/schedulelist/backend/api`
- **iOS Simulator/Web**: `http://localhost/schedulelist/backend/api`
- **Device Fisik**: Ganti dengan IP komputer Anda (contoh: `http://192.168.1.100/schedulelist/backend/api`)

### Untuk Device Fisik:
1. Cek IP komputer Anda:
   - Windows: `ipconfig` di Command Prompt
   - Mac/Linux: `ifconfig` di Terminal
   
2. Edit `lib/config/api_config.dart`, tambahkan opsi untuk physical device:
   ```dart
   // Untuk testing dengan device fisik, uncomment dan ganti IP:
   // return 'http://192.168.1.100/schedulelist/backend/api';
   ```

## Langkah 5: Jalankan Flutter App

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run app**
   ```bash
   flutter run
   ```

3. **Test Login/Register**
   - Buka app
   - Coba register dengan email baru
   - Login dengan akun yang baru dibuat

## Troubleshooting

### Error: Connection refused
- Pastikan XAMPP Apache dan MySQL running
- Pastikan folder `schedulelist` ada di `C:\xampp\htdocs\` atau folder htdocs Anda
- Test API di browser: `http://localhost/schedulelist/backend/api/auth/login.php`

### Error: Database connection failed
- Pastikan MySQL running di XAMPP
- Cek credentials di `backend/config/database.php`
- Pastikan database `schedulelist_db` sudah ter-create

### Error: 404 Not Found
- Pastikan struktur folder benar:
  ```
  C:\xampp\htdocs\schedulelist\backend\api\auth\login.php
  ```

### Android Emulator tidak konek
- Gunakan `10.0.2.2` bukan `localhost`
- Sudah otomatis di `api_config.dart`

### iOS Simulator tidak konek
- Gunakan `localhost` (sudah otomatis)
- Atau gunakan IP komputer

## Status Integrasi

✅ Database schema created
✅ Backend API ready (login, register)
✅ Flutter auth service created
✅ Login screen integrated with API
✅ Loading states added
✅ Error handling implemented

## Next Steps

Setelah login berhasil, Anda bisa:
1. Integrate Tasks API
2. Integrate Schedules API
3. Test full CRUD operations
