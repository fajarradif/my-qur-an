import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/bookmark_service.dart';
import '../screens/detail_surat_screen.dart';

class LastReadCard extends StatelessWidget {
  final VoidCallback? onRefresh;
  const LastReadCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookmarkService.getLastRead(),
      builder: (context, snapshot) {
        String surahName = 'Belum Ada';
        int ayatNo = 0;
        int surahNo = 0;

        if (snapshot.hasData) {
          surahName = snapshot.data!['surahName'];
          ayatNo = snapshot.data!['ayat'];
          surahNo = snapshot.data!['surah'];
        }

        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width > 40 
              ? (MediaQuery.of(context).size.width - 40) * 0.58 
              : 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepForestGreen, AppColors.deepGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book, color: AppColors.primaryYellow, size: 18),
                        SizedBox(width: 8),
                        Text('Terakhir Dibaca', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(surahName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(ayatNo == 0 ? 'Mulai membaca yuk!' : 'Ayat No: $ayatNo', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: surahNo == 0 ? null : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailSuratScreen(
                                nomorSurat: surahNo,
                                initialAyat: ayatNo,
                              ),
                            ),
                          );
                          if (onRefresh != null) onRefresh!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                          disabledBackgroundColor: Colors.white24,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_outlined, color: AppColors.primaryYellow, size: 32),
              ),
            ),
          ],
        ),
        );
      }
    );
  }
}
