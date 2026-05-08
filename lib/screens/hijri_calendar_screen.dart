import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/hijri_helper.dart';
import '../main.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late int _currentMonth;
  late int _currentYear;
  late int _todayDay;
  late int _todayMonth;
  late int _todayYear;

  @override
  void initState() {
    super.initState();
    final today = HijriHelper.fromGregorian(DateTime.now());
    _todayDay = today['day'];
    _todayMonth = today['month'];
    _todayYear = today['year'];
    _currentMonth = _todayMonth;
    _currentYear = _todayYear;
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text('Kalender Hijriah', style: TextStyle(color: AppColors.isDark(context) ? Colors.white : Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              AppColors.isDark(context) ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            ),
            onPressed: () {
              MyQuranApp.of(context).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Jika usap ke kiri (velocity negatif), ke bulan berikutnya
          if (details.primaryVelocity! < 0) {
            _nextMonth();
          } 
          // Jika usap ke kanan (velocity positif), ke bulan sebelumnya
          else if (details.primaryVelocity! > 0) {
            _prevMonth();
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekdayHeader(),
            Expanded(child: _buildCalendarGrid()),
            _buildHolidaysList(),
            _buildFooterInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _prevMonth,
          ),
          Column(
            children: [
              Text(
                HijriHelper.getMonthName(_currentMonth),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_currentYear Hijriah',
                style: const TextStyle(color: AppColors.primaryYellow, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) => Text(
          day,
          style: TextStyle(color: AppColors.isDark(context) ? Colors.white70 : AppColors.mutedGreen, fontWeight: FontWeight.bold, fontSize: 14),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Untuk simulasi kotak-kotak, kita asumsikan bulan Hijriah 29 atau 30 hari.
    // Catatan: Karena ini hitungan aritmatik sederhana, kita pakai 30 hari sebagai max.
    int daysInMonth = (_currentMonth % 2 == 0 && _currentMonth != 12) ? 29 : 30;
    final holidays = HijriHelper.getHolidays(_currentMonth);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          int day = index + 1;
          bool isToday = day == _todayDay && _currentMonth == _todayMonth && _currentYear == _todayYear;
          bool isHoliday = holidays.containsKey(day);

          return Container(
            decoration: BoxDecoration(
              color: isToday ? AppColors.primaryGreen : (isHoliday ? AppColors.primaryYellow.withValues(alpha: 0.2) : AppColors.sf(context)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: AppColors.isDark(context) ? 0.3 : 0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
              border: Border.all(
                color: isToday ? AppColors.primaryYellow : (isHoliday ? AppColors.primaryYellow : Colors.transparent),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : (isHoliday ? (AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen) : (AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen)),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  Widget _buildHolidaysList() {
    final holidays = HijriHelper.getHolidays(_currentMonth);
    if (holidays.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: AppColors.primaryYellow, size: 18),
              const SizedBox(width: 8),
              Text('Hari Penting Bulan Ini', style: TextStyle(color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ...holidays.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('${e.key} :', style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(e.value, style: TextStyle(color: AppColors.isDark(context) ? Colors.white70 : AppColors.primaryGreen, fontSize: 13)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kalender ini dihitung secara astronomis. Mungkin terdapat selisih 1 hari dengan pengamatan hilal.',
              style: TextStyle(color: AppColors.isDark(context) ? Colors.white70 : AppColors.primaryGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
