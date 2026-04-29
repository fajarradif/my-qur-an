import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/feature_menu_button.dart';
import '../widgets/last_read_card.dart';
import '../models/jadwal.dart';
import '../services/api_service.dart';
import 'quran_screen.dart';
import 'tahlil_screen.dart';
import 'tasbih_screen.dart';
import 'kiblat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<Jadwal> futureJadwal;

  @override
  void initState() {
    super.initState();
    // Default menggunakan kota Jakarta
    futureJadwal = ApiService.getJadwalSholat('58a2fc6ed39fd083f55d4182bf88826d');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  const LastReadCard(),
                  const SizedBox(height: 24),
                  _buildPrayerTimeCard(),
                  const SizedBox(height: 30),
                  _buildFeaturesGrid(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Inspirasi Harian', style: TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Lihat Semua', style: TextStyle(color: AppColors.secondaryGreen, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInspirationCard(),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildFloatingNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat Datang', style: TextStyle(color: AppColors.mutedGreen, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('Assalamualaikum', style: TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?img=11'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeCard() {
    return FutureBuilder<Jadwal>(
      future: futureJadwal,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStaticPrayerCard("Memuat Jadwal...");
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _buildStaticPrayerCard("Gagal Memuat Jadwal");
        }
        
        final jadwal = snapshot.data!;
        final nextPrayer = jadwal.getNextPrayer();
        
        final List<Map<String, String>> allPrayers = [
          {'name': 'Subuh', 'time': jadwal.subuh},
          {'name': 'Dzuhur', 'time': jadwal.dzuhur},
          {'name': 'Ashar', 'time': jadwal.ashar},
          {'name': 'Maghrib', 'time': jadwal.maghrib},
          {'name': 'Isya', 'time': jadwal.isya},
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jadwal Sholat Hari Ini', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(jadwal.tanggal, style: const TextStyle(color: AppColors.mutedGreen, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: allPrayers.map((prayer) {
                  final bool isNext = prayer['name'] == nextPrayer['name'];
                  return _buildPrayerItem(prayer['name']!, prayer['time']!, isNext);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerItem(String name, String time, bool isNext) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: isNext ? AppColors.primaryYellow : AppColors.mutedGreen,
            fontSize: 11,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isNext ? AppColors.primaryGreen : AppColors.iconBgGreen.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isNext ? [
              BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Text(
            time,
            style: TextStyle(
              color: isNext ? Colors.white : AppColors.primaryGreen,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticPrayerCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: AppColors.mutedGreen)),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FeatureMenuButton(
          icon: Icons.menu_book,
          label: 'Al-Quran',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranScreen()));
          },
        ),
        FeatureMenuButton(
          icon: Icons.receipt_long,
          label: 'Tahlil',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TahlilScreen()));
          },
        ),
        FeatureMenuButton(
          icon: Icons.brightness_high,
          label: 'Tasbih',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihScreen()));
          },
        ),
        FeatureMenuButton(
          icon: Icons.explore,
          label: 'Kiblat',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const KiblatScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildInspirationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 28,
              fontFamily: 'QuranFont',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '"Maka ingatlah kepada-Ku, Aku pun akan ingat kepadamu. Bersyukurlah kepada-Ku dan janganlah kamu ingkar kepada-Ku."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedGreen,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: AppColors.primaryYellow.withValues(alpha: 0.2),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text('QS. Al-Baqarah: 152', style: TextStyle(color: AppColors.primaryYellow, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, Icons.home_filled, 'Home'),
          _navItem(1, Icons.menu_book, 'Al-Quran'),
          _navItem(2, Icons.bookmark, 'Bookmarks'),
          _navItem(3, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = index == _selectedIndex;
    final color = isSelected ? AppColors.primaryYellow : AppColors.mutedGreen;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
