import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/emergency_model.dart';

/// Local database service for storing users and emergency records
/// Uses SQLite for persistent storage
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Get database instance, create if doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('women_safety.db');
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        badgeNumber TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Emergencies table
    await db.execute('''
      CREATE TABLE emergencies (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userPhone TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        triggeredAt TEXT NOT NULL,
        status TEXT NOT NULL,
        policeId TEXT,
        policeName TEXT,
        rescueCompletedAt TEXT,
        policeArrivalTime TEXT,
        safetyNotes TEXT,
        victimPhotoUrl TEXT,
        isVerified INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Insert demo users
    await _insertDemoUsers(db);
  }

  /// Insert demo users for testing
  Future _insertDemoUsers(Database db) async {
    // Demo woman user
    await db.insert('users', {
      'id': 'user_woman_1',
      'name': 'Priya Sharma',
      'email': 'priya@demo.com',
      'phone': '+919876543210',
      'password': 'demo123',
      'role': 'UserRole.woman',
      'badgeNumber': null,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Demo police user
    await db.insert('users', {
      'id': 'user_police_1',
      'name': 'Officer Rajesh Kumar',
      'email': 'police@demo.com',
      'phone': '+919328103613',
      'password': 'police123',
      'role': 'UserRole.police',
      'badgeNumber': 'POL12345',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Register new user
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? badgeNumber,
  }) async {
    final db = await database;
    
    try {
      final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await db.insert('users', {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.toString(),
        'badgeNumber': badgeNumber,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        badgeNumber: badgeNumber,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  /// Login user
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isEmpty) return null;

    final userData = result.first;
    return UserModel(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      phone: userData['phone'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == userData['role'],
      ),
      badgeNumber: userData['badgeNumber'] as String?,
      createdAt: DateTime.parse(userData['createdAt'] as String),
    );
  }

  /// Create emergency record
  Future<EmergencyModel> createEmergency(EmergencyModel emergency) async {
    final db = await database;
    
    await db.insert('emergencies', {
      'id': emergency.id,
      'userId': emergency.userId,
      'userName': emergency.userName,
      'userPhone': emergency.userPhone,
      'latitude': emergency.latitude,
      'longitude': emergency.longitude,
      'address': emergency.address,
      'triggeredAt': emergency.triggeredAt.toIso8601String(),
      'status': emergency.status.toString(),
      'policeId': emergency.policeId,
      'policeName': emergency.policeName,
      'rescueCompletedAt': emergency.rescueCompletedAt?.toIso8601String(),
      'policeArrivalTime': emergency.policeArrivalTime,
      'safetyNotes': emergency.safetyNotes,
      'victimPhotoUrl': emergency.victimPhotoUrl,
      'isVerified': emergency.isVerified ? 1 : 0,
    });

    return emergency;
  }

  /// Update emergency status
  Future<void> updateEmergency(EmergencyModel emergency) async {
    final db = await database;
    
    await db.update(
      'emergencies',
      {
        'status': emergency.status.toString(),
        'policeId': emergency.policeId,
        'policeName': emergency.policeName,
        'rescueCompletedAt': emergency.rescueCompletedAt?.toIso8601String(),
        'policeArrivalTime': emergency.policeArrivalTime,
        'safetyNotes': emergency.safetyNotes,
        'victimPhotoUrl': emergency.victimPhotoUrl,
        'isVerified': emergency.isVerified ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [emergency.id],
    );
  }

  /// Get all active emergencies (for police dashboard)
  Future<List<EmergencyModel>> getActiveEmergencies() async {
    final db = await database;
    
    final result = await db.query(
      'emergencies',
      where: 'status != ?',
      whereArgs: [EmergencyStatus.safetyConfirmed.toString()],
      orderBy: 'triggeredAt DESC',
    );

    return result.map((e) => _emergencyFromMap(e)).toList();
  }

  /// Get user's emergencies
  Future<List<EmergencyModel>> getUserEmergencies(String userId) async {
    final db = await database;
    
    final result = await db.query(
      'emergencies',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'triggeredAt DESC',
    );

    return result.map((e) => _emergencyFromMap(e)).toList();
  }

  /// Get emergency by ID
  Future<EmergencyModel?> getEmergencyById(String id) async {
    final db = await database;
    
    final result = await db.query(
      'emergencies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return _emergencyFromMap(result.first);
  }

  /// Convert map to EmergencyModel
  EmergencyModel _emergencyFromMap(Map<String, dynamic> map) {
    return EmergencyModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhone: map['userPhone'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
      triggeredAt: DateTime.parse(map['triggeredAt'] as String),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      policeId: map['policeId'] as String?,
      policeName: map['policeName'] as String?,
      rescueCompletedAt: map['rescueCompletedAt'] != null
          ? DateTime.parse(map['rescueCompletedAt'] as String)
          : null,
      policeArrivalTime: map['policeArrivalTime'] as String?,
      safetyNotes: map['safetyNotes'] as String?,
      victimPhotoUrl: map['victimPhotoUrl'] as String?,
      isVerified: (map['isVerified'] as int) == 1,
    );
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
