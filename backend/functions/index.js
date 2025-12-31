const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()

// Placeholder: send notification when report status changes
exports.onReportStatusChange = functions.firestore
  .document('reports/{reportId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {}
    const after = change.after.data() || {}
    if (before.status === after.status) return null
    // Implement FCM notification send here
    return null
  })
