Houmetna Club — Civic Reporting Platform

**Architecture:**
- `mobile/` — Flutter mobile app for citizens (Android/iOS)
- `backend/functions/` — Firebase Cloud Functions (notifications, triggers)
- Firebase services: Auth, Firestore, Storage, FCM

**Must-have Features (MVP):**
- ✅ Authentication: Email + Google (Firebase Auth)
- ✅ Report submission: photo, description, GPS location, category
- ✅ Report workflow: new → in progress → resolved
- ✅ User profile with report history
- ✅ Interactive map showing all reports
- 🔄 Push notifications (FCM) when status changes
- 🔄 Multilingual: Arabic / French / English

**Quick Start:**

1. **Install Flutter** (Windows):
   - Download: https://docs.flutter.dev/get-started/install/windows
   - Extract to `C:\src\flutter`
   - Add to PATH: `C:\src\flutter\bin`
   - Verify: `flutter doctor`

2. **Setup Firebase:**
   ```powershell
   cd mobile
   flutter pub get
   dart pub global activate flutterfire_cli
   flutterfire configure --project=houmetna-club
   ```

3. **Run the mobile app:**
   ```powershell
   flutter run
   ```

4. **Deploy backend functions:**
   ```powershell
   cd backend/functions
   npm install
   firebase deploy --only functions
   ```

**Firebase Console:** https://console.firebase.google.com/project/houmetna-club

**Next Steps:**
- Enable Email/Password and Google Sign-In in Firebase Console
- Add Google Maps API key for map features
- Deploy Firestore security rules
- Test on Android/iOS devices
