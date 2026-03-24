import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_model.dart';
import '../models/user_model.dart';
import 'location_service.dart';
import 'firebase_service.dart';
import 'contacts_service.dart';

/// Emergency service handling SOS triggers, calls, and SMS
/// Core service for emergency response functionality with Firebase
class EmergencyService {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService.instance;
  final ContactsService _contactsService = ContactsService();

  // Police emergency number (always included)
  static const String policeNumber = '+919328103613';

  /// Trigger emergency - called when power button triple-clicked
  Future<EmergencyModel?> triggerEmergency(UserModel user) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        print('Failed to get location');
        return null;
      }

      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final emergency = EmergencyModel(
        id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        triggeredAt: DateTime.now(),
        status: EmergencyStatus.helpRequested,
      );

      await _firebaseService.createEmergency(emergency);
      await makeEmergencyCall();

      // Load user's saved contacts and send SMS to all of them + police
      final contacts = await _contactsService.getContacts(user.id);
      final phones = <String>{policeNumber};
      for (final c in contacts) {
        if (c.phone.isNotEmpty) phones.add(c.phone);
      }
      for (final phone in phones) {
        await sendEmergencySMS(emergency, phone);
      }

      return emergency;
    } catch (e) {
      print('Error triggering emergency: $e');
      return null;
    }
  }

  /// Make emergency call to police
  Future<void> makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: policeNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        print('Cannot make phone call');
      }
    } catch (e) {
      print('Error making call: $e');
    }
  }

  /// Send emergency SMS with location to a specific phone number.
  /// Uses native SmsManager (silent). Falls back to SMS app if it fails.
  Future<void> sendEmergencySMS(EmergencyModel emergency, String phone) async {
    final message = '''EMERGENCY ALERT!

${emergency.userName} needs immediate help!

Location: ${emergency.address}
GPS: ${emergency.latitude}, ${emergency.longitude}

Google Maps: ${emergency.googleMapsLink}

Time: ${emergency.triggeredAt.toString()}

Please respond immediately!''';

    try {
      const smsChannel = MethodChannel('women_safety_app/sms');
      final success = await smsChannel.invokeMethod<bool>('sendSms', {
        'phone': phone,
        'message': message,
      });
      if (success == true) {
        print('SMS sent silently to $phone');
      } else {
        await _fallbackSmsApp(phone, message);
      }
    } on PlatformException catch (e) {
      print('Native SMS failed: $e — falling back to SMS app');
      await _fallbackSmsApp(phone, message);
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  /// Fallback: open SMS app pre-filled (used if SmsManager fails)
  Future<void> _fallbackSmsApp(String phone, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  /// Update emergency status (for police)
  Future<void> updateEmergencyStatus(
    EmergencyModel emergency,
    EmergencyStatus newStatus, {
    String? policeId,
    String? policeName,
  }) async {
    final updatedEmergency = emergency.copyWith(
      status: newStatus,
      policeId: policeId,
      policeName: policeName,
    );

    await _firebaseService.updateEmergency(updatedEmergency);
  }

  /// Mark rescue completed (for police)
  Future<void> markRescueCompleted(
    EmergencyModel emergency,
    String policeId,
    String policeName,
  ) async {
    final updatedEmergency = emergency.copyWith(
      status: EmergencyStatus.rescued,
      policeId: policeId,
      policeName: policeName,
      rescueCompletedAt: DateTime.now(),
    );

    await _firebaseService.updateEmergency(updatedEmergency);
  }

  /// Confirm safety (for women)
  Future<void> confirmSafety(
    EmergencyModel emergency,
    String policeArrivalTime,
    String? notes,
  ) async {
    final updatedEmergency = emergency.copyWith(
      status: EmergencyStatus.safetyConfirmed,
      policeArrivalTime: policeArrivalTime,
      safetyNotes: notes,
    );

    await _firebaseService.updateEmergency(updatedEmergency);
  }

  /// Verify victim photo (for police)
  Future<void> verifyVictim(
    EmergencyModel emergency,
    String photoUrl,
  ) async {
    final updatedEmergency = emergency.copyWith(
      victimPhotoUrl: photoUrl,
      isVerified: true,
    );

    await _firebaseService.updateEmergency(updatedEmergency);
  }

  /// Get active emergencies (for police dashboard)
  Future<List<EmergencyModel>> getActiveEmergencies() async {
    return await _firebaseService.getActiveEmergencies();
  }

  /// Get user's emergency history
  Future<List<EmergencyModel>> getUserEmergencies(String userId) async {
    return await _firebaseService.getUserEmergencies(userId);
  }
}
