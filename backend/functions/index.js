const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()

// When a report's status changes, record a notification document.
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

    const payload = {
      userId,
      reportId,
      title,
      body,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending'
    }

    await admin.firestore().collection('notifications').add(payload)
    return null
  })
