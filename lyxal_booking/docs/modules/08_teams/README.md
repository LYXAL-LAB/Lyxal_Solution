# 📘 Module 08 — Teams & Round-Robin (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Teams** gère l'organisation multi-utilisateurs, la réservation collective, les membres d'équipe (roles `owner`, `admin`, `member`), la répartition automatique Round-Robin (`fn::booking_round_robin_assign`) et le contrôle de disponibilité collective (`fn::booking_check_collective_availability`).

---

## 🏛️ Architecture & Contrats
- **SurrealDB Schema** : Tables `booking_team`, `booking_team_member`, `booking_team_group`.
- **SurrealQL Functions** :
  - `fn::booking_create_team($params: object)` ([`functions/teams/fn_create_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_create_team.surql))
  - `fn::booking_get_teams_for_user($params: object)` ([`functions/teams/fn_get_teams_for_user.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_get_teams_for_user.surql))
  - `fn::booking_get_team_details($params: object)` ([`functions/teams/fn_get_team_details.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_get_team_details.surql))
  - `fn::booking_update_team($params: object)` ([`functions/teams/fn_update_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_update_team.surql))
  - `fn::booking_delete_team($params: object)` ([`functions/teams/fn_delete_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_delete_team.surql))
  - `fn::booking_add_team_member($params: object)` ([`functions/teams/fn_add_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_add_team_member.surql))
  - `fn::booking_remove_team_member($params: object)` ([`functions/teams/fn_remove_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_remove_team_member.surql))
  - `fn::booking_round_robin_assign($params: object)` ([`functions/teams/fn_round_robin_assign.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_round_robin_assign.surql))
  - `fn::booking_check_collective_availability($params: object)` ([`functions/teams/fn_check_collective_availability.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_check_collective_availability.surql))
- **Service Rust Neutre** : [`engine/src/services/teams.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/teams.rs) (`create_team`, `list_user_teams`, `get_team_details`, `update_team`, `delete_team`, `add_team_member`, `remove_team_member`, `get_team_members`).
- **REST API v1** : [`engine/src/web/api/v1/teams.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/teams.rs)
  - `GET /api/v1/teams` ➔ Liste les équipes de l'utilisateur
  - `POST /api/v1/teams` ➔ Crée une équipe
  - `GET /api/v1/teams/{id}` ➔ Détails d'une équipe
  - `PATCH /api/v1/teams/{id}` ➔ Modifie une équipe
  - `DELETE /api/v1/teams/{id}` ➔ Supprime une équipe
  - `POST /api/v1/teams/{id}/members` ➔ Ajoute un membre
  - `DELETE /api/v1/teams/{id}/members/{user_id}` ➔ Supprime un membre
- **SDK Client TypeScript** :
  - [`workspace/sdk/teams/teams.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/teams/teams.types.ts)
  - [`workspace/sdk/teams/teams.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/teams/teams.client.ts)
- **UI React Workspace** :
  - [`workspace/modules/teams/TeamsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/teams/TeamsPage.tsx)

---

## 🔒 Statut de Complétude
- Backend (SurrealQL 29 primitives, Service, DTOs, API v1) : **`● VALIDÉ`**
- SDK Client TypeScript : **`● VALIDÉ`**
- UI React Workspace : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
