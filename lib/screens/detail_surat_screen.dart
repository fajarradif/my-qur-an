import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';

class DetailSuratScreen extends StatefulWidget {
  final int nomorSurat;

  const DetailSuratScreen({super.key, required this.nomorSurat});

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  late Future<SurahDetail> futureSurahDetail;

  @override
  void initState() {
    super.initState();
    futureSurahDetail = ApiService.getDetailSurat(widget.nomorSurat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tafsir & Ayat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: FutureBuilder<SurahDetail>(
        future: futureSurahDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi Kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data ayat tidak ditemukan.'));
          }

          final detail = snapshot.data!;
          return Column(
            children: [
              _buildHeader(detail),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  itemCount: detail.ayat.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 16),
                  itemBuilder: (context, index) {
                    return _buildAyatCard(detail.ayat[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SurahDetail detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(detail.namaLatin, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detail.arti, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(detail.tempatTurun, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.circle, size: 6, color: Colors.white54),
              ),
              Text('${detail.jumlahAyat} AYAT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(ayat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ayat Nomor & Action
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    ayat.nomorAyat.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.share, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 16),
                    Icon(Icons.play_arrow, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 16),
                    Icon(Icons.bookmark_outline, color: AppColors.primaryGreen, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Ayat Arab Text - Right Aligned
          Text(
            ayat.teksArab,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          // Teks Latin & Terjemahan
          Text(
            ayat.teksLatin,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryGreen,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ayat.teksIndonesia,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedGreen,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
