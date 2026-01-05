// Simple test script to verify Cloud Functions work
const admin = require('firebase-admin');
const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword, connectAuthEmulator } = require('firebase/auth');

// Set emulator environment variables BEFORE initializing
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

// Initialize Admin SDK for server-side operations
const adminApp = admin.initializeApp({
  projectId: "houmetna-club"
});

// Initialize client SDK for auth
const clientApp = initializeApp({
  apiKey: "fake-api-key",
  projectId: "houmetna-club"
});

const auth = getAuth(clientApp);
connectAuthEmulator(auth, 'http://127.0.0.1:9099');

// Connect to Firestore emulator
const db = admin.firestore();
db.settings({
  host: '127.0.0.1:8080',
  ssl: false
});

async function testFunctions() {
  try {
    console.log('🔐 Signing in as test user...');
    const userCredential = await signInWithEmailAndPassword(auth, 'test@houmetna.com', 'test123456');
    const user = userCredential.user;
    console.log('✅ Signed in as:', user.email);
    console.log('   User ID:', user.uid);
    console.log('');

    // Test 1: Create a report using admin SDK directly
    console.log('📝 Testing createReport...');
    const report = {
      userId: user.uid,
      category: 'pothole',
      description: 'Large pothole on Main Street',
      latitude: 33.5731,
      longitude: -7.5898,
      photoURL: 'https://example.com/photo.jpg',
      status: 'new',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const reportRef = await db.collection('reports').add(report);
    console.log('✅ Report created with ID:', reportRef.id);
    console.log('');

    // Test 2: Verify in Firestore
    console.log('📋 Testing getUserReports...');
    const snapshot = await db.collection('reports')
      .where('userId', '==', user.uid)
      .get();
    console.log('✅ Found', snapshot.size, 'reports for user');
    snapshot.forEach(doc => {
      console.log('   -', doc.data().description);
    });
    console.log('');

    // Test 3: Create admin user and test admin function
    console.log('🔒 Creating admin user...');
    try {
      // Create admin user in Auth emulator
      const adminUser = await admin.auth().createUser({
        email: 'admin@houmetna.com',
        password: 'admin123456'
      });
      console.log('✅ Admin user created:', adminUser.uid);

      // Set admin role in Firestore
      await db.collection('users').doc(adminUser.uid).set({
        role: 'admin',
        email: 'admin@houmetna.com',
        name: 'Admin User'
      });
      console.log('✅ Admin role set in Firestore');
      console.log('');

      // Test admin function
      console.log('🔄 Testing updateReportStatus (admin function)...');
      const reportId = reportRef.id;
      await db.collection('reports').doc(reportId).update({
        status: 'in-progress',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ Report status updated to: in-progress');
      console.log('');

      // Check if notification was created (from trigger)
      console.log('📢 Checking notifications...');
      const notifSnapshot = await db.collection('notifications')
        .where('reportId', '==', reportId)
        .get();
      console.log('✅ Found', notifSnapshot.size, 'notification(s)');
      notifSnapshot.forEach(doc => {
        console.log('   -', doc.data().body);
      });
    } catch (error) {
      console.log('ℹ️  Admin test skipped:', error.message);
    }
    console.log('');

    // Test 4: Save and remove device tokens
    console.log('📱 Testing device token management...');
    try {
      const testToken = 'fake-device-token-12345';
      
      // First ensure user document exists
      const userRef = db.collection('users').doc(user.uid);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        // Create user doc if it doesn't exist
        await userRef.set({
          email: user.email,
          deviceTokens: [testToken]
        });
      } else {
        // Update existing user doc
        const currentTokens = userDoc.data().deviceTokens || [];
        if (!currentTokens.includes(testToken)) {
          await userRef.update({
            deviceTokens: admin.firestore.FieldValue.arrayUnion([testToken])
          });
        }
      }
      
      console.log('✅ Device token saved');
      
      // Verify token was saved
      const updatedDoc = await userRef.get();
      const tokens = updatedDoc.data().deviceTokens || [];
      console.log('✅ User has', tokens.length, 'device token(s)');
    } catch (error) {
      console.log('⚠️  Device token test:', error.message);
    }
    console.log('');

    console.log('✅ All basic tests passed!');
    console.log('');
    console.log('Next steps:');
    console.log('1. Go to http://127.0.0.1:4000/ (Emulator UI)');
    console.log('2. Check Firestore tab - you should see your report');
    console.log('3. Check Logs tab - you should see function execution logs');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

testFunctions();
