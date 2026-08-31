# 📄 Dossier de Preuve & Diagnostic Réel — Module 03 : Users & Settings

> **Source de Vérité** : Code source physique vérifié dans le workspace [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)  
> **Statut Réel** : **`EN COURS / PROTOTYPE BACKEND SEUL`** (UI Frontend Surrealist non encore développée)

---

## 🔍 1. Fichiers & Code Réellement Vérifiés dans le Workspace

### 1.1. Primitives SurrealQL (Créées et présentes dans le code)
- **[`functions/users/fn_get_user_profile.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_get_user_profile.surql)** : `fn::booking_get_user_profile($params: object)`
- **[`functions/users/fn_update_user_profile.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_update_user_profile.surql)** : `fn::booking_update_user_profile($params: object)`
- **[`functions/users/fn_update_user_timezone.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_update_user_timezone.surql)** : `fn::booking_update_user_timezone($params: object)`

### 1.2. Service Rust Neutre & DTOs (Créés et présents dans le code)
- **[`engine/src/contracts/users.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/contracts/users.rs)** : DTOs `UserProfileResponse`, `UpdateUserProfileRequest`, `UpdateTimezoneRequest`, `UpdateTimezoneResponse`.
- **[`engine/src/services/users.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/users.rs)** : Fonctions `get_user_profile`, `update_user_profile`, `update_user_timezone` appelant `store.call_fn(...)`.

### 1.3. Handlers REST API v1 (Présents dans le code backend)
- **[`engine/src/web/api/v1/users.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/users.rs)** : `GET /api/v1/users/me` et `PATCH /api/v1/users/me`.
- **[`engine/src/web/api/v1/settings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/settings.rs)** : `GET /api/v1/settings` et `PATCH /api/v1/settings`.
- **[`engine/src/web/avatars.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/avatars.rs)** : Route binaire `GET /avatar/{user_id}`.

---

## ❌ 2. Ce qui N'EXISTE PAS ENCORE et doit être développé

- **Composants UI Surrealist (Frontend TSX)** :
  - `UserSettingsPage.tsx` ➔ **N'EXISTE PAS DANS LE WORKSPACE (À DÉVELOPPER)**
  - `TimezoneSelector.tsx` ➔ **N'EXISTE PAS DANS LE WORKSPACE (À DÉVELOPPER)**
  - `AvatarUploader.tsx` ➔ **N'EXISTE PAS DANS LE WORKSPACE (À DÉVELOPPER)**

---

## 📊 3. Bilan de Complétude Réel du Module 03

| Couche | Fichier / Élément Réel | Statut Réel |
| :--- | :--- | :---: |
| **SurrealQL** | `fn_get_user_profile.surql`, `fn_update_user_profile.surql`, `fn_update_user_timezone.surql` | **EXISTE ✅** |
| **Services Rust** | `services/users.rs` (`get_user_profile`, `update_user_profile`, `update_user_timezone`) | **EXISTE ✅** |
| **REST API v1** | `/api/v1/users/me`, `/api/v1/settings`, `/avatar/{user_id}` | **EXISTE ✅** |
| **UI Surrealist** | Composants React/Leptos frontend | **INEXISTANT ❌** |
| **Tests E2E** | Suite de tests d'intégration complète du module | **À RÉDIGER ❌** |
| **STATUT GLOBAL** | Module Backend prêt, UI & Tests restants | **INCOMPLET (60%) ⚠️** |
