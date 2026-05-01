import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/last_read_card.dart';
import '../services/bookmark_service.dart';
import 'detail_surat_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.deepGreen,
        title: const Text('BOOKMARKS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terakhir Dibaca',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LastReadCard(onRefresh: () => setState(() {})),
              const SizedBox(height: 32),
              _buildInspirationPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspirationPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryYellow, size: 32),
          const SizedBox(height: 16),
          const Text(
            'Lanjutkan tilawahmu hari ini untuk mendapatkan pahala dan ketenangan hati.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

