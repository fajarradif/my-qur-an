import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DzikirPagiPetangScreen extends StatelessWidget {
  const DzikirPagiPetangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Zikir Pagi & Petang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primaryYellow,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.primaryYellow,
            tabs: [
              Tab(icon: Icon(Icons.wb_sunny), text: 'Zikir Pagi'),
              Tab(icon: Icon(Icons.nightlight_round), text: 'Zikir Petang'),
            ],
          ),
        ),
        body: const TabBarView(
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
        'title': 'Membaca Ayat Kursi',
        'arabic': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        'latin': 'Allahu laa ilaaha illaa huwal hayyul qayyuum...',
        'info': 'Dibaca 1x (Pelindung dari jin hingga sore/pagi)',
      },
      {
        'title': 'Sayyidul Istighfar',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
        'latin': 'Allahumma anta rabbii laa ilaaha illaa anta khalaqtanii...',
        'info': 'Dibaca 1x (Penyebab masuk surga jika meninggal hari itu)',
      },
      {
        'title': 'Zikir Perlindungan',
        'arabic': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّMِيعُ الْعَلِيمُ',
        'latin': 'Bismillahilladzi laa yadhurru ma’asmihi syai’un fil ardhi...',
        'info': 'Dibaca 3x (Mencukupi perlindungan dari segala bahaya)',
      },
      {
        'title': 'Keridhaan kepada Allah',
        'arabic': 'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
        'latin': 'Radhiitu billahi rabba, wabil islaami diina...',
        'info': 'Dibaca 3x (Allah menjamin keridhaan-Nya di hari kiamat)',
      },
      {
        'title': 'Membaca Al-Ikhlas, Al-Falaq, An-Naas',
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        'latin': 'Qul huwallahu ahad... Qul a’udzu birabbil falaq... Qul a’udzu birabbin naas...',
        'info': 'Dibaca 3x (Mencukupi segala sesuatu)',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dzikirData.length,
      itemBuilder: (context, index) {
        final item = dzikirData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.iconBgGreen, width: 1))),
                child: Text(
                  item['title']!,
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item['arabic']!,
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 22, height: 1.8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item['latin']!,
                  style: const TextStyle(color: AppColors.mutedGreen, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryYellow, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['info']!,
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
