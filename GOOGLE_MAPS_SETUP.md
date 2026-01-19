# Google Maps Setup Guide

## 🗺️ Issue: Map Not Working on Police Dashboard

The map feature requires a Google Maps API key to display maps. Here's how to fix it:

## 🚀 Quick Fix (2 Options)

### Option 1: Get Free Google Maps API Key (Recommended)

#### Step 1: Get API Key (5 minutes)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Maps SDK for Android**
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Copy your API key

#### Step 2: Add API Key to App

Open `android/app/src/main/AndroidManifest.xml` and replace:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

With:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY"/>
```

#### Step 3: Run App

```bash
flutter run
```

Maps will now work! ✅

---

### Option 2: Use Alternative Without API Key (Quick Demo)

If you don't want to set up Google Maps API, you can use the "Open in Google Maps" button which works without API key!

#### How It Works Now (Without API Key)

1. Police sees emergency on dashboard ✅
2. Clicks "View Map" button ✅
3. Sees emergency information card ✅
4. Sees GPS coordinates ✅
5. Clicks "Navigate" button (top right) ✅
6. **Opens Google Maps app** with location ✅

The "Open in Google Maps" button works perfectly without any API key!

---

## 🎯 For Demo/Hackathon

### Without API Key (Works Now!)

**What Works:**
- ✅ Emergency dashboard
- ✅ Location coordinates display
- ✅ Address display
- ✅ Call button
- ✅ **"Open in Google Maps" button** (navigation icon)
- ✅ Opens external Google Maps app

**What Doesn't Work:**
- ❌ Embedded map view in app

**Demo Strategy:**
1. Show police dashboard
2. Click "View Map"
3. Show emergency info card
4. Show GPS coordinates
5. Click navigation icon (top right)
6. **Google Maps app opens** with exact location
7. Police can navigate from there

This is actually **better for real use** because:
- Google Maps app has better navigation
- Turn-by-turn directions
- Traffic updates
- No API key needed

---

## 📱 Alternative: Simple Location Display

If you want to show location without Google Maps, I can create a simple coordinate display screen. Let me know!

---

## 🔧 Detailed Google Maps Setup

### Step-by-Step API Key Setup

#### 1. Create Google Cloud Project

1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Name: "Women Safety App"
4. Click "Create"

#### 2. Enable Maps SDK

1. In the project, go to "APIs & Services" → "Library"
2. Search for "Maps SDK for Android"
3. Click on it
4. Click "Enable"

#### 3. Create API Key

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the API key (starts with `AIza...`)

#### 4. Restrict API Key (Optional but Recommended)

1. Click on the API key you just created
2. Under "Application restrictions":
   - Select "Android apps"
   - Click "Add an item"
   - Package name: `com.example.women_safety_app`
   - SHA-1: Get from `keytool -list -v -keystore ~/.android/debug.keystore`
3. Under "API restrictions":
   - Select "Restrict key"
   - Check "Maps SDK for Android"
4. Click "Save"

#### 5. Add to AndroidManifest.xml

Location: `android/app/src/main/AndroidManifest.xml`

Find this line:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

Replace with:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>
```

#### 6. Rebuild and Run

```bash
flutter clean
flutter pub get
flutter run
```

---

## 💰 Pricing

Google Maps is **FREE** for:
- First 28,000 map loads per month
- Perfect for demo/hackathon/small apps

You won't be charged unless you exceed free tier.

---

## 🐛 Troubleshooting

### Map Shows Gray Screen

**Cause**: Invalid or missing API key

**Fix**:
1. Check API key is correct in AndroidManifest.xml
2. Ensure Maps SDK for Android is enabled
3. Wait 5 minutes after creating key (propagation time)
4. Run `flutter clean` and rebuild

### Map Shows "For development purposes only"

**Cause**: API key not restricted properly

**Fix**: This is normal for development. Add billing to remove watermark (still free under quota).

### Map Not Loading

**Cause**: No internet connection or API key issue

**Fix**:
1. Check internet connection
2. Verify API key in manifest
3. Check console for errors: `flutter run --verbose`

---

## 🎯 Current Workaround (No API Key Needed)

The app currently works perfectly for demo without API key:

### Police Workflow:
1. Login as police ✅
2. See emergency on dashboard ✅
3. Click "View Map" ✅
4. See emergency details ✅
5. See GPS coordinates ✅
6. Click navigation icon (top right) ✅
7. **Google Maps app opens** ✅
8. Navigate to location ✅

### This Works Because:
- Uses `url_launcher` to open Google Maps app
- No API key required for external app launch
- Actually better UX for navigation
- Works on all devices

---

## 📊 Comparison

| Feature | With API Key | Without API Key |
|---------|-------------|-----------------|
| Embedded map in app | ✅ Yes | ❌ No |
| GPS coordinates | ✅ Yes | ✅ Yes |
| Address display | ✅ Yes | ✅ Yes |
| Open in Maps app | ✅ Yes | ✅ Yes |
| Navigation | ✅ Yes | ✅ Yes (via Maps app) |
| Call button | ✅ Yes | ✅ Yes |
| Setup time | 5 minutes | 0 minutes |
| Cost | Free (28k/month) | Free |

---

## 🎉 Recommendation for Demo

**Use the current implementation without API key!**

Why?
- ✅ Works immediately
- ✅ No setup needed
- ✅ Opens Google Maps app (better navigation)
- ✅ Shows all emergency info
- ✅ Professional and functional

The "Open in Google Maps" button is actually the **preferred approach** for emergency apps because:
- Dedicated navigation app
- Better routing
- Traffic updates
- Offline maps support

---

## 🔄 Quick Test

### Test Without API Key (Current State):

```bash
flutter run
```

1. Login as police: `police@demo.com` / `police123`
2. Trigger emergency from women's side
3. Click "View Map" on police dashboard
4. See emergency info ✅
5. See coordinates ✅
6. Click navigation icon (top right) ✅
7. Google Maps opens ✅

**Everything works except embedded map view!**

---

## 📝 Summary

**For Demo/Hackathon**: Use current implementation (no API key needed)
- Click navigation icon to open Google Maps app
- Works perfectly for demonstration

**For Production**: Add Google Maps API key
- Follow steps above
- Takes 5 minutes
- Free for most use cases

---

**Current Status**: ✅ Fully functional for demo without API key!

The "Open in Google Maps" feature works perfectly and is actually better for real-world use.
