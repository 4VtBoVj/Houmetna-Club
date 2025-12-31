import React, {useState} from 'react'
import { auth, db, storage } from '../services/firebase'
import { collection, addDoc, serverTimestamp } from 'firebase/firestore'
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'

export default function ReportForm(){
  const [photo, setPhoto] = useState(null)
  const [description, setDescription] = useState('')
  const [category, setCategory] = useState('voirie')
  const [location, setLocation] = useState(null)
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')

  async function pickLocation(){
    if (!navigator.geolocation) {
      setMessage('Geolocation not supported')
      return
    }
    navigator.geolocation.getCurrentPosition(pos => {
      setLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude })
    }, err => {
      setMessage('Unable to get location')
    })
  }

  async function handleSubmit(e){
    e.preventDefault()
    setLoading(true)
    setMessage('')
    try{
      const user = auth.currentUser
      const reportsRef = collection(db, 'reports')
      let photoURL = null
      if (photo){
        const storageRef = ref(storage, `reports/${Date.now()}_${photo.name}`)
        await uploadBytes(storageRef, photo)
        photoURL = await getDownloadURL(storageRef)
      }
      const doc = await addDoc(reportsRef, {
        userId: user ? user.uid : null,
        description,
        category,
        location: location || null,
        photoURL,
        status: 'new',
        createdAt: serverTimestamp()
      })
      setMessage('Report submitted')
      setDescription('')
      setPhoto(null)
      setCategory('voirie')
      setLocation(null)
    }catch(err){
      console.error(err)
      setMessage('Error submitting report')
    }finally{
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} style={{maxWidth:600, margin:'0 auto'}}>
      <h2>Submit a report</h2>

      <label>Photo</label>
      <input type="file" accept="image/*" onChange={e => setPhoto(e.target.files[0])} />

      <label>Description</label>
      <textarea value={description} onChange={e => setDescription(e.target.value)} rows={4} style={{width:'100%'}} />

      <label>Category</label>
      <select value={category} onChange={e => setCategory(e.target.value)}>
        <option value="voirie">Voirie</option>
        <option value="eclairage">Éclairage</option>
        <option value="dechets">Déchets</option>
        <option value="autre">Autre</option>
      </select>

      <div style={{marginTop:8}}>
        <button type="button" onClick={pickLocation}>Get GPS location</button>
        {location && <div>Lat: {location.lat.toFixed(6)}, Lng: {location.lng.toFixed(6)}</div>}
      </div>

      <div style={{marginTop:12}}>
        <button type="submit" disabled={loading}>{loading ? 'Submitting...' : 'Submit'}</button>
      </div>

      {message && <p>{message}</p>}
    </form>
  )
}
