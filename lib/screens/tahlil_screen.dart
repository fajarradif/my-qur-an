import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/tahlil.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/quran_number_marker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../main.dart';
import 'dart:ui';

class TahlilScreen extends StatefulWidget {
  const TahlilScreen({super.key});

  @override
  State<TahlilScreen> createState() => _TahlilScreenState();
}

class _TahlilScreenState extends State<TahlilScreen> {
  late Future<List<Tahlil>> futureTahlil;
  late Future<SurahDetail> futureYasin;
  bool _isMushafMode = false;
  int? _lastReadAyat;
  int? _playingAyat;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureTahlil = ApiService.getTahlilList();
    futureYasin = ApiService.getDetailSurat(36); // Surah Yasin
    _loadLastRead();
    
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted && state.processingState == ProcessingState.completed) {
        setState(() => _playingAyat = null);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int ayatNo, String audioUrl) async {
    try {
      if (_playingAyat == ayatNo) {
        await _audioPlayer.stop();
        setState(() => _playingAyat = null);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setAudioSource(AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: audioUrl,
            album: "My Quran",
            title: "Ayat Yasin $ayatNo",
            artist: "Misyari Rasyid",
            artUri: Uri.parse('https://images.unsplash.com/photo-1584286595398-a59f21d313f5?q=80&w=1000&auto=format&fit=crop'),
          ),
        ));
        await _audioPlayer.play();
        setState(() => _playingAyat = ayatNo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadLastRead() async {
    final lastRead = await BookmarkService.getLastRead();
    if (mounted && lastRead['surah'] == 36) {
      setState(() {
        _lastReadAyat = lastRead['ayat'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyQuranApp.of(context).isDarkMode;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isMushafMode 
                ? MyQuranApp.settingsOf(context).t('Mode Lafadz', 'Text Only Mode') 
                : 'Tahlil & Yasin',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  MyQuranApp.of(context).toggleTheme();
                });
              },
            ),
            IconButton(
              icon: Icon(_isMushafMode ? Icons.list_alt : Icons.menu_book, color: Colors.white),
              onPressed: () => setState(() => _isMushafMode = !_isMushafMode),
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryYellow,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.primaryYellow,
            tabs: [
              Tab(text: MyQuranApp.settingsOf(context).t('TAHLIL', 'TAHLIL')),
              Tab(text: MyQuranApp.settingsOf(context).t('SURAH YASIN', 'SURAH YASIN')),
            ],
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
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: AppColors.text1(context))));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(MyQuranApp.settingsOf(context).t('Data Tahlil tidak tersedia', 'Tahlil data not available'), style: TextStyle(color: AppColors.text1(context))));
        }

        final tahlilData = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tahlilData.length,
          itemBuilder: (context, index) {
            final tahlil = tahlilData[index];
            return _isMushafMode 
                ? _buildMushafTahlilCard(tahlil)
                : _buildTahlilCard(tahlil);
          },
        );
      },
    );
  }

  Widget _buildTahlilCard(Tahlil tahlil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(AppColors.isDark(context) ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _getTahlilTitle(tahlil.title),
            style: TextStyle(
              color: AppColors.gold(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tahlil.arabic,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 26,
              fontFamily: 'QuranFont',
              height: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tahlil.translation,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafTahlilCard(Tahlil tahlil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold(context).withOpacity(0.3), width: 1),
      ),
      child: Text(
        tahlil.arabic,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 28,
          fontFamily: 'QuranFont',
          color: AppColors.text1(context),
          height: 2.2,
        ),
      ),
    );
  }

  Widget _buildYasinTab() {
    return FutureBuilder<SurahDetail>(
      future: futureYasin,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: AppColors.text1(context))));
        } else if (!snapshot.hasData) {
          return Center(child: Text(MyQuranApp.settingsOf(context).t('Data Yasin tidak tersedia', 'Yasin data not available'), style: TextStyle(color: AppColors.text1(context))));
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

  Widget _buildAyatCard(String nomor, String arab, String latin, String terjemahan) {
    final bool isCurrentBookmark = _lastReadAyat == int.tryParse(nomor);
    final bool isPlaying = _playingAyat == int.tryParse(nomor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(AppColors.isDark(context) ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: isCurrentBookmark ? Border.all(color: AppColors.primaryYellow, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuranNumberMarker(
                  number: nomor,
                  size: 24,
                  color: isCurrentBookmark 
                    ? AppColors.primaryYellow 
                    : (AppColors.isDark(context) ? AppColors.gold(context) : AppColors.primaryGreen),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  arab,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 26,
                    fontFamily: 'QuranFont',
                    height: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  latin,
                  style: TextStyle(color: AppColors.gold(context), fontSize: 14, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text(
                  terjemahan,
                  style: TextStyle(color: AppColors.text2(context), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafYasinView(SurahDetail yasin) {
    List<InlineSpan> spans = [];
    for (var a in yasin.ayat) {
      final bool isCurrentBookmark = _lastReadAyat == a.nomorAyat;
      spans.add(
        TextSpan(
          text: '${a.teksArab} ',
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'QuranFont',
            color: AppColors.text1(context),
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
            color: isCurrentBookmark 
              ? AppColors.primaryYellow 
              : (AppColors.isDark(context) ? AppColors.gold(context) : AppColors.primaryGreen),
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
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold(context).withOpacity(0.3), width: 1),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: spans),
        ),
      ),
    );
  }

  String _getTahlilTitle(String originalTitle) {
    if (MyQuranApp.settingsOf(context).language == 'id') return originalTitle;
    
    final Map<String, String> translations = {
      'Tawasul Nabi Muhammad ﷺ': 'Tawassul to Prophet Muhammad ﷺ',
      'Tawasul Para Nabi & Ulama': 'Tawassul to Prophets & Scholars',
      'Tawasul Ahli Kubur': 'Tawassul to Inhabitants of the Grave',
      'Tawasul Khusus Arwah': 'Special Tawassul for Souls',
      'Surah Al-Ikhlas (3x)': 'Surah Al-Ikhlas (3x)',
      'Tahlil & Takbir': 'Tahlil & Takbir',
      'Surah Al-Falaq': 'Surah Al-Falaq',
      'Surah An-Nas': 'Surah An-Nas',
      'Surah Al-Fatihah': 'Surah Al-Fatihah',
      'Surah Al-Baqarah 1-5': 'Surah Al-Baqarah 1-5',
      'Surah Al-Baqarah 163': 'Surah Al-Baqarah 163',
      'Ayat Kursi': 'Ayat al-Kursi',
      'Istighfar (3x)': 'Istighfar (3x)',
      'Tahlil Afdaludz Dzikri': 'Tahlil (Afdhaluz Dzikri)',
      'Tahlil Hayyun Ma\'bud': 'Tahlil (Hayyun Ma\'bud)',
      'Tahlil Hayyun Baq': 'Tahlil (Hayyun Baq)',
      'Tahlil (100x)': 'Tahlil (100x)',
      'Sholawat (2x)': 'Salawat (2x)',
      'Tasbih (7x)': 'Tasbih (7x)',
      'Tasbih Subhanallah (33x)': 'Tasbih (33x)',
      'Sholawat Kamilah': 'Salawat Kamilah',
      'Doa Tahlil (Pembuka)': 'Tahlil Prayer (Opening)',
      'Doa Tahlil (Sampaikan Pahala)': 'Tahlil Prayer (Dedication)',
      'Doa Ampunan Ahli Kubur': 'Prayer for Forgiveness of the Deceased',
      'Doa Penutup': 'Closing Prayer',
    };
    
    return translations[originalTitle] ?? originalTitle;
  }
}
