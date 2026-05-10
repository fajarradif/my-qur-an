import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../main.dart';

class DzikirPagiPetangScreen extends StatelessWidget {
  const DzikirPagiPetangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: Text(MyQuranApp.settingsOf(context).t('Zikir Pagi & Petang', 'Morning & Evening Dhikr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                AppColors.isDark(context) ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.isDark(context) ? AppColors.primaryYellow : Colors.white,
              ),
              onPressed: () {
                MyQuranApp.of(context).toggleTheme();
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryYellow,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.primaryYellow,
            tabs: [
              Tab(icon: const Icon(Icons.wb_sunny), text: MyQuranApp.settingsOf(context).t('Zikir Pagi', 'Morning Dhikr')),
              Tab(icon: const Icon(Icons.nightlight_round), text: MyQuranApp.settingsOf(context).t('Zikir Petang', 'Evening Dhikr')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DzikirList(isPagi: true),
            DzikirList(isPagi: false),
          ],
        ),
      ),
    );
  }
}

class DzikirList extends StatelessWidget {
  final bool isPagi;
  const DzikirList({super.key, required this.isPagi});

  @override
  Widget build(BuildContext context) {
    // Data contoh zikir (bisa ditambah lagi nanti)
    final dzikirData = [
      {
        'title': MyQuranApp.settingsOf(context).t('Membaca Ayat Kursi', 'Reading Ayat Kursi'),
        'arabic': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        'latin': 'Allahu laa ilaaha illaa huwal hayyul qayyuum...',
        'info': MyQuranApp.settingsOf(context).t('Dibaca 1x (Pelindung dari jin hingga sore/pagi)', 'Read 1x (Protection from jinn until evening/morning)'),
      },
      {
        'title': 'Sayyidul Istighfar',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
        'latin': 'Allahumma anta rabbii laa ilaaha illaa anta khalaqtanii...',
        'info': MyQuranApp.settingsOf(context).t('Dibaca 1x (Penyebab masuk surga jika meninggal hari itu)', 'Read 1x (Ensures Paradise if passing away that day)'),
      },
      {
        'title': MyQuranApp.settingsOf(context).t('Zikir Perlindungan', 'Supplication for Protection'),
        'arabic': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ...',
        'latin': 'Bismillahilladzi laa yadhurru ma’asmihi syai’un fil ardhi...',
        'info': MyQuranApp.settingsOf(context).t('Dibaca 3x (Pelindung dari segala bahaya)', 'Read 3x (Protection from all dangers)'),
      }
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: dzikirData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final dzikir = dzikirData[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.sf(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(AppColors.isDark(context) ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        dzikir['info']!,
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                dzikir['title']!,
                style: TextStyle(color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                dzikir['arabic']!,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen,
                  fontSize: 22,
                  fontFamily: 'QuranFont',
                  height: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dzikir['latin']!,
                style: TextStyle(
                  color: AppColors.isDark(context) ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
