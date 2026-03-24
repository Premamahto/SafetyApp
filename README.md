# Women Safety App

A Flutter emergency safety app with dual roles (Woman & Police), Firebase integration, Google Sign-In, real-time alerts, and GPS-based SOS.

---

## Quick Start

### Run the App
```bash
flutter pub get
flutter run
```

### Demo Credentials
| Role   | Email              | Password   |
|--------|--------------------|------------|
| Woman  | priya@demo.com     | demo123    |
| Police | police@demo.com    | police123  |

> Login works with local SQLite automatically. Firebase is optional for cloud sync.

---

## Features

- **SOS Emergency Trigger** — one tap triggers call + SMS to police
- **Auto Phone Call** — calls +919328103613 immediately
- **SMS with GPS** — opens SMS app pre-filled with location + Google Maps link
- **Live Location** — GPS coordinates sent with every emergency
- **Police Dashboard** — real-time emergency list with map view
- **Safety Confirmation** — woman marks herself safe after rescue
- **PDF Report** — generate incident report after rescue
- **Emergency History** — full log of past emergencies
- **Google Sign-In** — sign in with Google account
- **Firebase Sync** — real-time updates across devices (optional)

---

## Firebase Setup

Your Firebase project: **sakhisamachar-f70d8**

### Enable Services (5 minutes)
1. Go to https://console.firebase.google.com/project/sakhisamachar-f70d8
2. **Authentication** → Sign-in method → Enable **Email/Password** and **Google**
3. **Firestore Database** → Create database → Start in test mode

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Google Sign-In
- SHA-1 fingerprint must be added to Firebase Console
- Get it with: `cd android && ./gradlew signingReport`
- Add under Project Settings → Your Android app → Add fingerprint

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   └── emergency_model.dart
├── services/
│   ├── firebase_service.dart     # Firebase Auth + Firestore
│   ├── database_service.dart     # SQLite (local fallback)
│   ├── emergency_service.dart    # SOS, call, SMS logic
│   ├── location_service.dart     # GPS
│   └── pdf_service.dart          # Report generation
├── providers/
│   ├── auth_provider.dart        # Login/register state
│   └── emergency_provider.dart   # Emergency state
└── screens/
    ├── splash_screen.dart
    ├── role_selection_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── women_dashboard_screen.dart
    ├── police_dashboard_screen.dart
    ├── live_map_screen.dart
    ├── safety_confirmation_screen.dart
    └── emergency_history_screen.dart
```

---

## SMS Logic

Uses `url_launcher` with `sms:` URI scheme:
- Opens device SMS app automatically
- Message pre-filled with name, address, GPS, Google Maps link
- User taps Send (1 tap)

> Automatic SMS packages (`telephony`, `sms_advanced`) are incompatible with modern Android Gradle (AGP 8.x) and have been removed.

---

## Emergency Number

**+919328103613**

To change it, update `static const String policeNumber` in:
- `lib/services/emergency_service.dart`
- `lib/services/database_service.dart`

---

## Authentication Flow

```
Login attempt
  → Try Firebase Auth first
  → If Firebase fails → fallback to SQLite
  → Demo users pre-seeded in SQLite on first launch
```

---

## Build Notes

- `compileSdk` and `targetSdk` set to **36** (required by plugins)
- `minSdk` = 21
- Firebase BOM: 32.7.0
- Kotlin: 2.2.20
- AGP: 8.11.1

### If build fails:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Permissions (AndroidManifest.xml)

```xml
INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION,
ACCESS_BACKGROUND_LOCATION, CALL_PHONE, SEND_SMS,
READ_PHONE_STATE, FOREGROUND_SERVICE, WAKE_LOCK
```

---

## Google Maps

The map screen uses `google_maps_flutter`. Without an API key, the map tile won't load but the "Open in Google Maps" button works fine.

To enable the map:
1. Get a Maps API key from https://console.cloud.google.com
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in `AndroidManifest.xml`

---

## Tech Stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| UI          | Flutter + Material 3              |
| State       | Provider                          |
| Auth        | Firebase Auth + Google Sign-In    |
| Database    | Firestore (cloud) + SQLite (local)|
| Location    | geolocator + geocoding            |
| Maps        | google_maps_flutter               |
| SMS/Call    | url_launcher                      |
| PDF         | pdf + printing                    |
| Permissions | permission_handler                |
