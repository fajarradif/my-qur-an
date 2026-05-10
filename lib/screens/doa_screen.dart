import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../models/doa.dart';
import '../services/api_service.dart';
import '../main.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

  static String translateDoaTitle(String title) {
    final String t = title.toLowerCase();
    
    // Keyword Matching yang lebih luas sesuai API MyQuran
    if (t.contains('mohon') && t.contains('kebaikan')) return 'Prayer for Goodness';
    if (t.contains('dunia') && t.contains('akhirat')) return 'Prayer for World & Hereafter';
    if (t.contains('perlindungan')) return 'Prayer for Protection';
    if (t.contains('keselamatan')) return 'Prayer for Safety';
    if (t.contains('keteguhan') || t.contains('kekuatan')) {
       if (t.contains('iman')) return 'Prayer for Strength of Faith';
    }
    if (t.contains('ampunan')) return 'Prayer for Forgiveness';
    if (t.contains('keadilan')) return 'Prayer for Justice';
    if (t.contains('api neraka')) return 'Protection from Hellfire';
    if (t.contains('lawan')) return 'Prayer against Opponents';
    if (t.contains('husnul khatimah')) return 'Prayer for Good Ending';
    if (t.contains('penyesalan') || t.contains('istighfar')) return 'Prayer of Repentance';
    if (t.contains('sabar') || t.contains('tabah')) return 'Prayer for Patience';
    if (t.contains('ilmu') || t.contains('belajar')) return 'Prayer for Knowledge';
    if (t.contains('rezeki') || t.contains('rizki')) return 'Prayer for Sustenance';
    if (t.contains('keluarga')) return 'Prayer for Family';
    if (t.contains('orang tua')) return 'Prayer for Parents';
    if (t.contains('sakit') || t.contains('sembuh')) return 'Prayer for Healing';
    
    // Default mapping untuk adab harian
    if (t.contains('makan')) return 'Prayer for Eating';
    if (t.contains('tidur')) return 'Prayer for Sleeping';
    if (t.contains('wudhu')) return 'Prayer for Wudu';
    if (t.contains('masjid')) return 'Prayer for Mosque';
    if (t.contains('rumah')) return 'Prayer for Home';
    if (t.contains('pakaian')) return 'Prayer for Clothing';
    if (t.contains('kamar mandi')) return 'Prayer for Bathroom';

    return title;
  }

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  late Future<List<Doa>> futureDoaList;
  List<Doa> _allDoas = [];
  List<Doa> _filteredDoas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureDoaList = ApiService.getDoaList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDoas = _allDoas
          .where((doa) =>
              doa.judul.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(MyQuranApp.settingsOf(context).t('Doa-doa Harian', 'Daily Prayers'), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.bg(context),
        iconTheme: IconThemeData(color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen),
        actions: [
          IconButton(
            icon: Icon(
              AppColors.isDark(context) ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.green(context),
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
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<Doa>>(
              future: futureDoaList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: AppColors.isDark(context) ? Colors.white : Colors.black)),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(MyQuranApp.settingsOf(context).t('Tidak ada data doa.', 'No prayer data.'), style: TextStyle(color: AppColors.isDark(context) ? Colors.white : Colors.black)));
                }

                if (_allDoas.isEmpty) {
                  _allDoas = snapshot.data!;
                  _filteredDoas = _allDoas;
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredDoas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doa = _filteredDoas[index];
                    return _buildDoaItem(doa);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.isDark(context) ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: MyQuranApp.settingsOf(context).t('Cari doa...', 'Search prayer...'),
          hintStyle: TextStyle(color: AppColors.isDark(context) ? Colors.white54 : Colors.grey),
          prefixIcon: Icon(Icons.search, color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen),
          filled: true,
          fillColor: AppColors.sf(context),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  String _getTranslatedTitle(String title) {
    if (MyQuranApp.settingsOf(context).language == 'id') return title;
    return DoaScreen.translateDoaTitle(title);
  }

  Widget _buildDoaItem(Doa doa) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DoaDetailScreen(doa: doa)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(AppColors.isDark(context) ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book, color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getTranslatedTitle(doa.judul),
                style: TextStyle(color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen, size: 14),
          ],
        ),
      ),
    );
  }
}

class DoaDetailScreen extends StatelessWidget {
  final Doa doa;
  const DoaDetailScreen({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(MyQuranApp.settingsOf(context).t('Detail Doa', 'Prayer Detail'), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen)),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen),
        actions: [
          IconButton(
            icon: Icon(
              AppColors.isDark(context) ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.green(context),
            ),
            onPressed: () {
              MyQuranApp.of(context).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${doa.judul}\n\n${doa.doa}\n\n${doa.artinya}'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(MyQuranApp.settingsOf(context).t('Doa disalin ke clipboard', 'Prayer copied to clipboard'))),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              MyQuranApp.settingsOf(context).language == 'en' 
                  ? DoaScreen.translateDoaTitle(doa.judul) 
                  : doa.judul,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              doa.doa,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen,
                fontSize: 26,
                fontFamily: 'QuranFont',
                height: 2,
              ),
            ),
            const SizedBox(height: 24),
            if (doa.latin.isNotEmpty) ...[
              Text(
                doa.latin,
                style: TextStyle(
                  color: AppColors.isDark(context) ? Colors.white70 : AppColors.primaryGreen,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Divider(color: AppColors.isDark(context) ? Colors.white24 : AppColors.primaryGreen, thickness: 0.5),
            const SizedBox(height: 16),
            Text(
              MyQuranApp.settingsOf(context).t('Artinya:', 'Meaning:'),
              style: TextStyle(
                color: AppColors.isDark(context) ? AppColors.primaryYellow : AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              doa.artinya,
              style: TextStyle(
                color: AppColors.isDark(context) ? Colors.white70 : AppColors.primaryGreen,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
