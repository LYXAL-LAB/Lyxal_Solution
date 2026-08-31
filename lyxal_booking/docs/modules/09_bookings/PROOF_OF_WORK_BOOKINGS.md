# 📄 Dossier de Preuve de Réalisation & Consolidation — Module 09 : Bookings (Moteur Authentifié Hôte)

> **Statut de Réalisation** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**  
> **Source de Vérité** : Code physique créé et vérifié dans [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)

---

## 📋 1. Découpage Stricte du Périmètre (Module 09 vs Module 10)

| Périmètre | Module Propriétaire | Statut |
| :--- | :--- | :--- |
| **Gestion Intérieure Hôte** (Liste, Détails, Création Authentifiée, Confirmation, Annulation, Report Hôte) | **Module 09 — Bookings** | **`UI IMPLEMENTED — READY FOR REVIEW 🟡`** |
| **Parcours Publics & Jetons Invités** (Booking Public `/p/{slug}`, Tokens d'Annulation/Report, Approval Hôte par Token, Claim Team) | **Module 10 — Public Booking** | **`EN CADRAGE (PROCHAIN MODULE) 🔜`** |

---

## 📋 2. Cartographie Exhaustive des Primitives SurrealQL (`functions/bookings/`)

| Fonction SurrealQL | Fichier `.surql` Physique Harmonisé | Rôle & Signature |
| :--- | :--- | :--- |
| `fn::booking_create_booking` | [`functions/bookings/fn_create_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_create_booking.surql) | Création atomique d'une réservation avec affectation de ressource / hôte (Round-Robin) et émission d'événement outbox (`booking.created`) |
| `fn::booking_cancel_booking` | [`functions/bookings/fn_cancel_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_cancel_booking.surql) | Annulation d'une réservation par l'hôte avec motif |
| `fn::booking_reschedule_booking` | [`functions/bookings/fn_reschedule_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_reschedule_booking.surql) | Report de créneau avec verrouillage optimiste |
| `fn::booking_approve_booking` | [`functions/bookings/fn_approve_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_approve_booking.surql) | Approbation manuelle d'une réservation en attente |
| `fn::booking_confirm_pending` | [`functions/bookings/fn_confirm_pending.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_confirm_pending.surql) | Passage au statut `confirmed` |
| `fn::booking_claim_booking` | [`functions/bookings/fn_claim_booking.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/bookings/fn_claim_booking.surql) | Attribution d'une réservation disponible par un membre d'équipe |

---

## 3. Contrats Rust DTOs & Services Neutres
- **DTOs Rust** : [`engine/src/contracts/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/contracts/bookings.rs) (`BookingResponse`, `CreateBookingRequest`, `CancelBookingRequest`, `CancelBookingResponse`, `RescheduleBookingRequest`).
- **Service Rust Neutre** : [`engine/src/services/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/bookings.rs) (`list_user_bookings`, `get_booking`, `create_booking`, `create_public_booking`, `cancel_booking`, `reschedule_booking`, `confirm_booking`).

---

## 4. Handlers Axum REST API v1
- **Fichier Source** : [`engine/src/web/api/v1/bookings.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/bookings.rs)
- **Endpoints Axum Authentifiés Exposés** :
  - `GET /api/v1/bookings` ➔ Liste les réservations de l'utilisateur
  - `POST /api/v1/bookings` ➔ Crée une réservation
  - `GET /api/v1/bookings/{id}` ➔ Détails d'une réservation
  - `POST /api/v1/bookings/{id}/cancel` ➔ Annule une réservation
  - `POST /api/v1/bookings/{id}/reschedule` ➔ Reporte une réservation
  - `POST /api/v1/bookings/{id}/confirm` ➔ Confirme une réservation

---

## 5. SDK Client TypeScript & UI React Workspace
- **SDK Client** : [`workspace/sdk/bookings/bookings.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/bookings/bookings.client.ts) (0 `fetch()` direct).
- **Composant UI** : [`workspace/modules/bookings/BookingsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/bookings/BookingsPage.tsx) avec filtres de statut, annulation motivée et création de réservation.

---

## 🔗 Chaîne de Parité Validée de Bout en Bout
```text
BookingsPage.tsx (UI React Workspace - 0 fetch direct)
        │
        ▼ (Appels SDK fortement typés)
bookingsClient.ts (SDK Client TypeScript)
        │
        ▼ (Appels REST HTTP /api/v1/bookings)
web/api/v1/bookings.rs (Axum Handlers - 0 reqwest/crypto)
        │
        ▼ (Services Neutres Rust)
services::bookings (list_user_bookings, get_booking, create_booking, cancel_booking, reschedule_booking, confirm_booking)
        │
        ▼ (Mutations atomiques SurrealQL)
fn::booking_create_booking, fn::booking_cancel_booking, fn::booking_reschedule_booking, fn::booking_confirm_pending
```
