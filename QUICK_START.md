# 🚀 Quick Start Guide for Frontend Developers

Get started building the frontend in 5 minutes.

---

## Prerequisites

- Node.js v18+ or Flutter SDK installed
- Git
- Firebase account access
- Code editor (VS Code, Android Studio, Xcode)

---

## Option 1: Flutter (Mobile App)

### 1. Create Flutter Project

```bash
flutter create houmetna_app
cd houmetna_app
```

### 2. Add Firebase Dependencies

```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_functions firebase_messaging
flutter pub get
```

### 3. Initialize Firebase

```bash
flutterfire configure --project=houmetna-club
```

This generates `lib/firebase_options.dart`

### 4. Basic Auth Setup (lib/main.dart)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 5. Create Login Screen

See [FIREBASE_MESSAGING_SETUP.md](docs/FIREBASE_MESSAGING_SETUP.md#flutter-implementation) for complete example with authentication.

### 6. Create Report Form

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> submitReport(String description, double lat, double lng) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('createReport')
        .call({
          'category': 'pothole',
          'description': description,
          'latitude': lat,
          'longitude': lng,
          'photoURL': null, // Add photo URL when available
        });
    
    print('Report created: ${result.data['reportId']}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### 7. List User Reports

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<List<Map>> getUserReports() async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('getUserReports')
        .call();
    
    return List<Map>.from(result.data as List);
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
```

### 8. Run on Emulator/Device

```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d macos

# Real device
flutter run
```

---

## Option 2: React Native (Cross-Platform Mobile)

### 1. Create React Native Project

```bash
npx create-expo-app houmetna-app
cd houmetna-app
```

### 2. Install Firebase Packages

```bash
npm install firebase @react-native-firebase/app @react-native-firebase/auth @react-native-firebase/functions @react-native-firebase/messaging
```

### 3. Initialize Firebase (App.js)

```javascript
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "houmetna-club.firebaseapp.com",
  projectId: "houmetna-club",
  storageBucket: "houmetna-club.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const functions = getFunctions(app);

export { auth, functions };
```

### 4. Create Login Component

```javascript
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from './App';

async function login(email, password) {
  try {
    await signInWithEmailAndPassword(auth, email, password);
    console.log('Logged in');
  } catch (error) {
    console.error(error);
  }
}
```

### 5. Submit Report

```javascript
import { httpsCallable } from 'firebase/functions';
import { functions } from './App';

const createReport = httpsCallable(functions, 'createReport');

async function submitReport(category, description, latitude, longitude) {
  try {
    const result = await createReport({
      category,
      description,
      latitude,
      longitude,
      photoURL: null
    });
    console.log('Report created:', result.data.reportId);
  } catch (error) {
    console.error(error);
  }
}
```

### 6. List Reports

```javascript
const getUserReports = httpsCallable(functions, 'getUserReports');

async function fetchReports() {
  try {
    const result = await getUserReports();
    console.log('User reports:', result.data);
  } catch (error) {
    console.error(error);
  }
}
```

### 7. Run App

```bash
# Start Expo
expo start

# Scan QR code with Expo Go app on phone
```

---

## Option 3: React Web App

### 1. Create React App

```bash
npx create-react-app houmetna-web
cd houmetna-web
```

### 2. Install Firebase

```bash
npm install firebase
```

### 3. Configure Firebase (firebase.js)

```javascript
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFunctions } from 'firebase/functions';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "houmetna-club.firebaseapp.com",
  projectId: "houmetna-club",
  storageBucket: "houmetna-club.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const functions = getFunctions(app);
```

### 4. Create Login Component

```javascript
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../firebase';
import { useState } from 'react';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async () => {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      // Navigate to dashboard
    } catch (error) {
      console.error('Login failed:', error);
    }
  };

  return (
    <div>
      <input 
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      <input 
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
      />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}
```

### 5. Report Submission Component

```javascript
import { httpsCallable } from 'firebase/functions';
import { functions } from '../firebase';
import { useState } from 'react';

export function ReportForm() {
  const [category, setCategory] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    try {
      const createReport = httpsCallable(functions, 'createReport');
      const result = await createReport({
        category,
        description,
        latitude: 33.5731,
        longitude: -7.5898,
        photoURL: null
      });
      console.log('Report created:', result.data.reportId);
      // Show success message
    } catch (error) {
      console.error('Error:', error);
    }
    setLoading(false);
  };

  return (
    <form onSubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
      <input 
        value={category}
        onChange={(e) => setCategory(e.target.value)}
        placeholder="Category (pothole, light, etc.)"
      />
      <textarea 
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder="Describe the issue"
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Submitting...' : 'Submit Report'}
      </button>
    </form>
  );
}
```

### 6. Reports List Component

```javascript
import { httpsCallable } from 'firebase/functions';
import { functions } from '../firebase';
import { useEffect, useState } from 'react';

export function ReportsList() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchReports = async () => {
      try {
        const getUserReports = httpsCallable(functions, 'getUserReports');
        const result = await getUserReports();
        setReports(result.data);
      } catch (error) {
        console.error('Error fetching reports:', error);
      }
      setLoading(false);
    };

    fetchReports();
  }, []);

  if (loading) return <p>Loading...</p>;

  return (
    <div>
      <h2>My Reports</h2>
      {reports.map(report => (
        <div key={report.id} style={{ border: '1px solid #ccc', padding: '10px' }}>
          <p><strong>{report.category}</strong> - {report.status}</p>
          <p>{report.description}</p>
          <small>{new Date(report.createdAt?.toDate?.()).toLocaleDateString()}</small>
        </div>
      ))}
    </div>
  );
}
```

### 7. Run App

```bash
npm start
```

Open http://localhost:3000

---

## Common Tasks

### Get Current User

```javascript
import { onAuthStateChanged, auth } from './firebase';

onAuthStateChanged(auth, (user) => {
  if (user) {
    console.log('User:', user.email);
  } else {
    console.log('No user logged in');
  }
});
```

### Logout

```javascript
import { signOut } from 'firebase/auth';

await signOut(auth);
```

### Request Location Permission

**Flutter:**
```dart
import 'package:geolocator/geolocator.dart';

Position position = await Geolocator.getCurrentPosition();
```

**React Native:**
```javascript
import { request, PERMISSIONS, RESULTS } from 'react-native-permissions';

const result = await request(PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION);
```

**Web:**
```javascript
navigator.geolocation.getCurrentPosition((position) => {
  const { latitude, longitude } = position.coords;
  console.log(`Location: ${latitude}, ${longitude}`);
});
```

---

## Troubleshooting

### "Project not found" Error

- Check your Firebase Project ID is `houmetna-club`
- Update your Firebase config with correct credentials

### "Function not callable"

- Ensure Cloud Functions are deployed: `firebase deploy --only functions`
- Check function names match exactly (case-sensitive)

### "Permission denied"

- Verify user is authenticated
- Check Firestore security rules allow the operation
- For admin functions, verify user has `role: 'admin'`

---

## Next Steps

1. **Implement Authentication:**
   - Login/Sign-up screens
   - Password reset
   - User profiles

2. **Build Report Features:**
   - Report form with photo upload
   - Report list view
   - Report details page
   - Status tracking

3. **Add Notifications:**
   - Follow [FIREBASE_MESSAGING_SETUP.md](docs/FIREBASE_MESSAGING_SETUP.md)
   - Request notification permission
   - Save device tokens
   - Display notifications

4. **Admin Dashboard (optional):**
   - View all reports
   - Filter by status
   - Update report status
   - Map view

---

## Need Help?

- Check [README.md](README.md) for backend setup
- Read [FIREBASE_MESSAGING_SETUP.md](docs/FIREBASE_MESSAGING_SETUP.md) for notifications
- Check [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for production deployment
- Visit [Firebase Docs](https://firebase.google.com/docs)

**You're ready to build! 🚀**
