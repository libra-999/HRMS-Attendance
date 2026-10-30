# Attendly · HRMS-APP

A standalone Flutter attendance application with a two-second splash screen,
live dashboard, and local check-in/check-out sessions. Runtime dependencies are
limited to the Flutter SDK; no API keys, server, network images, or downloaded
fonts are required. The mock repository resets when the app restarts.

## Run

Built and checked with Flutter 3.47.2 / Dart 3.13.2. The SDK constraint is in
`pubspec.yaml`. Android, iOS, and web project shells are included.

```bash
cd /home/libra/Documents/HR-Project/HRMS-APP
flutter pub get
flutter run
```

Choose an attached device/emulator, or use `flutter run -d chrome` for a browser
preview. Package/toolchain setup can require internet access; the mobile app's
attendance flow is entirely offline. iOS builds require macOS and Xcode.

## Directory structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── date_time_formatters.dart
├── data/
│   ├── models/
│   │   ├── attendance_log.dart
│   │   ├── attendance_status.dart
│   │   └── user_profile.dart
│   └── repositories/
│       ├── attendance_repository.dart
│       └── mock_attendance_repository.dart
├── presentation/
│   ├── controllers/
│   │   ├── attendance_controller.dart
│   │   └── attendance_scope.dart
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   └── home/
│   │       ├── home_page.dart
│   │       └── widgets/
│   │           ├── attendance_log_card.dart
│   │           ├── live_status_card.dart
│   │           └── user_info_bar.dart
│   └── widgets/
│       ├── brand_mark.dart
│       ├── dynamic_loader.dart
│       ├── primary_action_button.dart
│       ├── status_chip.dart
│       └── surface_card.dart
└── main.dart
test/
├── data/mock_attendance_repository_test.dart
└── presentation/
    ├── app_test.dart
    └── attendance_controller_test.dart
```

This follows the requested layer-first top-level layout, with feature-specific
screens and widgets grouped under `presentation/screens`. A strict feature-first
layout would put each feature's data/domain/presentation under `features/`; the
requested tree is preserved for this phase. Models and the repository contract
are plain Dart and have no dependency on Flutter.

## State and data flow

`main.dart` is the composition root. It injects `AttendanceRepository` into
`AttendanceController`. `AttendanceScope` exposes that `ChangeNotifier` using
Flutter's `InheritedNotifier`, so no third-party state-management package is
needed. Widgets depend on the controller and models, never on the mock class.

- Splash starts profile/history loading together, waits at least two seconds,
  and replaces its route with a fade into Home. Failed loading offers a retry;
  slow initialization keeps the splash visible until data is ready.
- Home displays the mock profile, device-local date, 24-hour clock, current
  attendance status, and full date/time of the latest action.
- Check-in creates a session; check-out completes the same session. The
  controller disables repeated submission and commits only successful results.
  Failure leaves the previous state intact and displays a retryable error.
- The mock enforces one open session at a time and permits multiple sessions
  per day. History includes five completed sample days before today.
- Working hours use timestamp differences, with no assumed lunch deductions.
  Today's total clips overnight sessions at local midnight. Active sessions
  update from wall-clock time every second and immediately on app resume.
- The clock timer and notifier are disposed with the app; late asynchronous
  results are ignored after disposal. History snapshots are unmodifiable.
- Light/dark themes follow the system. Layouts support scrolling, narrow
  screens, large text, and reduced-motion navigation.

Dates are English/device-local for this phase. A later localization layer can
replace `DateTimeFormatters` without altering the repository. The demo profile
represents a mock authenticated user; no real sign-in or preference storage is
implemented.

## Replace the mock with Spring Boot

Implement the four methods in `AttendanceRepository`:

```dart
abstract interface class AttendanceRepository {
  Future<UserProfile> getUserProfile();
  Future<List<AttendanceLog>> getAttendanceLogs();
  Future<AttendanceLog> checkIn();
  Future<AttendanceLog> checkOut();
}
```

Then inject the implementation at `runApp(AttendanceApp(repository: ...))` in
`main.dart`. Screens and the controller can stay unchanged. The adapter should
map server DTOs into these models, return the authoritative saved session from
mutations, and translate user-correctable failures to `AttendanceException`.
The backend should own identity, authoritative timestamps, single-open-session
validation, and mutation idempotency. Transport, authentication, durable offline
storage, pagination, and synchronization belong in that subsequent phase.

`AttendanceLog.status` is derived from its nullable checkout timestamp, preventing
contradictory status fields. `workingHours` reports completed time;
`elapsedAt(now)` includes an active session's elapsed time.

## Validation

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

Tests cover splash timing and route replacement, check-in/out UI, narrow layouts
at 200% text size in both themes, empty history, session duration and identity,
duplicate actions, clock rollback, overnight totals, error/retry behavior, live
clock updates, and disposal during asynchronous work.

Android/iOS shells retain Flutter's generated application identifiers, launcher
icons, and signing defaults. Configure those for your organization before store
distribution. The Flutter splash and dashboard use the Attendly brand mark.
