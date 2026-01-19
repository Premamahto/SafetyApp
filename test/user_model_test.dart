import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_app/models/user_model.dart';

/// Unit tests for User Model
/// Tests user creation, JSON conversion, and role management
void main() {
  group('UserModel Tests', () {
    test('User model creates correctly for woman role', () {
      final user = UserModel(
        id: 'user_1',
        name: 'Test Woman',
        email: 'woman@test.com',
        phone: '+919876543210',
        role: UserRole.woman,
        createdAt: DateTime.now(),
      );

      expect(user.id, equals('user_1'));
      expect(user.name, equals('Test Woman'));
      expect(user.role, equals(UserRole.woman));
      expect(user.badgeNumber, isNull);
    });

    test('User model creates correctly for police role', () {
      final user = UserModel(
        id: 'police_1',
        name: 'Officer Test',
        email: 'police@test.com',
        phone: '+919328103613',
        role: UserRole.police,
        badgeNumber: 'POL12345',
        createdAt: DateTime.now(),
      );

      expect(user.id, equals('police_1'));
      expect(user.role, equals(UserRole.police));
      expect(user.badgeNumber, equals('POL12345'));
    });

    test('User model converts to JSON correctly', () {
      final user = UserModel(
        id: 'user_2',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+919876543210',
        role: UserRole.woman,
        createdAt: DateTime.now(),
      );

      final json = user.toJson();

      expect(json['id'], equals('user_2'));
      expect(json['name'], equals('Test User'));
      expect(json['email'], equals('test@example.com'));
      expect(json['role'], contains('woman'));
    });

    test('User model creates from JSON correctly', () {
      final json = {
        'id': 'user_3',
        'name': 'JSON User',
        'email': 'json@test.com',
        'phone': '+919876543210',
        'role': UserRole.police.toString(),
        'badgeNumber': 'POL99999',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('user_3'));
      expect(user.name, equals('JSON User'));
      expect(user.role, equals(UserRole.police));
      expect(user.badgeNumber, equals('POL99999'));
    });

    test('User roles are distinct', () {
      expect(UserRole.woman, isNot(equals(UserRole.police)));
      expect(UserRole.values.length, equals(2));
    });
  });
}
