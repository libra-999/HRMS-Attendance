import 'attendance_status.dart';

/// One attendance session. Multiple sessions per day are supported.
class AttendanceLog {
  AttendanceLog({required this.id, required this.checkIn, this.checkOut}) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty');
    if (checkOut != null && checkOut!.isBefore(checkIn)) {
      throw ArgumentError('Check-out cannot precede check-in.');
    }
  }

  final String id;
  final DateTime checkIn;
  final DateTime? checkOut;

  DateTime get date => checkIn.toLocal();
  AttendanceStatus get status => checkOut == null
      ? AttendanceStatus.checkedIn
      : AttendanceStatus.checkedOut;
  Duration get workingHours => checkOut?.difference(checkIn) ?? Duration.zero;

  Duration elapsedAt(DateTime now) {
    final elapsed = (checkOut ?? now).difference(checkIn);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  AttendanceLog complete(DateTime at) {
    if (checkOut != null) throw StateError('This session is already complete.');
    return AttendanceLog(id: id, checkIn: checkIn, checkOut: at);
  }
}
