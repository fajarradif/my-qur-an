import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../main.dart';
import '../services/app_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = MyQuranApp.settingsOf(context);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(isDark, settings),
              const SizedBox(height: 40),
              _buildDarkModeToggle(context, isDark),
              const SizedBox(height: 16),
              _buildProfileMenu(Icons.settings, settings.t('Pengaturan', 'Settings'), isDark, onTap: () => _showSettingsDialog(context, isDark)),
              _buildProfileMenu(Icons.help_outline, settings.t('Pusat Bantuan', 'Help Center'), isDark, onTap: () => _showHelpDialog(context, isDark)),
              _buildProfileMenu(Icons.info_outline, settings.t('Tentang Aplikasi', 'About Application'), isDark, onTap: () => _showAboutDialog(context, isDark)),
              const SizedBox(height: 40),
              _buildLogoutButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, AppSettings settings) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                  border: Border.all(
                    color: isDark ? AppColors.darkGold : AppColors.primaryYellow, 
                    width: 4,
                  ),
                  image: settings.userPhotoPath != null 
                    ? DecorationImage(
                        image: FileImage(File(settings.userPhotoPath!)),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
                ),
                child: settings.userPhotoPath == null 
                  ? Icon(Icons.person, size: 60, color: isDark ? Colors.white24 : Colors.grey.shade400)
                  : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen, 
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              settings.userName,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, 
                fontSize: 22, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditProfileDialog(settings, isDark),
              child: Icon(Icons.edit, size: 18, color: isDark ? AppColors.darkGold : AppColors.primaryYellow),
            ),
          ],
        ),
        Text(
          settings.userEmail,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.mutedGreen, 
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final settings = MyQuranApp.settingsOf(context);
      await settings.updateProfile(
        name: settings.userName,
        email: settings.userEmail,
        photoPath: image.path,
      );
    }
  }

  void _showEditProfileDialog(AppSettings settings, bool isDark) {
    final nameController = TextEditingController(text: settings.userName);
    final emailController = TextEditingController(text: settings.userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(settings.t('Edit Profil', 'Edit Profile'), 
          style: TextStyle(color: isDark ? Colors.white : AppColors.primaryGreen, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: settings.t('Nama', 'Name'),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.mutedGreen),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.mutedGreen),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () async {
              await settings.updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), 
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny,
            color: isDark ? AppColors.darkGold : AppColors.primaryYellow,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyQuranApp.settingsOf(context).t('Mode Gelap', 'Dark Mode'),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isDark ? 'Aktif' : 'Nonaktif',
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
            onChanged: (value) {
              MyQuranApp.of(context).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, bool isDark) {
    final settings = MyQuranApp.settingsOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(settings.t('Pengaturan Aplikasi', 'App Settings'),
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildLanguageSelector(settings, isDark, setModalState),

                const SizedBox(height: 16),

                _buildNotifToggle(settings, isDark, setModalState),

                const SizedBox(height: 20),
                _buildSaveButton(context, settings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector(AppSettings settings, bool isDark, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 10),
              Text(settings.t('Bahasa Aplikasi', 'App Language'),
                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _languageCard(settings, 'id', '🇮🇩', 'Indonesia', isDark, setModalState),
              const SizedBox(width: 16),
              _languageCard(settings, 'en', '🇬🇧', 'Inggris', isDark, setModalState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageCard(AppSettings settings, String code, String flag, String name, bool isDark, StateSetter setModalState) {
    final isActive = settings.language == code;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          settings.setLanguage(code);
          setModalState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isActive ? AppColors.primaryGreen : Colors.grey.withOpacity(0.3), width: 2),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(name,
                style: TextStyle(
                  color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold, fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifToggle(AppSettings settings, bool isDark, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: AppColors.primaryYellow, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(settings.t('Notifikasi Waktu Sholat', 'Prayer Notification'),
              style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Switch.adaptive(
            value: settings.prayerNotifEnabled,
            activeColor: AppColors.primaryYellow,
            onChanged: (val) {
              settings.setPrayerNotifEnabled(val);
              setModalState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppSettings settings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(settings.t('Simpan & Tutup', 'Save & Close'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent, size: 60, color: Color(0xFF25D366)),
            const SizedBox(height: 16),
            Text('Pusat Bantuan', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Hubungi kami via WhatsApp:', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('0838-6368-4320', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _launchWhatsApp(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              child: const Text('Buka WhatsApp', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = Uri.parse('https://wa.me/6283863684320');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka WhatsApp')));
    }
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showAboutDialog(
      context: context,
      applicationName: 'MyQuran',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.mosque, color: AppColors.primaryGreen),
      children: [const Text('Aplikasi Al-Quran Digital Premium.')],
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? AppColors.darkGold : AppColors.primaryGreen),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.primaryGreen, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
