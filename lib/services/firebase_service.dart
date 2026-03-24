import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/emergency_model.dart';

// Web client ID (type 3) from google-services.json
const _webClientId =
    '104329471517-1lnn0vr1t8f9j6m78hcsq83sle3nl61b.apps.googleusercontent.com';

/// Firebase service for cloud database operations
/// Provides real-time sync and cloud storage
class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleSignInInitialized = false;

  FirebaseService._init();

  /// Initialize Google Sign-In (v7 requires explicit initialization)
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      _googleSignInInitialized = true;
    }
  }

  /// Register new user with Firebase Auth and Firestore
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? badgeNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Create user document in Firestore
      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        badgeNumber: badgeNumber,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(user.toJson());

      return user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  /// Login user with Firebase Auth
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  /// Sign in with Google (google_sign_in v7 API)
  Future<UserModel?> signInWithGoogle({required UserRole role}) async {
    try {
      print('FirebaseService: Starting Google Sign-In...');

      await _ensureGoogleSignInInitialized();

      // v7 API: authenticate() replaces signIn()
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      print('FirebaseService: Google account selected: ${googleUser.email}');

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // google_sign_in v7 only exposes idToken (accessToken removed)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      print('FirebaseService: Signing in to Firebase with Google credential...');

      final userCredential = await _auth.signInWithCredential(credential);
      final userId = userCredential.user!.uid;

      print('FirebaseService: Firebase sign-in successful, UID: $userId');

      // Check if user document already exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        print('FirebaseService: Existing user found');
        return UserModel.fromJson(userDoc.data()!);
      }

      // New user — create profile
      print('FirebaseService: Creating new user profile...');
      final user = UserModel(
        id: userId,
        name: googleUser.displayName ?? 'User',
        email: googleUser.email,
        phone: '',
        role: role,
        badgeNumber: role == UserRole.police ? 'PENDING' : null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(user.toJson());
      print('FirebaseService: New user profile created successfully');

      return user;
    } catch (e) {
      print('FirebaseService: Error signing in with Google: $e');
      return null;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get user profile from Firestore by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('FirebaseService: getUserById error: $e');
    }
    return null;
  }

  /// Create emergency record in Firestore
  Future<EmergencyModel> createEmergency(EmergencyModel emergency) async {
    await _firestore
        .collection('emergencies')
        .doc(emergency.id)
        .set(emergency.toJson());
    return emergency;
  }

  /// Update emergency status
  Future<void> updateEmergency(EmergencyModel emergency) async {
    await _firestore
        .collection('emergencies')
        .doc(emergency.id)
        .update(emergency.toJson());
  }

  /// Get active emergencies (real-time stream) — all statuses except safetyConfirmed
  Stream<List<EmergencyModel>> getActiveEmergenciesStream() {
    // Simple query — no compound index needed
    return _firestore
        .collection('emergencies')
        .orderBy('triggeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyModel.fromJson(doc.data()))
            .where((e) => e.status != EmergencyStatus.safetyConfirmed)
            .toList());
  }

  /// Get active emergencies (one-time fetch)
  Future<List<EmergencyModel>> getActiveEmergencies() async {
    final snapshot = await _firestore
        .collection('emergencies')
        .orderBy('triggeredAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EmergencyModel.fromJson(doc.data()))
        .where((e) => e.status != EmergencyStatus.safetyConfirmed)
        .toList();
  }

  /// Get user's emergencies (real-time stream)
  Stream<List<EmergencyModel>> getUserEmergenciesStream(String userId) {
    return _firestore
        .collection('emergencies')
        .where('userId', isEqualTo: userId)
        .orderBy('triggeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyModel.fromJson(doc.data()))
            .toList());
  }

  /// Get user's emergencies (one-time fetch)
  Future<List<EmergencyModel>> getUserEmergencies(String userId) async {
    final snapshot = await _firestore
        .collection('emergencies')
        .where('userId', isEqualTo: userId)
        .orderBy('triggeredAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EmergencyModel.fromJson(doc.data()))
        .toList();
  }

  /// Get emergency by ID
  Future<EmergencyModel?> getEmergencyById(String id) async {
    final doc = await _firestore.collection('emergencies').doc(id).get();
    
    if (doc.exists) {
      return EmergencyModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Create demo users (for testing)
  Future<void> createDemoUsers() async {
    try {
      // Check if demo users already exist
      final womanDoc = await _firestore.collection('users').doc('demo_woman').get();
      if (womanDoc.exists) return;

      // Create demo woman user
      await _firestore.collection('users').doc('demo_woman').set({
        'id': 'demo_woman',
        'name': 'Priya Sharma',
        'email': 'priya@demo.com',
        'phone': '+919876543210',
        'role': UserRole.woman.toString(),
        'badgeNumber': null,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Create demo police user
      await _firestore.collection('users').doc('demo_police').set({
        'id': 'demo_police',
        'name': 'Officer Rajesh Kumar',
        'email': 'police@demo.com',
        'phone': '+919328103613',
        'role': UserRole.police.toString(),
        'badgeNumber': 'POL12345',
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('Demo users created in Firestore');
    } catch (e) {
      print('Error creating demo users: $e');
    }
  }
}
