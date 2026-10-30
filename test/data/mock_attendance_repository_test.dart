import 'package:attendance_app/data/models/attendance_log.dart';
import 'package:attendance_app/data/models/attendance_status.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/repositories/mock_attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'check-in/out preserves identity and calculates actual duration',
    () async {
      var now = DateTime(2026, 10, 30, 9);
      final repository = MockAttendanceRepository(
        now: () => now,
        latency: Duration.zero,
        initialLogs: [],
      );
      final started = await repository.checkIn();
      expect(started.status, AttendanceStatus.checkedIn);
      now = now.add(const Duration(hours: 8, minutes: 15));
      final completed = await repository.checkOut();
      expect(completed.id, started.id);
      expect(completed.workingHours, const Duration(hours: 8, minutes: 15));
      expect(completed.status, AttendanceStatus.checkedOut);
      expect((await repository.getAttendanceLogs()).length, 1);
    },
  );

  test('rejects checkout without check-in and duplicate check-ins', () async {
    final repository = MockAttendanceRepository(
      latency: Duration.zero,
      initialLogs: [],
    );
    await expectLater(
      repository.checkOut(),
      throwsA(isA<AttendanceException>()),
    );
    await repository.checkIn();
    await expectLater(
      repository.checkIn(),
      throwsA(isA<AttendanceException>()),
    );
  });

  test(
    'multiple sessions have unique IDs even with the same timestamp',
    () async {
      final repository = MockAttendanceRepository(
        now: () => DateTime(2026, 10, 30, 9),
        latency: Duration.zero,
        initialLogs: [],
      );
      final first = await repository.checkIn();
      await repository.checkOut();
      final second = await repository.checkIn();
      expect(second.id, isNot(first.id));
      final logs = await repository.getAttendanceLogs();
      expect(logs.length, 2);
      expect(() => logs.clear(), throwsUnsupportedError);
    },
  );

  test('clock rollback leaves the session open for retry', () async {
    var now = DateTime(2026, 10, 30, 9);
    final repository = MockAttendanceRepository(
      now: () => now,
      latency: Duration.zero,
      initialLogs: [],
    );
    await repository.checkIn();
    now = now.subtract(const Duration(hours: 1));
    await expectLater(
      repository.checkOut(),
      throwsA(isA<AttendanceException>()),
    );
    expect((await repository.getAttendanceLogs()).single.checkOut, isNull);
  });

  test('invalid session dates are rejected in release as well as debug', () {
    expect(
      () => AttendanceLog(
        id: 'bad',
        checkIn: DateTime(2026, 10, 30, 10),
        checkOut: DateTime(2026, 10, 30, 9),
      ),
      throwsArgumentError,
    );
  });
}
