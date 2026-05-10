import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
              _buildProfileMenu(Icons.settings, 'Pengaturan', isDark, onTap: null),
              _buildProfileMenu(Icons.history, 'Riwayat Bacaan', isDark, onTap: null),
              _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', isDark, onTap: () => _showHelpDialog(context, isDark)),
              _buildProfileMenu(Icons.info_outline, 'Tentang Aplikasi', isDark, onTap: () => _showAboutDialog(context, isDark)),
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

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phone = '6283863684320'; // 083... -> 6283...
    const message = 'Halo Radifullah, saya pengguna aplikasi MyQuran. Saya ingin menyampaikan:';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
        );
      }
    }
  }

  void _showHelpDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF25D366).withOpacity(0.15),
                ),
                child: const Center(
                  child: Icon(Icons.support_agent_rounded, size: 36, color: Color(0xFF25D366)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Pusat Bantuan',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
                  fontSize: 20, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punya pertanyaan, saran, atau menemukan bug?',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
                      fontWeight: FontWeight.w600, fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungi developer langsung via WhatsApp. Kami siap membantu kamu!',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen,
                      fontSize: 13, height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Color(0xFF25D366)),
                const SizedBox(width: 8),
                Text('Developer: ', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen, fontSize: 13)),
                Text('Radifullah', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF25D366)),
                const SizedBox(width: 8),
                Text('WhatsApp: ', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen, fontSize: 13)),
                Text('0838-6368-4320', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchWhatsApp(context);
                },
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Buka WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup', style: TextStyle(color: isDark ? AppColors.darkMutedGreen : AppColors.mutedGreen)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.darkPrimaryGreen],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text('م', style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'Scheherazade')),
              ),
            ),
            const SizedBox(height: 16),
            Text('MyQuran',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
                fontSize: 22, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Versi 1.0.0',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: (isDark ? AppColors.darkMutedGreen : AppColors.mutedGreen).withOpacity(0.3)),
            const SizedBox(height: 16),
            _aboutRow(Icons.person, 'Pembuat', 'Radifullah', isDark),
            const SizedBox(height: 10),
            _aboutRow(Icons.code, 'Framework', 'Flutter & Dart', isDark),
            const SizedBox(height: 10),
            _aboutRow(Icons.school, 'Tujuan', 'Proyek UAS Mobile', isDark),
            const SizedBox(height: 10),
            _aboutRow(Icons.favorite, 'Dibuat dengan', 'Bismillah ❤️', isDark),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen, fontSize: 13)),
        Expanded(
          child: Text(value,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
              fontWeight: FontWeight.w600, fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: onTap != null
                ? (isDark ? AppColors.darkGold : AppColors.primaryYellow)
                : (isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen)),
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
