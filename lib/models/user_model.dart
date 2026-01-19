/// User model representing both Women and Police users
/// Supports role-based authentication and user management
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? badgeNumber; // For police officers
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.badgeNumber,
    required this.createdAt,
  });

  /// Convert user to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'badgeNumber': badgeNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create user from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
      ),
      badgeNumber: json['badgeNumber'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// User roles in the system
enum UserRole {
  woman,
  police,
}
