import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../services/hijri_helper.dart';
import '../theme/colors.dart';
import '../widgets/feature_menu_button.dart';
import '../widgets/last_read_card.dart';
import '../models/jadwal.dart';
import '../services/api_service.dart';
import 'quran_screen.dart';
import 'tahlil_screen.dart';
import 'tasbih_screen.dart';
import 'kiblat_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/location_picker_sheet.dart';
import 'murottal_screen.dart';
import 'doa_screen.dart';
import 'hijri_calendar_screen.dart';
import 'dzikir_pagi_petang_screen.dart';
import '../models/news.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentPage = 0;
  bool _showAllFeaturesGrid = false;
  late Future<Jadwal> futureJadwal;
  late Timer _timer;
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _showStickyHeader = false;
  String _currentTime = "";
  String _currentLocationName = "Mencari lokasi...";
  
  // Default ke Pamekasan jika gagal
  final String _defaultCityId = 'c52f1bd66cc19d05628bd8bf27af3ad6';
  final String _defaultCityName = 'Pamekasan, Madura';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Set fallback awal sebelum loading selesai
    futureJadwal = ApiService.getJadwalSholat(_defaultCityId);
    _initializeLocationAndJadwal();
    
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showStickyHeader) {
        setState(() => _showStickyHeader = true);
      } else if (_scrollController.offset <= 300 && _showStickyHeader) {
        setState(() => _showStickyHeader = false);
      }
    });

    // Update jam setiap detik
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  Future<void> _initializeLocationAndJadwal({bool forceGps = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isManual = prefs.getBool('is_manual_location') ?? false;

      // Jika forceGps, kita paksa pakai GPS dan hapus status manual
      if (forceGps) {
        isManual = false;
        await prefs.setBool('is_manual_location', false);
      }

      if (isManual) {
        // Mode Manual: Ambil dari cache
        String? cachedCityId = prefs.getString('manual_city_id');
        String? cachedCityName = prefs.getString('manual_city_name');
        
        if (cachedCityId != null && cachedCityName != null && mounted) {
          setState(() {
            _currentLocationName = cachedCityName;
            futureJadwal = ApiService.getJadwalSholat(cachedCityId);
          });
          return;
        }
      }

      // Mode GPS (Otomatis)
      if (mounted) setState(() => _currentLocationName = "Mencari lokasi (GPS)...");
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS mati');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Izin GPS ditolak');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Izin GPS ditolak permanen');

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Mencari lokasi terlalu lama (timeout)');
      });

      String? cityName = await ApiService.getCityNameFromCoords(position.latitude, position.longitude);
      
      if (cityName != null) {
        String? cityId = await ApiService.searchCityId(cityName);
        
        if (cityId != null && mounted) {
          setState(() {
            _currentLocationName = cityName;
            futureJadwal = ApiService.getJadwalSholat(cityId);
          });
          return;
        }
      }
      throw Exception('Kota tidak ditemukan di API');
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationName = _defaultCityName;
        });
      }
    }
  }

  Future<void> _setManualLocation(String cityId, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_manual_location', true);
    await prefs.setString('manual_city_id', cityId);
    await prefs.setString('manual_city_name', cityName);

    if (mounted) {
      setState(() {
        _currentLocationName = cityName;
        futureJadwal = ApiService.getJadwalSholat(cityId);
      });
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationPickerSheet(),
    ).then((result) {
      if (result != null && result is Map) {
        if (result['action'] == 'gps') {
          _initializeLocationAndJadwal(forceGps: true);
        } else if (result['action'] == 'manual') {
          _setManualLocation(result['id'].toString(), result['name'].toString());
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _currentTime = formattedDateTime;
      });
    }
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
            IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeContent(),
                const QuranScreen(),
                BookmarkScreen(key: ValueKey(_selectedIndex)),
                const ProfileScreen(),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: (_showStickyHeader && _selectedIndex == 0) ? 0 : -80,
              left: 0,
              right: 0,
              child: _buildStickyHeader(),
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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          
          SizedBox(
            height: MediaQuery.of(context).size.width > 40 
                ? (MediaQuery.of(context).size.width - 40) * 0.58 
                : 0,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildHijriCard(),
                LastReadCard(onRefresh: () => setState(() {})),
                _buildCountdownCard(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicator(),
          const SizedBox(height: 24),
          _buildPrayerTimeCard(),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Menu Utama', style: TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllFeaturesGrid = !_showAllFeaturesGrid;
                  });
                },
                child: Text(_showAllFeaturesGrid ? 'Tutup' : 'Lihat Semua', style: const TextStyle(color: AppColors.secondaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeaturesGrid(),
          const SizedBox(height: 30),
          const Text('Inspirasi Harian', style: TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInspirationCard(),
          const SizedBox(height: 30),
          const Text('Warta Islami', style: TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
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
            GestureDetector(
              onTap: _showLocationPicker,
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primaryYellow),
                  const SizedBox(width: 4),
                  Text(_currentLocationName, style: const TextStyle(color: AppColors.mutedGreen, fontSize: 12)),
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.mutedGreen),
                  const SizedBox(width: 8),
                  Text(_currentTime, style: const TextStyle(color: AppColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
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

  Widget _buildHijriCard() {
    final hijri = HijriHelper.fromGregorian(DateTime.now());
    final hijriDay = hijri['day'];
    final hijriMonth = HijriHelper.getMonthName(hijri['month']);
    final hijriYear = hijri['year'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepGreen, AppColors.emeraldGreen],
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
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.dark_mode,
              color: Colors.white.withValues(alpha: 0.1),
              size: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primaryYellow, size: 20),
                  const SizedBox(width: 8),
                  const Text('Kalender Hijriah', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$hijriDay $hijriMonth',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                '$hijriYear Hijriah',
                style: const TextStyle(color: AppColors.primaryYellow, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
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
                  Builder(
                    builder: (context) {
                      final hijri = HijriHelper.fromGregorian(DateTime.now());
                      return Text(
                        '${hijri['day']} ${HijriHelper.getMonthName(hijri['month'])} ${hijri['year']} H',
                        style: const TextStyle(color: AppColors.mutedGreen, fontSize: 10, fontWeight: FontWeight.w600),
                      );
                    }
                  ),
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
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _showAllFeaturesGrid ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildFirstRowFeatures(),
      ),
      secondChild: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildFirstRowFeatures(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildSecondRowFeatures(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFirstRowFeatures() {
    return [
      FeatureMenuButton(
        icon: Icons.menu_book,
        label: 'Al-Quran',
        onTap: () {
           setState(() => _selectedIndex = 1);
        },
      ),
      FeatureMenuButton(
        icon: Icons.auto_stories,
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
    ];
  }

  List<Widget> _buildSecondRowFeatures() {
    return [
      FeatureMenuButton(
        icon: Icons.headphones,
        label: 'Murottal',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MurottalScreen()));
        },
      ),
      FeatureMenuButton(
        icon: Icons.pan_tool,
        label: 'Doa-doa',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaScreen()));
        },
      ),
      FeatureMenuButton(
        icon: Icons.event_note,
        label: 'Kalender',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HijriCalendarScreen()));
        },
      ),
      FeatureMenuButton(
        icon: Icons.auto_awesome,
        label: 'Zikir',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DzikirPagiPetangScreen()));
        },
      ),
    ];
  }

  static void _emptyFunction() {}

  final List<Map<String, String>> _inspirations = const [
    {
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      'translation': '"Maka ingatlah kepada-Ku, Aku pun akan ingat kepadamu. Bersyukurlah kepada-Ku dan janganlah kamu ingkar kepada-Ku."',
      'source': 'QS. Al-Baqarah: 152',
    },
    {
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': '"Sesungguhnya bersama kesulitan ada kemudahan."',
      'source': 'QS. Al-Insyirah: 6',
    },
    {
      'arabic': 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
      'translation': '"Dan sungguh, kelak Tuhanmu pasti memberikan karunia-Nya kepadamu, sehingga engkau rida."',
      'source': 'QS. Ad-Duha: 5',
    },
    {
      'arabic': 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      'translation': '"Wahai orang-orang yang beriman! Mohonlah pertolongan (kepada Allah) dengan sabar dan salat. Sungguh, Allah beserta orang-orang yang sabar."',
      'source': 'QS. Al-Baqarah: 153',
    },
    {
      'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      'translation': '"Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya."',
      'source': 'QS. Al-Baqarah: 286',
    },
    {
      'arabic': 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
      'translation': '"Dan Tuhanmu berfirman, \'Berdoalah kepada-Ku, niscaya akan Aku perkenankan bagimu.\'"',
      'source': 'QS. Ghafir: 60',
    },
    {
      'arabic': 'وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا',
      'translation': '"Barangsiapa bertakwa kepada Allah niscaya Dia akan membukakan jalan keluar baginya."',
      'source': 'QS. At-Talaq: 2',
    },
    {
      'arabic': 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
      'translation': '"Janganlah kamu bersikap lemah, dan janganlah (pula) kamu bersedih hati, padahal kamulah orang-orang yang paling tinggi (derajatnya), jika kamu orang-orang yang beriman."',
      'source': 'QS. Ali \'Imran: 139',
    },
    {
      'arabic': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'translation': '"Ingatlah, hanya dengan mengingati Allah-lah hati menjadi tenteram."',
      'source': 'QS. Ar-Ra\'d: 28',
    },
    {
      'arabic': 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
      'translation': '"Sesungguhnya jika kamu bersyukur, pasti Kami akan menambah (nikmat) kepadamu, dan jika kamu mengingkari (nikmat-Ku), maka sesungguhnya azab-Ku sangat pedih."',
      'source': 'QS. Ibrahim: 7',
    },
    {
      'arabic': 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ ۖ وَعَسَىٰ أَن تُحِبُّوا شَيْئًا وَهُوَ شَرٌّ لَّكُمْ',
      'translation': '"Boleh jadi kamu membenci sesuatu, padahal ia amat baik bagimu, dan boleh jadi (pula) kamu menyukai sesuatu, padahal ia amat buruk bagimu."',
      'source': 'QS. Al-Baqarah: 216',
    },
    {
      'arabic': 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      'translation': '"Janganlah kamu berputus asa dari rahmat Allah. Sesungguhnya Allah mengampuni dosa-dosa semuanya."',
      'source': 'QS. Az-Zumar: 53',
    },
    {
      'arabic': 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
      'translation': '"Janganlah kamu berduka cita, sesungguhnya Allah beserta kita."',
      'source': 'QS. At-Tawbah: 40',
    },
    {
      'arabic': 'وَاللَّهُ خَيْرُ الْمَاكِرِينَ',
      'translation': '"Dan Allah adalah sebaik-baik pembalas tipu daya."',
      'source': 'QS. Al-Anfal: 30',
    },
    {
      'arabic': 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ',
      'translation': '"Orang-orang beriman itu sesungguhnya bersaudara."',
      'source': 'QS. Al-Hujurat: 10',
    },
    {
      'arabic': 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
      'translation': '"Maka nikmat Tuhan kamu yang manakah yang kamu dustakan?"',
      'source': 'QS. Ar-Rahman: 13',
    },
    {
      'arabic': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
      'translation': '"Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka (jawablah), bahwasanya Aku adalah dekat. Aku mengabulkan permohonan orang yang berdoa apabila ia memohon kepada-Ku."',
      'source': 'QS. Al-Baqarah: 186',
    },
    {
      'arabic': 'يُرِيدُ اللَّهُ أَن يُخَفِّفَ عَنكُمْ ۚ وَخُلِقَ الْإِنسَانُ ضَعِيفًا',
      'translation': '"Allah hendak memberikan keringanan kepadamu, dan manusia dijadikan bersifat lemah."',
      'source': 'QS. An-Nisa: 28',
    },
    {
      'arabic': 'إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ',
      'translation': '"Hanya kepada Allah aku mengadukan kesusahan dan kesedihanku."',
      'source': 'QS. Yusuf: 86',
    },
    {
      'arabic': 'لَا تَخَافَا ۖ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَىٰ',
      'translation': '"Janganlah kamu berdua khawatir, sesungguhnya Aku beserta kamu berdua, Aku mendengar dan melihat."',
      'source': 'QS. Ta-Ha: 46',
    },
    {
      'arabic': 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      'translation': '"Ya Tuhanku sesungguhnya aku sangat memerlukan sesuatu kebaikan yang Engkau turunkan kepadaku."',
      'source': 'QS. Al-Qasas: 24',
    },
    {
      'arabic': 'وَأَحْسِنُوا ۛ إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
      'translation': '"Dan berbuat baiklah, karena sesungguhnya Allah menyukai orang-orang yang berbuat baik."',
      'source': 'QS. Al-Baqarah: 195',
    },
    {
      'arabic': 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
      'translation': '"Dan Dia bersama kamu di mana saja kamu berada."',
      'source': 'QS. Al-Hadid: 4',
    },
    {
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'translation': '"Cukuplah Allah menjadi Penolong kami dan Allah adalah sebaik-baik Pelindung."',
      'source': 'QS. Ali \'Imran: 173',
    },
    {
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'translation': '"Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat dan peliharalah kami dari siksa neraka."',
      'source': 'QS. Al-Baqarah: 201',
    },
    {
      'arabic': 'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
      'translation': '"Sesungguhnya Allah menyukai orang-orang yang bertaubat dan menyukai orang-orang yang mensucikan diri."',
      'source': 'QS. Al-Baqarah: 222',
    },
    {
      'arabic': 'وَاسْتَغْفِرُوا اللَّهَ ۖ إِنَّ اللَّهَ غَفُورٌ رَّحِيمٌ',
      'translation': '"Dan mohonlah ampunan kepada Allah; sesungguhnya Allah Maha Pengampun lagi Maha Penyayang."',
      'source': 'QS. Al-Muzzammil: 20',
    },
    {
      'arabic': 'وَتَوَكَّلْ عَلَى اللَّهِ ۚ وَكَفَىٰ بِاللَّهِ وَكِيلًا',
      'translation': '"Dan bertawakallah kepada Allah. Dan cukuplah Allah sebagai Pemelihara."',
      'source': 'QS. Al-Ahzab: 3',
    },
    {
      'arabic': 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَّالَّذِينَ هُم مُّحْسِنُونَ',
      'translation': '"Sesungguhnya Allah beserta orang-orang yang bertakwa dan orang-orang yang berbuat kebaikan."',
      'source': 'QS. An-Nahl: 128',
    },
    {
      'arabic': 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      'translation': '"Dan katakanlah: \'Ya Tuhanku, tambahkanlah kepadaku ilmu pengetahuan.\'"',
      'source': 'QS. Ta-Ha: 114',
    },
    {
      'arabic': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
      'translation': '"Ya Tuhan kami, janganlah Engkau jadikan hati kami condong kepada kesesatan sesudah Engkau beri petunjuk kepada kami, dan karuniakanlah kepada kami rahmat dari sisi Engkau."',
      'source': 'QS. Ali \'Imran: 8',
    }
  ];

  Widget _buildInspirationCard() {
    final int todayIndex = DateTime.now().day % _inspirations.length;
    final inspiration = _inspirations[todayIndex];

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
          Text(
            inspiration['arabic']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 28,
              fontFamily: 'QuranFont',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            inspiration['translation']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
               child: Text(inspiration['source']!, style: const TextStyle(color: AppColors.primaryYellow, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  final List<News> _newsList = [
    News(
      title: 'Mengenal Sejarah Pembangunan Masjid Nabawi di Madinah',
      source: 'Republika',
      time: '2 jam yang lalu',
      imageUrl: 'https://static.republika.co.id/uploads/images/inpicture_slide/masjid-nabawi-madinah_210511145831-294.jpg',
      url: 'https://republika.co.id',
    ),
    News(
      title: 'Tips Menjaga Konsistensi Ibadah Pasca Ramadhan',
      source: 'Sindonews',
      time: '5 jam yang lalu',
      imageUrl: 'https://pict.sindonews.net/dyn/850/pena/news/2024/04/15/67/1359404/tips-menjaga-istiqamah-beribadah-setelah-ramadhan-vml.jpg',
      url: 'https://sindonews.com',
    ),
    News(
      title: 'Update Kondisi Palestina: Bantuan Kemanusiaan Terus Mengalir',
      source: 'Antara News',
      time: '8 jam yang lalu',
      imageUrl: 'https://img.antaranews.com/cache/1200x800/2023/11/04/antarafoto-bantuan-kemanusiaan-untuk-palestina-041123-adn-3.jpg.webp',
      url: 'https://antaranews.com',
    ),
  ];

  Widget _buildNewsSection() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          final news = _newsList[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    news.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: AppColors.iconBgGreen,
                      child: const Icon(Icons.image_not_supported, color: AppColors.primaryGreen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(news.source, style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 10)),
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: Colors.grey[400])),
                            const SizedBox(width: 8),
                            Text(news.time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader() {
    return FutureBuilder<Jadwal>(
      future: futureJadwal,
      builder: (context, snapshot) {
        String nextPrayerName = "Memuat...";
        String nextPrayerTime = "--:--";
        String countdown = "--:--:--";

        if (snapshot.hasData && snapshot.data != null) {
          try {
            final next = ApiService.getNextPrayer(snapshot.data!);
            nextPrayerName = next['name'];
            nextPrayerTime = next['time'];
            countdown = ApiService.getCountdown(next['time']);
          } catch (e) {
            // Jika gagal parse, biarkan default
          }
        }

        if (snapshot.hasError) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.98),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled, color: AppColors.primaryYellow, size: 18),
              const SizedBox(width: 12),
              Text(
                nextPrayerName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                nextPrayerTime,
                style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '- $countdown',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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
