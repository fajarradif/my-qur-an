import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FeatureMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FeatureMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.sf(context),
              borderRadius: BorderRadius.circular(20),
              border: AppColors.isDark(context) ? null : Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppColors.isDark(context) ? 0.2 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: AppColors.isDark(context) ? AppColors.darkGold : AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: TextStyle(
              color: AppColors.muted(context), 
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )
          ),
        ],
      ),
    );
  }
}
