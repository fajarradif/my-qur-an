class Jadwal {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  Jadwal({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      tanggal: json['tanggal'] ?? '',
      imsak: json['imsak'] ?? '',
      subuh: json['subuh'] ?? '',
      terbit: json['terbit'] ?? '',
      dhuha: json['dhuha'] ?? '',
      dzuhur: json['dzuhur'] ?? '',
      ashar: json['ashar'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isya: json['isya'] ?? '',
    );
  }

  // Model cerdas cari sholat terdekat berdasarkan jam HP (Local Time)
  Map<String, String> getNextPrayer() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    int toMinutes(String time) {
      if (time.isEmpty) return 0;
      final parts = time.split(':');
      if (parts.length != 2) return 0;
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final schedule = [
      {'name': 'Subuh', 'time': subuh},
      {'name': 'Dzuhur', 'time': dzuhur},
      {'name': 'Ashar', 'time': ashar},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Isya', 'time': isya},
    ];

    for (var prayer in schedule) {
      final prayerMins = toMinutes(prayer['time']!);
      if (prayerMins > currentMinutes) {
        return prayer;
      }
    }
    
    // Kalau hari ini sudah lewat Isya, tampilkan jadwal Subuh untuk besok
    return schedule.first;
  }
}
