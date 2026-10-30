import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/attendance_log.dart';
import '../../../widgets/status_chip.dart';
import '../../../widgets/surface_card.dart';

class AttendanceLogCard extends StatelessWidget {
  const AttendanceLogCard({super.key, required this.log, required this.now});
  final AttendanceLog log;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateTimeFormatters.shortDate(log.date),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusChip(status: log.status, activity: true),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth < 250 ||
                      MediaQuery.textScalerOf(context).scale(14) > 22
                  ? 2
                  : 3;
              final width =
                  (constraints.maxWidth - 12 * (columns - 1)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  _Metric(
                    label: 'Check-in',
                    value: DateTimeFormatters.time(log.checkIn),
                    width: width,
                  ),
                  _Metric(
                    label: 'Check-out',
                    value: DateTimeFormatters.time(log.checkOut),
                    width: width,
                  ),
                  _Metric(
                    label: 'Working hours',
                    value: DateTimeFormatters.hours(log.elapsedAt(now)),
                    width: width,
                  ),
                ],
              );
            },
          ),
          if (log.checkOut != null &&
              DateUtils.dateOnly(log.checkOut!.toLocal()) !=
                  DateUtils.dateOnly(log.date)) ...[
            const SizedBox(height: 12),
            Text(
              'Ended ${DateTimeFormatters.shortDate(log.checkOut!)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.width,
  });
  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
