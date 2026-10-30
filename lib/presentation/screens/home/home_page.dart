import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatters.dart';
import '../../../data/models/attendance_status.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/attendance_scope.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/primary_action_button.dart';
import '../../widgets/surface_card.dart';
import 'widgets/attendance_log_card.dart';
import 'widgets/live_status_card.dart';
import 'widgets/user_info_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AttendanceController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AttendanceScope.watch(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller?.refreshClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AttendanceScope.watch(context);
    final theme = Theme.of(context);
    final user = controller.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Workspace unavailable.')),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidth,
            ),
            child: ValueListenableBuilder<DateTime>(
              valueListenable: controller.clock,
              builder: (context, now, _) => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      24,
                      AppDimensions.pagePadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const BrandMark(size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AppStrings.appName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'WORKSPACE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    letterSpacing: 1.4,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          UserInfoBar(user: user, now: now),
                          const SizedBox(height: 20),
                          LiveStatusCard(
                            now: now,
                            status: controller.status,
                            lastActionAt: controller.lastActionAt,
                          ),
                          const SizedBox(height: 16),
                          PrimaryActionButton(
                            key: const Key('attendance-action'),
                            label:
                                controller.status == AttendanceStatus.checkedIn
                                ? AppStrings.checkOut
                                : AppStrings.checkIn,
                            icon:
                                controller.status == AttendanceStatus.checkedIn
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            isLoading: controller.isSubmitting,
                            onPressed: () =>
                                unawaited(controller.toggleAttendance()),
                          ),
                          if (controller.actionError != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                controller.actionError!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Demo workspace · Resets when the app restarts',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SurfaceCard(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time worked today',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Across all your sessions',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    DateTimeFormatters.hours(
                                      controller.workedToday(now),
                                    ),
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            AppStrings.recentActivity,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A clear view of your time, day by day.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (controller.logs.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SurfaceCard(
                          child: Text(
                            'Your workday starts here. Check in to create your first activity.',
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePadding,
                      ),
                      sliver: SliverList.builder(
                        itemCount: controller.logs.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AttendanceLogCard(
                            log: controller.logs[index],
                            now: now,
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
