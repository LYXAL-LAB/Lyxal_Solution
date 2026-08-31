# 📘 Module 03 — Users & Settings (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Users & Settings** régit la gestion du profil utilisateur hôte, ses préférences de contact (`booking_email`), son fuseau horaire par défaut IANA (`time_zone`), l'upload et la distribution sécurisée d'avatars binaires WebP, ainsi que la configuration globale de compte.

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Table `users` avec assertions sur l'adresse email et le rôle (`admin` / `user`).
- **SurrealQL Functions** :
  - `fn::booking_get_user_profile($params: object)` ([`fn_get_user_profile.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_get_user_profile.surql))
  - `fn::booking_update_user_profile($params: object)` ([`fn_update_user_profile.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_update_user_profile.surql))
  - `fn::booking_update_user_timezone($params: object)` ([`fn_update_user_timezone.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/users/fn_update_user_timezone.surql))
- **Service Rust Neutre** : [`engine/src/services/users.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/users.rs) via `store.call_fn(...)`.
- **REST API v1** :
  - `GET /api/v1/users/me` -> Lecture du profil authentifié
  - `PATCH /api/v1/users/me` -> Mise à jour du profil
  - `GET /api/v1/settings` -> Lecture des réglages
  - `PATCH /api/v1/settings` -> Mise à jour des réglages & timezone IANA
- **Route Binaire Technique** : `GET /avatar/{user_id}` pour la distribution d'avatars WebP.

---

## 🔒 Statut de Complétude
- Schema SurrealDB : **`● LOCKED`** (v1.0.0)
- SurrealQL Functions : **`● LOCKED`** (v1.0.0)
- Services Rust : **`● LOCKED`** (v1.0.0)
- REST API v1 : **`● LOCKED`** (v1.0.0)
- Tests & Validation : **`● LOCKED`** (v1.0.0)
- Documentation : **`● LOCKED`** (v1.0.0)
- Legacy Supprimé : **`● LOCKED`** (v1.0.0)
- **STATUT GLOBAL** : **`● CLOSED` (v1.0.0)**
