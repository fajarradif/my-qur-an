import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LastReadCard extends StatelessWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('Terakhir Dibaca', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Surah', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Al - Fatihah', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBackground,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('Lanjutkan >'),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.auto_stories, size: 110, color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
