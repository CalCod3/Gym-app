// models/user_with_membership_status.dart
class UserWithMembershipStatus {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool hasPaid;

  UserWithMembershipStatus({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.hasPaid,
  });

  factory UserWithMembershipStatus.fromJson(Map<String, dynamic> json) {
    return UserWithMembershipStatus(
      id: json['user']['id'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      email: json['user']['email'],
      hasPaid: json['has_paid'],
    );
  }
}
