import React, { useState, useEffect } from 'react'
import { auth } from '../services/firebase'
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged
} from 'firebase/auth'

export default function Auth(){
  const [mode, setMode] = useState('signin') // 'signin' | 'signup'
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [user, setUser] = useState(null)
  const [message, setMessage] = useState('')

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, u => setUser(u))
    return () => unsubscribe()
  }, [])

  async function handleSignUp(e){
    e.preventDefault()
    setMessage('')
    try{
      await createUserWithEmailAndPassword(auth, email, password)
      setMessage('Account created')
    }catch(err){
      console.error(err)
      setMessage(err.message)
    }
  }

  async function handleSignIn(e){
    e.preventDefault()
    setMessage('')
    try{
      await signInWithEmailAndPassword(auth, email, password)
      setMessage('Signed in')
    }catch(err){
      console.error(err)
      setMessage(err.message)
    }
  }

  async function handleGoogle(){
    setMessage('')
    try{
      const provider = new GoogleAuthProvider()
      await signInWithPopup(auth, provider)
      setMessage('Signed in with Google')
    }catch(err){
      console.error(err)
      setMessage(err.message)
    }
  }

  async function handleSignOut(){
    await signOut(auth)
    setMessage('Signed out')
  }

  return (
    <div style={{maxWidth:420, margin:'0 auto'}}>
      <h2>{mode === 'signin' ? 'Sign in' : 'Sign up'}</h2>

      {user ? (
        <div>
          <p>Signed in as {user.displayName || user.email}</p>
          <button onClick={handleSignOut}>Sign out</button>
        </div>
      ) : (
        <form onSubmit={mode === 'signin' ? handleSignIn : handleSignUp}>
          <label>Email</label>
          <input type="email" value={email} onChange={e => setEmail(e.target.value)} required />

          <label>Password</label>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} required minLength={6} />

          <div style={{marginTop:8}}>
            <button type="submit">{mode === 'signin' ? 'Sign in' : 'Create account'}</button>
            <button type="button" onClick={handleGoogle} style={{marginLeft:8}}>Sign in with Google</button>
          </div>

          <div style={{marginTop:8}}>
            <button type="button" onClick={() => setMode(mode === 'signin' ? 'signup' : 'signin')}>{mode === 'signin' ? "Create account" : 'Have an account? Sign in'}</button>
          </div>
        </form>
      )}

      {message && <p>{message}</p>}
    </div>
  )
}
