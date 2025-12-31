Firebase Setup — Houmetna Club

1) Install Firebase CLI (if not installed)

```bash
npm install -g firebase-tools
```

2) Login and initialize

```bash
firebase login
cd "c:/Project/Houmetna Club"
firebase init
```

- Select: Firestore, Functions, Hosting (optional), Emulators (optional)
- When asked for functions source directory use `backend/functions`

3) Set project ID

- Either run `firebase use --add` to select a project, or edit `.firebaserc` and replace `your-project-id`.

4) Web app config (frontend)

- In Firebase Console > Project settings > Your apps > Add web app.
- Copy the config and place values in `frontend/.env` (copy from `.env.example`). DO NOT commit secrets.

5) Service account (admin operations / server)

- For server admin tasks, create a service account in Firebase Console > Project settings > Service accounts.
- Download JSON and *keep it private*. For local development, set `GOOGLE_APPLICATION_CREDENTIALS` to the JSON path.

6) Firestore rules and Storage rules

- Review and tighten Firestore rules to ensure users can only modify their own documents.
- Example: only allow write to `reports` when authenticated; admins use custom claims.

7) Emulators (optional)

- To test locally run:

```bash
firebase emulators:start --only firestore,functions,hosting
```

8) Deploy

```bash
firebase deploy --only functions,hosting
```

Security notes
- Do not commit `.env` or service account files.
- Use Firebase custom claims for admin roles, or maintain an `admins` collection checked server-side.
