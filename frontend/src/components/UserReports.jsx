import React, { useEffect, useState } from 'react'
import { subscribeToUserReports } from '../services/userService'

export default function UserReports({ uid }){
  const [reports, setReports] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!uid) return
    const unsub = subscribeToUserReports(uid, list => {
      setReports(list)
      setLoading(false)
    })
    return () => unsub()
  }, [uid])

  if (loading) return <div>Loading reports...</div>
  if (!reports.length) return <div>No reports yet.</div>

  return (
    <div>
      {reports.map(r => (
        <div key={r.id} style={{border:'1px solid #eee', padding:8, marginBottom:8}}>
          <div><strong>{r.category}</strong> — {r.status}</div>
          <div>{r.description}</div>
          {r.photoURL && <img src={r.photoURL} alt="report" style={{width:140, marginTop:8}} />}
        </div>
      ))}
    </div>
  )
}
