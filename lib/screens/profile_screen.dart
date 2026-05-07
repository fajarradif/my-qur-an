import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(isDark),
              const SizedBox(height: 40),
              _buildDarkModeToggle(context, isDark),
              const SizedBox(height: 16),
              _buildProfileMenu(Icons.settings, 'Pengaturan', isDark),
              _buildProfileMenu(Icons.history, 'Riwayat Bacaan', isDark),
              _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', isDark),
              _buildProfileMenu(Icons.info_outline, 'Tentang Aplikasi', isDark),
              const SizedBox(height: 40),
              _buildLogoutButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkGold : AppColors.primaryYellow, 
                  width: 4,
                ),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen, 
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'MyQuran User',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'user@myquran.com',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen, 
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isDark 
          ? LinearGradient(
              colors: [AppColors.darkSurface, AppColors.darkCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: isDark ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny,
              key: ValueKey(isDark),
              color: isDark ? AppColors.darkGold : AppColors.primaryYellow,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Gelap',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isDark ? 'Aktif — Hemat baterai' : 'Nonaktif',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeColor: AppColors.darkGold,
            activeTrackColor: AppColors.darkPrimaryGreen,
            inactiveThumbColor: AppColors.mutedGreen,
            inactiveTrackColor: AppColors.iconBgGreen,
            onChanged: (value) {
              // Delay supaya animasi switch selesai dulu, baru ganti tema
              Future.delayed(const Duration(milliseconds: 150), () {
                MyQuranApp.of(context).toggleTheme();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen),
          const SizedBox(width: 16),
          Text(
            title, 
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, 
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? AppColors.darkMutedGreen : AppColors.mutedGreen),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
          foregroundColor: isDark ? Colors.red.shade300 : Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
