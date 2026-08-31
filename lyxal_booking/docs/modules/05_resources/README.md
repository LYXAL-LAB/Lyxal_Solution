# 📘 Module 05 — Resources (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Resources** gère le parc de ressources physiques et matérielles réservables (salles de réunion, véhicules, projecteurs, ordinateurs, caméras). Il permet d'associer ces ressources aux types d'événements et de vérifier les conflits de capacité et de réservation.

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Table `booking_resource` (Champs : `name`, `resource_type`, `capacity`, `location`, `description`, `feed_url`, `enabled`).
- **SurrealQL Functions** :
  - `fn::booking_create_resource($params: object)` ([`functions/resources/fn_create_resource.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/resources/fn_create_resource.surql))
  - `fn::booking_list_resources($params: object)` ([`functions/resources/fn_list_resources.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/resources/fn_list_resources.surql))
  - `fn::booking_get_resource($params: object)` ([`functions/resources/fn_get_resource.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/resources/fn_get_resource.surql))
  - `fn::booking_update_resource($params: object)` ([`functions/resources/fn_update_resource.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/resources/fn_update_resource.surql))
  - `fn::booking_delete_resource($params: object)` ([`functions/resources/fn_delete_resource.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/resources/fn_delete_resource.surql))
- **Service Rust Neutre** : [`engine/src/services/resources.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/resources.rs)
- **REST API v1** :
  - `GET /api/v1/resources` ➔ Liste des ressources
  - `POST /api/v1/resources` ➔ Création d'une ressource
  - `GET /api/v1/resources/{id}` ➔ Détails d'une ressource
  - `PUT /api/v1/resources/{id}` ➔ Modification d'une ressource
  - `DELETE /api/v1/resources/{id}` ➔ Suppression de ressource
- **SDK Client TypeScript** :
  - [`workspace/sdk/resources/resources.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/resources/resources.types.ts)
  - [`workspace/sdk/resources/resources.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/resources/resources.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/resources/ResourcesPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/resources/ResourcesPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL, Service, DTOs, API v1) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
