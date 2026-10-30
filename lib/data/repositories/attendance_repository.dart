import '../models/attendance_log.dart';
import '../models/user_profile.dart';

/// Implementations own identity, timestamps, persistence, and atomic validation.
/// A future API adapter can map its DTOs to these immutable models.
abstract interface class AttendanceRepository {
  Future<UserProfile> getUserProfile();
  Future<List<AttendanceLog>> getAttendanceLogs();
  Future<AttendanceLog> checkIn();
  Future<AttendanceLog> checkOut();
}

class AttendanceException implements Exception {
  const AttendanceException(this.message);
  final String message;

  @override
  String toString() => message;
}
