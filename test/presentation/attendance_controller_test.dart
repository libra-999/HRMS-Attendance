import 'package:attendance_app/data/models/attendance_log.dart';
import 'package:attendance_app/data/models/attendance_status.dart';
import 'package:attendance_app/data/models/user_profile.dart';
import 'package:attendance_app/data/repositories/mock_attendance_repository.dart';
import 'package:attendance_app/presentation/controllers/attendance_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class RecoverableRepository extends MockAttendanceRepository {
  RecoverableRepository() : super(latency: Duration.zero, initialLogs: []);
  bool failInitialization = true;
  bool failAction = false;

  @override
  Future<UserProfile> getUserProfile() async {
    if (failInitialization) throw Exception('Unavailable');
    return super.getUserProfile();
  }

  @override
  Future<AttendanceLog> checkIn() async {
    if (failAction) throw Exception('Unavailable');
    return super.checkIn();
  }
}

void main() {
  test('initialization can recover after a failure', () async {
    final repository = RecoverableRepository();
    final controller = AttendanceController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.isReady, isFalse);
    expect(controller.initializationError, isNotNull);
    repository.failInitialization = false;
    await controller.initialize();
    expect(controller.isReady, isTrue);
    expect(controller.initializationError, isNull);
    expect(controller.user?.firstName, 'Alex');
  });

  test(
    'rapid taps create one session and checkout updates that session',
    () async {
      var now = DateTime(2026, 10, 30, 9);
      final repository = MockAttendanceRepository(
        now: () => now,
        latency: const Duration(milliseconds: 10),
        initialLogs: [],
      );
      final controller = AttendanceController(
        repository: repository,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await Future.wait([
        controller.toggleAttendance(),
        controller.toggleAttendance(),
      ]);
      expect(controller.logs.length, 1);
      expect(controller.status, AttendanceStatus.checkedIn);
      now = now.add(const Duration(hours: 4));
      await controller.toggleAttendance();
      expect(controller.logs.length, 1);
      expect(controller.status, AttendanceStatus.checkedOut);
      expect(controller.workedToday(now), const Duration(hours: 4));
      expect(controller.lastActionAt, now);
    },
  );

  test(
    'failed action preserves state and supports a subsequent retry',
    () async {
      final repository = RecoverableRepository()..failInitialization = false;
      final controller = AttendanceController(repository: repository);
      addTearDown(controller.dispose);
      await controller.initialize();
      repository.failAction = true;
      await controller.toggleAttendance();
      expect(controller.actionError, isNotNull);
      expect(controller.logs, isEmpty);
      expect(controller.isSubmitting, isFalse);
      repository.failAction = false;
      await controller.toggleAttendance();
      expect(controller.actionError, isNull);
      expect(controller.status, AttendanceStatus.checkedIn);
    },
  );

  test(
    'today total clips overnight sessions and includes active time',
    () async {
      final now = DateTime(2026, 10, 30, 11);
      final repository = MockAttendanceRepository(
        latency: Duration.zero,
        initialLogs: [
          AttendanceLog(
            id: 'overnight',
            checkIn: DateTime(2026, 10, 29, 22),
            checkOut: DateTime(2026, 10, 30, 2),
          ),
          AttendanceLog(id: 'active', checkIn: DateTime(2026, 10, 30, 9)),
          AttendanceLog(
            id: 'old',
            checkIn: DateTime(2026, 10, 28, 9),
            checkOut: DateTime(2026, 10, 28, 17),
          ),
        ],
      );
      final controller = AttendanceController(
        repository: repository,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.workedToday(now), const Duration(hours: 4));
      expect(controller.logs.first.id, 'active');
    },
  );

  test('dispose during initialization safely ignores late results', () async {
    final controller = AttendanceController(
      repository: MockAttendanceRepository(
        latency: const Duration(milliseconds: 10),
      ),
    );
    final pending = controller.initialize();
    controller.dispose();
    await pending;
    expect(controller.isReady, isFalse);
  });

  test('dispose during submission safely ignores late results', () async {
    final controller = AttendanceController(
      repository: MockAttendanceRepository(
        latency: const Duration(milliseconds: 10),
        initialLogs: [],
      ),
    );
    await controller.initialize();
    final pending = controller.toggleAttendance();
    controller.dispose();
    await pending;
    expect(controller.logs, isEmpty);
  });

  testWidgets('clock reads wall time each tick and stops on disposal', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 30, 9);
    final controller = AttendanceController(
      repository: MockAttendanceRepository(),
      now: () => now,
    );
    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(controller.clock.value, now);
    controller.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
