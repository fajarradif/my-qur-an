import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../main.dart';
import 'detail_berita_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  Future<List<Map<String, dynamic>>>? futureNews;
  String _selectedType = 'Utama';
  String _selectedCategory = 'Terkini';
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = ['Terkini', 'Islami', 'Nasional', 'Internasional', 'Daerah'];

  @override
  void initState() {
    super.initState();
    futureNews = ApiService.getNews(category: 'terkini');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToList() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
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
        controller: _scrollController,
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
                icon: Icon(Icons.search, color: AppColors.isDark(context) ? Colors.white70 : AppColors.green(context)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      decoration: BoxDecoration(
                        color: AppColors.bg(context),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.muted(context).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Cari Kategori Berita',
                            style: TextStyle(color: AppColors.text1(context), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.gold(context).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: AppColors.gold(context)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pencarian hanya tersedia berdasarkan kategori: Terkini, Islami, Nasional, Internasional, dan Daerah.',
                                    style: TextStyle(color: AppColors.gold(context), fontSize: 12, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ..._categories.map((cat) {
                            final isActive = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedCategory = cat;
                                  futureNews = null;
                                });
                                setState(() {
                                  futureNews = ApiService.getNews(category: cat);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.gold(context).withOpacity(0.15)
                                      : AppColors.bg(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.gold(context)
                                        : AppColors.muted(context).withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.check_circle : Icons.circle_outlined,
                                      size: 18,
                                      color: isActive ? AppColors.gold(context) : AppColors.muted(context),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      cat,
                                      style: TextStyle(
                                        color: isActive ? AppColors.gold(context) : AppColors.text1(context),
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  AppColors.isDark(context) ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.green(context),
                ),
                onPressed: () {
                  MyQuranApp.of(context).toggleTheme();
                },
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
                      GestureDetector(
                        onTap: _scrollToList,
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(color: AppColors.gold(context), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailBeritaScreen(
                news: {...news, 'category': _selectedCategory},
              ),
            ),
          ),
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBeritaScreen(
              news: {...news, 'category': _selectedCategory},
            ),
          ),
        ),
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
