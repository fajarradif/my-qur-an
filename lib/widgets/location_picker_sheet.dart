import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isLoading = true);
      final results = await ApiService.searchCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mutedGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pilih Lokasi',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Tombol Gunakan GPS Otomatis
          InkWell(
            onTap: () => Navigator.pop(context, {'action': 'gps'}),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryYellow.withValues(alpha: 0.1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.my_location, color: AppColors.primaryYellow),
                  SizedBox(width: 12),
                  Text(
                    'Gunakan Lokasi Saat Ini (GPS)',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.mutedGreen)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('ATAU CARI MANUAL', style: TextStyle(color: AppColors.mutedGreen, fontSize: 10)),
                ),
                Expanded(child: Divider(color: AppColors.mutedGreen)),
              ],
            ),
          ),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Ketik nama kota (min. 3 huruf)...',
              hintStyle: TextStyle(color: AppColors.mutedGreen.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search, color: AppColors.mutedGreen),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search Results
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          else if (_searchResults.isNotEmpty)
            SizedBox(
              height: 250,
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(color: AppColors.mutedGreen.withValues(alpha: 0.2)),
                itemBuilder: (context, index) {
                  final city = _searchResults[index];
                  // Bersihkan "KOTA " dari nama yang tampil
                  String cityName = city['lokasi'].toString().replaceAll(RegExp(r'(KOTA|KAB\.)\s+', caseSensitive: false), '').trim();
                  // Format jadi CamelCase
                  cityName = cityName.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase()).join(' ');
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_city, color: AppColors.mutedGreen),
                    title: Text(city['lokasi'], style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
                    onTap: () => Navigator.pop(context, {
                      'action': 'manual',
                      'id': city['id'],
                      'name': cityName,
                    }),
                  );
                },
              ),
            )
          else if (_searchController.text.length >= 3)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Kota tidak ditemukan', style: TextStyle(color: AppColors.mutedGreen)),
            ),
            
          // Padding bottom to avoid keyboard overlap
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
