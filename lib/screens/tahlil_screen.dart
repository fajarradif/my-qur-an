import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/tahlil.dart';
import '../widgets/quran_number_marker.dart';

class TahlilScreen extends StatelessWidget {
  const TahlilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Tahlil> tahlilData = _getTahlilData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tahlil & Doa', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: tahlilData.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 16),
        itemBuilder: (context, index) {
          return _buildTahlilCard(tahlilData[index]);
        },
      ),
    );
  }

  Widget _buildTahlilCard(Tahlil tahlil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuranNumberMarker(
                number: tahlil.id.toString(),
                color: AppColors.primaryGreen,
                size: 32,
                textStyle: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tahlil.title,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tahlil.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28,
              fontFamily: 'QuranFont',
              color: AppColors.textDark,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tahlil.translation,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedGreen,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Tahlil> _getTahlilData() {
    return [
      Tahlil(
        id: 1,
        title: "Pengantar (Al-Fatihah)",
        arabic: "اِلَى حَضْرَةِ النَّبِيِّ الْمُصْطَفَى صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ وَاٰلِهٖ وَاَزْوَاجِهٖ وَذُرِّيَّتِهٖ وَاَهْلِ بَيْتِهِ الْكِرَامِ، شَيْءٌ لِلّٰهِ لَهُمُ الْفَاتِحَةُ",
        translation: "Kepada yang terhormat Nabi Muhammad SAW, segenap keluarga, istri-istri, dan keturunannya. Bacaan Al-Fatihah ini kami peruntukkan kepada mereka.",
      ),
      Tahlil(
        id: 2,
        title: "Al-Ikhlas",
        arabic: "قُلْ هُوَ اللّٰهُ اَحَدٌ، اَللّٰهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ (٣×)",
        translation: "Katakanlah (Muhammad), 'Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. (Allah) tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan-Nya.' (3x)",
      ),
      Tahlil(
        id: 3,
        title: "Al-Falaq",
        arabic: "قُلْ اَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَ، وَمِنْ شَرِّ النَّفّٰثٰتِ فِى الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ",
        translation: "Katakanlah, 'Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan (perempuan-perempuan) penyihir yang meniup pada buhul-buhul (talinya), dan dari kejahatan orang yang dengki apabila dia dengki.'",
      ),
      Tahlil(
        id: 4,
        title: "An-Nas",
        arabic: "قُلْ اَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، اِلٰهِ النَّاسِ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، اَلَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَالنَّاسِ",
        translation: "Katakanlah, 'Aku berlindung kepada Tuhannya manusia, Raja manusia, Sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia.'",
      ),
      Tahlil(
        id: 5,
        title: "Ayat Kursi",
        arabic: "اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ وَّلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ وَلَا يَؤُوْدُهٗ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيْمُ",
        translation: "Allah, tidak ada tuhan selain Dia. Yang Mahahidup, yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Mahatinggi, Mahabesar.",
      ),
      Tahlil(
        id: 6,
        title: "Tahlil",
        arabic: "لَآ اِلٰهَ اِلَّا اللّٰهُ (١٠٠×)",
        translation: "Tiada Tuhan selain Allah. (100x)",
      ),
    ];
  }
}
