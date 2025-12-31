import React from 'react'
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import SubmitReportPage from './pages/SubmitReportPage'
import LoginPage from './pages/LoginPage'
import AdminDashboard from './pages/AdminDashboard'
import ProfilePage from './pages/ProfilePage'

export default function App(){
  return (
    <BrowserRouter>
      <div style={{padding:20}}>
        <h1>Houmetna Club — Prototype</h1>
        <nav style={{marginBottom:12}}>
          <Link to="/">Home</Link> | <Link to="/submit">Submit Report</Link> | <Link to="/login">Login</Link>
          | <Link to="/profile">Profile</Link>
        </nav>
        <Routes>
          <Route path="/" element={<div>This is a scaffold. Implement auth, reporting UI, and admin routes.</div>} />
          <Route path="/submit" element={<SubmitReportPage/>} />
          <Route path="/login" element={<LoginPage/>} />
          <Route path="/profile" element={<ProfilePage/>} />
          <Route path="/admin" element={<AdminDashboard/>} />
        </Routes>
      </div>
    </BrowserRouter>
  )
}
