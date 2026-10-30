import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/data/repositories/mock_attendance_repository.dart';
import 'package:attendance_app/main.dart';
import 'package:attendance_app/presentation/controllers/attendance_controller.dart';
import 'package:attendance_app/presentation/controllers/attendance_scope.dart';
import 'package:attendance_app/presentation/screens/home/home_page.dart';
import 'package:attendance_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'splash waits two seconds then navigates and toggles attendance',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        AttendanceApp(repository: MockAttendanceRepository()),
      );
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1999));
      expect(find.byType(HomePage), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Checked Out'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('attendance-action')));
      await tester.tap(find.text('Check In'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Checked In'), findsOneWidget);
      expect(find.text('Check Out'), findsOneWidget);
      await tester.tap(find.text('Check Out'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Checked Out'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'dashboard supports narrow screens and large text (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AttendanceController(
          repository: MockAttendanceRepository(latency: Duration.zero),
        );
        await tester.runAsync(controller.initialize);
        await tester.pumpWidget(
          AttendanceScope(
            controller: controller,
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const HomePage(),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );
  }

  testWidgets('empty history shows an invitation to check in', (tester) async {
    final controller = AttendanceController(
      repository: MockAttendanceRepository(
        latency: Duration.zero,
        initialLogs: [],
      ),
    );
    await tester.runAsync(controller.initialize);
    await tester.pumpWidget(
      AttendanceScope(
        controller: controller,
        child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
      ),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();
    expect(
      find.text(
        'Your workday starts here. Check in to create your first activity.',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
