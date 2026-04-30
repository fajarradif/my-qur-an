import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/tahlil.dart';
import '../models/ayat.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../widgets/quran_number_marker.dart';

class TahlilScreen extends StatefulWidget {
  const TahlilScreen({super.key});

  @override
  State<TahlilScreen> createState() => _TahlilScreenState();
}

class _TahlilScreenState extends State<TahlilScreen> {
  late Future<List<Tahlil>> futureTahlil;
  late Future<SurahDetail> futureYasin;
  bool _isMushafMode = false;

  @override
  void initState() {
    super.initState();
    futureTahlil = ApiService.getTahlilList();
    futureYasin = ApiService.getDetailSurat(36); // Surah Yasin
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.deepGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isMushafMode ? 'Mode Lafadz' : 'Tahlil & Yasin',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isMushafMode ? Icons.list_alt : Icons.menu_book,
                color: Colors.white,
              ),
              tooltip: _isMushafMode ? 'Mode Detail' : 'Mode Lafadz',
              onPressed: () {
                setState(() {
                  _isMushafMode = !_isMushafMode;
                });
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.iconBgGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primaryYellow,
                ),
                labelColor: AppColors.deepGreen,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Tahlil'),
                  Tab(text: 'Yasin'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTahlilTab(),
            _buildYasinTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTahlilTab() {
    return FutureBuilder<List<Tahlil>>(
      future: futureTahlil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), () {
            setState(() => futureTahlil = ApiService.getTahlilList());
          });
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Data Tahlil tidak tersedia'));
        }

        final tahlilData = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tahlilData.length,
          itemBuilder: (context, index) {
            return _isMushafMode 
                ? _buildMushafTahlilCard(tahlilData[index])
                : _buildTahlilCard(tahlilData[index]);
          },
        );
      },
    );
  }

  Widget _buildYasinTab() {
    return FutureBuilder<SurahDetail>(
      future: futureYasin,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), () {
            setState(() => futureYasin = ApiService.getDetailSurat(36));
          });
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Data Yasin tidak tersedia'));
        }

        final yasin = snapshot.data!;
        if (_isMushafMode) {
          return _buildMushafYasinView(yasin);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: yasin.ayat.length,
          itemBuilder: (context, index) {
            final ayat = yasin.ayat[index];
            return _buildAyatCard(ayat.nomorAyat.toString(), ayat.teksArab, ayat.teksLatin, ayat.teksIndonesia);
          },
        );
      },
    );
  }

  Widget _buildMushafTahlilCard(Tahlil tahlil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.iconBgGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        tahlil.arabic,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 28,
          fontFamily: 'QuranFont',
          color: AppColors.textDark,
          height: 2.2,
        ),
      ),
    );
  }

  Widget _buildMushafYasinView(SurahDetail yasin) {
    List<InlineSpan> spans = [];
    for (var a in yasin.ayat) {
      spans.add(
        TextSpan(
          text: '${a.teksArab} ',
          style: const TextStyle(
            fontSize: 26,
            fontFamily: 'QuranFont',
            color: AppColors.textDark,
            height: 2.2,
          ),
        ),
      );
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: QuranNumberMarker(
            number: a.nomorAyat.toString(),
            size: 28,
            isInline: true,
            color: const Color(0xFFC5A358),
          ),
        ),
      );
      spans.add(const TextSpan(text: ' '));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7E7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFC5A358), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'QuranFont',
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(children: spans),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTahlilCard(Tahlil tahlil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.iconBgGreen.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuranNumberMarker(
                number: tahlil.id.toString(),
                color: AppColors.primaryGreen,
                size: 32,
                textStyle: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tahlil.title,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tahlil.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 26,
              fontFamily: 'QuranFont',
              color: AppColors.textDark,
              height: 2.2,
            ),
          ),
          const SizedBox(height: 20),
          if (tahlil.latin.isNotEmpty) ...[
            Text(
              tahlil.latin,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryGreen,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iconBgGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tahlil.translation,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(String number, String arabic, String latin, String translation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.iconBgGreen.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuranNumberMarker(
                number: number,
                color: AppColors.primaryGreen,
                size: 32,
                textStyle: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 10),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.play_circle_outline, color: AppColors.primaryGreen),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 26,
              fontFamily: 'QuranFont',
              color: AppColors.textDark,
              height: 2.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            latin,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryGreen,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iconBgGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              translation,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi kesalahan',
              style: TextStyle(color: AppColors.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedGreen, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
