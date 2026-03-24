import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/emergency_model.dart';
import '../models/user_model.dart';
import '../services/emergency_service.dart';
import '../services/firebase_service.dart';
import '../services/power_button_service.dart';
import '../services/volume_button_service.dart';

/// Emergency provider for managing emergency state
/// Handles emergency triggers, updates, and real-time status
class EmergencyProvider with ChangeNotifier {
  final EmergencyService _emergencyService = EmergencyService();
  final FirebaseService _firebaseService = FirebaseService.instance;
  final PowerButtonService _powerButtonService = PowerButtonService();
  final VolumeButtonService _volumeButtonService = VolumeButtonService();
  StreamSubscription<List<EmergencyModel>>? _activeEmergenciesSubscription;
  
  EmergencyModel? _currentEmergency;
  List<EmergencyModel> _emergencies = [];
  bool _isLoading = false;

  EmergencyModel? get currentEmergency => _currentEmergency;
  List<EmergencyModel> get emergencies => _emergencies;
  bool get isLoading => _isLoading;

  /// Initialize emergency provider
  Future<void> initialize(UserModel user) async {
    // Initialize power button service (foreground only)
    await _powerButtonService.initialize();
    _powerButtonService.tripleClickStream.listen((triggered) {
      if (triggered) triggerEmergency(user);
    });

    // Initialize volume button service (works in background too)
    await _volumeButtonService.initialize(
      phone: user.phone,
      name: user.name,
    );
    _volumeButtonService.tripleClickStream.listen((triggered) {
      if (triggered) triggerEmergency(user);
    });

    // Load user's emergencies
    await loadUserEmergencies(user.id);
  }

  /// Trigger emergency (SOS)
  Future<void> triggerEmergency(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final emergency = await _emergencyService.triggerEmergency(user);
      
      if (emergency != null) {
        _currentEmergency = emergency;
        _emergencies.insert(0, emergency);
      }
    } catch (e) {
      print('Error triggering emergency: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user's emergencies
  Future<void> loadUserEmergencies(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _emergencies = await _emergencyService.getUserEmergencies(userId);
      
      // Set current emergency to the most recent active one
      if (_emergencies.isNotEmpty) {
        _currentEmergency = _emergencies.firstWhere(
          (e) => e.status != EmergencyStatus.safetyConfirmed,
          orElse: () => _emergencies.first,
        );
      }
    } catch (e) {
      print('Error loading emergencies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load active emergencies (for police) — real-time stream
  void subscribeToActiveEmergencies(void Function() onUpdate) {
    _activeEmergenciesSubscription?.cancel();
    _activeEmergenciesSubscription = _firebaseService
        .getActiveEmergenciesStream()
        .listen((list) {
      _emergencies = list;
      _isLoading = false;
      notifyListeners();
      onUpdate();
    }, onError: (e) {
      print('Stream error, falling back to one-time fetch: $e');
      loadActiveEmergencies();
    });
  }

  /// Load active emergencies (one-time fetch fallback)
  Future<void> loadActiveEmergencies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _emergencies = await _emergencyService.getActiveEmergencies();
    } catch (e) {
      print('Error loading active emergencies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update emergency status
  Future<void> updateStatus(
    EmergencyModel emergency,
    EmergencyStatus newStatus, {
    String? policeId,
    String? policeName,
  }) async {
    try {
      await _emergencyService.updateEmergencyStatus(
        emergency,
        newStatus,
        policeId: policeId,
        policeName: policeName,
      );

      // Update local state
      final index = _emergencies.indexWhere((e) => e.id == emergency.id);
      if (index != -1) {
        _emergencies[index] = emergency.copyWith(
          status: newStatus,
          policeId: policeId,
          policeName: policeName,
        );
      }

      if (_currentEmergency?.id == emergency.id) {
        _currentEmergency = _emergencies[index];
      }

      notifyListeners();
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  /// Mark rescue completed (police)
  Future<void> markRescueCompleted(
    EmergencyModel emergency,
    String policeId,
    String policeName,
  ) async {
    try {
      await _emergencyService.markRescueCompleted(
        emergency,
        policeId,
        policeName,
      );

      // Reload emergencies
      await loadActiveEmergencies();
    } catch (e) {
      print('Error marking rescue completed: $e');
    }
  }

  /// Confirm safety (women)
  Future<void> confirmSafety(
    EmergencyModel emergency,
    String policeArrivalTime,
    String? notes,
  ) async {
    try {
      await _emergencyService.confirmSafety(
        emergency,
        policeArrivalTime,
        notes,
      );

      // Update local state
      final index = _emergencies.indexWhere((e) => e.id == emergency.id);
      if (index != -1) {
        _emergencies[index] = emergency.copyWith(
          status: EmergencyStatus.safetyConfirmed,
          policeArrivalTime: policeArrivalTime,
          safetyNotes: notes,
        );
      }

      _currentEmergency = null;
      notifyListeners();
    } catch (e) {
      print('Error confirming safety: $e');
    }
  }

  /// Verify victim (police)
  Future<void> verifyVictim(
    EmergencyModel emergency,
    String photoUrl,
  ) async {
    try {
      await _emergencyService.verifyVictim(emergency, photoUrl);

      // Update local state
      final index = _emergencies.indexWhere((e) => e.id == emergency.id);
      if (index != -1) {
        _emergencies[index] = emergency.copyWith(
          victimPhotoUrl: photoUrl,
          isVerified: true,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error verifying victim: $e');
    }
  }

  /// Simulate triple click (for testing)
  void simulateTripleClick() {
    _powerButtonService.simulateTripleClick();
    _volumeButtonService.simulateTriplePress();
  }

  @override
  void dispose() {
    _activeEmergenciesSubscription?.cancel();
    _powerButtonService.dispose();
    _volumeButtonService.dispose();
    super.dispose();
  }
}
