import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/last_read_card.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import '../widgets/quran_number_marker.dart';
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
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.deepGreen,
        elevation: 0,
        title: const Text('AL-QURAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LastReadCard(onRefresh: () => setState(() {})),
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
            labelColor: AppColors.gold(context),
            unselectedLabelColor: AppColors.muted(context),
            indicatorColor: AppColors.gold(context),
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
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.green(context))),
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
          return Center(child: Text('Tidak ada data surat.', style: TextStyle(color: AppColors.muted(context))));
        }

        final surahs = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti SingleChildScrollView luar
          itemCount: surahs.length, // Menampilkan 114 kotak
          separatorBuilder: (context, index) => Divider(color: AppColors.bg(context), height: 24, thickness: 2),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: QuranNumberMarker(number: surah.nomor.toString()),
              title: Text(surah.namaLatin, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context))),
              // Tambahan informasi jumlah ayat
              subtitle: Text('Ayat: ${surah.jumlahAyat}', style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(surah.nama, style: TextStyle(color: AppColors.gold(context), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'QuranFont')),
                  const SizedBox(width: 16),
                  Icon(Icons.play_circle_fill, color: AppColors.gold(context)),
                ],
              ),
              onTap: () async {
                // Berpindah ke Halaman Detail dengan membawa Data Nomor Surat
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailSuratScreen(nomorSurat: surah.nomor),
                  ),
                );
                if (mounted) {
                  setState(() {
                    // Refresh LastReadCard
                  });
                }
              },
            );
          },
        );
      },
    );
  }
}
