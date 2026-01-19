# Emergency Phone Number Update

## ✅ Current Configuration

The emergency police contact number is set throughout the application.

### 📞 Current Number

**Emergency Contact:** `+91 9328103613`

### 📝 What Was Changed

#### 1. Core Service (Main Implementation)
- **File**: `lib/services/emergency_service.dart`
- **Line**: Police number constant
- **Change**: Updated to `+919328103613`

#### 2. Demo Police User
- **File**: `lib/services/database_service.dart`
- **Change**: Demo police user phone number updated
- **Impact**: Pre-seeded police user now has the new number

#### 3. Documentation Files Updated
- ✅ `README.md` - Main documentation
- ✅ `QUICK_START.md` - Quick start guide (2 occurrences)
- ✅ `PROJECT_SUMMARY.md` - Project summary (2 occurrences)
- ✅ `IMPLEMENTATION_GUIDE.md` - Implementation guide
- ✅ `FEATURES.md` - Features list

### 🎯 How It Works Now

When emergency is triggered:

1. **Automatic Call**: Opens phone dialer with `+91 9328103613`
2. **Emergency SMS**: Sends SMS to `+91 9328103613` with:
   - Emergency alert message
   - User's name and location
   - GPS coordinates
   - Google Maps link

### 🧪 Testing

To test the new number:

```bash
# Run the app
flutter run

# Login as woman
Email: priya@demo.com
Password: demo123

# Trigger emergency
Tap SOS button or "Simulate Triple Click"

# Verify
- Phone dialer opens with: +91 9328103613
- SMS app opens with pre-filled message to: +91 9328103613
```

### 📱 Demo Police User

The demo police account also updated:

```
Email: police@demo.com
Password: police123
Phone: +91 9328103613
Badge: POL12345
```

### 🔄 To Change Number Again

If you need to change the number in the future:

1. Open `lib/services/emergency_service.dart`
2. Find line: `static const String policeNumber = '+919328103613';`
3. Replace with your number (include country code)
4. Save and run: `flutter run`

### ✅ Verification Checklist

- [x] Emergency service updated
- [x] Demo police user updated
- [x] All documentation updated
- [x] Number format correct (+91 prefix)
- [x] Ready to test

### 🎉 Status

**All changes complete!** The app now uses `+91 9328103613` for all emergency calls and SMS.

---

**Updated**: January 16, 2026
**Emergency Number**: +91 9328103613
