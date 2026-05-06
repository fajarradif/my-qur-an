import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  final int _target = 33;

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasbih Digital', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Target Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Target: $_target',
                style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 50),
            
            // Counter Display
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const Text(
              'Subhanallah',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.mutedGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Main Tap Area
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.3), width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.deepGreen,
                          AppColors.emeraldGreen,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onTap: _resetCounter,
                ),
                const SizedBox(width: 40),
                _actionButton(
                  icon: Icons.settings,
                  label: 'Target',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.primaryGreen, size: 30),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.mutedGreen, fontSize: 12),
        ),
      ],
    );
  }
}
