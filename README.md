Houmetna Club — Civic Reporting Platform

Purpose
- Mobile-first app for citizens to report urban issues (potholes, lighting, waste, etc.).
- Municipal admin dashboard to manage and track interventions.
- Civil society visibility and analytics.

Must-have features (MVP)
- Authentication: Email + Google (Firebase Auth)
- Report submission: photo, description, GPS location, category
- Report workflow: new → in progress → resolved
- Admin dashboard with map + filters
- Push notifications (FCM) for status changes
- User profile with name, photo, email and report history
- Multilingual: Arabic / French / English
- History of interventions and basic analytics

Quick start
- See `firebase.md` for Firebase setup steps.
- Frontend folder contains a React + Vite starter.
- Backend contains placeholder Firebase Functions for notifications and admin actions.

Next steps
- Configure a Firebase project and add credentials.
- Implement authentication and the report submission UI.
