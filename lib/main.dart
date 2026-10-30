import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/mock_attendance_repository.dart';
import 'presentation/controllers/attendance_controller.dart';
import 'presentation/controllers/attendance_scope.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AttendanceApp(repository: MockAttendanceRepository()));
}

/// Composition root: replace the repository here to connect a live backend.
class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key, required this.repository});
  final AttendanceRepository repository;

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  late final AttendanceController _controller = AttendanceController(
    repository: widget.repository,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AttendanceScope(
    controller: _controller,
    child: MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    ),
  );
}
