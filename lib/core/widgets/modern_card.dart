import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.borderRadius),
        ),
        elevation: 8,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surface],
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
