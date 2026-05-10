import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  Future<List<Map<String, dynamic>>>? futureNews;
  String _selectedType = 'Utama'; // Utama, Keislaman
  String _selectedCategory = 'Terkini'; // Terkini, Nasional, Internasional, Daerah, Risalah

  final List<String> _categories = ['Terkini', 'Islami', 'Nasional', 'Internasional', 'Daerah'];

  @override
  void initState() {
    super.initState();
    futureNews = ApiService.getNews(category: 'terbaru');
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka tautan: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.bg(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Warta Islami',
                style: TextStyle(
                  color: AppColors.text1(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: AppColors.green(context)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border, color: AppColors.green(context)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal Categories (Premium Look)
                _buildModernCategories(),
                
                const SizedBox(height: 24),
                
                // Featured News (Headline)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sorotan Utama',
                        style: TextStyle(color: AppColors.text1(context), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(color: AppColors.gold(context), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeaturedSection(),
                
                const SizedBox(height: 32),
                
                // Regular News List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Berita Terkini',
                    style: TextStyle(color: AppColors.text1(context), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // News List
          FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_selectedCategory), // Paksa ganti total pas kategori berubah
            future: futureNews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
                );
              }
              
              final newsList = snapshot.data ?? [];
              if (newsList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Belum ada berita.')),
                );
              }

              // Kita sisihkan 1 berita buat Headline, sisanya di list bawah
              final remainingNews = newsList.length > 1 ? newsList.sublist(1) : newsList;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final news = remainingNews[index];
                      return _buildNewsCard(news);
                    },
                    childCount: remainingNews.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
                futureNews = null; // Reset biar muncul loading
              });
              // Ambil data baru
              setState(() {
                futureNews = ApiService.getNews(category: cat);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold(context) : AppColors.gold(context).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.gold(context) : AppColors.gold(context).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.text1(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey('featured_$_selectedCategory'),
      future: futureNews,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final news = snapshot.data![0];
        
        return GestureDetector(
          onTap: () => _launchUrl(news['link']),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green(context).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      news['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.iconBgGreen,
                        child: const Icon(Icons.image_not_supported, color: AppColors.primaryGreen, size: 40),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold(context),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'HOT TOPIC',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          news['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold(context).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchUrl(news['link']),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  news['thumbnail'],
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.iconBgGreen,
                    child: const Icon(Icons.image_not_supported, color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text1(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 10, color: AppColors.muted(context)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM yyyy').format(DateTime.parse(news['pubDate'])),
                          style: TextStyle(color: AppColors.muted(context), fontSize: 10),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold(context).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedCategory,
                            style: TextStyle(color: AppColors.gold(context), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.share_outlined, size: 14, color: AppColors.gold(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
