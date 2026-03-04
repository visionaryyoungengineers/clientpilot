import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we're in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(24.0), // --radius-lg equivalent
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF161A22).withAlpha(26), // 10% opacity
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

class AeroGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const AeroGlassCard({
    super.key, 
    required this.child, 
    this.padding = const EdgeInsets.all(16.0),
    this.blur = 12.0, // glass-bg default
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
