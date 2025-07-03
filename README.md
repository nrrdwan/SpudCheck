# 🥔 SpudCheck

**SpudCheck** adalah aplikasi AI berbasis Flutter untuk mendeteksi kondisi kentang melalui citra gambar. Aplikasi ini memanfaatkan model TensorFlow Lite untuk klasifikasi dan diagnosis otomatis kondisi kentang, serta memberikan informasi terkait penyakit, penyebab, hingga solusi penanganan.

> 🌱 Solusi cerdas untuk petani modern — deteksi cepat, hasil akurat.

---

## 🚀 Fitur Utama

- 🔍 **Deteksi Penyakit Kentang Otomatis**  
  Unggah atau ambil foto kentang, dan sistem akan mengidentifikasi jenis serta status kesehatannya.

- 📋 **Deskripsi Lengkap & Solusi**  
  Menampilkan detail penyakit, penyebab, tingkat penularan, serta langkah penanganan berdasarkan hasil deteksi.

- 🎨 **UI Modern & Responsif**  
  Desain antarmuka adaptif dengan dukungan mode terang dan gelap.

- 🖥️ **Dukungan Multi-Platform**  
  Dibangun dengan Flutter, mendukung Android, iOS, Web, Windows, Linux, dan macOS.

---

## ⚙️ Instalasi

### 📌 Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code / Xcode (disesuaikan dengan target platform)

### 💻 Clone & Setup

```bash
git clone https://github.com/username/spudcheck.git
cd spudcheck
flutter pub get
```

### ▶️ Menjalankan Aplikasi

```bash
flutter run
```

### 📦 Build Aplikasi

- **Android:**
  ```bash
  flutter build apk
  ```

- **iOS:**
  ```bash
  flutter build ios
  ```

- **Web:**
  ```bash
  flutter build web
  ```

- **Desktop (Windows/Linux/macOS):**
  ```bash
  flutter build windows
  flutter build linux
  flutter build macos
  ```

---

## 🗂️ Struktur Proyek

```bash
spudcheck/
├── lib/
│   ├── main.dart              # Entry point aplikasi & konfigurasi awal
│   ├── service.dart           # Integrasi model TFLite & logika klasifikasi
│   ├── splash_screen.dart     # Tampilan splash screen awal
├── assets/
│   ├── model_kentang.tflite   # Model AI untuk klasifikasi kentang
│   ├── labels.txt             # Daftar label klasifikasi
│   ├── kentang_deskripsi.json# Informasi penyakit & deskripsi klasifikasi
│   ├── spudcheck.png          # Logo aplikasi
│   └── spudcheckawal.png      # Gambar pendukung halaman awal
```

---

## 🧠 Teknologi yang Digunakan

- **Flutter & Dart** — Framework UI lintas platform  
- **TensorFlow Lite** — Model klasifikasi gambar ringan  
- **Image Picker & TFLite Flutter** — Pengambilan gambar & inference AI  
- **JSON Parsing** — Deskripsi klasifikasi yang dinamis dan terstruktur

---

## 🙌 Kontribusi

Kami menyambut kontribusi Anda!

1. Buka *Issue Tracker* untuk melaporkan bug atau request fitur.  
2. *Fork* repo ini dan buat *pull request* untuk perubahan kode.  
3. Pastikan perubahan Anda sudah teruji & terdokumentasi dengan baik.

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).  
Silakan gunakan, modifikasi, dan distribusikan dengan tetap mencantumkan atribusi yang sesuai.

---

## 📢 Tentang Proyek

SpudCheck dikembangkan sebagai bagian dari inisiatif untuk memberdayakan petani dengan teknologi AI berbasis mobile. Kami percaya teknologi dapat menyederhanakan diagnosa tanaman dan meningkatkan produktivitas pertanian secara berkelanjutan.

---

**SpudCheck** — *AI-powered potato detection for smarter farming.*
