import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

class DetailBeritaScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const DetailBeritaScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(news['pubDate']));
    } catch (_) {
      formattedDate = '-';
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.deepGreen,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    news['thumbnail'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.deepGreen,
                      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold(context).withOpacity(0.4)),
                    ),
                    child: Text(
                      (news['category'] ?? 'Islami').toString().toUpperCase(),
                      style: TextStyle(
                        color: AppColors.gold(context),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    news['title'] ?? '',
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider dengan info tanggal
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 13, color: AppColors.muted(context)),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(color: AppColors.muted(context), fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.menu_book_rounded, size: 13, color: AppColors.muted(context)),
                      const SizedBox(width: 6),
                      Text(
                        '${_estimateReadTime(news['content'] ?? '')} menit baca',
                        style: TextStyle(color: AppColors.muted(context), fontSize: 12),
                      ),
                    ],
                  ),

                  Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.muted(context).withOpacity(0.2),
                  ),

                  // Isi Artikel
                  Text(
                    news['content'] ?? news['title'] ?? '',
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer Source
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.green(context).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.green(context).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.green(context), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Artikel ini merupakan konten dari Warta Islami MyQuran. Untuk berita lebih lanjut, kunjungi republika.co.id.',
                            style: TextStyle(color: AppColors.muted(context), fontSize: 12, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _estimateReadTime(String content) {
    final wordCount = content.split(' ').length;
    return (wordCount / 200).ceil().clamp(1, 99);
  }
}
