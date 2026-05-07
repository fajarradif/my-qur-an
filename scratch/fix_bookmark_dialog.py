
import os

path = 'lib/screens/detail_surat_screen.dart'
with open(path, 'r') as f:
    content = f.read()

new_dialog_method = """  void _showBookmarkDialog(Ayat ayat, String surahName) {
    final bool isAlreadyMarked = _lastReadAyat == ayat.nomorAyat;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAlreadyMarked ? 'Hapus Penanda' : 'Penanda Bacaan', 
          style: TextStyle(color: AppColors.text1(context))),
        content: Text(
          isAlreadyMarked 
            ? 'Hapus penanda terakhir dibaca pada ayat ${ayat.nomorAyat}?'
            : 'Jadikan ayat ${ayat.nomorAyat} sebagai penanda terakhir dibaca?',
          style: TextStyle(color: AppColors.text2(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.muted(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAlreadyMarked ? Colors.red : AppColors.green(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (isAlreadyMarked) {
                await BookmarkService.clearLastRead();
                if (mounted) setState(() => _lastReadAyat = null);
              } else {
                await BookmarkService.saveLastRead(
                  surah: widget.nomorSurat,
                  surahName: surahName,
                  ayat: ayat.nomorAyat,
                );
                if (mounted) setState(() => _lastReadAyat = ayat.nomorAyat);
              }
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAlreadyMarked ? 'Penanda dihapus' : 'Berhasil ditandai: Ayat ${ayat.nomorAyat}'),
                    backgroundColor: isAlreadyMarked ? Colors.red : AppColors.green(context),
                  ),
                );
              }
            },
            child: Text(isAlreadyMarked ? 'Ya, Hapus' : 'Ya, Tandai'),
          ),
        ],
      ),
    );
  }
"""

start_marker = '  void _showBookmarkDialog('
start_idx = content.find(start_marker)
if start_idx != -1:
    # Find the start of the next method
    # It's likely Widget _buildMurottalPlayer or something else
    next_method_idx = content.find('  Widget ', start_idx + 20)
    if next_method_idx == -1:
        next_method_idx = content.rfind('}')
    
    new_content = content[:start_idx] + new_dialog_method + '\n' + content[next_method_idx:]
    with open(path, 'w') as f:
        f.write(new_content)
    print('SUCCESS')
else:
    print('FAILED')
