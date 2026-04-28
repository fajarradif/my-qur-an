import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/last_read_card.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUR\'AN'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const LastReadCard(),
            const SizedBox(height: 24),
            _buildTabBar(context),
            const SizedBox(height: 16),
            _buildSurahList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primaryGold,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            indicatorColor: AppColors.primaryGold,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Surah'),
              Tab(text: 'Para'),
              Tab(text: 'Page'),
              Tab(text: 'Hijb'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(bool isDark) {
    final surahs = [
      {'id': 1, 'name': 'Al-Fatihah', 'arabic': 'الفاتحة'},
      {'id': 2, 'name': 'Al-Baqarah', 'arabic': 'البقرة'},
      {'id': 3, 'name': 'Al-Imran', 'arabic': 'آل عمران'},
      {'id': 4, 'name': 'An-Nisa', 'arabic': 'النساء'},
      {'id': 5, 'name': 'Al-Ma\'idah', 'arabic': 'المائدة'},
      {'id': 6, 'name': 'Al-An\'am', 'arabic': 'الأنعام'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surahs.length,
      separatorBuilder: (context, index) => Divider(color: isDark ? AppColors.darkSurface : Colors.grey.shade200, height: 24),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star_border, color: AppColors.primaryGold, size: 40),
              Text(
                surah['id'].toString(), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
              ),
            ],
          ),
          title: Text(surah['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(surah['arabic'].toString(), style: const TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Icon(Icons.play_circle_fill, color: AppColors.primaryGold),
            ],
          ),
          onTap: () {},
        );
      },
    );
  }
}
