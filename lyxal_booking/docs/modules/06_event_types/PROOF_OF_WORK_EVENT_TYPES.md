# 📄 Dossier de Preuve de Réalisation & Consolidation — Module 06 : EventTypes

> **Statut de Réalisation** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**  
> **Source de Vérité** : Code physique créé et vérifié dans [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)

---

## 📋 1. Cartographie Exhaustive des Primitives SurrealQL (`functions/event_types/`)

| Fonction SurrealQL | Fichier `.surql` Physique Harmonisé | Rôle & Signature |
| :--- | :--- | :--- |
| `fn::booking_create_event_type` | [`functions/event_types/fn_create_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_create_event_type.surql) | Création d'un créneau (titre, slug, durée, buffers, localisation) |
| `fn::booking_list_event_types` | [`functions/event_types/fn_list_event_types.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_list_event_types.surql) | Lecture des créneaux configurés par l'utilisateur |
| `fn::booking_get_event_type` | [`functions/event_types/fn_get_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_get_event_type.surql) | Lecture détaillée d'un créneau par son `slug` (filtré par `user_id`) |
| `fn::booking_update_event_type` | [`functions/event_types/fn_update_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_update_event_type.surql) | Modification des propriétés (titre, buffers, localisation, visibilité) |
| `fn::booking_delete_event_type` | [`functions/event_types/fn_delete_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_delete_event_type.surql) | Suppression atomique avec contrôle des dépendances et réservations |
| `fn::booking_toggle_event_type` | [`functions/event_types/fn_toggle_event_type.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_toggle_event_type.surql) | Bascule atomique du statut actif / masqué |
| `fn::booking_get_event_type_resources` | [`functions/event_types/fn_get_event_type_resources.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_get_event_type_resources.surql) | Lecture des ressources physiques rattachées au créneau |
| `fn::booking_update_event_type_resources` | [`functions/event_types/fn_update_event_type_resources.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/event_types/fn_update_event_type_resources.surql) | Mutation atomique de la sélection des ressources rattachées |

---

## 📊 2. Matrice de Parité des Champs Historiques (`EventTypeForm`)

| Champ Historique | Destination & Support dans Lyxal OS | Statut Officiel |
| :--- | :--- | :---: |
| `title`, `slug`, `length` | Intégrés dans `booking_event_type` et REST DTOs (`title`, `slug`, `duration_minutes`) | **CONSOLIDÉ ✅** |
| `before_buffer_minutes`, `after_buffer_minutes` | Intégrés dans `booking_event_type` et DTOs | **CONSOLIDÉ ✅** |
| `location_type`, `meeting_provider` | Enum `location_type` (`GOOGLE_MEET`, `ZOOM`, `PHONE`, `IN_PERSON`) | **CONSOLIDÉ ✅** |
| `resource_ids` / `attachable_resources` | Gérés via relation `booking_event_type_resource` & endpoints GET/PUT `/resources` | **CONSOLIDÉ ✅** |
| `booking_notice_min`, `booking_window_days` | **CIBLE DÉFINIE : Module 07 Availability** | **À VALIDER (MODULE 07) 🟡** |
| `confirmation_mode` | **CIBLE DÉFINIE : Module 08 Bookings** | **À VALIDER (MODULE 08) 🟡** |
| `calendar_source_id` / `write_calendar` | **CIBLE DÉFINIE : Module 04 Calendars** (gestion globale + override optionnel) | **À VALIDER 🟡** |

---

## 3. Scope Fonctionnel & Séparation Utilisateur / Équipe
- **Événements Personnels (`PERSONAL`)** : Identifiés de manière unique par `user_id` + `slug`. URLs publiques canoniques sous la forme `/u/{username}/{slug}`.
- **Événements d'Équipe (`TEAM`)** : Identifiés de manière unique par `team_id` + `slug`. Les membres et la répartition Round-Robin seront gérés au sein du **Module 09 — Teams**.

---

## 4. Contrats Rust DTOs & Services Neutres
- **DTOs Rust** : [`engine/src/contracts/event_types.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/contracts/event_types.rs) (`CreateEventTypeRequest`, `UpdateEventTypeRequest`, `EventTypeResponse`, `ToggleEventTypeResponse`, `EventTypeResourcesRequest`, `EventTypeResourcesResponse`).
- **Service Rust Neutre** : [`engine/src/services/event_types.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/event_types.rs) (`create_event_type`, `list_event_types`, `get_event_type`, `update_event_type`, `delete_event_type`, `toggle_event_type`, `get_event_type_resources`, `update_event_type_resources`).

---

## 5. Handlers Axum REST API v1
- **Fichier Source** : [`engine/src/web/api/v1/event_types.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/event_types.rs)
- **Endpoints Axum Exposés** :
  - `GET /api/v1/event-types` ➔ Liste les créneaux de l'utilisateur
  - `POST /api/v1/event-types` ➔ Crée un créneau
  - `GET /api/v1/event-types/{slug}` ➔ Détails par `user_id` + `slug`
  - `PATCH /api/v1/event-types/{slug}` ➔ Modifie un créneau par slug
  - `DELETE /api/v1/event-types/{slug}` ➔ Supprime un créneau avec rejet si réservations actives
  - `PATCH /api/v1/event-types/{slug}/toggle` ➔ Bascule le statut actif / masqué
  - `GET /api/v1/event-types/{slug}/resources` ➔ Liste les IDs des ressources rattachées
  - `PUT /api/v1/event-types/{slug}/resources` ➔ Met à jour la liste des ressources rattachées

---

## 6. SDK Client TypeScript & UI React Workspace
- **SDK TypeScript** : [`workspace/sdk/event-types/event_types.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/event-types/event_types.client.ts) (0 `fetch()` dans l'UI).
- **Composant UI** : [`workspace/modules/event-types/EventTypesPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/event-types/EventTypesPage.tsx) avec routage canonique `/u/{username}/{slug}` et toggle en temps réel.

---

## 🔗 Chaîne de Parité Validée de Bout en Bout
```text
EventTypesPage.tsx (UI React Workspace - 0 fetch direct)
        │
        ▼ (Appels SDK fortement typés)
eventTypesClient.ts (SDK Client TypeScript)
        │
        ▼ (Appels REST HTTP /api/v1/event-types)
web/api/v1/event_types.rs (Axum Handlers - 0 reqwest/crypto)
        │
        ▼ (Services Neutres Rust)
services::event_types (create, list, get, update, delete, toggle, get_resources, update_resources)
        │
        ▼ (Mutations atomiques SurrealQL)
fn::booking_create_event_type, fn::booking_list_event_types, fn::booking_toggle_event_type, fn::booking_update_event_type_resources
```
