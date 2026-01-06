# 🏢 Houmetna Club - Civic Reporting Platform

**Full-stack application** for reporting and tracking civic issues like potholes, broken streetlights, and infrastructure problems.

---

## 📦 Project Structure

```
houmetna-club/
├── backend/              # Firebase Cloud Functions (Node.js)
│   └── functions/        # 7 Cloud Functions + security rules
├── web/                  # Flutter Web App (Frontend)
│   └── lib/             # Dart source code
├── docs/                 # Complete documentation
├── firebase.json         # Firebase configuration
├── firestore.rules      # Database security rules
└── storage.rules        # File upload security rules
```

---

## 🚀 Quick Start

### Prerequisites
- **Node.js** v18+ (for backend)
- **Flutter SDK** (for frontend)
- **Firebase CLI**: `npm install -g firebase-tools`
- **Git**

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd houmetna-club
```

### 2. Backend Setup
```bash
cd backend/functions
npm install
cd ../..
firebase login
firebase emulators:start
```

Backend runs on:
- Functions: http://localhost:5001
- Firestore: http://localhost:8080
- Auth: http://localhost:9099
- Emulator UI: http://localhost:4000

### 3. Frontend Setup
```bash
cd web
flutter pub get
flutter run -d chrome --web-port=3000
```

Web app runs on: http://localhost:3000

### 4. Create Test User
```bash
# In the backend folder
node test-functions.js
```

Test credentials: `test@houmetna.com` / `test123456`

---

## ✅ Features

### Backend (Cloud Functions)
- ✅ `createReport` - Submit civic reports
- ✅ `getUserReports` - List user's reports
- ✅ `getAllReports` - Admin: view all reports
- ✅ `updateReportStatus` - Admin: change status
- ✅ `onReportStatusChange` - Auto-send notifications
- ✅ `saveDeviceToken` - Store FCM tokens
- ✅ `removeDeviceToken` - Remove FCM tokens

### Frontend (Flutter Web)
- ✅ Login/Authentication
- ✅ Submit reports (category + description)
- ✅ View user reports
- ✅ Real-time status updates
- ✅ Responsive UI

### Database (Firestore)
- ✅ `reports` - All civic reports
- ✅ `users` - User profiles + roles
- ✅ `notifications` - Push notification history
- ⏳ `comments` - Report comments (structure ready)
- ⏳ `votes` - Upvote/downvote (structure ready)

### Security
- ✅ Firebase Authentication (Email/Password + Google)
- ✅ Role-based access (user/admin)
- ✅ Firestore security rules
- ✅ Cloud Storage validation (5MB photo limit)

---

## 🔧 Development Workflow

### Running Locally
1. **Terminal 1** - Backend:
   ```bash
   firebase emulators:start
   ```

2. **Terminal 2** - Frontend:
   ```bash
   cd web
   flutter run -d chrome --web-port=3000
   ```

3. **Login** with test account and start submitting reports!

### Testing Backend
```bash
node test-functions.js
```

Shows:
- ✅ User authentication
- ✅ Report creation
- ✅ Admin functions
- ✅ Device token management

---

## 📚 Documentation

- **[README.md](README.md)** - This file (project overview)
- **[QUICK_START.md](QUICK_START.md)** - Frontend setup for Flutter/React Native/React Web
- **[PROJECT_COMPLETION_SUMMARY.md](PROJECT_COMPLETION_SUMMARY.md)** - Complete status overview
- **[FILE_INDEX.md](FILE_INDEX.md)** - Navigation guide for all files
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design
- **[docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)** - Firebase configuration
- **[docs/FIREBASE_MESSAGING_SETUP.md](docs/FIREBASE_MESSAGING_SETUP.md)** - Push notifications guide
- **[docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** - Production deployment checklist

---

## 🛠️ Troubleshooting

### Port 8080 Already in Use
```powershell
# Kill existing Firebase processes
taskkill /F /IM java.exe /T

# Restart emulators
firebase emulators:start
```

### Flutter Not Found
```powershell
# Add Flutter to PATH (Windows)
$env:PATH += ";C:\path\to\flutter\bin"

# Or install via Chocolatey
choco install flutter
```

### "User not found" Error
Create test user via Firebase Emulator UI:
1. Go to http://localhost:4000/auth
2. Click "Add User"
3. Email: `test@houmetna.com`, Password: `test123456`

---

## 🚀 Deployment

Follow **[docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** for complete production deployment steps.

**Quick deploy backend:**
```bash
firebase deploy --only functions
```

**Deploy frontend to Firebase Hosting:**
```bash
cd web
flutter build web
firebase deploy --only hosting
```

---

## 👥 Team Collaboration

### Backend Team
- Work in `backend/` folder
- Test with emulators
- Deploy functions: `firebase deploy --only functions`

### Frontend Team
- Work in `web/` folder
- Connect to local backend (emulators) or production
- Build: `flutter build web`

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes, commit
git add .
git commit -m "feat: add feature"

# Push and create PR
git push origin feature/your-feature
```

---

## 📝 Next Steps

### For New Developers
1. Read [QUICK_START.md](QUICK_START.md) for your platform
2. Run `firebase emulators:start` to start backend
3. Run `flutter run -d chrome` to start frontend
4. Login with test account and explore

### For Product Managers
1. Read [PROJECT_COMPLETION_SUMMARY.md](PROJECT_COMPLETION_SUMMARY.md)
2. Check [FILE_INDEX.md](FILE_INDEX.md) for navigation
3. Review feature roadmap in completion summary

---

## 📊 Project Status

**Backend:** ✅ Production-ready  
**Frontend Web:** ✅ Working (basic features)  
**Mobile Apps:** ⏳ Not started  
**Admin Dashboard:** ⏳ Not started  

**Last Updated:** January 5, 2026

---

## 📄 License

[Add your license here]

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes and test
4. Submit pull request

---

**Built with ❤️ using Firebase, Flutter, and Node.js**
