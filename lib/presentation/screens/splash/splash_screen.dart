import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/attendance_scope.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/dynamic_loader.dart';
import '../home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;
  bool _transitioning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      final controller = AttendanceScope.watch(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_initialize(controller));
      });
    }
  }

  Future<void> _initialize(AttendanceController controller) async {
    await Future.wait<void>([
      controller.initialize(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted || !controller.isReady || _transitioning) return;
    _transitioning = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    unawaited(
      Navigator.of(context).pushReplacement<void, void>(
        PageRouteBuilder<void>(
          transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 400),
          pageBuilder: (_, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AttendanceScope.watch(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrandMark(size: 88),
                        const SizedBox(height: 28),
                        Text(
                          AppStrings.appName,
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.tagline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (controller.initializationError != null) ...[
                          Text(
                            controller.initializationError!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: controller.isInitializing
                                ? null
                                : () => unawaited(_initialize(controller)),
                            child: const Text('Try again'),
                          ),
                        ] else ...[
                          const DynamicLoader(
                            label: 'Preparing your workspace',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Preparing your workspace',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'A little clarity for every workday.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
