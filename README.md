# Houmetna Club — Civic Reporting Platform (Backend)

A civic reporting platform where citizens can report urban issues (potholes, broken lights, waste management, etc.) to municipalities.

---

## 📋 What's Been Done So Far

### ✅ Completed Features

**Backend Infrastructure (Production-Ready):**
- Firebase project configured (`houmetna-club`) with emulators for local dev
- 5 Cloud Functions fully implemented and tested:
  - `createReport` ✅ - Creates reports with location, photos, user tracking
  - `updateReportStatus` ✅ - Admin-only status updates (new → in-progress → resolved)
  - `onReportStatusChange` ✅ - Auto-triggers notifications on status change
  - `getUserReports` ✅ - Users see only their own reports
  - `getAllReports` ✅ - Admin-only: fetch all reports with pagination
- Firestore security rules ✅ - User/admin permissions enforced
- Cloud Storage rules ✅ - Photo uploads with size/type limits
- Automated test suite ✅ - Verifies all functionality works

**Data Structure:**
- **reports** collection: category, description, location (GPS), photoURL, status, userId, timestamps
- **users** collection: name, email, photoURL, role (user/admin)
- **notifications** collection: userId, reportId, message, type, read status, timestamps
- Admin role system implemented (check users collection for `role: 'admin'`)

**Documentation:**
- Architecture overview ([docs/ARCHITECTURE.md](docs/ARCHITECTURE.md))
- Firebase setup guide ([docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md))

### 🚧 What's Left to Do

**High Priority:**
- [ ] Push notifications using Firebase Cloud Messaging (FCM)
- [ ] Multilingual support (Arabic, French, English)
- [ ] Comments feature (allow users to comment on reports)
- [ ] Voting system (upvote reports to show priority)

**Medium Priority:**
- [ ] Admin analytics dashboard (report statistics)
- [ ] Report categories expansion (currently basic)
- [ ] Photo compression before upload
- [ ] Email notifications (in addition to push)

**Before Production:**
- [ ] Deploy functions to Firebase production
- [ ] Deploy security rules to production
- [ ] Set up CI/CD pipeline
- [ ] Add monitoring and error tracking

---

## 🚀 How to Set Up and Run the Project

### Prerequisites

You need to install these tools on your machine:

1. **Node.js** (version 18 or higher)
   - Download: https://nodejs.org/
   - Verify: `node --version` (should show v18.x or higher)

2. **Firebase CLI**
   ```powershell
   npm install -g firebase-tools
   ```
   - Verify: `firebase --version`

3. **Git** (to clone the project)
   - Download: https://git-scm.com/

### Step 1: Clone and Install Dependencies

```powershell
# Clone the project (if not already)
cd C:\Project\Houmetna Club

# Install backend dependencies
cd backend/functions
npm install
```

This will install all required packages (Firebase Functions, Firebase Admin SDK, etc.)

### Step 2: Firebase Login

```powershell
firebase login
```

This opens your browser to authenticate with Google. Use the account that has access to the `houmetna-club` Firebase project.

### Step 3: Link to Firebase Project

The project is already linked to `houmetna-club`, but verify:

```powershell
firebase use
```

Should show: `* houmetna-club (current)`

If not, run:
```powershell
firebase use houmetna-club
```

---

## 🧪 How to Test the Backend

### Start Firebase Emulators

From the project root (`C:\Project\Houmetna Club`):

```powershell
firebase emulators:start
```

You'll see:
```
✔  All emulators ready!
i  View Emulator UI at http://127.0.0.1:4000/

Emulators running:
- Authentication: 127.0.0.1:9099
- Functions: 127.0.0.1:5001
- Firestore: 127.0.0.1:8080
- Storage: 127.0.0.1:9199
```

**Keep this terminal open** while testing!

### Test Using Emulator UI

1. **Open the Emulator UI:**
   - Go to: http://127.0.0.1:4000/

2. **Create Test Users:**
   - Click **Authentication** tab
   - Click **Add user**
   - Create a regular user:
     - Email: `test@houmetna.com`
     - Password: `test123456`
     - Click **Save**
   - Create an admin user:
     - Email: `admin@houmetna.com`
     - Password: `admin123456`
     - Copy the **User UID** (you'll need it)

3. **Set Admin Role:**
   - Click **Firestore** tab
   - Click **Start collection**
   - Collection ID: `users`
   - Document ID: Paste the admin user's UID
   - Add fields:
     - `role` (string): `admin`
     - `email` (string): `admin@houmetna.com`
     - `name` (string): `Admin User`
   - Click **Save**

### Test Functions via Node.js Script

The test script handles everything automatically:

**1. Create ONE test user in the Emulator UI:**
   - Go to: http://127.0.0.1:4000/
   - Click **Authentication** tab
   - Click **Add user**:
     - Email: `test@houmetna.com`
     - Password: `test123456`
     - Click **Save**

**2. Run the automated test script:**
```powershell
node test-functions.js
```

The script automatically:
- ✅ Signs in as test user
- ✅ Creates a report
- ✅ Lists user's reports
- ✅ Creates admin user (no manual setup needed)
- ✅ Sets admin role in Firestore
- ✅ Tests admin functions
- ✅ Updates report status
- ✅ Verifies data persistence

**3. Check results in Emulator UI (optional):**
   - Go to http://127.0.0.1:4000/
   - **Firestore** tab → see `reports`, `users`, `notifications` collections
   - **Logs** tab → see function execution details

### Test All Functions

| Function | Status | What It Does |
|----------|--------|--------------|
| `createReport` | ✅ Tested | Any user creates a report |
| `updateReportStatus` | ✅ Tested | Admin updates status |
| `onReportStatusChange` | ✅ Tested | Auto-creates notification on status change |
| `getUserReports` | ✅ Tested | User sees only their reports |
| `getAllReports` | ✅ Tested | Admin sees all reports |

| Function | Who Can Use | What It Does |
|----------|-------------|--------------|
| `createReport` | Any authenticated user | Creates a new report |
| `updateReportStatus` | Admin only | Changes report status |
| `onReportStatusChange` | (Automatic trigger) | Creates notification when status changes |
| `getUserReports` | Any authenticated user | Gets user's own reports |
| `getAllReports` | Admin only | Gets all reports (with limit) |

---

## 📁 Project Structure

```
Houmetna Club/
├── backend/
│   └── functions/
│       ├── index.js           # All Cloud Functions code
│       └── package.json       # Dependencies (firebase-admin v12, firebase-functions v5)
├── docs/
│   ├── ARCHITECTURE.md        # System architecture
│   └── FIREBASE_SETUP.md      # Firebase configuration guide
├── firebase.json              # Firebase emulator config
├── .firebaserc                # Project ID link (houmetna-club)
├── firestore.rules            # Firestore security rules
├── storage.rules              # Cloud Storage security rules
├── test-functions.js          # Automated test script (run this to verify everything)
└── README.md                  # This file
```

---

## 🔑 Important Firebase Info

**Firebase Console:** https://console.firebase.google.com/project/houmetna-club

**Project ID:** `houmetna-club`

**Enabled Services:**
- Authentication (Email/Password + Google Sign-In)
- Cloud Firestore (NoSQL database)
- Cloud Storage (File uploads)
- Cloud Functions (Backend API)

**Firestore Collections:**
- `reports` - All civic reports
- `users` - User profiles and roles
- `notifications` - User notifications
- `votes` - (Ready for implementation)
- `comments` - (Ready for implementation)

**Security:**
- Users can only edit their own reports
- Admins can edit any report
- Photo uploads limited to 5MB for reports, 2MB for avatars
- All write operations require authentication

---

## 🐛 Troubleshooting

**"Firebase project not found"**
- Run: `firebase use houmetna-club`
- Make sure you're logged in: `firebase login`

**"Node version warning"**
- Functions require Node 18, but will use your installed version
- If you have Node 24, it will show a warning but still work

**"Permission denied" errors**
- Make sure you're using an admin account for admin functions
- Check that admin user has `role: 'admin'` in Firestore users collection

**Emulators won't start**
- Check if ports 4000, 5001, 8080, 9099, 9199 are available
- Close any other Firebase emulators running
- Try: `firebase emulators:start --only functions,firestore,auth,storage`

**Functions not loading**
- Make sure you ran `npm install` in `backend/functions`
- Check for errors in the terminal where emulators are running

---

## 📞 Need Help?

- Check [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
- Check [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) for Firebase configuration
- Firebase documentation: https://firebase.google.com/docs

---

## 📝 Notes for Dev Team

1. **No Frontend Yet:** This project currently has only the backend. You'll need to build a mobile app (Flutter/React Native) or web app to consume these APIs.

2. **Local Testing:** Always use Firebase Emulators for testing. Don't test directly on production Firebase project.

3. **Admin Testing:** Remember to set `role: 'admin'` in the users collection for any user who needs admin permissions.

4. **Next Sprint:** Focus on implementing push notifications (FCM) and multilingual support as these are critical MVP features.

5. **Code Quality:** All functions include error handling and proper authentication checks. Keep this standard when adding new functions.

Good luck! 🚀
