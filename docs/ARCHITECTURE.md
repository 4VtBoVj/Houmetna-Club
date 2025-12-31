Architecture (proposal)

- Frontend: React + Vite, Firebase Web SDK for Auth/Firestore/Storage/FCM
- Backend: Firebase Functions for admin actions and push notifications
- DB: Firestore collections: `users`, `reports`, `comments`, `votes`, `interventions`
- Storage: Firebase Storage for report photos

Roles
- Citizen: create account, submit reports, follow status, receive notifications
- Admin: web dashboard to manage reports and update status
