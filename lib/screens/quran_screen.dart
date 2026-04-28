import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/last_read_card.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import 'detail_surat_screen.dart'; // import detail

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> futureSurahs;

  @override
  void initState() {
    super.initState();
    // Meminta Service API untuk mulai mendownload data saat halaman ini dibuka
    futureSurahs = ApiService.getSuratList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUR\'AN', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const LastReadCard(),
            const SizedBox(height: 24),
            _buildTabBar(context),
            const SizedBox(height: 16),
            _buildSurahList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primaryYellow,
            unselectedLabelColor: AppColors.mutedGreen,
            indicatorColor: AppColors.primaryYellow,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Surah'),
              Tab(text: 'Para'),
              Tab(text: 'Page'),
              Tab(text: 'Hijb'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    // Scaffold Data via FutureBuilder untuk animasi Loading otomatis
    return FutureBuilder<List<Surah>>(
      future: futureSurahs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Ketika proses download JSON sedang berjalan, tampilkan muter-muter
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          );
        } else if (snapshot.hasError) {
          // Jika tidak ada koneksi/error, tampilkan warna merah
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Gagal memuat data: \n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data surat.'));
        }

        final surahs = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti SingleChildScrollView luar
          itemCount: surahs.length, // Menampilkan 114 kotak
          separatorBuilder: (context, index) => const Divider(color: AppColors.background, height: 24, thickness: 2),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Stack(
                alignment: Alignment.center,
                children: [
                   const Icon(Icons.star_border, color: AppColors.primaryYellow, size: 40),
                   Text(
                     surah.nomor.toString(), // Nomor Surat asli dari Equran
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                   ),
                ],
              ),
              title: Text(surah.namaLatin, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              // Tambahan informasi jumlah ayat
              subtitle: Text('Ayat: ${surah.jumlahAyat}', style: const TextStyle(color: AppColors.mutedGreen, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(surah.nama, style: const TextStyle(color: AppColors.primaryYellow, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Icon(Icons.play_circle_fill, color: AppColors.primaryYellow),
                ],
              ),
              onTap: () {
                // Berpindah ke Halaman Detail dengan membawa Data Nomor Surat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailSuratScreen(nomorSurat: surah.nomor),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
