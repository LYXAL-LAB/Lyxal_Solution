# 📘 Module 04 — Calendars (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Calendars** orchestre la connexion, la synchronisation et la gestion des agendas distants (CalDAV, Exchange EWS, Google Calendar OAuth2, Webcal ICS). Il permet l'interrogation automatique des créneaux occupés et la sélection d'un calendrier cible d'écriture pour l'insertion de réservations.

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Table `booking_caldav_source` (Champs : `name`, `provider_type`, `auth_type`, `server_url`, `username`, `encrypted_secret`, `status`, `last_synced_at`).
- **SurrealQL Functions** :
  - `fn::booking_create_caldav_source($params: object)` ([`functions/integrations/fn_create_caldav_source.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_create_caldav_source.surql))
  - `fn::booking_get_user_caldav_sources($params: object)` ([`functions/integrations/fn_get_user_caldav_sources.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_get_user_caldav_sources.surql))
  - `fn::booking_delete_caldav_source($params: object)` ([`functions/integrations/fn_delete_caldav_source.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_delete_caldav_source.surql))
- **Service Rust Neutre** : [`engine/src/services/calendar_sources.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/calendar_sources.rs)
- **REST API v1** :
  - `GET /api/v1/calendars` ➔ Liste des sources distantes
  - `POST /api/v1/calendars` ➔ Création d'une nouvelle source
  - `DELETE /api/v1/calendars/{id}` ➔ Suppression de source
  - `POST /api/v1/calendars/{id}/sync` ➔ Synchronisation manuelle
  - `PUT /api/v1/calendars/{id}/write` ➔ Sélection du calendrier d'écriture
  - `GET /api/v1/calendars/google/connect` ➔ Consentement Google OAuth2
- **SDK Client TypeScript** :
  - [`workspace/sdk/calendars/calendars.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/calendars/calendars.types.ts)
  - [`workspace/sdk/calendars/calendars.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/calendars/calendars.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/calendars/CalendarsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/calendars/CalendarsPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL, Service, DTOs, API v1) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
