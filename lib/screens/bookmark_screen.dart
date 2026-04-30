import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.iconBgGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_border, size: 80, color: AppColors.primaryYellow),
              ),
              const SizedBox(height: 24),
              const Text(
                'Belum Ada Bookmark',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Ayat yang kamu tandai akan muncul di sini agar mudah dibaca kembali.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedGreen, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
