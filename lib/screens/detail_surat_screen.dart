import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/ayat.dart';
import '../models/surah_detail.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/quran_number_marker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../main.dart'; // import MyQuranApp

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
  bool _showDetails = false; // Default: Minimalis (Sembunyiin info tambahan)
  int? _lastReadAyat;
  String _selectedQori = '05'; // Default Misyari Rasyid
  final Map<String, String> _qoriNames = {
    '01': 'Abdullah Al-Juhany',
    '02': 'Abdul Muhsin Al-Qasim',
    '03': 'Abdurrahman as-Sudais',
    '04': 'Ibrahim Al-Dossari',
    '05': 'Misyari Rasyid',
  };
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayatKeys = {};

  @override
  void initState() {
    super.initState();
    futureSurahDetail = ApiService.getDetailSurat(widget.nomorSurat);
    _loadLastRead();
    
    // Listen to audio player state untuk update UI secara real-time berdasarkan state mesin
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final lastRead = await BookmarkService.getLastRead();
    if (mounted && lastRead['surah'] == widget.nomorSurat) {
      setState(() {
        _lastReadAyat = lastRead['ayat'];
      });
    }
  }

  Future<void> _playAudio(int ayatNo, String audioUrl) async {
    try {
      final currentMediaItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      // Jika klik ayat yang sama DAN Syekh yang sama dengan yang sedang di-load
      final isCurrentlyLoaded = currentMediaItem?.extras?['ayatNo'] == ayatNo && 
                                currentMediaItem?.extras?['isMurottal'] == false &&
                                currentMediaItem?.extras?['qoriId'] == _selectedQori;

      if (isCurrentlyLoaded) {
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

      // Jika klik ayat baru atau Syekh baru
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioUrl,
          album: "My Quran",
          title: "Ayat $ayatNo",
          artist: _qoriNames[_selectedQori] ?? "Unknown",
          artUri: Uri.parse('https://images.unsplash.com/photo-1584286595398-a59f21d313f5?q=80&w=1000&auto=format&fit=crop'),
          extras: {'ayatNo': ayatNo, 'isMurottal': false, 'qoriId': _selectedQori},
        ),
      ));
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _playMurottal(SurahDetail detail, {bool forcePlay = false}) async {
    try {
      final audioUrl = detail.audioFull[_selectedQori];
      if (audioUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio Murottal tidak tersedia')),
          );
        }
        return;
      }

      final currentMediaItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      final isCurrentlyLoaded = currentMediaItem?.extras?['isMurottal'] == true && 
                                currentMediaItem?.extras?['qoriId'] == _selectedQori &&
                                currentMediaItem?.id == audioUrl;

      // Jika sedang diputar dan bukan force play, maka pause/resume
      if (isCurrentlyLoaded && !forcePlay) {
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

      // Jika klik Play tapi ganti qori/belum diload
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioUrl,
          album: "My Quran Murottal",
          title: "Surah ${detail.namaLatin}",
          artist: _qoriNames[_selectedQori] ?? "Unknown",
          artUri: Uri.parse('https://images.unsplash.com/photo-1584286595398-a59f21d313f5?q=80&w=1000&auto=format&fit=crop'),
          extras: {'isMurottal': true, 'qoriId': _selectedQori},
        ),
      ));
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar murottal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToAyat(int ayatNumber, {int retryCount = 0}) {
    if (!mounted) return;

    final key = _ayatKeys[ayatNumber];

    // Jika widget sudah ter-render (karena masuk dalam cacheExtent), scroll dengan sangat smooth
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn,
      );
    } else if (retryCount < 5) {
      // Jika belum ada, lakukan animasi cepat ke area estimasi
      if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) {
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToAyat(ayatNumber, retryCount: retryCount + 1));
        return;
      }

      // Rata-rata tinggi ayat di surat panjang sekitar 550-600px (Arab + Latin + Terjemah)
      double estimation = (ayatNumber - 1) * 580.0;
      double maxScroll = _scrollController.position.maxScrollExtent;
      double target = estimation.clamp(0.0, maxScroll);
      
      // Animasi cepat (1.2 detik) ke area target
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        // Setelah sampai, panggil lagi untuk mendapatkan posisi presisi via ensureVisible
        _scrollToAyat(ayatNumber, retryCount: retryCount + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: FutureBuilder<SurahDetail>(
          future: futureSurahDetail,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            return Text(
              snapshot.data!.namaLatin,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text1(context), fontSize: 18),
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.bg(context),
        iconTheme: IconThemeData(color: AppColors.green(context)),
        actions: [
          IconButton(
            icon: Icon(
              _showDetails ? Icons.visibility : Icons.visibility_off,
              color: AppColors.green(context),
            ),
            tooltip: _showDetails ? 'Mode Minimalis' : 'Tampilkan Detail',
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
          ),
          FutureBuilder<SurahDetail>(
            future: futureSurahDetail,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.tune, color: AppColors.green(context)),
                tooltip: 'Pengaturan',
                onPressed: () => _showControlPanel(snapshot.data!),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<SurahDetail>(
        future: futureSurahDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.green(context)));
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToAyat(widget.initialAyat!);
              });
            }
          }

          return _isMushafMode 
            ? _buildMushafView(detail) 
            : _buildTafsirView(detail);
        },
      ),
    );
  }

  Widget _buildTafsirView(SurahDetail detail) {
    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 30000,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: detail.ayat.length + 1, // Tambah 1 untuk Header
      separatorBuilder: (context, index) => Divider(color: AppColors.muted(context).withValues(alpha: 0.1), height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(detail);
        }
        final ayat = detail.ayat[index - 1];
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
          final bool isCurrentBookmark = _lastReadAyat == a.nomorAyat;
          
          // Tambahkan anchor key di awal ayat agar scrolling tepat ke awal teks
          spans.add(
            WidgetSpan(child: SizedBox.shrink(key: _ayatKeys[a.nomorAyat])),
          );

          // Tambahkan teks ayat
          spans.add(
            TextSpan(
              text: '${a.teksArab} ',
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'QuranFont',
                color: AppColors.text1(context),
                backgroundColor: isCurrentBookmark ? AppColors.gold(context).withValues(alpha: 0.25) : null,
                height: 2.2,
                wordSpacing: 2, 
              ),
            ),
          );
          
          // Tambahkan penanda ayat (inline) yang bisa diklik
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () async {
                  if (_lastReadAyat == a.nomorAyat) {
                    await BookmarkService.clearLastRead();
                    if (mounted) {
                      setState(() => _lastReadAyat = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Penanda dihapus'), duration: Duration(seconds: 1)),
                      );
                    }
                  } else {
                    await BookmarkService.saveLastRead(
                      surah: widget.nomorSurat,
                      surahName: detail.namaLatin,
                      ayat: a.nomorAyat,
                    );
                    if (mounted) {
                      setState(() => _lastReadAyat = a.nomorAyat);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Penanda dipindahkan ke ayat ${a.nomorAyat}'), duration: const Duration(seconds: 2)),
                      );
                    }
                  }
                },
                child: QuranNumberMarker(
                  number: a.nomorAyat.toString(),
                  size: fontSize * 1.2, 
                  isInline: true,
                  color: isCurrentBookmark ? const Color(0xFF800000) : const Color(0xFFC5A358), // Merah Maroon jika bookmark
                ),
              ),
            ),
          );
          
          // Beri spasi setelah marker
          spans.add(const TextSpan(text: ' '));
        }

        return _buildMushafFrame(
          surahName: detail.nama,
          child: ListView( // Gunakan ListView agar area scroll lebih stabil
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
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
                      color: AppColors.green(context),
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
    final isDark = AppColors.isDark(context);
    final goldColor = isDark ? AppColors.darkGold : const Color(0xFFC5A358);
    final frameColor = isDark ? AppColors.darkSurface : const Color(0xFFFDF7E7);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: frameColor,
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
                  Text('الجزء ١', style: TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(surahName, style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'QuranFont')),
                  Text('١', style: TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
        color: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (AppColors.isDark(context) ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.3),
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

  void _showMurottalSettings(SurahDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
          final isMurottalLoaded = currentItem?.extras?['isMurottal'] == true && currentItem?.id == detail.audioFull[_selectedQori];
          final isMurottalPlaying = isMurottalLoaded && _audioPlayer.playing && _audioPlayer.processingState != ProcessingState.completed;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.muted(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pemutar Murottal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Surah ${detail.namaLatin}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.muted(context),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Qori Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.green(context), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedQori,
                            dropdownColor: AppColors.sf(context),
                            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.green(context)),
                            isExpanded: true,
                            style: TextStyle(color: AppColors.text1(context), fontWeight: FontWeight.w500),
                            items: _qoriNames.entries.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedQori = val;
                                });
                                setModalState(() {}); // Update Modal UI
                                
                                // Sync audio if playing
                                if (isMurottalPlaying || isMurottalLoaded) {
                                  _playMurottal(detail, forcePlay: true);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () => _audioPlayer.seek(
                        Duration(milliseconds: (_audioPlayer.position.inMilliseconds - 10000).clamp(0, 999999999))
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () async {
                        await _playMurottal(detail);
                        setModalState(() {}); // Update Modal UI
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.green(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green(context).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isMurottalPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.forward_30),
                      onPressed: () => _audioPlayer.seek(
                        Duration(milliseconds: (_audioPlayer.position.inMilliseconds + 30000))
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showControlPanel(SurahDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.muted(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pengaturan Bacaan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Menu Items
                _buildMenuTile(
                  icon: Icons.bookmark,
                  title: 'Ke Ayat Terakhir Dibaca',
                  subtitle: _lastReadAyat != null ? 'Ayat $_lastReadAyat' : 'Belum ada penanda',
                  color: AppColors.gold(context),
                  onTap: _lastReadAyat != null ? () {
                    Navigator.pop(context);
                    _scrollToAyat(_lastReadAyat!);
                  } : null,
                ),
                
                _buildMenuTile(
                  icon: Icons.headphones,
                  title: 'Putar Murottal',
                  subtitle: 'Pilih Imam & Kontrol Audio',
                  color: AppColors.green(context),
                  onTap: () {
                    Navigator.pop(context);
                    _showMurottalSettings(detail);
                  },
                ),
                
                _buildMenuTile(
                  icon: AppColors.isDark(context) ? Icons.wb_sunny : Icons.nightlight_round,
                  title: 'Ganti Tema',
                  subtitle: AppColors.isDark(context) ? 'Mode Terang' : 'Mode Gelap',
                  color: Colors.blue,
                  onTap: () {
                    setModalState(() {
                      MyQuranApp.of(context).toggleTheme();
                    });
                  },
                ),
                
                _buildMenuTile(
                  icon: _isMushafMode ? Icons.list_alt : Icons.menu_book,
                  title: 'Mode Tampilan',
                  subtitle: _isMushafMode ? 'Pindah ke Mode Tafsir' : 'Pindah ke Mode Mushaf',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isMushafMode = !_isMushafMode;
                    });
                  },
                ),
                
                const SizedBox(height: 32),
                Text(
                  'Fitur lainnya segera hadir...',
                  style: TextStyle(color: AppColors.muted(context), fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: onTap == null ? AppColors.muted(context) : AppColors.text1(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.muted(context), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildMurottalPlayer(SurahDetail detail) {
    final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    final isMurottalLoaded = currentItem?.extras?['isMurottal'] == true && currentItem?.id == detail.audioFull[_selectedQori];
    final isMurottalPlaying = isMurottalLoaded && _audioPlayer.playing && _audioPlayer.processingState != ProcessingState.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Dropdown Imam
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedQori,
                dropdownColor: AppColors.primaryGreen,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                items: _qoriNames.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedQori = val;
                    });

                    // Jika ada audio yang lagi jalan (baik murottal atau ayat)
                    // Kita otomatis pindahkan ke Syekh yang baru di posisi yang sama
                    if (isMurottalPlaying || isMurottalLoaded) {
                       _playMurottal(detail, forcePlay: true);
                    } else {
                      // Cek apakah ada ayat tunggal yang lagi jalan
                      final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
                      if (currentItem != null && currentItem.extras?['ayatNo'] != null) {
                        int ayatNo = currentItem.extras!['ayatNo'];
                        // Cari data ayatnya untuk ambil URL audio Syekh yang baru
                        try {
                          final ayat = detail.ayat.firstWhere((a) => a.nomorAyat == ayatNo);
                          String? audioUrl = ayat.audio[_selectedQori] ?? ayat.audio.values.firstOrNull;
                          if (audioUrl != null) {
                            _playAudio(ayatNo, audioUrl);
                          }
                        } catch (_) {}
                      }
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Play/Pause Button
          InkWell(
            onTap: () => _playMurottal(detail),
            child: CircleAvatar(
              backgroundColor: AppColors.gold(context),
              radius: 20,
              child: Icon(
                isMurottalPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.isDark(context) ? AppColors.darkBackground : AppColors.primaryGreen,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(Ayat ayat, String detailNamaLatin) {
    final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    final isThisAyatLoaded = currentItem?.extras?['ayatNo'] == ayat.nomorAyat && currentItem?.extras?['isMurottal'] == false;
    final isPlaying = isThisAyatLoaded && _audioPlayer.playing && _audioPlayer.processingState != ProcessingState.completed;

    return GestureDetector(
      onLongPress: () => _showBookmarkDialog(ayat, detailNamaLatin),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuranNumberMarker(
                  number: ayat.nomorAyat.toString(),
                  color: AppColors.green(context),
                  size: 36,
                  textStyle: TextStyle(color: AppColors.green(context), fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ayat.teksArab,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'QuranFont',
                          color: AppColors.text1(context),
                          height: 2.0,
                          backgroundColor: _lastReadAyat == ayat.nomorAyat ? AppColors.gold(context).withValues(alpha: 0.15) : null,
                        ),
                      ),
                      if (_showDetails) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, size: 18),
                              color: AppColors.green(context).withValues(alpha: 0.7),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                size: 24,
                              ),
                              color: AppColors.green(context),
                              onPressed: () {
                                String? audioUrl = ayat.audio[_selectedQori] ?? ayat.audio.values.firstOrNull;
                                if (audioUrl != null) {
                                  _playAudio(ayat.nomorAyat, audioUrl);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _lastReadAyat == ayat.nomorAyat ? Icons.bookmark : Icons.bookmark_outline,
                                size: 18,
                              ),
                              color: _lastReadAyat == ayat.nomorAyat ? AppColors.gold(context) : AppColors.muted(context),
                              onPressed: () async {
                                if (_lastReadAyat == ayat.nomorAyat) {
                                  await BookmarkService.clearLastRead();
                                  setState(() => _lastReadAyat = null);
                                } else {
                                  await BookmarkService.saveLastRead(
                                    surah: widget.nomorSurat,
                                    surahName: detailNamaLatin,
                                    ayat: ayat.nomorAyat,
                                  );
                                  setState(() => _lastReadAyat = ayat.nomorAyat);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  ayat.teksLatin,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.green(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  ayat.teksIndonesia,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text2(context),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBookmarkDialog(Ayat ayat, String surahName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Penanda Bacaan', style: TextStyle(color: AppColors.text1(context))),
        content: Text(
          'Jadikan ayat ${ayat.nomorAyat} sebagai penanda terakhir dibaca?',
          style: TextStyle(color: AppColors.text2(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.muted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await BookmarkService.saveLastRead(
                surah: widget.nomorSurat,
                surahName: surahName,
                ayat: ayat.nomorAyat,
              );
              if (mounted) {
                setState(() => _lastReadAyat = ayat.nomorAyat);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil ditandai: Ayat ${ayat.nomorAyat}'),
                    backgroundColor: AppColors.green(context),
                  ),
                );
              }
            },
            child: const Text('Ya, Tandai'),
          ),
        ],
      ),
    );
  }

}