import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _currentPage = 0;
  late Future<Jadwal> futureJadwal;
  late Timer _timer;
  late PageController _pageController;
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Kota Pamekasan ID (API v3): c52f1bd66cc19d05628bd8bf27af3ad6
    futureJadwal = ApiService.getJadwalSholat('c52f1bd66cc19d05628bd8bf27af3ad6');
    
    // Update jam setiap detik
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _currentTime = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
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
                  
                  SizedBox(
                    height: 200,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        const LastReadCard(),
                        _buildCountdownCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPageIndicator(),
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.primaryGreen : AppColors.mutedGreen.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Pamekasan, Madura', style: TextStyle(color: AppColors.mutedGreen, fontSize: 12)),
                const SizedBox(width: 8),
                Text(_currentTime, style: const TextStyle(color: AppColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
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

  Widget _buildCountdownCard() {
    return FutureBuilder<Jadwal>(
      future: futureJadwal,
      builder: (context, snapshot) {
        String countdownText = "--:--:--";
        String nextPrayerName = "Menunggu...";
        
        if (snapshot.hasData) {
          final jadwal = snapshot.data!;
          final now = DateTime.now();
          
          // Cari sholat terdekat berikutnya
          final List<Map<String, String>> prayers = [
            {'name': 'Subuh', 'time': jadwal.subuh},
            {'name': 'Dzuhur', 'time': jadwal.dzuhur},
            {'name': 'Ashar', 'time': jadwal.ashar},
            {'name': 'Maghrib', 'time': jadwal.maghrib},
            {'name': 'Isya', 'time': jadwal.isya},
          ];
          
          final currentMinutes = now.hour * 60 + now.minute;
          Map<String, String>? next;
          
          for (var p in prayers) {
            final parts = p['time']!.split(':');
            final pMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
            if (pMins > currentMinutes) {
              next = p;
              break;
            }
          }
          
          next ??= prayers.first; // Jika sudah lewat Isya, targetnya Subuh besok
          nextPrayerName = next['name']!;
          
          final parts = next['time']!.split(':');
          final target = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          
          // Jika target adalah Subuh besok
          var diffTarget = target;
          if (target.isBefore(now)) {
             diffTarget = target.add(const Duration(days: 1));
          }
          
          final diff = diffTarget.difference(now);
          final hours = diff.inHours.toString().padLeft(2, '0');
          final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
          countdownText = "$hours:$minutes:$seconds";
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepForestGreen, AppColors.deepGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.primaryYellow, size: 20),
                  const SizedBox(width: 8),
                  Text('Menuju Waktu $nextPrayerName', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                countdownText,
                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              const Text('Tetap istiqomah dalam ibadah ya!', style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
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
        final now = DateTime.now();
        final currentMinutes = now.hour * 60 + now.minute;
        
        final List<Map<String, dynamic>> allPrayers = [
          {'name': 'Subuh', 'time': jadwal.subuh},
          {'name': 'Dzuhur', 'time': jadwal.dzuhur},
          {'name': 'Ashar', 'time': jadwal.ashar},
          {'name': 'Maghrib', 'time': jadwal.maghrib},
          {'name': 'Isya', 'time': jadwal.isya},
        ];

        // Cari sholat mana yang sedang aktif saat ini
        String activeName = "";
        for (int i = 0; i < allPrayers.length; i++) {
          final parts = allPrayers[i]['time']!.split(':');
          final pMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          
          int nextMins = 1440; // Default akhir hari
          if (i < allPrayers.length - 1) {
            final nextParts = allPrayers[i+1]['time']!.split(':');
            nextMins = int.parse(nextParts[0]) * 60 + int.parse(nextParts[1]);
          }

          if (currentMinutes >= pMins && currentMinutes < nextMins) {
            activeName = allPrayers[i]['name'];
            break;
          }
        }
        
        // Kasus spesial sebelum Subuh
        if (activeName == "") activeName = "Isya";

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
                  final bool isActive = prayer['name'] == activeName;
                  return Expanded(
                    child: _buildPrayerItem(prayer['name']!, prayer['time']!, isActive),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerItem(String name, String time, bool isActive) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: isActive ? AppColors.primaryYellow : AppColors.mutedGreen,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : AppColors.iconBgGreen.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [
              BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Text(
            time,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.primaryGreen,
              fontSize: 12,
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
          icon: Icons.auto_stories, // Changed from receipt_long
          label: 'Tahlil & Yasin',
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
