# 📄 Dossier de Preuve de Réalisation — Phase A & Premier Écran Vertical Users & Settings

> **Version Homologuée** : `v1.0.0 (Frontend UI & SDK Complete)`  
> **Source de Vérité** : Code physique créé et vérifié dans [`lyxal_booking/workspace`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace)

---

## 1. Lot A1 — Socle Applicatif Lyxal Workspace
- **[`workspace/layout/AppShell.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/layout/AppShell.tsx)** : Layout unifié avec Sidebar de navigation, Header, Fil d'Ariane, gestionnaire de profils et zones de contenu.
- **[`workspace/components/Toast.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/components/Toast.tsx)** : Composant Toast & Provider pour la notification unifiée (succès, erreurs API, avertissements).
- **[`workspace/App.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/App.tsx)** : Point d'entrée principal connectant le Shell aux modules de la plateforme.

---

## 2. Lot A2 — Infrastructure SDK Client (Frontière Typée)
- **[`workspace/sdk/client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/client.ts)** : Client HTTP centralisé (`HttpClient`) avec :
  - Support de l'authentification Bearer/Cookie.
  - Parsing d'erreurs d'API typées (`ApiErrorBody` / `ApiError`).
  - Gestion des timeouts, annulations de requêtes et uploads multipart.
- **[`workspace/sdk/users/users.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/users/users.types.ts)** : Interfaces DTOs TypeScript strictement conformes aux contrats Rust (`UserProfileResponse`, `UpdateUserProfileRequest`, `UpdateTimezoneRequest`, `UpdateTimezoneResponse`).
- **[`workspace/sdk/users/users.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/users/users.client.ts)** : Client fortement typé (`UsersClient`) exposant :
  - `getProfile()` ➔ `GET /api/v1/users/me`
  - `updateProfile(request)` ➔ `PATCH /api/v1/users/me`
  - `updateTimezone(timeZone)` ➔ `PATCH /api/v1/settings`
  - `uploadAvatar(file)` ➔ `POST /api/v1/users/me/avatar`

---

## 3. Lot A3 — Premier Écran Vertical Complet (Users & Settings)
- **[`workspace/modules/users/UserSettingsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/users/UserSettingsPage.tsx)** :
  - **Zéro `fetch()` direct** : Consomme **100%** le client SDK `usersClient`.
  - **Gestion des états** : Loading, Error, Saving, Uploading, Toasts de confirmation.
  - **Fonctionnalités** : Chargement du profil, modification du nom et de l'email de réservation, changement du fuseau horaire IANA par défaut et téléversement d'avatar.

---

## 🔗 Chaine de Parité Validée de Bout en Bout
```text
UserSettingsPage.tsx (UI)
        │
        ▼ (Appels fortement typés)
usersClient.ts (SDK Client)
        │
        ▼ (HTTP REST API v1)
/api/v1/users/me & /api/v1/settings (Axum Handlers)
        │
        ▼ (Wrappers Rust 1-ligne)
services::users (Engine Service)
        │
        ▼ (Mutation atomique)
fn::booking_update_user_profile & fn::booking_update_user_timezone (SurrealQL)
```
