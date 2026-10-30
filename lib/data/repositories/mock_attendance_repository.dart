import '../models/attendance_log.dart';
import '../models/user_profile.dart';
import 'attendance_repository.dart';

/// In-memory demo storage: deliberately resets on a cold app restart.
class MockAttendanceRepository implements AttendanceRepository {
  MockAttendanceRepository({
    DateTime Function()? now,
    this.latency = const Duration(milliseconds: 350),
    List<AttendanceLog>? initialLogs,
  }) : _now = now ?? DateTime.now {
    _logs = List.of(initialLogs ?? _seed(_now()));
  }

  final DateTime Function() _now;
  final Duration latency;
  late final List<AttendanceLog> _logs;
  int _sequence = 0;

  static List<AttendanceLog> _seed(DateTime now) {
    final local = now.toLocal();
    return List.generate(5, (index) {
      final day = DateTime(local.year, local.month, local.day - index - 1);
      return AttendanceLog(
        id: 'history-$index',
        checkIn: DateTime(day.year, day.month, day.day, 9, index * 3),
        checkOut: DateTime(day.year, day.month, day.day, 17, 30 + index * 2),
      );
    });
  }

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<UserProfile> getUserProfile() async {
    await _wait();
    return const UserProfile(
      id: 'demo-user',
      firstName: 'Alex',
      lastName: 'Morgan',
      position: 'Product Designer',
      department: 'Design team',
    );
  }

  @override
  Future<List<AttendanceLog>> getAttendanceLogs() async {
    await _wait();
    final sorted = List<AttendanceLog>.of(_logs)
      ..sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return List.unmodifiable(sorted);
  }

  @override
  Future<AttendanceLog> checkIn() async {
    await _wait();
    if (_logs.any((log) => log.checkOut == null)) {
      throw const AttendanceException('You already have an active session.');
    }
    final at = _now();
    final log = AttendanceLog(
      id: 'session-${at.microsecondsSinceEpoch}-${_sequence++}',
      checkIn: at,
    );
    _logs.add(log);
    return log;
  }

  @override
  Future<AttendanceLog> checkOut() async {
    await _wait();
    final index = _logs.indexWhere((log) => log.checkOut == null);
    if (index == -1) {
      throw const AttendanceException('Check in before ending your session.');
    }
    final at = _now();
    if (at.isBefore(_logs[index].checkIn)) {
      throw const AttendanceException(
        'Your device clock changed. Check the time and retry.',
      );
    }
    final completed = _logs[index].complete(at);
    _logs[index] = completed;
    return completed;
  }
}
