# Blueprint Aplikasi: MyQuran

## 1. Tema dan Nama Aplikasi
- **Nama Aplikasi:** MyQuran
- **Tema:** Agama & Gaya Hidup (Religi)
- **Deskripsi:** Aplikasi Al-Quran digital berbasis mobile yang memiliki desain antarmuka (UI) yang elegan, modern, dan tidak terlalu ramai, sehingga menawarkan kenyamanan maksimal untuk penggunanya saat membaca ayat-ayat Al-Quran.

## 2. Daftar Fitur Aplikasi
- **Membaca Al-Quran:** Menampilkan Surah dan Juz dengan teks Arab yang jelas.
- **Terjemahan dan Tafsir:** Menyediakan terjemahan dalam Bahasa Indonesia serta tafsir tiap ayat.
- **Audio Murottal:** Fitur memutar audio bacaan Al-Quran dari berbagai Qari terkemuka.
- **Penanda Bacaan (Bookmark):** Memudahkan pengguna menyimpan ayat terakhir yang dibaca.
- **Jadwal Sholat:** Menampilkan jadwal sholat secara *real-time* berdasarkan lokasi pengguna.
- **Arah Kiblat:** Kompas navigasi yang akurat untuk menentukan arah kiblat.

## 3. Desain (Layout/UI)
- **Konsep:** Clean, Elegan, dan Minimalis.
- **Warna: ** Penggunaan palet warna hijau gelap (Dark Green) dan perpaduan emas (Gold) atau putih untuk mendukung konsep yang eksklusif dan nyaman di mata (terutama fitur Dark Mode).
- **Tipografi:** Menggunakan font Sans-Serif modern untuk antarmuka umum dan Khat Utsmani yang standar untuk teks ayat Al-Quran.

## 4. Rencana Kerja Aplikasi (Timeline Pengembangan)
- **Minggu 1:** Inisiasi proyek, penyiapan repository Git, penyusunan rancangan/blueprint, dan konsep UI/UX.
- **Minggu 2:** Pembuatan struktur folder Flutter, setup UI/UX untuk Halaman Utama (Dashboard) dan navigasi aplikasi (Bottom Navigation).
- **Minggu 3:** *Slicing* Halaman Daftar Surah dan Halaman Detail Surah (Teks Arab dan Terjemahan).
- **Minggu 4:** Integrasi API Al-Quran (Data Quran dan Audio Murottal).
- **Minggu 5:** Pengembangan fungsionalitas pendukung (Jadwal Sholat, Arah Kiblat, dan Fitur Bookmark).
- **Minggu 6:** Proses Testing, perbaikan bug (Bug Fixing), serta finalisasi *layout* agar tetap elegan dan responsif.
- **Minggu 7:** Persiapan perilisan, pembuatan *assets launcher*, dan pendaftaran ke Google Play Store / Apple App Store (H - 2 Minggu sebelum pelaksanaan UAS).

## 5. Dokumentasi Cara Kerja Aplikasi
1. **Halaman Beranda:** Menampilkan menu utama, waktu sholat berikutnya, serta "Lanjutkan Bacaan" untuk akses cepat ke ayat terakhir yang dibaca pengguna.
2. **Halaman Al-Quran:** Pengguna dapat memilih tampilan per Surah maupun per Juz. Saat di-klik, pengguna akan diarahkan ke detail ayat dan bisa mendengarkan audio per ayat.
3. **Halaman Kiblat:** Menampilkan kompas berdasarkan lokasi GPS *device* ke kakbah.
4. **Halaman Pengaturan:** Pengguna bisa menyesuaikan ukuran teks, tema aplikasi (Terang/Gelap), dan bahasa.

---
*Proyek ini dikembangkan dengan kerangka kerja (framework) **Flutter** sebagai bagian dari pemenuhan Tugas UAS mata kuliah Mobile Programming.*
