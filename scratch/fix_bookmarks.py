
import os

path = 'lib/screens/detail_surat_screen.dart'
with open(path, 'r') as f:
    content = f.read()

new_method = """  Widget _buildAyatCard(Ayat ayat, String detailNamaLatin) {
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
          'Jadikan ayat ' + str(ayat.nomorAyat) + ' sebagai penanda terakhir dibaca?',
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
                    content: Text('Berhasil ditandai: Ayat ' + str(ayat.nomorAyat)),
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
"""

start_marker = '  Widget _buildAyatCard(Ayat ayat, String detailNamaLatin) {'
start_idx = content.find(start_marker)
if start_idx != -1:
    new_content = content[:start_idx] + new_method + '\n}'
    with open(path, 'w') as f:
        f.write(new_content)
    print('SUCCESS')
else:
    print('FAILED')
