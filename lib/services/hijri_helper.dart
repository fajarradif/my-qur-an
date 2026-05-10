class HijriHelper {
  // Fungsi sederhana konversi Masehi ke Hijriah (Algoritma Kuwaiti/Arithmetical)
  static Map<String, dynamic> fromGregorian(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    if ((year < 1583) || ((year == 1582) && (month < 10)) || ((year == 1582) && (month == 10) && (day <= 14))) {
      // Kalender sebelum Gregorian tidak didukung untuk kesederhanaan
    }

    double jd;
    if ((year > 1582) || ((year == 1582) && (month > 10)) || ((year == 1582) && (month == 10) && (day > 14))) {
      jd = ((1461 * (year + 4800 + ((month - 14) / 12).floor())) / 4).floorToDouble() +
           ((367 * (month - 2 - 12 * (((month - 14) / 12).floor()))) / 12).floorToDouble() -
           ((3 * (((year + 4900 + ((month - 14) / 12).floor()) / 100).floor())) / 4).floorToDouble() +
           day - 32075;
    } else {
      jd = 367 * year - ((7 * (year + 5001 + ((month - 9) / 7).floor())) / 4).floorToDouble() +
           ((275 * month) / 9).floorToDouble() + day + 1729777;
    }

    double l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
            (((l) / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        (((j) / 16).floor()) * (((15238 * j) / 43).floor()) + 29;
    
    int m = ((24 * l) / 709).floor();
    int d = (l - ((709 * m) / 24).floor()).toInt();
    int y = 30 * n + j - 30;

    return {
      'day': d,
      'month': m,
      'year': y,
    };
  }

  static String getMonthName(int month) {
    const months = [
      'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
      'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
      'Ramadhan', 'Syawal', 'Dzulkaidah', 'Dzulhijjah'
    ];
    return months[month - 1];
  }

  static Map<int, String> getHolidays(int month) {
    // Daftar hari besar Islam sederhana
    final allHolidays = {
      1: {1: 'Tahun Baru Hijriah', 10: 'Hari Asyura'},
      3: {12: 'Maulid Nabi Muhammad SAW'},
      7: {27: 'Isra\' Mi\'raj'},
      9: {1: 'Awal Puasa Ramadhan', 17: 'Nuzulul Qur\'an'},
      10: {1: 'Hari Raya Idul Fitri'},
      12: {10: 'Hari Raya Idul Adha', 11: 'Hari Tasyrik', 12: 'Hari Tasyrik', 13: 'Hari Tasyrik'},
    };

    return allHolidays[month] ?? {};
  }

  static String getPasaran(DateTime date) {
    // Referensi: 1 Januari 2024 adalah Senin Pahing
    final referenceDate = DateTime(2024, 1, 1);
    final diff = date.difference(referenceDate).inDays;
    
    // Siklus 5 harian: Pahing, Pon, Wage, Kliwon, Legi
    const pasaranList = ['Pahing', 'Pon', 'Wage', 'Kliwon', 'Legi'];
    
    // Handle diff negatif jika perlu, tapi untuk aplikasi ini cukup dari 2024 ke atas
    int index = diff % 5;
    if (index < 0) index += 5;
    
    return pasaranList[index];
  }
}
