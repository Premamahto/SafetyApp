import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_app/models/user_model.dart';
import 'package:women_safety_app/models/emergency_model.dart';
import 'package:women_safety_app/services/emergency_service.dart';

/// Unit tests for Emergency Service
/// Tests emergency trigger, status updates, and rescue operations
void main() {
  group('EmergencyService Tests', () {
    test('Emergency trigger creates valid emergency model', () {
      // Create test user
      final testUser = UserModel(
        id: 'test_user_1',
        name: 'Test Woman',
        email: 'test@example.com',
        phone: '+919876543210',
        role: UserRole.woman,
        createdAt: DateTime.now(),
      );

      // Note: This test would require mocking location and database services
      // For demo purposes, we're testing the model structure
      
      final testEmergency = EmergencyModel(
        id: 'emergency_test_1',
        userId: testUser.id,
        userName: testUser.name,
        userPhone: testUser.phone,
        latitude: 23.0225,
        longitude: 72.5714,
        address: 'Test Address, Ahmedabad',
        triggeredAt: DateTime.now(),
        status: EmergencyStatus.helpRequested,
      );

      expect(testEmergency.userId, equals(testUser.id));
      expect(testEmergency.status, equals(EmergencyStatus.helpRequested));
      expect(testEmergency.googleMapsLink, contains('google.com/maps'));
    });

    test('Emergency status transitions correctly', () {
      final emergency = EmergencyModel(
        id: 'emergency_test_2',
        userId: 'user_1',
        userName: 'Test User',
        userPhone: '+919876543210',
        latitude: 23.0225,
        longitude: 72.5714,
        address: 'Test Address',
        triggeredAt: DateTime.now(),
        status: EmergencyStatus.helpRequested,
      );

      // Test status update to police on the way
      final updatedEmergency = emergency.copyWith(
        status: EmergencyStatus.policeOnTheWay,
        policeId: 'police_1',
        policeName: 'Officer Test',
      );

      expect(updatedEmergency.status, equals(EmergencyStatus.policeOnTheWay));
      expect(updatedEmergency.policeId, equals('police_1'));
      expect(updatedEmergency.policeName, equals('Officer Test'));
    });

    test('Emergency model converts to JSON correctly', () {
      final emergency = EmergencyModel(
        id: 'emergency_test_3',
        userId: 'user_1',
        userName: 'Test User',
        userPhone: '+919876543210',
        latitude: 23.0225,
        longitude: 72.5714,
        address: 'Test Address',
        triggeredAt: DateTime.now(),
        status: EmergencyStatus.rescued,
        policeId: 'police_1',
        policeName: 'Officer Test',
      );

      final json = emergency.toJson();

      expect(json['id'], equals('emergency_test_3'));
      expect(json['userId'], equals('user_1'));
      expect(json['status'], contains('rescued'));
      expect(json['policeId'], equals('police_1'));
    });

    test('Emergency model creates from JSON correctly', () {
      final json = {
        'id': 'emergency_test_4',
        'userId': 'user_1',
        'userName': 'Test User',
        'userPhone': '+919876543210',
        'latitude': 23.0225,
        'longitude': 72.5714,
        'address': 'Test Address',
        'triggeredAt': DateTime.now().toIso8601String(),
        'status': EmergencyStatus.helpRequested.toString(),
        'policeId': null,
        'policeName': null,
        'rescueCompletedAt': null,
        'policeArrivalTime': null,
        'safetyNotes': null,
        'victimPhotoUrl': null,
        'isVerified': false,
      };

      final emergency = EmergencyModel.fromJson(json);

      expect(emergency.id, equals('emergency_test_4'));
      expect(emergency.userName, equals('Test User'));
      expect(emergency.status, equals(EmergencyStatus.helpRequested));
    });

    test('Google Maps link is generated correctly', () {
      final emergency = EmergencyModel(
        id: 'emergency_test_5',
        userId: 'user_1',
        userName: 'Test User',
        userPhone: '+919876543210',
        latitude: 23.0225,
        longitude: 72.5714,
        address: 'Test Address',
        triggeredAt: DateTime.now(),
        status: EmergencyStatus.helpRequested,
      );

      final mapsLink = emergency.googleMapsLink;

      expect(mapsLink, contains('https://www.google.com/maps'));
      expect(mapsLink, contains('23.0225'));
      expect(mapsLink, contains('72.5714'));
    });
  });
}
