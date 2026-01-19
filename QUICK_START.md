# Quick Start Guide - Women Safety App

## ⚡ 5-Minute Setup

### 1. Install Dependencies
```bash
cd women_safety_app
flutter pub get
```

### 2. Run Tests (Optional)
```bash
flutter test
```
Expected: ✅ All 10 tests passed!

### 3. Run the App
```bash
flutter run
```

## 🎮 Testing the App

### Demo Credentials

**Women User:**
```
Email: priya@demo.com
Password: demo123
```

**Police User:**
```
Email: police@demo.com
Password: police123
```

## 🧪 Test Scenarios

### Scenario 1: Women Emergency (2 minutes)

1. Launch app → Select "I am a Woman"
2. Login with women credentials
3. Tap red SOS button OR "Simulate Triple Click"
4. Observe: Call initiated, SMS sent, status shows "Help Requested"
5. View emergency on dashboard

### Scenario 2: Police Response (2 minutes)

1. Launch app on second device/emulator
2. Select "I am Police"
3. Login with police credentials
4. See active emergency on dashboard
5. Tap "View Map" → See location
6. Tap "On The Way" → Status updates
7. Tap "Mark Rescue Completed"

### Scenario 3: Complete Flow (5 minutes)

**Device 1 (Woman):**
1. Login → Trigger emergency
2. Wait for status updates

**Device 2 (Police):**
1. Login → See emergency
2. Update to "On The Way"
3. Mark "Rescue Completed"

**Device 1 (Woman):**
1. See "Rescued" status
2. Tap "Confirm I am Safe"
3. Enter arrival time: "10:30 AM"
4. Add notes (optional)
5. Submit
6. Tap "Generate Safety Report"
7. View/Share PDF

## 📱 Key Features to Demo

### Women Dashboard
- ✅ Large red SOS button
- ✅ Emergency status card
- ✅ Simulate triple click button
- ✅ History icon (top right)
- ✅ Safety confirmation button (after rescue)

### Police Dashboard
- ✅ Active emergencies list
- ✅ View Map button
- ✅ On The Way button
- ✅ Mark Rescue Completed button
- ✅ Refresh icon (top right)

### Live Map Screen
- ✅ Google Maps with emergency marker
- ✅ Victim information card
- ✅ Call button
- ✅ Navigate button
- ✅ GPS coordinates display

## 🔧 Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Tests failing?
```bash
flutter pub get
flutter test
```

### Location not working?
- Enable GPS on device
- Grant location permissions when prompted
- Check internet connection

### Maps not loading?
- Add Google Maps API key (optional for basic testing)
- Check internet connection
- App works without maps, just limited map features

## 📞 Important Numbers

**Demo Police Number:** +91 9328103613

This number is used for:
- Emergency calls
- SMS alerts

## 🎯 What to Show in Demo

1. **Dual User System** (30 seconds)
   - Show role selection
   - Login as both types

2. **Emergency Trigger** (1 minute)
   - Tap SOS button
   - Show automatic call
   - Show SMS with location

3. **Police Response** (1 minute)
   - Show police dashboard
   - View location on map
   - Update status

4. **Safety Confirmation** (1 minute)
   - Confirm safety
   - Generate PDF report
   - Show report content

5. **History** (30 seconds)
   - Show emergency history
   - Download past reports

## 💡 Pro Tips

1. **Use Two Devices**: Best experience with two devices/emulators
2. **Test Simulation**: Use "Simulate Triple Click" for reliable testing
3. **Check Permissions**: Grant all permissions for full functionality
4. **Internet Required**: For maps and address resolution
5. **Demo Data**: Pre-loaded users work immediately

## 🚀 Commands Cheat Sheet

```bash
# Setup
flutter pub get

# Run tests
flutter test

# Run app
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk

# Clean build
flutter clean

# Check devices
flutter devices

# View logs
flutter logs
```

## 📋 Pre-Demo Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Tests passing (`flutter test`)
- [ ] App runs on device/emulator
- [ ] Location permissions granted
- [ ] Internet connection active
- [ ] Two devices ready (optional)
- [ ] Demo credentials memorized
- [ ] Key features identified

## 🎬 Demo Script (5 minutes)

**Minute 1:** Introduction
- "Women Safety App with emergency response"
- Show role selection screen

**Minute 2:** Women User
- Login as woman
- Trigger emergency
- Show automatic call and SMS

**Minute 3:** Police User
- Login as police
- Show emergency dashboard
- View location on map

**Minute 4:** Response Flow
- Update status to "On The Way"
- Mark rescue completed
- Show status updates

**Minute 5:** Completion
- Confirm safety
- Generate PDF report
- Show emergency history

## 🔥 Quick Demo (2 minutes)

1. **Login** as woman (15 sec)
2. **Trigger** emergency (15 sec)
3. **Show** police dashboard (30 sec)
4. **Update** status (30 sec)
5. **Generate** report (30 sec)

## 📱 Screenshots to Capture

1. Role selection screen
2. Women dashboard with SOS button
3. Emergency status card
4. Police dashboard with emergencies
5. Live map with location
6. Safety confirmation screen
7. PDF report
8. Emergency history

## 🎓 Key Points to Mention

- ✅ Dual user roles (Women & Police)
- ✅ Triple-click power button detection
- ✅ Automatic emergency call
- ✅ SMS with GPS location
- ✅ Real-time status updates
- ✅ Live location tracking
- ✅ PDF safety reports
- ✅ Complete emergency history
- ✅ Clean architecture
- ✅ Comprehensive testing

## 🚨 Emergency Flow Summary

```
Woman triggers SOS
    ↓
Automatic call + SMS
    ↓
Police sees emergency
    ↓
Police responds
    ↓
Woman confirms safety
    ↓
PDF report generated
```

## 📞 Support

**Issues?** Check:
1. README.md - Complete documentation
2. IMPLEMENTATION_GUIDE.md - Detailed testing
3. Console logs - Error messages

**Demo Police Number:** +91 9328103613

---

**Ready to Demo! 🎉**

Run `flutter run` and start testing!
