import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';

class QuranNumberMarker extends StatelessWidget {
  final String number;
  final double size;
  final Color? color;
  final TextStyle? textStyle;
  final bool isInline; // New parameter for Mushaf mode integration

  const QuranNumberMarker({
    super.key,
    required this.number,
    this.size = 40,
    this.color,
    this.textStyle,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? AppColors.primaryYellow;
    final bool isSmall = size < 30;
    
    return Container(
      width: size,
      height: size,
      margin: isInline ? const EdgeInsets.symmetric(horizontal: 4) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ornamental shape
          Transform.rotate(
            angle: math.pi / 8, // More traditional octagonal feel
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                border: Border.all(color: markerColor.withOpacity(0.5), width: isSmall ? 0.5 : 1.0),
                borderRadius: BorderRadius.circular(isSmall ? 2 : 4),
              ),
            ),
          ),
          // Background Ornamental Shape (Square rotated 45 deg)
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                border: Border.all(color: markerColor, width: isSmall ? 1.0 : 1.5),
                borderRadius: BorderRadius.circular(isSmall ? 2 : 4),
              ),
            ),
          ),
          // Inner circle for contrast if inline
          if (isInline)
             Container(
               width: size * 0.5,
               height: size * 0.5,
               decoration: BoxDecoration(
                 color: markerColor.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
             ),
          // The Number
          Text(
            number,
            style: textStyle ?? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 8 : (number.length > 2 ? 10 : 12),
              color: color ?? AppColors.primaryGreen,
              fontFamily: 'Roboto', // Keep number clear
            ),
          ),
        ],
      ),
    );
  }
}
