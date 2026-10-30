import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.onColor = false,
    this.activity = false,
  });
  final AttendanceStatus status;
  final bool onColor;
  final bool activity;

  @override
  Widget build(BuildContext context) {
    final active = status == AttendanceStatus.checkedIn;
    final scheme = Theme.of(context).colorScheme;
    final color = onColor
        ? Colors.white
        : active
        ? scheme.primary
        : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: onColor
            ? Colors.white.withValues(alpha: 0.16)
            : active
            ? scheme.primaryContainer
            : AppColors.successBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.circle : Icons.check_circle_rounded,
            size: active ? 7 : 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              activity ? status.activityLabel : status.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
