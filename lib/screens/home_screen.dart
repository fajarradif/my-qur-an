import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/feature_menu_button.dart';
import '../widgets/last_read_card.dart';
import '../models/jadwal.dart';
import '../services/api_service.dart';
import 'quran_screen.dart';

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
    // Default menggunakan kota Jakarta, ini akan dimuat begitu layar Home dibuka
    futureJadwal = ApiService.getJadwalSholat('58a2fc6ed39fd083f55d4182bf88826d');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100), // padding bawah buat nav bar mengambang
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
            
            // Bottom Navigation Bar ala card floating
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
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
          return _buildStaticPrayerCard("Memuat...", "--:--", "Mohon tunggu");
        } else if (snapshot.hasError) {
          return _buildStaticPrayerCard("Error", "--:--", "Gagal memuat API");
        } else if (!snapshot.hasData) {
          return _buildStaticPrayerCard("Periksa Koneksi", "--:--", "Tidak ada data");
        }
        
        final jadwal = snapshot.data!;
        final nextPrayer = jadwal.getNextPrayer();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.iconBgGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextPrayer['name']!, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                      const Text('Akurat via myquran.com', style: TextStyle(color: AppColors.mutedGreen, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(nextPrayer['time']!, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('WIB', style: TextStyle(color: AppColors.mutedGreen, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Fallback UI kalau loading atau error
  Widget _buildStaticPrayerCard(String title, String time, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.iconBgGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: AppColors.mutedGreen, fontSize: 10)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
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
          icon: Icons.receipt_long, // Tahlil
          label: 'Tahlil',
          onTap: () {},
        ),
        FeatureMenuButton(
          icon: Icons.brightness_high, // Tasbih
          label: 'Tasbih',
          onTap: () {},
        ),
        FeatureMenuButton(
          icon: Icons.explore,
          label: 'Kiblat',
          onTap: () {},
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                 color: AppColors.primaryYellow.withOpacity(0.2),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
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
