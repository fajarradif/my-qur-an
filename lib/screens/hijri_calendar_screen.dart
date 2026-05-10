import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/hijri_helper.dart';
import '../main.dart';

class HijriCalendarScreen extends StatefulWidget {
  final bool swipeEnabled;
  const HijriCalendarScreen({super.key, this.swipeEnabled = false});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  DateTime _today = DateTime.now();
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime(_today.year, _today.month, 1);
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
  }

  String _toArabic(int n) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((e) => arabicDigits[int.parse(e)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(MyQuranApp.settingsOf(context).t('Kalender', 'Calendar'), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      ),
      body: GestureDetector(
        onHorizontalDragEnd: widget.swipeEnabled
            ? (details) {
                if (details.primaryVelocity! < 0) {
                  _nextMonth();
                } else if (details.primaryVelocity! > 0) {
                  _prevMonth();
                }
              }
            : null,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              _buildHeader(),
              _buildWeekdayHeader(),
              _buildCalendarGrid(),
              _buildHolidaysSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthName = DateFormat('MMMM yyyy', MyQuranApp.settingsOf(context).language == 'id' ? 'id_ID' : 'en_US').format(_focusedDate);
    
    final firstDayHijri = HijriHelper.fromGregorian(_focusedDate);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final lastDayHijri = HijriHelper.fromGregorian(lastDayOfMonth);
    
    String hijriRange = "${HijriHelper.getMonthName(firstDayHijri['month'])}";
    if (firstDayHijri['month'] != lastDayHijri['month']) {
      hijriRange += " - ${HijriHelper.getMonthName(lastDayHijri['month'])}";
    }
    hijriRange += " ${firstDayHijri['year']} H";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/islamic_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
              ),
              onPressed: _prevMonth,
            ),
            Column(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  hijriRange,
                  style: TextStyle(color: AppColors.gold(context).withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ),
              onPressed: _nextMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = MyQuranApp.settingsOf(context).language == 'id' 
        ? ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) => Text(
          day,
          style: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.bold, fontSize: 13),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstWeekday = _focusedDate.weekday % 7; 
    
    final prevMonthDate = DateTime(_focusedDate.year, _focusedDate.month, 0);
    final daysInPrevMonth = prevMonthDate.day;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.62, 
      ),
      itemCount: 42, 
      itemBuilder: (context, index) {
        int day = 0;
        bool isCurrentMonth = false;
        DateTime date;

        if (index < firstWeekday) {
          day = daysInPrevMonth - (firstWeekday - index - 1);
          date = DateTime(_focusedDate.year, _focusedDate.month - 1, day);
        } else if (index < firstWeekday + daysInMonth) {
          day = index - firstWeekday + 1;
          isCurrentMonth = true;
          date = DateTime(_focusedDate.year, _focusedDate.month, day);
        } else {
          day = index - (firstWeekday + daysInMonth) + 1;
          date = DateTime(_focusedDate.year, _focusedDate.month + 1, day);
        }

        final hijri = HijriHelper.fromGregorian(date);
        final pasaran = HijriHelper.getPasaran(date);
        final isToday = date.day == _today.day && date.month == _today.month && date.year == _today.year;
        final isSunday = date.weekday == DateTime.sunday;
        
        final hijriHolidays = HijriHelper.getHolidays(hijri['month']);
        final isIslamicHoliday = hijriHolidays.containsKey(hijri['day']);
        final isRedDate = _isRedDate(date);

        return Container(
          decoration: BoxDecoration(
            border: isToday 
              ? Border.all(color: AppColors.primaryGreen, width: 2)
              : Border.all(color: AppColors.isDark(context) ? Colors.white10 : Colors.black.withOpacity(0.05), width: 0.5),
            color: isToday ? AppColors.primaryGreen.withOpacity(0.15) : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _toArabic(hijri['day']),
                    style: TextStyle(
                      color: isIslamicHoliday ? Colors.red.withOpacity(0.7) : (isCurrentMonth ? (AppColors.isDark(context) ? Colors.white54 : Colors.black45) : Colors.grey.withOpacity(0.3)),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Text(
                day.toString(),
                style: TextStyle(
                  color: isSunday || isRedDate || isIslamicHoliday
                    ? Colors.red 
                    : (isCurrentMonth 
                        ? (AppColors.isDark(context) ? Colors.white : Colors.black87) 
                        : Colors.grey.withOpacity(0.3)),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  pasaran,
                  style: TextStyle(
                    color: isCurrentMonth ? (isSunday ? Colors.red.withOpacity(0.5) : Colors.grey) : Colors.grey.withOpacity(0.2),
                    fontSize: 8.5,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(bottom: 3),
                  width: 4, height: 4,
                  decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isRedDate(DateTime date) {
    // Daftar hari LIBUR (Tanggal Merah) 2026
    final redDates = {
      '1-1': 'Tahun Baru Masehi',
      '3-17': 'Hari Raya Nyepi',
      '4-3': 'Wafat Yesus Kristus',
      '5-1': 'Hari Buruh Internasional',
      '5-14': 'Kenaikan Yesus Kristus',
      '5-21': 'Hari Raya Waisak',
      '6-1': 'Hari Lahir Pancasila',
      '8-17': 'Hari Kemerdekaan RI',
      '12-25': 'Hari Raya Natal',
    };
    return redDates.containsKey('${date.month}-${date.day}');
  }

  Widget _buildHolidaysSection() {
    final firstDayHijri = HijriHelper.fromGregorian(_focusedDate);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final lastDayHijri = HijriHelper.fromGregorian(lastDayOfMonth);
    
    Map<String, String> importantDays = {};
    
    // Libur Islam (Dinamis dari HijriHelper)
    final h1 = HijriHelper.getHolidays(firstDayHijri['month']);
    h1.forEach((day, name) => importantDays['${firstDayHijri['month']}-$day (H)'] = name);
    
    if (firstDayHijri['month'] != lastDayHijri['month']) {
      final h2 = HijriHelper.getHolidays(lastDayHijri['month']);
      h2.forEach((day, name) => importantDays['${lastDayHijri['month']}-$day (H)'] = name);
    }

    // Hari Penting Indonesia (Gabungan Tanggal Merah & Hari Peringatan)
    final indonesianDays = {
      1: {'1': 'Tahun Baru Masehi (L)', '3': 'Hari Amal Bakti Kemenag'},
      2: {'21': 'Hari Peduli Sampah Nasional'},
      3: {'17': 'Hari Raya Nyepi (L)', '21': 'Hari Hutan Sedunia'},
      4: {'3': 'Wafat Yesus Kristus (L)', '21': 'Hari Kartini', '22': 'Hari Bumi'},
      5: {'1': 'Hari Buruh (L)', '2': 'Hari Pendidikan Nasional', '14': 'Kenaikan Yesus Kristus (L)', '20': 'Hari Kebangkitan Nasional', '21': 'Hari Raya Waisak (L)'},
      6: {'1': 'Hari Lahir Pancasila (L)', '21': 'Hari Krida Pertanian'},
      7: {'22': 'Hari Kejaksaan Nasional', '23': 'Hari Anak Nasional'},
      8: {'10': 'Hari Veteran Nasional', '14': 'Hari Pramuka', '17': 'Hari Kemerdekaan RI (L)'},
      9: {'17': 'Hari Perhubungan Nasional', '24': 'Hari Tani Nasional'},
      10: {'1': 'Hari Kesaktian Pancasila', '2': 'Hari Batik Nasional', '5': 'Hari TNI', '22': 'Hari Santri Nasional', '28': 'Hari Sumpah Pemuda'},
      11: {'10': 'Hari Pahlawan', '12': 'Hari Kesehatan Nasional', '25': 'Hari Guru Nasional'},
      12: {'9': 'Hari Anti Korupsi', '13': 'Hari Nusantara', '22': 'Hari Ibu', '25': 'Hari Natal (L)'},
    };

    if (indonesianDays.containsKey(_focusedDate.month)) {
      indonesianDays[_focusedDate.month]!.forEach((day, name) {
        importantDays['$day ${DateFormat('MMM').format(_focusedDate)}'] = name;
      });
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.gold(context), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(
                MyQuranApp.settingsOf(context).t('Hari Besar & Penting', 'Holidays & Important Days'),
                style: TextStyle(color: AppColors.text1(context), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(L) = Libur Nasional / Tanggal Merah',
            style: TextStyle(color: AppColors.muted(context), fontSize: 10, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          if (importantDays.isEmpty)
             Center(child: Text(MyQuranApp.settingsOf(context).t('Tidak ada hari penting bulan ini', 'No important days this month'), style: TextStyle(color: AppColors.muted(context)))),
          ...importantDays.entries.map((e) {
            final isLibur = e.value.contains('(L)');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(color: (isLibur ? Colors.red : AppColors.gold(context)).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(e.key, style: TextStyle(color: isLibur ? Colors.red : AppColors.gold(context), fontWeight: FontWeight.bold, fontSize: 11))),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      MyQuranApp.settingsOf(context).language == 'id' 
                        ? e.value 
                        : _getTranslatedHoliday(e.value),
                      style: TextStyle(color: isLibur ? Colors.red.withOpacity(0.8) : AppColors.text1(context), fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getTranslatedHoliday(String holiday) {
    final Map<String, String> mapping = {
      'Tahun Baru Hijriah': 'Hijri New Year',
      'Hari Asyura': 'Ashura Day',
      'Maulid Nabi Muhammad SAW': 'Mawlid al-Nabi',
      'Isra\' Mi\'raj': 'Isra Mi\'raj',
      'Awal Puasa Ramadhan': 'Beginning of Ramadan',
      'Nuzulul Qur\'an': 'Nuzulul Quran',
      'Hari Raya Idul Fitri': 'Eid al-Fitr',
      'Hari Raya Idul Adha': 'Eid al-Adha',
      'Hari Tasyrik': 'Tashreeq Day',
      'Tahun Baru Masehi (L)': 'New Year (H)',
      'Hari Santri Nasional': 'National Santri Day',
      'Hari Pahlawan': 'Heroes Day',
      'Hari Ibu': 'Mothers Day',
      'Hari Sumpah Pemuda': 'Youth Pledge Day',
      'Hari Kartini': 'Kartini Day',
      'Hari Guru Nasional': 'National Teachers Day',
      'Hari Kemerdekaan RI (L)': 'Independence Day (H)',
      'Hari Raya Natal (L)': 'Christmas (H)',
      'Kenaikan Yesus Kristus (L)': 'Ascension Day (H)',
      'Hari Raya Waisak (L)': 'Vesak Day (H)',
    };
    return mapping[holiday] ?? holiday;
  }
}
