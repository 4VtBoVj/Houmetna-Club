import { db } from './firebase'
import { collection, query, orderBy, onSnapshot, updateDoc, doc } from 'firebase/firestore'

export function subscribeToReports(onChange){
  const q = query(collection(db, 'reports'), orderBy('createdAt', 'desc'))
  return onSnapshot(q, snapshot => {
    const reports = snapshot.docs.map(d => ({ id: d.id, ...d.data() }))
    onChange(reports)
  })
}

export async function updateReportStatus(reportId, status){
  const ref = doc(db, 'reports', reportId)
  await updateDoc(ref, { status })
}
