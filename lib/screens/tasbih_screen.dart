import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  int _target = 33;
  final TextEditingController _dhikrController = TextEditingController(text: 'Subhanallah');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _dhikrController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dhikrController.text = prefs.getString('custom_dhikr') ?? 'Subhanallah';
      _target = prefs.getInt('tasbih_target') ?? 33;
    });
  }

  Future<void> _saveDhikr(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_dhikr', text);
  }

  Future<void> _saveTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_target', target);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter == _target) {
        // Getar beruntun biar lebih berasa
        HapticFeedback.vibrate();
        Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.vibrate());
        Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.vibrate());
      } else {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _decrementCounter() {
    if (_counter > 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _counter--;
      });
    }
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
    });
  }

  void _showTargetDialog() {
    final TextEditingController targetEditController = TextEditingController(text: _target.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Target Dzikir', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: targetEditController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contoh: 33, 99, 100',
            filled: true,
            fillColor: AppColors.sf(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final int? newTarget = int.tryParse(targetEditController.text);
              if (newTarget != null && newTarget > 0) {
                setState(() => _target = newTarget);
                _saveTarget(newTarget);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Target Info (Bisa diklik juga buat ganti)
            GestureDetector(
              onTap: _showTargetDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag, color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Target: $_target',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Counter Display
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            
            // Editable Dhikr Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1), width: 1),
                ),
                child: TextField(
                  controller: _dhikrController,
                  textAlign: TextAlign.center,
                  onChanged: _saveDhikr,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukkan doa/dzikir...',
                    hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 14),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.edit_note, color: AppColors.primaryGreen, size: 18),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 16),
                      onPressed: () {
                        _dhikrController.clear();
                        _saveDhikr('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Main Tap Area
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 200,
                height: 200,
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
                    width: 165,
                    height: 165,
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
                      size: 55,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onTap: _resetCounter,
                ),
                const SizedBox(width: 25),
                _actionButton(
                  icon: Icons.remove_circle_outline,
                  label: 'Kurangi',
                  onTap: _decrementCounter,
                ),
                const SizedBox(width: 25),
                _actionButton(
                  icon: Icons.settings,
                  label: 'Target',
                  onTap: _showTargetDialog,
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

