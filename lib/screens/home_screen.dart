import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/feature_menu_button.dart';
import '../widgets/last_read_card.dart';
import 'quran_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(isDark),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi cepat ke Al-Quran
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranScreen()));
        },
        backgroundColor: AppColors.primaryGold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.menu_book, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.secondaryGold,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assalamualaikum,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              Text('Siswa', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrayerTimeCard(isDark),
          const SizedBox(height: 24),
          const LastReadCard(), // Fitur Bookmark
          const SizedBox(height: 24),
          _buildFeaturesGrid(),
          const SizedBox(height: 24),
          Text('Konten Unggulan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildFeaturedCard(isDark),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DZUHUR', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('12:16 PM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 4),
              Text('05/08/2026', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Icon(Icons.wb_sunny, size: 64, color: AppColors.primaryGold),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FeatureMenuButton(
          icon: Icons.menu_book,
          label: 'Al-Quran',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranScreen()));
          },
        ),
        FeatureMenuButton(
          icon: Icons.explore,
          label: 'Kiblat',
          onTap: () {},
        ),
        FeatureMenuButton(
          icon: Icons.calculate, // Ikon Tasbih Digital
          label: 'Tasbih',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Kajian Rutin', style: TextStyle(color: AppColors.primaryGold, fontSize: 10)),
              ),
              const SizedBox(height: 12),
              Text('Mendalami\nMakna Ikhlas', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Icon(Icons.calendar_month, size: 60, color: AppColors.primaryGold),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? AppColors.primaryGold : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            const SizedBox(width: 48), // Ruang kosong untuk floating action button
            IconButton(
              icon: Icon(Icons.person_outline, color: _selectedIndex == 1 ? AppColors.primaryGold : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
          ],
        ),
      ),
    );
  }
}
