import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/attendance_status.dart';
import '../../../widgets/status_chip.dart';

class LiveStatusCard extends StatelessWidget {
  const LiveStatusCard({
    super.key,
    required this.now,
    required this.status,
    required this.lastActionAt,
  });
  final DateTime now;
  final AttendanceStatus status;
  final DateTime? lastActionAt;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, Color(0xFF8272E7)],
      ),
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'YOUR WORKDAY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            StatusChip(status: status, onColor: true),
          ],
        ),
        const SizedBox(height: 24),
        Semantics(
          label: 'Current local time ${DateTimeFormatters.clock(now)}',
          excludeSemantics: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              DateTimeFormatters.clock(now),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status == AttendanceStatus.checkedIn
              ? 'You’re on the clock. Make it a good day.'
              : 'A fresh start is one check-in away.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: Colors.white.withValues(alpha: 0.23)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.history_rounded, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lastActionAt == null
                    ? 'No attendance recorded yet'
                    : 'Last action · ${DateTimeFormatters.shortDate(lastActionAt!)} at ${DateTimeFormatters.time(lastActionAt)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
