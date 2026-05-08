import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../theme/colors.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import '../widgets/quran_number_marker.dart';
import '../models/surah_detail.dart';
import '../main.dart';

class MurottalScreen extends StatefulWidget {
  const MurottalScreen({super.key});

  @override
  State<MurottalScreen> createState() => _MurottalScreenState();
}

class _MurottalScreenState extends State<MurottalScreen> {
  late Future<List<Surah>> futureSurahList;
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String _selectedQori = '05'; // Default Misyari Rasyid
  final Map<String, String> _qoriNames = {
    '01': 'Abdullah Al-Juhany',
    '02': 'Abdul Muhsin Al-Qasim',
    '03': 'Abdurrahman as-Sudais',
    '04': 'Ibrahim Al-Dossari',
    '05': 'Misyari Rasyid',
  };

  @override
  void initState() {
    super.initState();
    futureSurahList = ApiService.getSuratList();
    _searchController.addListener(_onSearchChanged);
    
    // Listen to audio player state for UI updates
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredSurahs = _allSurahs
          .where((surah) =>
              surah.namaLatin.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              surah.nomor.toString().contains(_searchController.text))
          .toList();
    });
  }

  Future<void> _playMurottal(Surah surah, {bool forcePlay = false}) async {
    try {
      // Ambil detail surat dulu untuk dapet URL audio yang valid dari API
      final SurahDetail detail = await ApiService.getDetailSurat(surah.nomor);
      final String? audioUrl = detail.audioFull[_selectedQori];

      if (audioUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio tidak tersedia untuk Syekh ini')),
          );
        }
        return;
      }

      final currentMediaItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      final isCurrentlyLoaded = currentMediaItem?.id == audioUrl;

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

      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioUrl,
          album: "My Quran Murottal",
          title: "Surah ${surah.namaLatin}",
          artist: _qoriNames[_selectedQori] ?? "Unknown",
          artUri: Uri.parse('https://images.unsplash.com/photo-1584286595398-a59f21d313f5?q=80&w=1000&auto=format&fit=crop'),
          extras: {'surahNo': surah.nomor, 'qoriId': _selectedQori},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text('Murottal Al-Quran', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text1(context))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.bg(context),
        iconTheme: IconThemeData(color: AppColors.green(context)),
        actions: [
          IconButton(
            icon: Icon(
              AppColors.isDark(context) ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.green(context),
            ),
            onPressed: () {
              MyQuranApp.of(context).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildQoriSelector(),
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<Surah>>(
              future: futureSurahList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.green(context)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: AppColors.text1(context))));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('Tidak ada data surat.', style: TextStyle(color: AppColors.text1(context))));
                }

                if (_allSurahs.isEmpty) {
                  _allSurahs = snapshot.data!;
                  _filteredSurahs = _allSurahs;
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _filteredSurahs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return _buildSurahItem(surah);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQoriSelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.green(context).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQori,
          dropdownColor: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.primaryGreen,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: _qoriNames.entries.map((e) {
            return DropdownMenuItem<String>(
              value: e.key,
              child: Text(e.value),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              if (mounted) {
                setState(() => _selectedQori = val);
              }
              // Jika ada audio yang lagi jalan, pindah qori
              final currentMediaItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
              if (_audioPlayer.playing && currentMediaItem != null) {
                 final surahNo = currentMediaItem.extras?['surahNo'];
                 if (surahNo != null) {
                    final surah = _allSurahs.firstWhere((s) => s.nomor == surahNo);
                    _playMurottal(surah, forcePlay: true);
                 }
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama surat...',
          prefixIcon: Icon(Icons.search, color: AppColors.green(context)),
          filled: true,
          fillColor: AppColors.sf(context),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(Surah surah) {
    final currentItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    final bool isThisSurahLoaded = currentItem?.extras?['surahNo'] == surah.nomor && currentItem?.extras?['qoriId'] == _selectedQori;
    final bool isPlaying = isThisSurahLoaded && _audioPlayer.playing && _audioPlayer.processingState != ProcessingState.completed;
    final bool isBuffering = isThisSurahLoaded && 
        (_audioPlayer.processingState == ProcessingState.buffering || _audioPlayer.processingState == ProcessingState.loading);

    return InkWell(
      onTap: () => _playMurottal(surah),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: AppColors.isDark(context) ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: isThisSurahLoaded ? Border.all(color: AppColors.green(context).withValues(alpha: 0.3), width: 1) : null,
        ),
        child: Row(
          children: [
            QuranNumberMarker(
              number: surah.nomor.toString(),
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.namaLatin,
                    style: TextStyle(color: AppColors.text1(context), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${surah.jumlahAyat} Ayat',
                    style: TextStyle(color: AppColors.text2(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              surah.nama,
              style: TextStyle(color: AppColors.green(context), fontSize: 20, fontFamily: 'QuranFont'),
            ),
            const SizedBox(width: 16),
            isBuffering 
              ? SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green(context)))
              : Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: AppColors.green(context),
                  size: 32,
                ),
          ],
        ),
      ),
    );
  }
}
