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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: const TextStyle(
              color: AppColors.mutedGreen, 
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )
          ),
        ],
      ),
    );
  }
}
