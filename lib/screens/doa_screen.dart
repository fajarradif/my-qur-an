import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../models/doa.dart';
import '../services/api_service.dart';
import '../main.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

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
        title: Text('Doa-doa Harian', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen)),
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
                  return Center(child: Text('Tidak ada data doa.', style: TextStyle(color: AppColors.isDark(context) ? Colors.white : Colors.black)));
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
          hintText: 'Cari doa...',
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
                doa.judul,
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
        title: Text('Detail Doa', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDark(context) ? Colors.white : AppColors.primaryGreen)),
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
                const SnackBar(content: Text('Doa disalin ke clipboard')),
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
              doa.judul,
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
              'Artinya:',
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
