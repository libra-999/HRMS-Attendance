class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.department,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String position;
  final String department;

  String get fullName => '$firstName $lastName'.trim();
  String get initials => [firstName, lastName]
      .where((part) => part.trim().isNotEmpty)
      .map((part) => String.fromCharCode(part.trim().runes.first))
      .join()
      .toUpperCase();
}
