import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AeroBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)), // radius-xl
                boxShadow: [
                  // elevation-hero: 0 12px 48px -8px hsl(220 20% 10% / 0.08) (approximation inverted for top sheet)
                  BoxShadow(
                    color: const Color(0xFF161A22).withAlpha(20), // 8% opacity
                    blurRadius: 48,
                    spreadRadius: 0,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mutedForeground.withAlpha(60),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
