# 📱 Cara Pakai Aplikasi ScheduleList Sehari-hari

## 🎯 Ada 3 Cara Menggunakan Aplikasi Ini:

---

## 🌟 **CARA 0: Database ONLINE (PALING REKOMENDASI!)** ⭐

### Keuntungan:
✅ Tidak perlu XAMPP lagi
✅ Bisa pakai dari mana saja (WiFi apapun, bahkan pakai data seluler)
✅ Tidak perlu laptop/PC nyala terus
✅ Data tersimpan online, lebih aman
✅ Sekali setup, pakai selamanya!

### Cara Setup:
1. **Lihat panduan lengkap**: [HOSTING_ONLINE.md](HOSTING_ONLINE.md)
2. Upload backend ke hosting gratis (InfinityFree recommended)
3. Update URL di `lib/config/api_config.dart`
4. Build APK dan install ke HP
5. **SELESAI!** Langsung pakai, tidak perlu ribet lagi!

---

## 🎯 Ada 3 Cara Lainnya:

---

## ✅ **CARA 1: Pakai di HP Android (REKOMENDASI)**

### A. Setup Backend (Cukup Sekali Saja)

1. **Install XAMPP** di laptop/PC
   - Download dari https://www.apachefriends.org/
   - Install di C:\xampp\

2. **Copy folder backend**
   - Copy folder `backend` ke `C:\xampp\htdocs\schedulelist\`

3. **Setup Database**
   - Buka XAMPP Control Panel → Start Apache & MySQL
   - Buka browser: http://localhost/phpmyadmin
   - Klik "New" → nama database: `schedulelist_db`
   - Import file: `backend/database/schema.sql`

4. **Cek IP Komputer**
   - Buka Command Prompt (CMD)
   - Ketik: `ipconfig`
   - Cari "IPv4 Address" (contoh: 192.168.1.100)
   - CATAT IP ini!

### B. Build APK untuk HP Android

1. **Update IP di kode**
   - Buka file `lib/config/api_config.dart`
   - Ganti IP di baris ke-16 dengan IP komputer kamu:
   ```dart
   return 'http://192.168.1.100/schedulelist/backend/api'; // ganti dengan IP kamu
   ```

2. **Build APK**
   - Buka Terminal di VS Code
   - Jalankan perintah:
   ```bash
   flutter build apk --release
   ```
   - Tunggu 2-5 menit sampai selesai

3. **Install di HP**
   - File APK ada di: `build\app\outputs\flutter-apk\app-release.apk`
   - Copy file ini ke HP (via USB/WhatsApp/Email)
   - Install APK di HP Android
   - Izinkan "Install from Unknown Sources" jika diminta

### C. Cara Pakai Sehari-hari

1. **Pastikan Backend Jalan**
   - Setiap kali mau pakai app, pastikan:
   - XAMPP di laptop/PC sudah jalan (Apache & MySQL harus ON)
   - HP dan laptop/PC harus di jaringan WiFi yang SAMA

2. **Buka Aplikasi**
   - Tap icon ScheduleList di HP
   - Login dengan akun yang sudah dibuat
   - Mulai gunakan!

### ⚠️ PENTING:
- HP dan laptop/PC harus connect ke WiFi yang SAMA
- XAMPP harus selalu ON saat pakai aplikasi
- Kalau pindah WiFi, mungkin perlu update IP lagi

---

## ✅ **CARA 2: Pakai di Laptop/PC (Development Mode)**

### A. Jalankan Backend (Sekali Saja)
Sama seperti Cara 1 bagian A (steps 1-3)

### B. Jalankan Aplikasi

1. **Pakai Emulator Android**
   - Buka Android Studio
   - Start emulator Android
   - Di VS Code Terminal:
   ```bash
   flutter run
   ```

2. **Pakai Browser (Chrome)**
   - Di Terminal:
   ```bash
   flutter run -d chrome
   ```

3. **Pakai Windows Desktop**
   - Di Terminal:
   ```bash
   flutter run -d windows
   ```

### C. Cara Pakai Sehari-hari
1. Buka XAMPP → Start Apache & MySQL
2. Buka VS Code → Terminal → ketik `flutter run -d [pilih device]`
3. Aplikasi akan otomatis terbuka

---

## 🔥 **TIPS PRAKTIS**

### Untuk Pakai Tanpa Repot:
1. ✅ Build APK sekali saja (Cara 1)
2. ✅ Install di HP
3. ✅ Tinggal pastikan XAMPP ON setiap kali mau pakai

### Troubleshooting:
- **App tidak connect ke backend?**
  - Cek XAMPP Apache & MySQL sudah ON
  - Cek HP dan laptop connect ke WiFi yang sama
  - Test buka browser di HP: http://[IP-KOMPUTER]/schedulelist/backend/

- **IP berubah terus?**
  - Set IP Static di router WiFi
  - Atau pakai No-IP / DynDNS

- **APK tidak bisa install?**
  - Aktifkan "Unknown Sources" di Settings HP
  - Coba build ulang dengan: `flutter clean` lalu `flutter build apk --release`

---

## 🚀 **CARA TERCEPAT (Quick Start)**

```bash
# 1. Update IP di api_config.dart (ganti dengan IP komputer kamu)
# 2. Build APK
flutter clean
flutter build apk --release

# 3. File APK ada di:
# build\app\outputs\flutter-apk\app-release.apk

# 4. Copy ke HP dan install
# 5. SELESAI! Tinggal pakai sehari-hari
```

---

## 💡 REKOMENDASI

**Untuk Pemakaian Sehari-hari:**
→ Gunakan **CARA 1** (Build APK)
→ Lebih praktis dan cepat
→ Tidak perlu buka VS Code setiap kali

**Untuk Development/Testing:**
→ Gunakan **CARA 2** (Flutter Run)
→ Cocok kalau masih mau edit kode
→ Bisa hot reload
