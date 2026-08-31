# 📘 Module 07 — Availability (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Availability** constitue le moteur temporel de calcul des plages libres et d'ouverture de réservation. Il gère les plannings hebdomadaires récurrents (heures d'ouverture), les exceptions ponctuelles (overrides/absences), l'application des règles de préavis/fenêtres de réservation (`booking_notice_min`, `booking_window_days`), et la déduction dynamique des fenêtres disponibles.

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Tables `booking_availability_rule`, `booking_availability_override`, `booking_schedule`.
- **SurrealQL Functions** :
  - `fn::booking_get_available_slots($params: object)` ([`functions/availability/fn_get_available_slots.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_get_available_slots.surql))
  - `fn::booking_is_slot_available($params: object)` ([`functions/availability/fn_is_slot_available.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_is_slot_available.surql))
  - `fn::booking_apply_buffers($params: object)` ([`functions/availability/fn_apply_buffers.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_apply_buffers.surql))
  - `fn::booking_check_frequency_limit($params: object)` ([`functions/availability/fn_check_frequency_limit.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_check_frequency_limit.surql))
  - `fn::booking_save_availability_rules($params: object)` ([`functions/event_types/fn_save_availability_rules.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_save_availability_rules.surql))
- **Service Rust Neutre** : [`engine/src/services/availability.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/availability.rs) (`get_available_slots`, `get_availability_schedules`, `save_availability_schedule`, `validate_range`, `normalize_timezone`).
- **REST API v1** :
  - `GET /api/v1/availability/slots?event_type_slug=...&date_from=...&date_to=...&time_zone=...` ➔ Calcule les créneaux disponibles
  - `GET /api/v1/availability/schedules` ➔ Liste les plannings d'ouverture
  - `POST /api/v1/availability/schedules` ➔ Enregistre un planning d'ouverture
- **SDK Client TypeScript** :
  - [`workspace/sdk/availability/availability.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/availability/availability.types.ts)
  - [`workspace/sdk/availability/availability.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/availability/availability.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/availability/AvailabilityPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/availability/AvailabilityPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL, Service, DTOs, API v1) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
