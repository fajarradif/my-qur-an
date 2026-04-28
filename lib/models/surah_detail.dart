import 'ayat.dart';

class SurahDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final List<Ayat> ayat;

  SurahDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.ayat,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    var ayatList = json['ayat'] as List? ?? [];
    List<Ayat> ayatParsed = ayatList.map((i) => Ayat.fromJson(i)).toList();

    return SurahDetail(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      ayat: ayatParsed,
    );
  }
}
