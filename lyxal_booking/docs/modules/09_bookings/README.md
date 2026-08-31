# 📘 Module 09 — Bookings (Moteur de Réservation Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Bookings** constitue le cœur du moteur de réservation de Lyxal OS. Il gère la création atomique de rendez-vous, l'affectation de ressource / hôte (Round-Robin), les approbations manuelle et par jeton hôte, la gestion des annulations et reports par jetons invités, et l'émission d'événements outbox (`booking.created`, `booking.cancelled`).

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Table `booking`, `booking_reminder`, `event_outbox`.
- **SurrealQL Functions** :
  - `fn::booking_create_booking($params: object)` ([`functions/bookings/fn_create_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_create_booking.surql))
  - `fn::booking_cancel_booking($params: object)` ([`functions/bookings/fn_cancel_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_cancel_booking.surql))
  - `fn::booking_reschedule_booking($params: object)` ([`functions/bookings/fn_reschedule_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_reschedule_booking.surql))
  - `fn::booking_approve_booking($params: object)` ([`functions/bookings/fn_approve_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_approve_booking.surql))
  - `fn::booking_confirm_pending($params: object)` ([`functions/bookings/fn_confirm_pending.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_confirm_pending.surql))
- **Service Rust Neutre** : [`engine/src/services/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/bookings.rs) (`list_user_bookings`, `get_booking`, `create_booking`, `create_public_booking`, `cancel_booking`, `reschedule_booking`, `confirm_booking`, `get_public_token_info`, `cancel_public_booking_by_token`, `reschedule_public_booking_by_token`, `approve_public_booking_by_token`, `decline_public_booking_by_token`, `claim_booking`).
- **REST API v1** : [`engine/src/web/api/v1/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/bookings.rs)
  - `GET /api/v1/bookings` ➔ Liste les réservations de l'utilisateur
  - `POST /api/v1/bookings` ➔ Crée une réservation
  - `GET /api/v1/bookings/{id}` ➔ Détails d'une réservation
  - `POST /api/v1/bookings/{id}/cancel` ➔ Annule une réservation
  - `POST /api/v1/bookings/{id}/reschedule` ➔ Reporte une réservation
  - `POST /api/v1/bookings/{id}/confirm` ➔ Confirme manuellement une réservation
  - `POST /api/v1/public/event-types/{slug}/bookings` ➔ Réservation publique (invité)
  - `GET /api/v1/public/bookings/token/{token}` ➔ Informations d'un jeton public
  - `POST /api/v1/public/bookings/cancel/{token}` ➔ Annulation par jeton invité
  - `POST /api/v1/public/bookings/reschedule/{token}` ➔ Report par jeton invité
- **SDK Client TypeScript** :
  - [`workspace/sdk/bookings/bookings.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/bookings/bookings.types.ts)
  - [`workspace/sdk/bookings/bookings.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/bookings/bookings.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/bookings/BookingsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/bookings/BookingsPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL 18 primitives, Service, DTOs, API v1 privée et publique) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
