import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'feature_menu_button.dart';

class AllFeaturesSheet extends StatelessWidget {
  const AllFeaturesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Semua Fitur',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            children: [
              FeatureMenuButton(
                icon: Icons.menu_book,
                label: 'Al-Quran',
                onTap: () {
                  Navigator.pop(context);
                  // Default action to switch to Quran Tab can be handled by callback if needed
                },
              ),
              FeatureMenuButton(
                icon: Icons.book_online,
                label: 'Tahlil & Yasin',
                onTap: () => Navigator.pop(context),
              ),
              FeatureMenuButton(
                icon: Icons.brightness_high,
                label: 'Tasbih',
                onTap: () => Navigator.pop(context),
              ),
              FeatureMenuButton(
                icon: Icons.explore,
                label: 'Kiblat',
                onTap: () => Navigator.pop(context),
              ),
              // NEW FEATURE: Murottal
              FeatureMenuButton(
                icon: Icons.headphones,
                label: 'Murottal',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Buka halaman Murottal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Murottal akan segera dibuat!')),
                  );
                },
              ),
              FeatureMenuButton(
                icon: Icons.pan_tool,
                label: 'Doa-doa',
                onTap: () => Navigator.pop(context),
              ),
              FeatureMenuButton(
                icon: Icons.calendar_month,
                label: 'Jadwal',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
