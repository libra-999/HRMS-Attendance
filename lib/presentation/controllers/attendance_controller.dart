import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/attendance_log.dart';
import '../../data/models/attendance_status.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({required this.repository, DateTime Function()? now})
    : _now = now ?? DateTime.now {
    clock = ValueNotifier(_now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => refreshClock());
  }

  final AttendanceRepository repository;
  final DateTime Function() _now;
  late final ValueNotifier<DateTime> clock;
  late final Timer _timer;
  bool _disposed = false;
  bool _initializing = false;
  bool _isReady = false;
  bool _isSubmitting = false;
  String? _initializationError;
  String? _actionError;
  UserProfile? _user;
  List<AttendanceLog> _logs = const [];

  bool get isReady => _isReady;
  bool get isInitializing => _initializing;
  bool get isSubmitting => _isSubmitting;
  String? get initializationError => _initializationError;
  String? get actionError => _actionError;
  UserProfile? get user => _user;
  List<AttendanceLog> get logs => _logs;
  AttendanceLog? get activeLog {
    for (final log in _logs) {
      if (log.checkOut == null) return log;
    }
    return null;
  }

  AttendanceStatus get status => activeLog == null
      ? AttendanceStatus.checkedOut
      : AttendanceStatus.checkedIn;

  DateTime? get lastActionAt {
    DateTime? latest;
    for (final log in _logs) {
      final action = log.checkOut ?? log.checkIn;
      if (latest == null || action.isAfter(latest)) latest = action;
    }
    return latest;
  }

  /// Clips sessions to today's local boundaries, including overnight shifts.
  Duration workedToday(DateTime now) {
    final local = now.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    final end = DateTime(local.year, local.month, local.day + 1);
    var total = Duration.zero;
    for (final log in _logs) {
      final from = log.checkIn.isBefore(start) ? start : log.checkIn;
      var to = log.checkOut ?? now;
      if (to.isAfter(end)) to = end;
      if (to.isAfter(now)) to = now;
      if (to.isAfter(from)) total += to.difference(from);
    }
    return total;
  }

  Future<void> initialize() async {
    if (_disposed || _initializing || _isReady) return;
    _initializing = true;
    _initializationError = null;
    notifyListeners();
    try {
      // Both calls complete before committing a consistent initial snapshot.
      final results = await Future.wait<Object>([
        repository.getUserProfile(),
        repository.getAttendanceLogs(),
      ]);
      if (_disposed) return;
      _user = results[0] as UserProfile;
      _setLogs(results[1] as List<AttendanceLog>);
      _isReady = true;
    } catch (_) {
      if (!_disposed) _initializationError = AppStrings.initializationError;
    } finally {
      if (!_disposed) {
        _initializing = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleAttendance() async {
    if (_disposed || !_isReady || _isSubmitting) return;
    _isSubmitting = true;
    _actionError = null;
    notifyListeners();
    try {
      final log = await (activeLog == null
          ? repository.checkIn()
          : repository.checkOut());
      if (_disposed) return;
      _setLogs([..._logs.where((item) => item.id != log.id), log]);
      refreshClock();
    } on AttendanceException catch (error) {
      if (!_disposed) _actionError = error.message;
    } catch (_) {
      if (!_disposed) _actionError = AppStrings.actionError;
    } finally {
      if (!_disposed) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  void _setLogs(List<AttendanceLog> logs) {
    final sorted = List<AttendanceLog>.of(logs)
      ..sort((a, b) => b.checkIn.compareTo(a.checkIn));
    _logs = List.unmodifiable(sorted);
  }

  void refreshClock() {
    if (!_disposed) clock.value = _now();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel();
    clock.dispose();
    super.dispose();
  }
}
