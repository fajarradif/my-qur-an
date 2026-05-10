import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../theme/colors.dart';
import '../models/ayat.dart';
import '../models/surah.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import '../services/bookmark_service.dart';
import '../widgets/quran_number_marker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../main.dart'; 

class DetailSuratScreen extends StatefulWidget {
  final int nomorSurat;
  final int? initialAyat;

  const DetailSuratScreen({super.key, required this.nomorSurat, this.initialAyat});

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  late int _currentNomor;
  late Future<SurahDetail> futureSurahDetail;
  late Future<List<Surah>> futureSurahList;
  bool _isMushafMode = false;
  bool _showLatin = true;
  bool _showTranslation = true;
  int? _lastReadAyat;
  int? _pendingScrollAyat;
  
  String _selectedQori = '05'; 
  final Map<String, String> _qoriNames = {
    '01': 'Abdullah Al-Juhany',
    '02': 'Abdul Muhsin Al-Qasim',
    '03': 'Abdurrahman as-Sudais',
    '04': 'Ibrahim Al-Dossari',
    '05': 'Misyari Rasyid',
  };
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _surahBarController = ScrollController();
  final Map<int, GlobalKey> _ayatKeys = {};

  @override
  void initState() {
    super.initState();
    _currentNomor = widget.nomorSurat;
    _pendingScrollAyat = widget.initialAyat;
    _loadSurahData();
    futureSurahList = ApiService.getSuratList();
    _loadLastRead();
    
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) MyQuranApp.settingsOf(context).addListener(_onSettingsChanged);
      _scrollToActiveSurah();
    });
  }

  void _loadSurahData() {
    futureSurahDetail = ApiService.getDetailSurat(_currentNomor).then((detail) {
      if (_pendingScrollAyat != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _scrollToAyat(_pendingScrollAyat!);
            _pendingScrollAyat = null;
          }
        });
      }
      return detail;
    });
  }

  void _changeSurah(int nomor, {int? targetAyat}) {
    if (nomor == _currentNomor) {
      if (targetAyat != null) _scrollToAyat(targetAyat);
      return;
    }
    setState(() {
      _currentNomor = nomor;
      _pendingScrollAyat = targetAyat;
      _loadSurahData();
      _ayatKeys.clear();
      _lastReadAyat = null; 
    });
    _loadLastRead();
    _scrollToActiveSurah();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _scrollToActiveSurah() {
    double target = (_currentNomor - 1) * 90.0 - (MediaQuery.of(context).size.width / 2) + 45;
    if (_surahBarController.hasClients) {
      _surahBarController.animateTo(
        target.clamp(0.0, _surahBarController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    try { MyQuranApp.settingsOf(context).removeListener(_onSettingsChanged); } catch (_) {}
    _audioPlayer.dispose();
    _scrollController.dispose();
    _surahBarController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final lastRead = await BookmarkService.getLastRead();
    if (mounted) {
      setState(() {
        if (lastRead['surah'] == _currentNomor) {
          _lastReadAyat = lastRead['ayat'];
        } else {
          _lastReadAyat = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.primaryGreen,
        elevation: 0,
        centerTitle: false, // Digeser ke kiri
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<SurahDetail>(
          future: futureSurahDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                children: [
                  Text(snapshot.data!.namaLatin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(snapshot.data!.arti, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              );
            }
            return const Text('Memuat...', style: TextStyle(color: Colors.white));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isMushafMode ? Icons.list_alt : Icons.menu_book, color: Colors.white),
            onPressed: () => setState(() => _isMushafMode = !_isMushafMode),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => _showSurahSettings(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSurahSelectorBar(),
          Expanded(
            child: FutureBuilder<SurahDetail>(
              future: futureSurahDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                }
                final detail = snapshot.data!;
                return _isMushafMode ? _buildMushafView(detail) : _buildListView(detail);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahSelectorBar() {
    return FutureBuilder<List<Surah>>(
      future: futureSurahList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 55);
        final surahs = snapshot.data!;
        return Container(
          height: 55,
          color: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.primaryGreen,
          child: ListView.builder(
            controller: _surahBarController,
            scrollDirection: Axis.horizontal,
            itemCount: surahs.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final s = surahs[index];
              final isActive = s.nomor == _currentNomor;
              return GestureDetector(
                onTap: () => _changeSurah(s.nomor),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive ? Border.all(color: Colors.white38) : null,
                  ),
                  child: Center(
                    child: Text(
                      s.namaLatin,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white60,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(SurahDetail detail) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: detail.ayat.length + 1, 
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(detail);
        
        final ayat = detail.ayat[index - 1];
        _ayatKeys[ayat.nomorAyat] = GlobalKey();

        return Column(
          key: _ayatKeys[ayat.nomorAyat],
          children: [
            if (index == 1 && detail.nomor != 1 && detail.nomor != 9)
              _buildBismillah(),
            _buildAyatItem(ayat, detail),
            const Divider(height: 1, thickness: 0.5),
          ],
        );
      },
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
          style: TextStyle(
            color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen,
            fontSize: 28,
            fontFamily: 'QuranFont',
          ),
        ),
      ),
    );
  }

  Widget _buildAyatItem(Ayat ayat, SurahDetail surah) {
    final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    final isThisAyat = currentItem != null && currentItem.extras?['ayatNo'] == ayat.nomorAyat && currentItem.extras?['surahNo'] == _currentNomor;
    
    final isPlaying = _audioPlayer.playing && isThisAyat && _audioPlayer.processingState != ProcessingState.completed;
    
    final isBookmarked = _lastReadAyat == ayat.nomorAyat;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuranNumberMarker(
                number: ayat.nomorAyat.toString(),
                size: 32,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppColors.primaryGreen, size: 18),
                onPressed: () => _copyAyat(ayat, surah), 
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline, color: AppColors.primaryGreen, size: 22),
                onPressed: () => _playAudio(ayat.nomorAyat, ayat.audio[_selectedQori]!),
              ),
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? AppColors.primaryYellow : AppColors.primaryGreen, size: 20),
                onPressed: () => _saveLastRead(ayat.nomorAyat, surah),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ayat.teksArab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 28,
              fontFamily: 'QuranFont',
              height: 1.8,
            ),
          ),
          if (_showLatin) ...[
            const SizedBox(height: 12),
            Text(
              ayat.teksLatin,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (_showTranslation) ...[
            const SizedBox(height: 8),
            Text(
              ayat.teksIndonesia,
              style: TextStyle(
                color: AppColors.text2(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMushafView(SurahDetail detail) {
    List<InlineSpan> spans = [];
    
    for (var ayat in detail.ayat) {
      spans.add(TextSpan(
        text: ayat.teksArab,
        style: TextStyle(
          color: AppColors.isDark(context) ? Colors.white.withOpacity(0.9) : Colors.black87,
          fontSize: 28,
          fontFamily: 'QuranFont',
          height: 1.8,
        ),
      ));
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: QuranNumberMarker(number: ayat.nomorAyat.toString(), size: 28),
        ),
      ));
    }

    return _buildMushafFrame(
      surahName: detail.nama,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (detail.nomor != 1 && detail.nomor != 9)
             _buildBismillah(),
          Text.rich(
            TextSpan(children: spans),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildMushafFrame({required Widget child, required String surahName}) {
    final isDark = AppColors.isDark(context);
    final goldColor = isDark ? AppColors.darkGold : const Color(0xFFC5A358);
    final frameColor = isDark ? AppColors.darkSurface : const Color(0xFFFDF7E7);
    
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: frameColor,
        border: Border.all(color: goldColor, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: goldColor.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: goldColor.withOpacity(0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الجزء ١', style: TextStyle(color: Color(0xFFC5A358), fontSize: 11, fontWeight: FontWeight.bold)),
                Text(surahName, style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'QuranFont')),
                const Text('١', style: TextStyle(color: Color(0xFFC5A358), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildHeader(SurahDetail detail) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/islamic_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.2, 
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(detail.tempatTurun.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${detail.jumlahAyat} AYAT', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              detail.nama, 
              style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'QuranFont'),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Text(
            detail.arti, 
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  void _showSurahSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = AppColors.isDark(context);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildSettingsTile(
                          icon: isDark ? Icons.light_mode : Icons.dark_mode,
                          label: isDark ? 'Mode Terang' : 'Mode Gelap',
                          onTap: () {
                            MyQuranApp.of(context).toggleTheme();
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSettingsTile(
                          icon: Icons.bookmark,
                          label: 'Ke Penanda',
                          onTap: () async {
                            Navigator.pop(context);
                            final lastRead = await BookmarkService.getLastRead();
                            if (lastRead['surah'] != 0) {
                              _changeSurah(lastRead['surah'], targetAyat: lastRead['ayat']);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildToggleRow('Tampilkan Latin', _showLatin, (v) {
                    setState(() => _showLatin = v);
                    setModalState(() {});
                  }),
                  _buildToggleRow('Tampilkan Terjemahan', _showTranslation, (v) {
                    setState(() => _showTranslation = v);
                    setModalState(() {});
                  }),
                  
                  const Divider(height: 32),
                  
                  Text('Pilih Imam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text1(context))),
                  const SizedBox(height: 12),
                  ..._qoriNames.entries.map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value, style: TextStyle(color: AppColors.text1(context), fontSize: 14)),
                    trailing: _selectedQori == e.key ? const Icon(Icons.check_circle, color: AppColors.primaryGreen) : null,
                    onTap: () {
                      setState(() => _selectedQori = e.key);
                      setModalState(() {});
                    },
                  )).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppColors.text1(context), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.text1(context))),
        Switch(
          value: value,
          activeColor: AppColors.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _scrollToAyat(int ayatNumber) {
    if (!mounted) return;
    
    final key = _ayatKeys[ayatNumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(seconds: 1), curve: Curves.easeInOut, alignment: 0.1);
    } else {
      double estimation = (ayatNumber - 1) * 350.0; 
      double maxScroll = _scrollController.position.maxScrollExtent;
      
      _scrollController.animateTo(
        estimation.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          final retryKey = _ayatKeys[ayatNumber];
          if (retryKey != null && retryKey.currentContext != null) {
             Scrollable.ensureVisible(retryKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.1);
          }
        });
      });
    }
  }

  void _copyAyat(Ayat ayat, SurahDetail surah) {
    final textToCopy = "${ayat.teksArab}\n\n${ayat.teksIndonesia}\n\n(QS. ${surah.namaLatin}: ${ayat.nomorAyat})";
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayat tersalin ke papan klip'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _playAudio(int ayatNo, String audioUrl) async {
    try {
      final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      final isThisAyat = currentItem != null && currentItem.extras?['ayatNo'] == ayatNo && currentItem.extras?['surahNo'] == _currentNomor;

      if (isThisAyat) {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
        } else {
          if (_audioPlayer.processingState == ProcessingState.completed) {
            await _audioPlayer.seek(Duration.zero);
          }
          await _audioPlayer.play();
        }
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioUrl,
          album: "My Quran",
          title: "Ayat $ayatNo",
          artist: _qoriNames[_selectedQori] ?? "Unknown",
          extras: {'ayatNo': ayatNo, 'surahNo': _currentNomor},
        ),
      ));
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  void _saveLastRead(int ayatNo, SurahDetail surah) async {
    await BookmarkService.saveLastRead(surah: surah.nomor, ayat: ayatNo, surahName: surah.namaLatin);
    _loadLastRead(); 
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tersalin di Terakhir Baca')));
  }
}