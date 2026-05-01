import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/ayat.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/quran_number_marker.dart';

class DetailSuratScreen extends StatefulWidget {
  final int nomorSurat;
  final int? initialAyat;

  const DetailSuratScreen({super.key, required this.nomorSurat, this.initialAyat});

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  late Future<SurahDetail> futureSurahDetail;
  bool _isMushafMode = false;
  int? _lastReadAyat;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayatKeys = {};

  @override
  void initState() {
    super.initState();
    futureSurahDetail = ApiService.getDetailSurat(widget.nomorSurat);
    _loadLastRead();
    
    // Jika ada initialAyat, kita akan scroll setelah data dimuat di FutureBuilder
  }

  Future<void> _loadLastRead() async {
    final lastRead = await BookmarkService.getLastRead();
    if (mounted && lastRead['surah'] == widget.nomorSurat) {
      setState(() {
        _lastReadAyat = lastRead['ayat'];
      });
    }
  }

  void _scrollToAyat(int ayatNumber, {int retryCount = 0}) {
    // Beri waktu sebentar agar ListView merender item-itemnya
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final key = _ayatKeys[ayatNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else if (retryCount < 5) {
        // Jika belum ketemu (mungkin karena lazy loading belum build itemnya), 
        // kita coba scroll sedikit ke bawah untuk memicu build item berikutnya, lalu coba lagi.
        _scrollController.animateTo(
          _scrollController.offset + 500, 
          duration: const Duration(milliseconds: 100), 
          curve: Curves.linear
        ).then((_) => _scrollToAyat(ayatNumber, retryCount: retryCount + 1));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          
          // Inisialisasi keys hanya sekali saat data pertama kali tersedia
          if (_ayatKeys.isEmpty) {
            for (var a in detail.ayat) {
              _ayatKeys[a.nomorAyat] = GlobalKey();
            }
            
            // Jika ada initialAyat, trigger scroll
            if (widget.initialAyat != null && widget.initialAyat! > 0) {
              _scrollToAyat(widget.initialAyat!);
            }
          }

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
      controller: _scrollController,
      cacheExtent: 10000, // Pre-build items dalam rentang 10000 pixel
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: detail.ayat.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 16),
      itemBuilder: (context, index) {
        final ayat = detail.ayat[index];
        return Container(
          key: _ayatKeys[ayat.nomorAyat],
          child: _buildAyatCard(ayat, detail.namaLatin),
        );
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
          if (_lastReadAyat != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark, color: AppColors.primaryYellow, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Terakhir dibaca: Ayat $_lastReadAyat',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyatCard(Ayat ayat, String detailNamaLatin) {
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.primaryGreen, size: 20),
                      onPressed: () {
                        // Implement share
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: AppColors.primaryGreen, size: 24),
                      onPressed: () {
                        // Implement audio
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _lastReadAyat == ayat.nomorAyat ? Icons.bookmark : Icons.bookmark_outline, 
                        color: _lastReadAyat == ayat.nomorAyat ? AppColors.primaryYellow : AppColors.primaryGreen, 
                        size: 20
                      ),
                      onPressed: () async {
                        if (_lastReadAyat == ayat.nomorAyat) {
                          // Jika diklik lagi ayat yang sama, hapus bookmark
                          await BookmarkService.clearLastRead();
                          if (mounted) {
                            setState(() => _lastReadAyat = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Penanda dihapus'),
                                backgroundColor: AppColors.mutedGreen,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        } else {
                          // Jika diklik ayat lain, pindahkan bookmark
                          await BookmarkService.saveLastRead(
                            surah: widget.nomorSurat,
                            surahName: detailNamaLatin,
                            ayat: ayat.nomorAyat,
                          );
                          if (mounted) {
                            setState(() => _lastReadAyat = ayat.nomorAyat);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Penanda dipindahkan ke ayat ${ayat.nomorAyat}'),
                                backgroundColor: AppColors.primaryGreen,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
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
