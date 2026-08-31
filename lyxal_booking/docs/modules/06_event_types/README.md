# 📘 Module 06 — EventTypes (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **EventTypes** régit la définition des prestations et créneaux de réservation réutilisables (ex: "Consultation 30 min", "Démonstration Produit 45 min", "Audit Technique 1h30"). Il configure les durées, tarifs, descriptions, visibilité publique, et les régles de réservation associées.

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Table `booking_event_type` (Champs : `title`, `slug`, `length` / `duration_minutes`, `description`, `hidden` / `active`).
- **SurrealQL Functions** :
  - `fn::booking_create_event_type($params: object)` ([`functions/event_types/fn_create_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_create_event_type.surql))
  - `fn::booking_list_event_types($params: object)` ([`functions/event_types/fn_list_event_types.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_list_event_types.surql))
  - `fn::booking_get_event_type($params: object)` ([`functions/event_types/fn_get_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_get_event_type.surql))
  - `fn::booking_update_event_type($params: object)` ([`functions/event_types/fn_update_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_update_event_type.surql))
  - `fn::booking_delete_event_type($params: object)` ([`functions/event_types/fn_delete_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_delete_event_type.surql))
- **Service Rust Neutre** : [`engine/src/services/event_types.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/event_types.rs)
- **REST API v1** :
  - `GET /api/v1/event-types` ➔ Liste les créneaux
  - `POST /api/v1/event-types` ➔ Crée un nouveau créneau
  - `GET /api/v1/event-types/{slug}` ➔ Détails d'un créneau
  - `PATCH /api/v1/event-types/{slug}` ➔ Modifie un créneau
  - `DELETE /api/v1/event-types/{slug}` ➔ Supprime un créneau
- **SDK Client TypeScript** :
  - [`workspace/sdk/event-types/event_types.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/event-types/event_types.types.ts)
  - [`workspace/sdk/event-types/event_types.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/event-types/event_types.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/event-types/EventTypesPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/event-types/EventTypesPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL, Service, DTOs, API v1) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
