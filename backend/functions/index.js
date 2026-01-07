const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()
const db = admin.firestore()

// Firestore helpers from initialized admin
const FieldValue = admin.firestore.FieldValue
const Timestamp = admin.firestore.Timestamp

// Create a new report
exports.createReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in')
  }

  const report = {
    userId: context.auth.uid,
    category: data.category,
    description: data.description,
    latitude: data.latitude || null,
    longitude: data.longitude || null,
    // store photoUrls as an array to match the mobile UI model
    photoUrls: Array.isArray(data.photoUrls) ? data.photoUrls : (data.photoURL ? [data.photoURL] : []),
    status: 'new',
    createdAt: Date.now(),
    updatedAt: Date.now()
  }

  const docRef = await db.collection('reports').add(report)
  return { reportId: docRef.id, success: true }
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

  // Validate input
  if (!data || !data.reportId || !data.status) {
    throw new functions.https.HttpsError('invalid-argument', 'reportId and status are required')
  }

  try {
    const reportRef = db.collection('reports').doc(data.reportId)

    // Ensure report exists before updating to avoid NOT_FOUND errors
    const reportSnap = await reportRef.get()
    if (!reportSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Report not found')
    }

    await reportRef.update({
      status: data.status,
      updatedAt: (FieldValue && FieldValue.serverTimestamp) ? FieldValue.serverTimestamp() : Timestamp.now()
    })

    return { success: true }
  } catch (err) {
    // Log full error for debugging and return an INTERNAL HttpsError with minimal info
    console.error('updateReportStatus error:', err)
    throw new functions.https.HttpsError('internal', 'Failed to update report status')
  }
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

    // Save to notifications collection
    await db.collection('notifications').add({
      userId,
      reportId,
      title,
      body,
      read: false,
      createdAt: (FieldValue && FieldValue.serverTimestamp) ? FieldValue.serverTimestamp() : Timestamp.now()
    })
    
    // Send push notification if user has device tokens
    if (userId) {
      try {
        const userDoc = await db.collection('users').doc(userId).get()
        const deviceTokens = userDoc.data()?.deviceTokens || []
        
        if (deviceTokens.length > 0) {
          const message = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reportId: reportId,
              status: after.status,
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
          }
          
          // Send to all device tokens
          const results = await Promise.all(
            deviceTokens.map(token => 
              admin.messaging().send({
                ...message,
                token: token
              }).catch(error => {
                // Log error but don't fail the whole function
                console.error(`Failed to send to token ${token}:`, error)
                return null
              })
            )
          )
          
          console.log(`Sent notifications to ${results.filter(r => r !== null).length} devices`)
        }
      } catch (error) {
        console.error('Error sending FCM notification:', error)
      }
    }
    
    return null
  })

// Save device token for push notifications
exports.saveDeviceToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in')
  }

  const token = data.token
  if (!token) {
    throw new functions.https.HttpsError('invalid-argument', 'Device token is required')
  }

  const userId = context.auth.uid
  const userRef = db.collection('users').doc(userId)

  // Add token to user's device tokens array (if not already there)
  await userRef.set({
    deviceTokens: FieldValue.arrayUnion(token)
  }, { merge: true })

  return { success: true, message: 'Device token saved' }
})

// Remove device token on logout
exports.removeDeviceToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in')
  }

  const token = data.token
  if (!token) {
    throw new functions.https.HttpsError('invalid-argument', 'Device token is required')
  }

  const userId = context.auth.uid
  const userRef = db.collection('users').doc(userId)

  // Remove token from user's device tokens array
  await userRef.set({
    deviceTokens: FieldValue.arrayRemove(token)
  }, { merge: true })

  return { success: true, message: 'Device token removed' }
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
