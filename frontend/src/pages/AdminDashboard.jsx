import React, { useEffect, useState } from 'react'
import { subscribeToReports, updateReportStatus } from '../services/reportService'
import AdminMap from '../components/AdminMap'

export default function AdminDashboard(){
  const [reports, setReports] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsub = subscribeToReports(list => {
      setReports(list)
      setLoading(false)
    })
    return () => unsub()
  }, [])

  if (loading) return <div style={{padding:20}}>Loading reports...</div>

  return (
    <div style={{padding:20}}>
      <h2>Admin Dashboard — Reports</h2>

      <div style={{display:'grid', gridTemplateColumns:'1fr 400px', gap:12}}>
        <div>
          <AdminMap reports={reports} />
        </div>

        <div>
          <table style={{width:'100%', borderCollapse:'collapse'}}>
            <thead>
              <tr>
                <th style={{textAlign:'left'}}>Photo</th>
                <th style={{textAlign:'left'}}>Description</th>
                <th>Category</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {reports.map(r => (
                <tr key={r.id} style={{borderTop:'1px solid #ddd'}}>
                  <td style={{width:120}}>{r.photoURL ? <img src={r.photoURL} alt="photo" style={{width:100}} /> : '—'}</td>
                  <td style={{maxWidth:220}}>{r.description}</td>
                  <td style={{textAlign:'center'}}>{r.category}</td>
                  <td style={{textAlign:'center'}}>{r.status}</td>
                  <td style={{textAlign:'center'}}>
                    <select value={r.status} onChange={e => updateReportStatus(r.id, e.target.value)}>
                      <option value="new">new</option>
                      <option value="in_progress">in_progress</option>
                      <option value="resolved">resolved</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
