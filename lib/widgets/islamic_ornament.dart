import 'package:flutter/material.dart';
import '../theme/colors.dart';

class IslamicOrnament extends StatelessWidget {
  final double height;
  const IslamicOrnament({super.key, this.height = 250});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        // Background gradient biar smooth nyatu sama konten bawah
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [AppColors.darkBackground, AppColors.darkBackground.withValues(alpha: 0.0)]
            : [AppColors.deepForestGreen, AppColors.deepForestGreen.withValues(alpha: 0.0)],
        ),
      ),
      child: Stack(
        children: [
          // Gambar Ornamen
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.3 : 0.6, // Biar nggak terlalu mencolok dan nutupin teks
              child: Image.asset(
                'assets/images/mosque_ornament.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                // Kalau gambar belum ada, jangan sampe eror (pake errorBuilder)
                errorBuilder: (context, error, stackTrace) {
                  return Container(); // Kosongin aja kalau gambar belum ditaruh
                },
              ),
            ),
          ),
          // Layer Overlay biar teks di atasnya tetep kebaca
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bg(context).withValues(alpha: 0.8),
                    AppColors.bg(context),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
