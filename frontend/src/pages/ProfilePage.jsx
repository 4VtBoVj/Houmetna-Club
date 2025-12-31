import React, { useEffect, useState } from 'react'
import useAuth from '../hooks/useAuth'
import { getUserProfile, saveUserProfile, subscribeToUserReports } from '../services/userService'

import UserReports from '../components/UserReports'

export default function ProfilePage(){
  const { user, loading } = useAuth()
  const [name, setName] = useState('')
  const [photoFile, setPhotoFile] = useState(null)
  const [photoPreview, setPhotoPreview] = useState(null)
  const [message, setMessage] = useState('')
  const [saving, setSaving] = useState(false)
  const [profile, setProfile] = useState(null)

  useEffect(() => {
    if (!user) return
    // load profile from users collection or auth
    (async () => {
      const p = await getUserProfile(user.uid)
      setProfile(p)
      setName(user.displayName || (p && p.displayName) || '')
      setPhotoPreview(user.photoURL || (p && p.photoURL) || null)
    })()
  }, [user])

  useEffect(() => {
    if (!photoFile) return
    const url = URL.createObjectURL(photoFile)
    setPhotoPreview(url)
    return () => URL.revokeObjectURL(url)
  }, [photoFile])

  if (loading) return <div style={{padding:20}}>Loading...</div>
  if (!user) return <div style={{padding:20}}>Please <a href="/login">sign in</a> to view your profile.</div>

  async function handleSave(e){
    e.preventDefault()
    setSaving(true)
    setMessage('')
    try{
      await saveUserProfile(user.uid, { displayName: name, photoFile })
      setMessage('Profile saved')
      setPhotoFile(null)
    }catch(err){
      console.error(err)
      setMessage('Error saving profile')
    }finally{
      setSaving(false)
    }
  }

  return (
    <div style={{padding:20}}>
      <h2>My Profile</h2>
      <form onSubmit={handleSave} style={{maxWidth:480}}>
        <div>
          <label>Name</label>
          <input value={name} onChange={e => setName(e.target.value)} />
        </div>

        <div style={{marginTop:8}}>
          <label>Photo</label>
          <input type="file" accept="image/*" onChange={e => setPhotoFile(e.target.files[0])} />
          {photoPreview && <div style={{marginTop:8}}><img src={photoPreview} alt="preview" style={{width:120,borderRadius:8}}/></div>}
        </div>

        <div style={{marginTop:12}}>
          <button type="submit" disabled={saving}>{saving ? 'Saving...' : 'Save profile'}</button>
        </div>

        {message && <p>{message}</p>}
      </form>

      <hr style={{margin:'20px 0'}} />

      <h3>My Reports</h3>
      <UserReports uid={user.uid} />
    </div>
  )
}
