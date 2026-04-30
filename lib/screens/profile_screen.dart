import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 40),
              _buildProfileMenu(Icons.settings, 'Pengaturan'),
              _buildProfileMenu(Icons.history, 'Riwayat Bacaan'),
              _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan'),
              _buildProfileMenu(Icons.info_outline, 'Tentang Aplikasi'),
              const SizedBox(height: 40),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryYellow, width: 4),
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
                decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'MyQuran User',
          style: TextStyle(color: AppColors.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'user@myquran.com',
          style: TextStyle(color: AppColors.mutedGreen, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mutedGreen),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
