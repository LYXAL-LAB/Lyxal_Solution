# 📘 Module 10 — Public Booking (Réservation Publique & Jetons Invités - Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Public Booking** orchestre le parcours de réservation invité sans authentification préalable, l'exposition des pages publiques hôte/équipe, et l'exécution sécurisée des 5 parcours par jetons à usage unique (`cancel`, `reschedule`, `approve`, `decline`, `claim`).

---

## 🏛️ Architecture & Contrats
- **REST API v1 Publique** : [`engine/src/web/api/v1/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/bookings.rs) (`public_router()`)
  - `POST /api/v1/public/event-types/{slug}/bookings` ➔ Création de réservation invité
  - `GET /api/v1/public/bookings/token/{token}` ➔ Lecture des infos du jeton
  - `POST /api/v1/public/bookings/cancel/{token}` ➔ Annulation invité par token
  - `POST /api/v1/public/bookings/reschedule/{token}` ➔ Report invité par token
  - `POST /api/v1/public/bookings/approve/{token}` ➔ Approbation hôte par token
  - `POST /api/v1/public/bookings/decline/{token}` ➔ Refus hôte par token
  - `POST /api/v1/public/bookings/claim/{id}` ➔ Revendication d'équipe par token
- **SurrealQL Primitives** :
  - `fn::booking_get_token_info($params: object)` ([`functions/bookings/fn_get_token_info.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_get_token_info.surql))
  - `fn::booking_cancel_by_token($params: object)` ([`functions/bookings/fn_cancel_by_token.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_cancel_by_token.surql))
  - `fn::booking_reschedule_by_token($params: object)` ([`functions/bookings/fn_reschedule_by_token.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_reschedule_by_token.surql))
  - `fn::booking_approve_by_token($params: object)` ([`functions/bookings/fn_approve_by_token.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_approve_by_token.surql))
  - `fn::booking_decline_by_token($params: object)` ([`functions/bookings/fn_decline_by_token.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_decline_by_token.surql))
  - `fn::booking_claim_booking($params: object)` ([`functions/bookings/fn_claim_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_claim_booking.surql))
- **SDK Client TypeScript** :
  - [`workspace/sdk/bookings/bookings.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/bookings/bookings.client.ts) (`createPublicBooking`, `getPublicTokenInfo`, `cancelPublicBooking`, `reschedulePublicBooking`, `approvePublicBooking`, `declinePublicBooking`, `claimBooking`).
- **UI React Workspace** :
  - [`workspace/modules/public-booking/PublicBookingPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/public-booking/PublicBookingPage.tsx)
  - [`workspace/modules/public-booking/PublicTokenActionPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/public-booking/PublicTokenActionPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (REST API v1 publique, Primitives SurrealQL 5 tokens, Outbox resolution) : **`● VALIDÉ`**
- SDK Client TypeScript (7 méthodes publiques typées) : **`● VALIDÉ`**
- UI React Workspace (Écran de réservation invité + Écran d'action token) : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
