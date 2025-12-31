import { auth, db, storage } from './firebase'
import { doc, getDoc, setDoc, collection, query, where, orderBy, onSnapshot } from 'firebase/firestore'
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'
import { updateProfile } from 'firebase/auth'

export async function getUserProfile(uid){
  const d = await getDoc(doc(db, 'users', uid))
  return d.exists() ? d.data() : null
}

export async function saveUserProfile(uid, { displayName, photoFile }){
  let photoURL = null
  if (photoFile){
    const storageRef = ref(storage, `users/${uid}/avatar_${Date.now()}`)
    await uploadBytes(storageRef, photoFile)
    photoURL = await getDownloadURL(storageRef)
  }

  // Update Firebase Auth profile if current user
  if (auth.currentUser && auth.currentUser.uid === uid){
    await updateProfile(auth.currentUser, { displayName, photoURL })
  }

  const payload = { displayName: displayName || null }
  if (photoURL) payload.photoURL = photoURL
  await setDoc(doc(db, 'users', uid), payload, { merge: true })
  return { ...payload }
}

export function subscribeToUserReports(uid, onChange){
  const q = query(collection(db, 'reports'), where('userId', '==', uid), orderBy('createdAt', 'desc'))
  return onSnapshot(q, snap => {
    const reports = snap.docs.map(d => ({ id: d.id, ...d.data() }))
    onChange(reports)
  })
}
