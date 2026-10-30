import 'package:flutter/widgets.dart';

import 'attendance_controller.dart';

/// SDK-only provider. The app owns and disposes the injected controller.
class AttendanceScope extends InheritedNotifier<AttendanceController> {
  const AttendanceScope({
    super.key,
    required AttendanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AttendanceController watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AttendanceScope>();
    assert(scope != null, 'AttendanceScope is missing above this widget.');
    return scope!.notifier!;
  }
}
