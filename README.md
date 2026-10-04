# 💈 Rafiqil Barbershop — Aplikasi Manajemen

Aplikasi manajemen barbershop **full-stack (simulasi)** untuk **Rafiqil Barbershop**, dibangun dengan **Flutter (Dart)** dan **antarmuka Bahasa Indonesia**. Aplikasi berjalan tanpa backend nyata — semua data menggunakan **data dummy in-memory** yang di-seed secara otomatis saat pertama kali login, sehingga aplikasi langsung terasa "hidup".

> **Pemilik:** Rafiqil • **Telepon:** +6282211283036 • **Email:** xrafiqil@gmail.com

---

## ✨ Fitur Utama

| Fitur | Keterangan |
|---|---|
| 🔐 **Autentikasi** | Login & logout dengan kredensial demo, status loading, validasi form. |
| 🧭 **Layout Dashboard** | Sidebar navigasi (desktop/tablet) yang otomatis berubah jadi bottom-nav (mobile). |
| 👥 **Pelanggan (CRUD)** | Tambah, lihat, cari, edit, hapus pelanggan + riwayat kunjungan. |
| ✂️ **Layanan (CRUD)** | Kelola jasa barbershop, harga, durasi, status aktif/nonaktif. |
| 🧾 **Transaksi (CRUD)** | Buat transaksi multi-layanan, metode bayar, status (Lunas/Menunggu/Batal), filter. |
| 📅 **Jadwal (CRUD)** | Reservasi pelanggan dengan tanggal/jam, status, dikelompokkan per tanggal. |
| 📊 **Statistik** | Kartu omset, grafik omset 7 hari (fl_chart), layanan terlaris, jadwal mendatang. |

### UI Modern & Polished
- **Empty states** ramah dengan ilustrasi ikon + CTA di setiap daftar kosong.
- **Loading states** berupa skeleton/shimmer (bootstrap data & daftar).
- **Optimistic updates** — perubahan langsung tampil di UI sebelum "jaringan" selesai, dengan rollback bila gagal.
- **Responsive design** — beradaptasi mulus dari layar HP hingga desktop lebar.
- **Realistic demo data** — pelanggan, layanan, ~24 transaksi, dan belasan jadwal di-seed saat first load.

---

## 🔑 Kredensial Demo

```
Email    : admin@rafiqil.com
Password : rafiqil123
```
(Form login sudah terisi otomatis dengan kredensial ini.)

---

## 🚀 Cara Menjalankan

Prasyarat: **Flutter SDK ≥ 3.10** (diuji pada Flutter 3.44 / Dart 3.12).

```bash
cd rafiqil_barbershop
flutter pub get

# Jalankan di Chrome (web)
flutter run -d chrome

# atau di emulator / perangkat Android–iOS
flutter run

# atau desktop (aktifkan dulu bila perlu: flutter config --enable-macos-desktop dll.)
flutter run -d windows   # / macos / linux
```

> Folder platform `web/` sudah disertakan. Untuk Android/iOS/desktop, jalankan sekali:
> `flutter create --platforms=android,ios,windows,macos,linux .` untuk membuat scaffolding platform, lalu `flutter run`.

### Build rilis web
```bash
flutter build web --release
# hasil di build/web
```

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                  # Entry point + AuthGate (login ↔ dashboard) + seed
├── theme/
│   └── app_theme.dart         # Palet warna (charcoal + gold) & ThemeData
├── utils/
│   └── formatters.dart        # Format Rupiah & tanggal Bahasa Indonesia
├── models/                    # Customer, BarberService, BarberTransaction, Schedule, AppUser
├── data/
│   └── seed_data.dart         # Data demo realistis
├── providers/
│   ├── auth_provider.dart     # Status login/logout
│   └── data_provider.dart     # "Backend palsu" in-memory + statistik + CRUD optimistic
├── widgets/                   # EmptyState, ShimmerSkeleton, StatusBadge, StatCard, dll.
└── screens/
    ├── auth/                  # Login (split-panel branding di desktop)
    ├── dashboard/             # AppShell (sidebar) + Dashboard (stats & chart)
    ├── customers/             # Daftar + form pelanggan
    ├── services/              # Grid + form layanan
    ├── transactions/          # Daftar + form transaksi
    └── schedules/             # Daftar (grup tanggal) + form jadwal
```

---

## 🏗️ Arsitektur

- **State management:** [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier`) — ringan, tanpa codegen.
- **`DataProvider`** berperan sebagai repository in-memory yang **mensimulasikan latensi jaringan** (`Future.delayed`) untuk memunculkan loading & optimistic update yang realistis. Mengganti ke API/database nyata cukup dengan mengganti isi method CRUD di provider ini.
- **`AuthProvider`** memvalidasi kredensial demo dan menyimpan sesi pengguna.
- Tidak ada penyimpanan permanen: data di-reset setiap aplikasi dimulai ulang (sesuai permintaan "data dummy, tanpa database").

---

## 📦 Dependensi

`provider`, `intl`, `uuid`, `google_fonts`, `fl_chart`.

---

## ✅ Status Verifikasi

`flutter analyze` & `dart analyze` → **No errors** (hanya saran gaya `prefer_const` opsional).
Seluruh kode berhasil dikompilasi ke kernel (front-end compiler Flutter).


https://rafiqil.github.io/rafiqil_barbershop/
