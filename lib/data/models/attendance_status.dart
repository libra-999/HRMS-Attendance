enum AttendanceStatus {
  checkedIn,
  checkedOut;

  String get label => switch (this) {
    checkedIn => 'Checked In',
    checkedOut => 'Checked Out',
  };

  String get activityLabel => switch (this) {
    checkedIn => 'In progress',
    checkedOut => 'Completed',
  };
}
