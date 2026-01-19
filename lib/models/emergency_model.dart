/// Emergency incident model
/// Tracks all emergency requests from trigger to resolution
class EmergencyModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime triggeredAt;
  final EmergencyStatus status;
  final String? policeId;
  final String? policeName;
  final DateTime? rescueCompletedAt;
  final String? policeArrivalTime;
  final String? safetyNotes;
  final String? victimPhotoUrl;
  final bool isVerified;

  EmergencyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.triggeredAt,
    required this.status,
    this.policeId,
    this.policeName,
    this.rescueCompletedAt,
    this.policeArrivalTime,
    this.safetyNotes,
    this.victimPhotoUrl,
    this.isVerified = false,
  });

  /// Get Google Maps link for the emergency location
  String get googleMapsLink {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'triggeredAt': triggeredAt.toIso8601String(),
      'status': status.toString(),
      'policeId': policeId,
      'policeName': policeName,
      'rescueCompletedAt': rescueCompletedAt?.toIso8601String(),
      'policeArrivalTime': policeArrivalTime,
      'safetyNotes': safetyNotes,
      'victimPhotoUrl': victimPhotoUrl,
      'isVerified': isVerified,
    };
  }

  /// Create from JSON
  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      triggeredAt: DateTime.parse(json['triggeredAt']),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      policeId: json['policeId'],
      policeName: json['policeName'],
      rescueCompletedAt: json['rescueCompletedAt'] != null
          ? DateTime.parse(json['rescueCompletedAt'])
          : null,
      policeArrivalTime: json['policeArrivalTime'],
      safetyNotes: json['safetyNotes'],
      victimPhotoUrl: json['victimPhotoUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  /// Create a copy with updated fields
  EmergencyModel copyWith({
    EmergencyStatus? status,
    String? policeId,
    String? policeName,
    DateTime? rescueCompletedAt,
    String? policeArrivalTime,
    String? safetyNotes,
    String? victimPhotoUrl,
    bool? isVerified,
  }) {
    return EmergencyModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      latitude: latitude,
      longitude: longitude,
      address: address,
      triggeredAt: triggeredAt,
      status: status ?? this.status,
      policeId: policeId ?? this.policeId,
      policeName: policeName ?? this.policeName,
      rescueCompletedAt: rescueCompletedAt ?? this.rescueCompletedAt,
      policeArrivalTime: policeArrivalTime ?? this.policeArrivalTime,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      victimPhotoUrl: victimPhotoUrl ?? this.victimPhotoUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Emergency status lifecycle
enum EmergencyStatus {
  helpRequested,
  policeOnTheWay,
  rescued,
  safetyConfirmed,
}
