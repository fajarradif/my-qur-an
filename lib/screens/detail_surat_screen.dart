import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/ayat.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../widgets/quran_number_marker.dart';

class DetailSuratScreen extends StatefulWidget {
  final int nomorSurat;

  const DetailSuratScreen({super.key, required this.nomorSurat});

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  late Future<SurahDetail> futureSurahDetail;
  bool _isMushafMode = false;

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
        title: Text(_isMushafMode ? 'Mushaf Mode' : 'Tafsir & Ayat', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        actions: [
          IconButton(
            icon: Icon(
              _isMushafMode ? Icons.list_alt : Icons.menu_book,
              color: AppColors.primaryGreen,
            ),
            tooltip: _isMushafMode ? 'Mode Tafsir' : 'Mode Mushaf',
            onPressed: () {
              setState(() {
                _isMushafMode = !_isMushafMode;
              });
            },
          ),
        ],
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
              // Sembunyikan header card jika di Mode Mushaf untuk memberi ruang maksimal
              if (!_isMushafMode) _buildHeader(detail),
              if (!_isMushafMode) const SizedBox(height: 16),
              Expanded(
                child: _isMushafMode ? _buildMushafView(detail) : _buildTafsirView(detail),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTafsirView(SurahDetail detail) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: detail.ayat.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 16),
      itemBuilder: (context, index) {
        return _buildAyatCard(detail.ayat[index]);
      },
    );
  }

  Widget _buildMushafView(SurahDetail detail) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sesuaikan ukuran font berdasarkan lebar layar (responsif)
        final double fontSize = constraints.maxWidth < 400 ? 22 : 26;
        final double bismillahSize = constraints.maxWidth < 400 ? 24 : 30;
        
        List<InlineSpan> spans = [];

        for (var a in detail.ayat) {
          // Tambahkan teks ayat
          spans.add(
            TextSpan(
              text: '${a.teksArab} ',
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'QuranFont',
                color: AppColors.textDark,
                height: 2.2,
                wordSpacing: 2, // Tambahkan sedikit spasi antar kata agar justified lebih rapi
              ),
            ),
          );
          
          // Tambahkan penanda ayat (inline)
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: QuranNumberMarker(
                number: a.nomorAyat.toString(),
                size: fontSize * 1.1, // Proporsional dengan font
                isInline: true,
                color: const Color(0xFFC5A358),
              ),
            ),
          );
          
          // Beri spasi setelah marker
          spans.add(const TextSpan(text: ' '));
        }

        return _buildMushafFrame(
          surahName: detail.nama,
          child: ListView( // Gunakan ListView agar area scroll lebih stabil
            padding: EdgeInsets.zero,
            children: [
              // Bismillah dipisah agar tidak merusak rata kanan-kiri body utama
              if (detail.nomor != 9 && detail.nomor != 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8),
                  child: Text(
                    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bismillahSize,
                      fontFamily: 'QuranFont',
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              
              // Body Ayat dengan RichText Justified
              Text.rich(
                TextSpan(children: spans),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                softWrap: true,
              ),
              const SizedBox(height: 40), // Ruang di bawah halaman
            ],
          ),
        );
      },
    );
  }

  Widget _buildMushafFrame({required Widget child, required String surahName}) {
    const goldColor = Color(0xFFC5A358);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7E7),
        border: Border.all(color: goldColor, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          children: [
            // Header Mushaf
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.05),
                border: Border(bottom: BorderSide(color: goldColor.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الجزء ١', style: TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(surahName, style: const TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'QuranFont')),
                  const Text('١', style: TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: child,
              ),
            ),
            // Footer Mushaf
            Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: goldColor.withValues(alpha: 0.1))),
              ),
            ),
          ],
        ),
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
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
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

  Widget _buildAyatCard(Ayat ayat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuranNumberMarker(
                  number: ayat.nomorAyat.toString(),
                  color: AppColors.primaryGreen,
                  size: 36,
                  textStyle: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
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
          Text(
            ayat.teksArab,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'QuranFont',
              color: AppColors.textDark,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 16),
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
