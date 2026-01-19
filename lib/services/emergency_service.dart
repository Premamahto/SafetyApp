import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_model.dart';
import '../models/user_model.dart';
import 'location_service.dart';
import 'database_service.dart';

/// Emergency service handling SOS triggers, calls, and SMS
/// Core service for emergency response functionality
class EmergencyService {
  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  // Police emergency number
  static const String policeNumber = '+919328103613';

  /// Trigger emergency - called when power button triple-clicked
  Future<EmergencyModel?> triggerEmergency(UserModel user) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        print('Failed to get location');
        return null;
      }

      // Get address from coordinates
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create emergency record
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

      // Save to database
      await _dbService.createEmergency(emergency);

      // Make emergency call
      await makeEmergencyCall();

      // Send emergency SMS
      await sendEmergencySMS(emergency);

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

  /// Send emergency SMS with location
  Future<void> sendEmergencySMS(EmergencyModel emergency) async {
    final message = '''
🚨 EMERGENCY ALERT 🚨

${emergency.userName} needs immediate help!

Location: ${emergency.address}
GPS: ${emergency.latitude}, ${emergency.longitude}

Google Maps: ${emergency.googleMapsLink}

Time: ${emergency.triggeredAt.toString()}

Please respond immediately!
''';

    try {
      // Use SMS URL scheme to send SMS
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: policeNumber,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        print('Cannot send SMS');
      }
    } catch (e) {
      print('Error sending SMS: $e');
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

    await _dbService.updateEmergency(updatedEmergency);
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

    await _dbService.updateEmergency(updatedEmergency);
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

    await _dbService.updateEmergency(updatedEmergency);
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

    await _dbService.updateEmergency(updatedEmergency);
  }

  /// Get active emergencies (for police dashboard)
  Future<List<EmergencyModel>> getActiveEmergencies() async {
    return await _dbService.getActiveEmergencies();
  }

  /// Get user's emergency history
  Future<List<EmergencyModel>> getUserEmergencies(String userId) async {
    return await _dbService.getUserEmergencies(userId);
  }
}
