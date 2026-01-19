# Women Safety App 🛡️

A comprehensive Flutter mobile application designed to enhance women's safety through emergency response features, real-time location tracking, and police coordination.

## 📱 Features

### For Women Users
- **Emergency SOS Trigger**: Triple-click power button or tap SOS button to trigger emergency
- **Automatic Emergency Call**: Instantly calls police when emergency is triggered
- **SMS with Live Location**: Sends SMS with GPS coordinates and Google Maps link
- **Real-time Status Updates**: View emergency status (Help Requested → Police On The Way → Rescued)
- **Safety Confirmation**: Mark yourself safe after rescue
- **Safety Report Generation**: Download PDF report with incident details
- **Emergency History**: View past emergency incidents

### For Police Users
- **Emergency Dashboard**: View all active emergency requests
- **Live Location Tracking**: See victim's location on Google Maps
- **Status Management**: Update emergency status (On The Way, Rescue Completed)
- **Direct Communication**: Call victim directly from the app
- **Victim Verification**: Upload and verify victim photos

## 🏗️ Architecture

The app follows clean architecture principles:

```
lib/
├── models/           # Data models (User, Emergency)
├── services/         # Business logic services
│   ├── database_service.dart      # SQLite database operations
│   ├── location_service.dart      # GPS and location tracking
│   ├── emergency_service.dart     # Emergency handling
│   ├── power_button_service.dart  # Power button detection
│   └── pdf_service.dart           # PDF report generation
├── providers/        # State management (Provider pattern)
│   ├── auth_provider.dart         # Authentication state
│   └── emergency_provider.dart    # Emergency state
├── screens/          # UI screens
│   ├── splash_screen.dart
│   ├── role_selection_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── women_dashboard_screen.dart
│   ├── police_dashboard_screen.dart
│   ├── live_map_screen.dart
│   ├── safety_confirmation_screen.dart
│   └── emergency_history_screen.dart
└── main.dart         # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API level 21+)

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd women_safety_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API Key (Optional for Demo)**
   - **For Demo**: The app works without API key! Use "Open in Google Maps" button
   - **For Production**: Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android
   - Add your API key to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE"/>
     ```
   - See `GOOGLE_MAPS_SETUP.md` for detailed instructions

4. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

### Demo Credentials

**Women User:**
- Email: `priya@demo.com`
- Password: `demo123`

**Police User:**
- Email: `police@demo.com`
- Password: `police123`

**Demo Police Number:** `+91 9328103613`

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/emergency_service_test.dart
flutter test test/user_model_test.dart
```

### Test Coverage
- ✅ User model creation and JSON conversion
- ✅ Emergency model lifecycle and status transitions
- ✅ Emergency service operations
- ✅ Google Maps link generation

## 📋 How to Use

### For Women Users

1. **Register/Login**
   - Select "I am a Woman" on role selection
   - Login with demo credentials or register new account

2. **Trigger Emergency**
   - **Method 1**: Triple-click the power button (production feature)
   - **Method 2**: Tap the red SOS button on dashboard
   - **Method 3**: Use "Simulate Triple Click" button for testing

3. **Emergency Flow**
   - App automatically calls police
   - SMS sent with your location
   - Status updates as police respond
   - Confirm safety when rescued
   - Generate and download safety report

4. **View History**
   - Tap history icon in app bar
   - View all past emergencies
   - Download reports for completed incidents

### For Police Users

1. **Login**
   - Select "I am Police" on role selection
   - Login with police credentials

2. **Respond to Emergencies**
   - View active emergencies on dashboard
   - Tap "View Map" to see victim's location
   - Update status to "On The Way"
   - Mark "Rescue Completed" when done

3. **Communication**
   - Call victim directly from emergency card
   - View real-time location on map
   - Navigate using Google Maps

## 🔐 Permissions

The app requires the following permissions:

- **Location**: GPS tracking for emergency location
- **Phone**: Make emergency calls
- **SMS**: Send emergency messages
- **Background Location**: Track location when app is in background
- **Internet**: Maps and data sync

All permissions are requested at runtime with proper explanations.

## 🛠️ Technical Stack

- **Framework**: Flutter 3.38.7
- **Language**: Dart 3.10.7
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Maps**: Google Maps Flutter
- **Location**: Geolocator, Geocoding
- **PDF Generation**: pdf, printing
- **Communication**: url_launcher, flutter_sms
- **Permissions**: permission_handler

## 📱 Key Features Implementation

### Power Button Detection
The app detects triple-click of the power button to trigger emergency. For production:
1. Implement native Android code in `MainActivity.kt`
2. Override `onKeyDown` to detect `KEYCODE_POWER`
3. Use MethodChannel to communicate with Flutter
4. Implement background service for detection when app is closed

Current implementation includes a "Simulate Triple Click" button for testing.

### Background Services
- Emergency detection works in background
- Location tracking continues when app is minimized
- Uses WorkManager for scheduled tasks

### Offline Support
- Local SQLite database stores all data
- Works without internet (except maps)
- Syncs when connection is restored

## 🔄 Emergency Status Flow

```
Help Requested → Police On The Way → Rescued → Safety Confirmed
```

1. **Help Requested**: Emergency triggered by user
2. **Police On The Way**: Police officer accepted and responding
3. **Rescued**: Police marked rescue as completed
4. **Safety Confirmed**: User confirmed safety and added notes

## 📄 Safety Report

Generated PDF includes:
- Incident date and time
- User information
- Location details (address + GPS coordinates)
- Police officer details
- Arrival time
- Safety confirmation
- Additional notes
- Verification status

## 🐛 Troubleshooting

### Common Issues

1. **Location not working**
   - Enable GPS on device
   - Grant location permissions
   - Check internet connection for address resolution

2. **SMS not sending**
   - Grant SMS permissions
   - Check if device supports SMS
   - Verify phone number format

3. **Maps not loading**
   - Add valid Google Maps API key
   - Enable Maps SDK in Google Cloud Console
   - Check internet connection

4. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter and Dart versions

## 🚧 Production Considerations

### Before deploying to production:

1. **Power Button Detection**
   - Implement native Android code for actual power button detection
   - Add iOS support using volume button detection
   - Test on multiple device models

2. **Backend Integration**
   - Replace SQLite with cloud database (Firebase/PostgreSQL)
   - Implement real-time sync
   - Add push notifications

3. **Security**
   - Implement proper authentication (JWT/OAuth)
   - Encrypt sensitive data
   - Add API rate limiting
   - Secure communication channels

4. **Testing**
   - Add integration tests
   - Test on multiple devices
   - Perform security audit
   - Load testing for concurrent emergencies

5. **Legal Compliance**
   - Privacy policy
   - Terms of service
   - Data protection compliance (GDPR, etc.)
   - Emergency services coordination

## 📞 Emergency Number Configuration

The demo uses `+91 9328103613` as the police number. To change:

1. Open `lib/services/emergency_service.dart`
2. Update the `policeNumber` constant:
   ```dart
   static const String policeNumber = 'YOUR_NUMBER_HERE';
   ```

## 🤝 Contributing

This is a demo/hackathon project. For production use:
1. Implement proper backend
2. Add comprehensive testing
3. Implement native power button detection
4. Add real-time features
5. Coordinate with local emergency services

## 📝 License

This project is created for educational and demonstration purposes.

## 👥 Support

For issues or questions:
1. Check the troubleshooting section
2. Review the code comments
3. Test with demo credentials first

## 🎯 Future Enhancements

- [ ] Real-time location sharing
- [ ] Multiple emergency contacts
- [ ] Voice activation
- [ ] Fake call feature
- [ ] Safe zone alerts
- [ ] Community safety features
- [ ] Multi-language support
- [ ] iOS support
- [ ] Web dashboard for police
- [ ] Analytics and reporting

---

**Note**: This is a demo application. For production deployment, implement proper backend infrastructure, security measures, and coordinate with local emergency services.

**Emergency Services**: Always test with demo numbers. Coordinate with local authorities before deploying to production.

**Safety First**: This app is a tool to assist in emergencies but should not replace calling official emergency numbers (911, 112, 100, etc.) when in immediate danger.
