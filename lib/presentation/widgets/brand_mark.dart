import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(size * 0.3),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Icon(Icons.av_timer_rounded, color: Colors.white, size: size * 0.58),
  );
}
