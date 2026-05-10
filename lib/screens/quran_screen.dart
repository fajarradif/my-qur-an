import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/last_read_card.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import '../widgets/quran_number_marker.dart';
import 'detail_surat_screen.dart'; // import detail
import '../main.dart'; // import MyQuranApp
import '../services/bookmark_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> futureSurahs;

  @override
  void initState() {
    super.initState();
    futureSurahs = ApiService.getSuratList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.isDark(context) ? AppColors.darkSurface : AppColors.deepGreen,
          elevation: 0,
          title: const Text('AL-QURAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                AppColors.isDark(context) ? Icons.wb_sunny : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () {
                MyQuranApp.of(context).toggleTheme();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LastReadCard(onRefresh: () => setState(() {})),
            ),
            const SizedBox(height: 20),
            _buildTabBar(context),
            const Expanded(
              child: TabBarView(
                children: [
                  _SurahTab(),
                  _JuzTab(),
                  _RiwayatTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      labelColor: AppColors.gold(context),
      unselectedLabelColor: AppColors.muted(context),
      indicatorColor: AppColors.gold(context),
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'SURAH'),
        Tab(text: 'JUZ'),
        Tab(text: 'RIWAYAT'),
      ],
    );
  }
}

// Pisahkan widget tab biar kodingan di atas nggak kepanjangan dan lebih bersih
class _SurahTab extends StatelessWidget {
  const _SurahTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: ApiService.getSuratList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat data: \n${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data surat.', style: TextStyle(color: AppColors.muted(context))));
        }

        final surahs = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: surahs.length,
          separatorBuilder: (context, index) => Divider(color: AppColors.muted(context).withOpacity(0.1), height: 1),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: QuranNumberMarker(number: surah.nomor.toString()),
              title: Text(surah.namaLatin, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context))),
              subtitle: Text('${surah.jumlahAyat} AYAT', style: TextStyle(color: AppColors.muted(context), fontSize: 10, letterSpacing: 1)),
              trailing: Text(surah.nama, style: TextStyle(color: AppColors.gold(context), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'QuranFont')),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailSuratScreen(nomorSurat: surah.nomor)));
              },
            );
          },
        );
      },
    );
  }
}

class _JuzTab extends StatelessWidget {
  const _JuzTab();

  // Mapping Juz ke daftar Surat (Nomor Surat, Nama Surat, Range Ayat)
  static const Map<int, List<Map<String, dynamic>>> _juzContent = {
    1: [{'no': 1, 'nama': 'Al-Fatihah', 'range': '1-7'}, {'no': 2, 'nama': 'Al-Baqarah', 'range': '1-141'}],
    2: [{'no': 2, 'nama': 'Al-Baqarah', 'range': '142-252'}],
    3: [{'no': 2, 'nama': 'Al-Baqarah', 'range': '253-286'}, {'no': 3, 'nama': 'Ali \'Imran', 'range': '1-92'}],
    4: [{'no': 3, 'nama': 'Ali \'Imran', 'range': '93-200'}, {'no': 4, 'nama': 'An-Nisa\'', 'range': '1-23'}],
    5: [{'no': 4, 'nama': 'An-Nisa\'', 'range': '24-147'}],
    6: [{'no': 4, 'nama': 'An-Nisa\'', 'range': '148-176'}, {'no': 5, 'nama': 'Al-Ma\'idah', 'range': '1-81'}],
    7: [{'no': 5, 'nama': 'Al-Ma\'idah', 'range': '82-120'}, {'no': 6, 'nama': 'Al-An\'am', 'range': '1-110'}],
    8: [{'no': 6, 'nama': 'Al-An\'am', 'range': '111-165'}, {'no': 7, 'nama': 'Al-A\'raf', 'range': '1-87'}],
    9: [{'no': 7, 'nama': 'Al-A\'raf', 'range': '88-206'}, {'no': 8, 'nama': 'Al-Anfal', 'range': '1-40'}],
    10: [{'no': 8, 'nama': 'Al-Anfal', 'range': '41-75'}, {'no': 9, 'nama': 'At-Tawbah', 'range': '1-92'}],
    11: [{'no': 9, 'nama': 'At-Tawbah', 'range': '93-129'}, {'no': 10, 'nama': 'Yunus', 'range': '1-109'}, {'no': 11, 'nama': 'Hud', 'range': '1-5'}],
    12: [{'no': 11, 'nama': 'Hud', 'range': '6-123'}, {'no': 12, 'nama': 'Yusuf', 'range': '1-52'}],
    13: [{'no': 12, 'nama': 'Yusuf', 'range': '53-111'}, {'no': 13, 'nama': 'Ar-Ra\'d', 'range': '1-43'}, {'no': 14, 'nama': 'Ibrahim', 'range': '1-52'}],
    14: [{'no': 15, 'nama': 'Al-Hijr', 'range': '1-99'}, {'no': 16, 'nama': 'An-Nahl', 'range': '1-128'}],
    15: [{'no': 17, 'nama': 'Al-Isra\'', 'range': '1-111'}, {'no': 18, 'nama': 'Al-Kahf', 'range': '1-74'}],
    16: [{'no': 18, 'nama': 'Al-Kahf', 'range': '75-110'}, {'no': 19, 'nama': 'Maryam', 'range': '1-98'}, {'no': 20, 'nama': 'Taha', 'range': '1-135'}],
    17: [{'no': 21, 'nama': 'Al-Anbiya\'', 'range': '1-112'}, {'no': 22, 'nama': 'Al-Hajj', 'range': '1-78'}],
    18: [{'no': 23, 'nama': 'Al-Mu\'minun', 'range': '1-118'}, {'no': 24, 'nama': 'An-Nur', 'range': '1-64'}, {'no': 25, 'nama': 'Al-Furqan', 'range': '1-20'}],
    19: [{'no': 25, 'nama': 'Al-Furqan', 'range': '21-77'}, {'no': 26, 'nama': 'Ash-Shu\'ara\'', 'range': '1-227'}, {'no': 27, 'nama': 'An-Naml', 'range': '1-55'}],
    20: [{'no': 27, 'nama': 'An-Naml', 'range': '56-93'}, {'no': 28, 'nama': 'Al-Qasas', 'range': '1-88'}, {'no': 29, 'nama': 'Al-\'Ankabut', 'range': '1-45'}],
    21: [{'no': 29, 'nama': 'Al-\'Ankabut', 'range': '46-69'}, {'no': 30, 'nama': 'Ar-Rum', 'range': '1-60'}, {'no': 31, 'nama': 'Luqman', 'range': '1-34'}, {'no': 32, 'nama': 'As-Sajdah', 'range': '1-30'}, {'no': 33, 'nama': 'Al-Ahzab', 'range': '1-30'}],
    22: [{'no': 33, 'nama': 'Al-Ahzab', 'range': '31-73'}, {'no': 34, 'nama': 'Saba\'', 'range': '1-54'}, {'no': 35, 'nama': 'Fatir', 'range': '1-45'}, {'no': 36, 'nama': 'Ya-Sin', 'range': '1-27'}],
    23: [{'no': 36, 'nama': 'Ya-Sin', 'range': '28-83'}, {'no': 37, 'nama': 'As-Saffat', 'range': '1-182'}, {'no': 38, 'nama': 'Sad', 'range': '1-88'}, {'no': 39, 'nama': 'Az-Zumar', 'range': '1-31'}],
    24: [{'no': 39, 'nama': 'Az-Zumar', 'range': '32-75'}, {'no': 40, 'nama': 'Ghafir', 'range': '1-85'}, {'no': 41, 'nama': 'Fussilat', 'range': '1-46'}],
    25: [{'no': 41, 'nama': 'Fussilat', 'range': '47-54'}, {'no': 42, 'nama': 'Ash-Shura', 'range': '1-53'}, {'no': 43, 'nama': 'Az-Zukhruf', 'range': '1-89'}, {'no': 44, 'nama': 'Ad-Dukhan', 'range': '1-59'}, {'no': 45, 'nama': 'Al-Jathiyah', 'range': '1-37'}],
    26: [{'no': 46, 'nama': 'Al-Ahqaf', 'range': '1-35'}, {'no': 47, 'nama': 'Muhammad', 'range': '1-38'}, {'no': 48, 'nama': 'Al-Fath', 'range': '1-29'}, {'no': 49, 'nama': 'Al-Hujurat', 'range': '1-18'}, {'no': 50, 'nama': 'Qaf', 'range': '1-45'}, {'no': 51, 'nama': 'Adh-Dhariyat', 'range': '1-30'}],
    27: [{'no': 51, 'nama': 'Adh-Dhariyat', 'range': '31-60'}, {'no': 52, 'nama': 'At-Tur', 'range': '1-49'}, {'no': 53, 'nama': 'An-Najm', 'range': '1-62'}, {'no': 54, 'nama': 'Al-Qamar', 'range': '1-55'}, {'no': 55, 'nama': 'Ar-Rahman', 'range': '1-78'}, {'no': 56, 'nama': 'Al-Waqi\'ah', 'range': '1-96'}, {'no': 57, 'nama': 'Al-Hadid', 'range': '1-29'}],
    28: [{'no': 58, 'nama': 'Al-Mujadilah', 'range': '1-22'}, {'no': 59, 'nama': 'Al-Hashr', 'range': '1-24'}, {'no': 60, 'nama': 'Al-Mumtahanah', 'range': '1-13'}, {'no': 61, 'nama': 'As-Saff', 'range': '1-14'}, {'no': 62, 'nama': 'Al-Jumu\'ah', 'range': '1-11'}, {'no': 63, 'nama': 'Al-Munafiqun', 'range': '1-11'}, {'no': 64, 'nama': 'At-Taghabun', 'range': '1-18'}, {'no': 65, 'nama': 'At-Talaq', 'range': '1-12'}, {'no': 66, 'nama': 'At-Tahrim', 'range': '1-12'}],
    29: [{'no': 67, 'nama': 'Al-Mulk', 'range': '1-30'}, {'no': 68, 'nama': 'Al-Qalam', 'range': '1-52'}, {'no': 69, 'nama': 'Al-Haqqah', 'range': '1-52'}, {'no': 70, 'nama': 'Al-Ma\'arij', 'range': '1-44'}, {'no': 71, 'nama': 'Nuh', 'range': '1-28'}, {'no': 72, 'nama': 'Al-Jinn', 'range': '1-28'}, {'no': 73, 'nama': 'Al-Muzzammil', 'range': '1-20'}, {'no': 74, 'nama': 'Al-Muddaththir', 'range': '1-56'}, {'no': 75, 'nama': 'Al-Qiyamah', 'range': '1-40'}, {'no': 76, 'nama': 'Al-Insan', 'range': '1-31'}, {'no': 77, 'nama': 'Al-Mursalat', 'range': '1-50'}],
    30: [{'no': 78, 'nama': 'An-Naba\'', 'range': '1-40'}, {'no': 79, 'nama': 'An-Nazi\'at', 'range': '1-46'}, {'no': 80, 'nama': '\'Abasa', 'range': '1-42'}, {'no': 81, 'nama': 'At-Takwir', 'range': '1-29'}, {'no': 82, 'nama': 'Al-Infitar', 'range': '1-19'}, {'no': 83, 'nama': 'Al-Mutaffifin', 'range': '1-36'}, {'no': 84, 'nama': 'Al-Inshiqaq', 'range': '1-25'}, {'no': 85, 'nama': 'Al-Buruj', 'range': '1-22'}, {'no': 86, 'nama': 'At-Tariq', 'range': '1-17'}, {'no': 87, 'nama': 'Al-A\'la', 'range': '1-19'}, {'no': 88, 'nama': 'Al-Ghashiyah', 'range': '1-26'}, {'no': 89, 'nama': 'Al-Fajr', 'range': '1-30'}, {'no': 90, 'nama': 'Al-Balad', 'range': '1-20'}, {'no': 91, 'nama': 'Ash-Shams', 'range': '1-15'}, {'no': 92, 'nama': 'Al-Layl', 'range': '1-21'}, {'no': 93, 'nama': 'Ad-Duha', 'range': '1-11'}, {'no': 94, 'nama': 'Ash-Sharh', 'range': '1-8'}, {'no': 95, 'nama': 'At-Tin', 'range': '1-8'}, {'no': 96, 'nama': 'Al-\'Alaq', 'range': '1-19'}, {'no': 97, 'nama': 'Al-Qadr', 'range': '1-5'}, {'no': 98, 'nama': 'Al-Bayyinah', 'range': '1-8'}, {'no': 99, 'nama': 'Az-Zalzalah', 'range': '1-8'}, {'no': 100, 'nama': 'Al-\'Adiyat', 'range': '1-11'}, {'no': 101, 'nama': 'Al-Qari\'ah', 'range': '1-11'}, {'no': 102, 'nama': 'At-Takathur', 'range': '1-8'}, {'no': 103, 'nama': 'Al-\'Asr', 'range': '1-3'}, {'no': 104, 'nama': 'Al-Humazah', 'range': '1-9'}, {'no': 105, 'nama': 'Al-Fil', 'range': '1-5'}, {'no': 106, 'nama': 'Quraysh', 'range': '1-4'}, {'no': 107, 'nama': 'Al-Ma\'un', 'range': '1-7'}, {'no': 108, 'nama': 'Al-Kawthar', 'range': '1-3'}, {'no': 109, 'nama': 'Al-Kafirun', 'range': '1-6'}, {'no': 110, 'nama': 'An-Nasr', 'range': '1-3'}, {'no': 111, 'nama': 'Al-Masad', 'range': '1-5'}, {'no': 112, 'nama': 'Al-Ikhlas', 'range': '1-4'}, {'no': 113, 'nama': 'Al-Falaq', 'range': '1-5'}, {'no': 114, 'nama': 'An-Nas', 'range': '1-6'}],
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final contents = _juzContent[juzNumber] ?? [];

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey(juzNumber),
            leading: QuranNumberMarker(number: juzNumber.toString(), color: AppColors.gold(context)),
            title: Text('Juz $juzNumber', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context))),
            subtitle: Text('${contents.length} Surat', style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
            iconColor: AppColors.gold(context),
            childrenPadding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
            children: contents.map((surat) {
              final rangeParts = surat['range'].toString().split('-');
              final startAyat = int.parse(rangeParts[0]);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: QuranNumberMarker(number: surat['no'].toString(), size: 30, color: AppColors.gold(context)),
                title: Text(surat['nama'], style: TextStyle(color: AppColors.text1(context), fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Ayat ${surat['range']}', style: TextStyle(color: AppColors.muted(context), fontSize: 11)),
                trailing: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.muted(context).withOpacity(0.5)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailSuratScreen(
                        nomorSurat: surat['no'],
                        initialAyat: startAyat,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _RiwayatTab extends StatelessWidget {
  const _RiwayatTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookmarkService.getLastRead(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!['surah'] == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.muted(context).withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('Belum ada riwayat baca', style: TextStyle(color: AppColors.muted(context))),
              ],
            ),
          );
        }

        final lastRead = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('TERAKHIR DIBACA', style: TextStyle(color: AppColors.gold(context), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: QuranNumberMarker(number: lastRead['surah'].toString()),
              title: Text(lastRead['surahName'], style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context))),
              subtitle: Text('Ayat: ${lastRead['ayat']}', style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
              trailing: Icon(Icons.play_circle_fill, color: AppColors.gold(context)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailSuratScreen(nomorSurat: lastRead['surah'])));
              },
            ),
          ],
        );
      },
    );
  }
}
