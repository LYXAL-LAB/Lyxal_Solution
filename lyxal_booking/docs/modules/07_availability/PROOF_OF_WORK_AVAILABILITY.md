# 📄 Dossier de Preuve de Réalisation & Consolidation — Module 07 : Availability

> **Statut de Réalisation** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**  
> **Source de Vérité** : Code physique créé et vérifié dans [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)

---

## 📋 1. Cartographie Exhaustive des Primitives SurrealQL (`functions/availability/`)

| Fonction SurrealQL | Fichier `.surql` Physique Harmonisé | Rôle & Signature |
| :--- | :--- | :--- |
| `fn::booking_get_available_slots` | [`functions/availability/fn_get_available_slots.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_get_available_slots.surql) | Moteur principal de déduction et calcul des créneaux libres (chargement serveur de `booking_notice_min` & `booking_window_days`) |
| `fn::booking_is_slot_available` | [`functions/availability/fn_is_slot_available.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_is_slot_available.surql) | Vérification ponctuelle d'un créneau unique contre les conflits |
| `fn::booking_apply_buffers` | [`functions/availability/fn_apply_buffers.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_apply_buffers.surql) | Application des tampons de sécurité avant/après rendez-vous |
| `fn::booking_check_frequency_limit` | [`functions/availability/fn_check_frequency_limit.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_check_frequency_limit.surql) | Contrôle des limites de fréquence de réservation (jour/semaine/mois) |
| `fn::booking_save_availability_rules` | [`functions/event_types/fn_save_availability_rules.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_save_availability_rules.surql) | Persistance des heures d'ouverture hebdomadaires récurrentes |
| `fn::booking_save_availability_override` | [`functions/availability/fn_save_availability_override.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_save_availability_override.surql) | Enregistrement/Upsert d'une exception ponctuelle par clé naturelle (`user_id_YYYY-MM-DD`) |
| `fn::booking_get_availability_overrides` | [`functions/availability/fn_get_availability_overrides.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_get_availability_overrides.surql) | Lecture des exceptions ponctuelles de disponibilité |
| `fn::booking_delete_availability_override` | [`functions/availability/fn_delete_availability_override.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_delete_availability_override.surql) | Suppression d'une exception ponctuelle par son ID |

---

## 🛡️ 2. Isolation des Règles Métier (Sécurité Serveur vs Client)
- **Suppression du Faux Contrôle Client** : Les paramètres `booking_notice_min` et `booking_window_days` ont été retirés de `AvailabilityQuery` sur `GET /api/v1/availability/slots`. Un navigateur ne peut plus falsifier le préavis ni l'horizon de réservation.
- **Résolution Déterministe** : La primitive SurrealQL [`fn::booking_get_available_slots`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/availability/fn_get_available_slots.surql) charge `booking_notice_min`, `booking_window_days`, `before_buffer_minutes`, `after_buffer_minutes` et la liste des ressources rattachées directement depuis la table `booking_event_type`.
- **Agrégation d'Occupations Locales** : Le moteur consulte uniquement les snapshots locaux d'intervalles occupés (`booking_calendar_busy_interval` alimenté en arrière-plan par les workers de synchro Google/CalDAV), sans exécuter aucun appel HTTP externe synchrone.

---

## 3. Contrats Rust DTOs & Services Neutres
- **DTOs Rust** : [`engine/src/contracts/availability.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/contracts/availability.rs) (`AvailabilityQuery`, `AvailabilitySlotResponse`, `AvailabilityResponse`, `AvailabilityScheduleRule`, `AvailabilityScheduleResponse`, `SaveAvailabilityScheduleRequest`, `AvailabilityOverrideResponse`, `SaveAvailabilityOverrideRequest`, `DeleteAvailabilityOverrideResponse`).
- **Service Rust Neutre** : [`engine/src/services/availability.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/availability.rs) (`get_available_slots`, `get_availability_schedules`, `save_availability_schedule`, `get_availability_overrides`, `save_availability_override`, `delete_availability_override`, `validate_range`, `normalize_timezone`).

---

## 4. Handlers Axum REST API v1
- **Fichier Source** : [`engine/src/web/api/v1/availability.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/availability.rs)
- **Endpoints Axum Exposés** :
  - `GET /api/v1/availability/slots?event_type_slug=...&date_from=...&date_to=...&time_zone=...` ➔ Calcule les créneaux libres (sécurité serveur)
  - `GET /api/v1/availability/schedules` ➔ Liste les plannings d'ouverture
  - `POST /api/v1/availability/schedules` ➔ Enregistre un planning d'ouverture
  - `GET /api/v1/availability/overrides` ➔ Liste les exceptions ponctuelles
  - `POST /api/v1/availability/overrides` ➔ Enregistre/met à jour une exception ponctuelle
  - `DELETE /api/v1/availability/overrides/{id}` ➔ Supprime une exception ponctuelle

---

## 5. SDK Client TypeScript & UI React Workspace
- **SDK Client** : [`workspace/sdk/availability/availability.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/availability/availability.client.ts) (0 `fetch()` direct).
- **Composant UI** : [`workspace/modules/availability/AvailabilityPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/availability/AvailabilityPage.tsx) avec gestionnaire d'overrides et calculateur de créneaux.

---

## 🔗 Chaîne de Parité Validée de Bout en Bout
```text
AvailabilityPage.tsx (UI React Workspace - 0 fetch direct)
        │
        ▼ (Appels SDK fortement typés)
availabilityClient.ts (SDK Client TypeScript)
        │
        ▼ (Appels REST HTTP /api/v1/availability)
web/api/v1/availability.rs (Axum Handlers - 0 reqwest/crypto)
        │
        ▼ (Services Neutres Rust)
services::availability (get_available_slots, get_availability_schedules, save_availability_schedule, get_availability_overrides, save_availability_override, delete_availability_override)
        │
        ▼ (Mutations atomiques SurrealQL)
fn::booking_get_available_slots, fn::booking_is_slot_available, fn::booking_save_availability_rules, fn::booking_save_availability_override
```
