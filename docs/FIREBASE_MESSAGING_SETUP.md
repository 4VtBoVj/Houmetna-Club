# Firebase Cloud Messaging (FCM) Implementation Guide

Complete guide to implement push notifications in your frontend app.

---

## 📱 Platform-Specific Guides

### Flutter Implementation

#### Step 1: Install Dependencies

```bash
flutter pub add firebase_core firebase_messaging
flutter pub get
```

#### Step 2: Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Messaging
  await _initializeMessaging();
  
  runApp(const MyApp());
}

Future<void> _initializeMessaging() async {
  final messaging = FirebaseMessaging.instance;
  
  // Request permission
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carryForward: true,
    critical: false,
    provisional: false,
    sound: true,
  );
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permission');
    
    // Get token and save
    final token = await messaging.getToken();
    await _saveDeviceToken(token!);
    
    // Listen for token refreshes
    messaging.onTokenRefresh.listen((newToken) {
      _saveDeviceToken(newToken);
    });
  }
  
  // Handle notifications when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received while app is open');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    
    // Show local notification
    _showLocalNotification(message);
  });
  
  // Handle notification when app is resumed from background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('User tapped notification');
    print('Data: ${message.data}');
    
    // Navigate to report details
    if (message.data['reportId'] != null) {
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (context) => ReportDetailPage(id: message.data['reportId']),
      // ));
    }
  });
}

// Save device token to Firestore
Future<void> _saveDeviceToken(String token) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFunctions.instance
          .httpsCallable('saveDeviceToken')
          .call({'token': token});
      print('Device token saved');
    }
  } catch (e) {
    print('Error saving token: $e');
  }
}

// Show local notification when app is in foreground
void _showLocalNotification(RemoteMessage message) {
  // Use flutter_local_notifications package
  // Implementation depends on your notification UI choice
}
```

#### Step 3: Android Configuration (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21 // FCM requires API 21+
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging'
}
```

#### Step 4: iOS Configuration (ios/Podfile)

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

#### Step 5: Handle Logout

```dart
Future<void> logout() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    
    if (token != null) {
      // Remove token from database
      await FirebaseFunctions.instance
          .httpsCallable('removeDeviceToken')
          .call({'token': token});
    }
    
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print('Error during logout: $e');
  }
}
```

---

### React Native Implementation

#### Step 1: Install Dependencies

```bash
npm install @react-native-firebase/app @react-native-firebase/messaging
# or
yarn add @react-native-firebase/app @react-native-firebase/messaging
```

#### Step 2: Link Native Modules

```bash
cd ios && pod install && cd ..
```

#### Step 3: Initialize in App.js

```javascript
import React, { useEffect } from 'react';
import messaging from '@react-native-firebase/messaging';
import { PermissionsAndroid } from 'react-native';

const App = () => {
  useEffect(() => {
    initializeMessaging();
  }, []);

  const initializeMessaging = async () => {
    // Request permission (Android 13+)
    if (Platform.OS === 'android') {
      await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS,
      );
    }

    // Get initial permission status
    const authStatus = await messaging().requestPermission();
    const enabled =
      authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
      authStatus === messaging.AuthorizationStatus.PROVISIONAL;

    if (enabled) {
      console.log('Notification permission granted');
      
      // Get token and save
      const token = await messaging().getToken();
      await saveDeviceToken(token);
      
      // Listen for token refreshes
      const unsubscribeTokenRefresh = messaging().onTokenRefresh(token => {
        saveDeviceToken(token);
      });
      
      // Handle notifications in foreground
      const unsubscribeForeground = messaging().onMessage(async remoteMessage => {
        console.log('Notification in foreground:', remoteMessage);
        showLocalNotification(remoteMessage);
      });
      
      // Handle notification tap
      const unsubscribeNotificationTap = messaging().onNotificationOpenedApp(remoteMessage => {
        console.log('User tapped notification:', remoteMessage);
        if (remoteMessage.data.reportId) {
          // Navigate to report details
          navigation.navigate('ReportDetail', { id: remoteMessage.data.reportId });
        }
      });
      
      return () => {
        unsubscribeTokenRefresh();
        unsubscribeForeground();
        unsubscribeNotificationTap();
      };
    }
  };

  return (
    // Your app component
  );
};

const saveDeviceToken = async (token) => {
  try {
    const functions = firebase.functions();
    await functions.httpsCallable('saveDeviceToken')({ token });
    console.log('Device token saved');
  } catch (error) {
    console.error('Error saving token:', error);
  }
};

const showLocalNotification = (message) => {
  // Use react-native-notifee or similar
  // Implementation depends on your notification UI choice
};

export default App;
```

#### Step 4: Android Configuration

Create `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging'
}
```

#### Step 5: Handle Logout

```javascript
const logout = async () => {
  try {
    const token = await messaging().getToken();
    
    if (token) {
      // Remove token from database
      const functions = firebase.functions();
      await functions.httpsCallable('removeDeviceToken')({ token });
    }
    
    // Sign out
    await firebase.auth().signOut();
  } catch (error) {
    console.error('Error during logout:', error);
  }
};
```

---

### Web Implementation

#### Step 1: Install Firebase

```bash
npm install firebase
```

#### Step 2: Initialize in your app

```javascript
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getMessaging, getToken, onMessage } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "houmetna-club.firebaseapp.com",
  projectId: "houmetna-club",
  storageBucket: "houmetna-club.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

// Request permission
async function initializeMessaging() {
  try {
    const permission = await Notification.requestPermission();
    
    if (permission === 'granted') {
      console.log('Notification permission granted');
      
      // Get token
      const token = await getToken(messaging, {
        vapidKey: 'YOUR_VAPID_KEY' // Get from Firebase Console
      });
      
      await saveDeviceToken(token);
      
      // Handle notifications
      onMessage(messaging, (payload) => {
        console.log('Message received:', payload);
        showNotification(payload.notification.title, payload.notification.body);
      });
    }
  } catch (error) {
    console.error('Error initializing messaging:', error);
  }
}

async function saveDeviceToken(token) {
  try {
    const response = await fetch('/api/saveDeviceToken', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token })
    });
    console.log('Token saved');
  } catch (error) {
    console.error('Error saving token:', error);
  }
}

function showNotification(title, body) {
  new Notification(title, {
    body: body,
    icon: '/logo.png'
  });
}

// Call on app load
initializeMessaging();
```

#### Step 3: Create Service Worker (public/firebase-messaging-sw.js)

```javascript
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "houmetna-club.firebaseapp.com",
  projectId: "houmetna-club",
  storageBucket: "houmetna-club.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Background message:', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/logo.png',
    data: payload.data
  };
  
  self.registration.showNotification(notificationTitle, notificationOptions);
});
```

#### Step 4: Handle Logout

```javascript
async function logout() {
  try {
    const token = await getToken(messaging, {
      vapidKey: 'YOUR_VAPID_KEY'
    });
    
    if (token) {
      // Remove token from database
      await fetch('/api/removeDeviceToken', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token })
      });
    }
    
    // Sign out
    await signOut(auth);
  } catch (error) {
    console.error('Error during logout:', error);
  }
}
```

---

## 🚀 Production Deployment Checklist

### Firebase Console Setup

1. **Go to Firebase Console:**
   - https://console.firebase.google.com/project/houmetna-club

2. **Cloud Messaging Tab:**
   - [ ] Upload Android credentials (APK signing key)
   - [ ] Upload iOS APNs certificate
   - [ ] Note Server Key and Sender ID

3. **Android Setup:**
   ```bash
   # Get your SHA-256 fingerprint
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   - [ ] Add SHA-256 to Firebase Project Settings
   - [ ] Download google-services.json
   - [ ] Place in `android/app/google-services.json`

4. **iOS Setup:**
   - [ ] Export APNs certificate from Apple Developer
   - [ ] Upload to Firebase Console
   - [ ] Download GoogleService-Info.plist
   - [ ] Add to Xcode project

### Before Going Live

- [ ] Test on real Android device
- [ ] Test on real iOS device
- [ ] Test on web with different browsers
- [ ] Verify notifications work in foreground
- [ ] Verify notifications work in background
- [ ] Test notification tap navigation
- [ ] Verify tokens are saved to Firestore
- [ ] Test logout removes tokens
- [ ] Test token refresh works

### Testing Checklist

```bash
# 1. Create test user and opt-in to notifications
# 2. Check Firestore users collection
# 3. See deviceTokens array populated

# 4. As admin, update a report status
# 5. Check notifications collection
# 6. See push notification on device

# 7. Tap notification
# 8. App opens to correct report

# 9. Test logout
# 10. Verify token removed from Firestore
```

---

## 🔧 Troubleshooting

### Android Issues

**"Google Play Services not available"**
- Install Google Play Services on emulator or use real device

**No notifications received**
- Check AndroidManifest.xml has INTERNET permission
- Verify minSdkVersion is 21+
- Check firebase-messaging dependency

### iOS Issues

**"APNs certificate is invalid"**
- Regenerate certificate in Apple Developer account
- Upload new certificate to Firebase

**No notifications in background**
- Verify app has notification permission
- Check APNs certificate is correctly configured

### Web Issues

**"Service Worker registration failed"**
- Ensure firebase-messaging-sw.js is in public folder
- Check HTTPS is enabled (required for Service Workers)

**"getToken failed"**
- Verify VAPID key is correct
- Check browser supports notifications (not Safari)

---

## 📚 Additional Resources

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [React Native Firebase Messaging](https://rnfirebase.io/messaging/usage)
- [Web Firebase Messaging](https://firebase.google.com/docs/cloud-messaging/js/client)
