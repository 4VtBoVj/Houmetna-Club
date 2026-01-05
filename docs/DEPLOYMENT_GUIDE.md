# Production Deployment Guide

Complete checklist for deploying Houmetna Club to production.

---

## 🔧 Phase 1: Backend Deployment (Firebase Cloud Functions)

### Step 1: Prepare for Production

```bash
cd backend/functions
npm install
npm audit fix
```

Check for security vulnerabilities:
```bash
npm audit
```

### Step 2: Deploy Cloud Functions

```bash
# From project root
firebase deploy --only functions
```

This deploys:
- ✅ createReport
- ✅ updateReportStatus
- ✅ onReportStatusChange
- ✅ getUserReports
- ✅ getAllReports
- ✅ saveDeviceToken
- ✅ removeDeviceToken

### Step 3: Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

### Step 4: Deploy Storage Security Rules

```bash
firebase deploy --only storage:rules
```

### Step 5: Verify Deployment

```bash
firebase functions:list
firebase firestore:indexes
```

All functions should be running at:
```
https://us-central1-houmetna-club.cloudfunctions.net/functionName
```

---

## 📱 Phase 2: Mobile App Deployment

### Flutter to Android

#### Step 1: Build Signed APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/apk/release/app-release.apk`

#### Step 2: Setup Firebase Credentials

1. Get SHA-256 fingerprint:
```bash
cd android
./gradlew signingReport
cd ..
```

2. Add to Firebase Console:
   - Project Settings → Your Apps → Android
   - Add SHA-256 fingerprint

3. Download `google-services.json`:
   - Place in `android/app/google-services.json`

#### Step 3: Configure Release Signing

Edit `android/app/build.gradle`:

```gradle
android {
  signingConfigs {
    release {
      storeFile file("keystore.jks")
      storePassword "YOUR_STORE_PASSWORD"
      keyAlias "YOUR_KEY_ALIAS"
      keyPassword "YOUR_KEY_PASSWORD"
    }
  }
  
  buildTypes {
    release {
      signingConfig signingConfigs.release
    }
  }
}
```

#### Step 4: Build & Sign

```bash
flutter build apk --release --flavor production
```

#### Step 5: Upload to Play Store

1. Create Play Store Developer Account ($25 one-time)
2. Create app in Play Console
3. Upload APK to internal testing track first
4. Test with real users
5. Promote to production

### Flutter to iOS

#### Step 1: Build iOS App

```bash
flutter build ios --release
```

#### Step 2: Setup Code Signing

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner → Signing & Capabilities
3. Select your Team
4. Set Bundle Identifier: `com.yourcompany.houmetna`

#### Step 3: Configure Provisioning Profile

1. Apple Developer Account → Certificates, IDs & Profiles
2. Create App ID
3. Create Provisioning Profile (Ad Hoc or App Store)
4. Download and select in Xcode

#### Step 4: Build & Archive

```bash
flutter build ios --release
```

Then in Xcode:
- Product → Scheme → Runner
- Product → Build For → Running
- Product → Archive

#### Step 5: Upload to App Store

1. Create app in App Store Connect
2. Validate archive
3. Upload archive
4. Fill in app details (screenshots, description, etc.)
5. Submit for review

---

## 🌐 Phase 3: Web Deployment

### Step 1: Build Production Bundle

```bash
# For React
npm run build

# For Vue
yarn build

# For Next.js
next build
```

### Step 2: Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

Or deploy specific site:
```bash
firebase deploy --only hosting:houmetna-club
```

### Step 3: Verify Deployment

Your app will be live at:
```
https://houmetna-club.web.app
https://houmetna-club.firebaseapp.com
```

---

## 🔐 Phase 4: Security Configuration

### Firebase Authentication

1. Go to Firebase Console → Authentication → Sign-in Method
2. Enable:
   - [ ] Email/Password
   - [ ] Google Sign-In
   - [ ] (Optional) Facebook, GitHub, etc.

3. Configure OAuth Redirect URLs:
   - Add your domain to authorized redirect URIs

### Firestore Security Rules

Verify rules are deployed:
```bash
firebase firestore:indexes
```

Check rules file is updated:
```bash
cat firestore.rules
```

### Storage Security Rules

Verify storage rules:
```bash
cat storage.rules
```

---

## 📊 Phase 5: Monitoring & Analytics

### Enable Firebase Analytics

```bash
# Flutter
# Add to pubspec.yaml:
firebase_analytics: ^latest
```

```javascript
// Web/React
import { getAnalytics } from "firebase/analytics";
const analytics = getAnalytics(app);
```

### Setup Error Reporting

1. Firebase Console → Quality → Crash Reporting
2. Errors are logged automatically

### Enable Performance Monitoring

```bash
# Flutter
firebase_performance: ^latest
```

```javascript
// Web
import { getPerformance } from "firebase/performance";
const perf = getPerformance(app);
```

---

## 🔔 Phase 6: Push Notifications

### Setup FCM

1. Firebase Console → Cloud Messaging
2. Upload Android credentials
3. Upload iOS APNs certificate
4. Note Server Key and Sender ID

### Configure in App

Update your app with:
- [ ] VAPID Key (for web)
- [ ] Sender ID (for mobile)
- [ ] Server Key (for backend)

---

## 📋 Phase 7: Testing Checklist

### Backend Testing

- [ ] All Cloud Functions callable and working
- [ ] Firestore rules enforce security
- [ ] Storage rules validate uploads
- [ ] Notifications trigger on status change
- [ ] Device tokens save/remove correctly

### Mobile App Testing

- [ ] App installs from App Store / Play Store
- [ ] Authentication works
- [ ] Can create and view reports
- [ ] Can receive push notifications
- [ ] Notification tap navigates correctly
- [ ] Logout removes device token

### Web App Testing

- [ ] App loads on all major browsers
- [ ] Responsive design works
- [ ] Can create and view reports
- [ ] Push notifications work (if available)
- [ ] Performance is acceptable

---

## 🚀 Phase 8: Launch

### Pre-Launch Checklist

- [ ] All tests passing
- [ ] No console errors
- [ ] Performance metrics acceptable
- [ ] Security audit completed
- [ ] Backup and rollback plan ready
- [ ] Support team trained

### Launch Steps

1. **Announce launch** to target users
2. **Monitor for issues** in real-time
3. **Be ready to rollback** if critical issues
4. **Gather user feedback**
5. **Plan first update** based on feedback

### Post-Launch Monitoring

Monitor Firebase Console:
- [ ] Crash Reporting
- [ ] Performance Monitoring
- [ ] Cloud Functions executions
- [ ] Firestore usage
- [ ] Authentication metrics

---

## 📞 Troubleshooting

### Functions Won't Deploy

```bash
# Check for syntax errors
firebase deploy --only functions --debug

# Check Node version
node --version  # Should be v18+
```

### Authentication Issues

1. Check OAuth credentials in Firebase Console
2. Verify redirect URIs match your app domain
3. Check email/password auth is enabled

### Push Notifications Not Working

1. Verify FCM credentials are uploaded
2. Check device tokens are being saved
3. Verify APNs certificate (iOS) is valid
4. Check notification permissions requested in app

---

## 📚 Rollback Plan

If critical issues occur:

### Rollback Functions
```bash
firebase functions:delete functionName
firebase deploy --only functions
```

### Rollback Hosting
```bash
firebase hosting:channel:delete previousChannel
firebase hosting:clone previousChannel
```

### Rollback Database Rules
```bash
# Revert firestore.rules to previous version
firebase deploy --only firestore:rules
```

---

## 🎯 Post-Launch Optimization

### Performance Optimization

1. Analyze Firebase Performance metrics
2. Optimize slow functions
3. Implement Firestore indexes for queries
4. Cache frequently accessed data

### Cost Optimization

1. Review Firebase pricing
2. Set up budget alerts
3. Optimize function execution time
4. Cleanup old data

### User Experience

1. Gather analytics
2. Implement A/B testing
3. Collect user feedback
4. Plan improvements
