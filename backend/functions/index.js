const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()
const db = admin.firestore()

// Create a new report
exports.createReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in')
  }

  const report = {
    userId: context.auth.uid,
    category: data.category,
    description: data.description,
    location: data.latitude && data.longitude 
      ? new admin.firestore.GeoPoint(data.latitude, data.longitude)
      : null,
    photoURL: data.photoURL || null,
    status: 'new',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }

  const docRef = await db.collection('reports').add(report)
  return { id: docRef.id, ...report }
})

// Update report status (admin only)
exports.updateReportStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in')
  }

  // Check if user is admin
  const userDoc = await db.collection('users').doc(context.auth.uid).get()
  if (!userDoc.exists || userDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only')
  }

  await db.collection('reports').doc(data.reportId).update({
    status: data.status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  })

  return { success: true }
})

// Trigger: Send notification when status changes
exports.onReportStatusChange = functions.firestore
  .document('reports/{reportId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {}
    const after = change.after.data() || {}
    
    if (before.status === after.status) return null
    
    const reportId = context.params.reportId
    const userId = after.userId || null
    const title = `Report status: ${after.status}`
    const body = `Your report "${(after.description || '').slice(0,60)}" is now ${after.status}.`

    await db.collection('notifications').add({
      userId,
      reportId,
      title,
      body,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    })
    
    return null
  })

// Get user's reports
exports.getUserReports = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in')
  }

  const snapshot = await db.collection('reports')
    .where('userId', '==', context.auth.uid)
    .orderBy('createdAt', 'desc')
    .get()

  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
})

// Get all reports (admin only)
exports.getAllReports = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in')
  }

  const userDoc = await db.collection('users').doc(context.auth.uid).get()
  if (!userDoc.exists || userDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only')
  }

  const snapshot = await db.collection('reports')
    .orderBy('createdAt', 'desc')
    .limit(data.limit || 100)
    .get()

  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
})
