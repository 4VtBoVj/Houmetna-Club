Titre : Présentation du projet Houmetna Club — Démonstration complète (≈ 20 min)

0:00 — 0:20 — Intro rapide (20s)
- Narration : « Bonjour, je présente Houmetna Club, une plateforme citoyenne de signalement d’incidents urbains. Cette vidéo dure environ 20 minutes et couvre l’interface utilisateur, la partie backend (logique métier, architecture, APIs), l’exécution frontend/backend, la relation frontend↔backend et les tests. »
- À l’écran : titre + logo + nom du présentateur.

0:20 — 2:00 — Présentation de l’interface utilisateur (1m40)
- Montrer l’application sur mobile (ou émulateur). Parcourir :
  - Écran d’accueil / liste des rapports.
  - Écran de création d’un rapport (catégorie, description, photo, localisation).
  - Écran détail d’un rapport (statut, photos, description).
  - Écran admin (si présent) pour gérer les rapports.
- Narration : expliquer les éléments visibles : champs, boutons, badges (nouveau / en cours / résolu), workflow utilisateur.

2:00 — 5:00 — Démonstration : création d’un rapport (3 min)
- À l’écran : enregistrer une création de rapport (ou simuler via l’UI).
- Montrer l’ajout de photo (ou image de test), position GPS et soumission.
- Narration : expliquer ce que fait le client au moment d’appuyer sur « Envoyer » :
  - Validation locale des champs.
  - Upload de la photo (si implémenté) → stockage (Cloud Storage) → récupération d’une URL.
  - Appel à l’API backend `createReport` (expliquer payload attendu : `category, description, latitude, longitude, photoUrls`).
- Commande utile (terminal) pour montrer l’app en fonctionnement (si sur émulateur) :

```bash
# depuis mobile_ui
flutter run
```

5:00 — 9:00 — Explication détaillée du backend — Logique métier (4 min)
- Narration : exposer les règles métier :
  - Tout utilisateur authentifié peut créer un rapport.
  - Les rapports ont des statuts : `new` → `in-progress` → `resolved`.
  - Seuls les admins (champ `role: 'admin'` dans `users/{uid}`) peuvent changer le statut via `updateReportStatus`.
  - Quand le statut change, on crée une notification + envoi FCM (si configuré).
- À l’écran : ouvrir et montrer l’extrait de `backend/functions/index.js` (fonctions clés) :
  - `createReport` : structure du document `reports` (fields : userId, category, photoUrls, status, timestamps).
  - `updateReportStatus` : vérification admin, mise à jour `status`, `updatedAt`.
  - `onReportStatusChange` : trigger onUpdate qui crée notification et déclenche FCM.
- Montrer la collection Firestore (Emulator UI) avec exemples de documents.

9:00 — 11:30 — Explication détaillée du backend — Architecture globale (2m30)
- Narration + schéma à l’écran (diapos ou dessin rapide) :
  - Clients (mobile) ↔ Firebase (Auth, Firestore, Storage, Functions) ↔ FCM.
  - Cloud Functions = couche API / logique serveur.
  - Firestore = base de données NoSQL, collections : `reports`, `users`, `notifications`.
  - Storage = photos.
- À l’écran : montrer `firebase.json` et configuration des émulateurs (ports).
- Rappel sur la sécurité : règles Firestore contrôlent qui peut lire/écrire.

11:30 — 14:00 — APIs développées (2m30)
- Lister les endpoints / fonctions (expliquer chaque usage) :
  - `createReport` (callable) — input/payload, output `{ reportId }`.
  - `updateReportStatus` (callable) — admin only.
  - `getUserReports` — récupère les rapports d’un utilisateur.
  - `getAllReports` — pagination pour admin.
  - `saveDeviceToken` / `removeDeviceToken` — gestion tokens FCM.
  - Trigger `onReportStatusChange` — notifications & FCM.
- À l’écran : montrer exemples d’appels (client) et payloads JSON.
- Exemple rapide d’appel depuis node / terminal (emulateur) :

```bash
# appeler fonction via firebase emulators: (ex. using firebase functions shell or curl to local emulators)
# Pour tester createReport depuis un script de test :
node test-functions.js
```

14:00 — 15:30 — Exécution de la partie frontend (1m30)
- Montrer comment lancer l’app mobile (emulateur ou device) :

```bash
cd mobile_ui
flutter pub get
flutter run
```

- Expliquer configuration pour utiliser les émulateurs (avant `run`) :
  - Dans le code Flutter appeler `useAuthEmulator('localhost', 9099)`, `useFirestoreEmulator('localhost', 8080)`, `useFunctionsEmulator('localhost', 5001)` (montrer l’emplacement dans le code).
- Montrer écran en directe en interagissant.

15:30 — 17:00 — Exécution de la partie backend (1m30)
- Montrer comment démarrer les émulateurs :

```bash
cd "C:/Users/Utilisateur/Desktop/projet mobile/Houmetna-Club"
firebase emulators:start --only auth,firestore,functions,storage
```

- Montrer logs des fonctions quand on crée un rapport / met à jour un statut.
- Montrer `test-functions.js` ou commandes node qui automatisent les tests unitaires/integration (expliquer ce que le script fait).

17:00 — 18:30 — Mise en évidence frontend ↔ backend (1m30)
- Narration : expliquer le flux complet :
  - Frontend valide / crée la requête → upload photo → appelle `createReport` → Function écrit en Firestore.
  - Admin modifie statut via frontend → appelle `updateReportStatus` → Function met à jour Firestore → trigger `onReportStatusChange` crée notification + envoie FCM.
- À l’écran : démonstration live d’un cycle complet (créer rapport → backend log → admin update → utilisateur reçoit notification / notification doc created).

18:30 — 19:30 — Démonstration des tests (1 min)
- Montrer le script `test-functions.js` (ou tests existants), exécuter :

```bash
node test-functions.js
```

- À l’écran : montrer résultats, assertions passées, collections Firestore peuplées.
- Expliquer couverture des tests (ce qui est testé : création, lecture, permissions admin, triggers).

19:30 — 20:00 — Conclusion et points d’amélioration (30s)
- Résumer points forts : backend prêt, flows sécurisés, notifications implémentées.
- Prochaines étapes suggérées : front complet, compression d’images, multi-langue, déploiement CI/CD.
- Dire au spectateur où trouver le code et la doc (montrer `README.md`).

Annexes / Instructions techniques à afficher dans la vidéo (capture d’écran ou insert) :
- Commandes clés à afficher en texte :

```bash
# lancer émulateurs
firebase emulators:start --only auth,firestore,functions,storage

# exécuter tests automatisés
node test-functions.js

# lancer frontend (Flutter)
cd mobile_ui
flutter pub get
flutter run

# construire APK debug
flutter build apk --debug
```

Conseils de tournage / montage (brefs)
- Utiliser des captures d’écran en plein écran pour le code et l’émulateur.
- Ajouter des callouts textuels pour chaque commande montrée.
- Mettre en pause la vidéo quand vous tapez des commandes, puis montrer le résultat du log.
- Ajouter sous-titres pour les parties techniques clés.

Fin du script.