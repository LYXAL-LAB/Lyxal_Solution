# 📄 Dossier de Preuve de Réalisation & Consolidation — Module 08 : Teams & Round-Robin

> **Statut de Réalisation** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**  
> **Source de Vérité** : Code physique créé et vérifié dans [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)

---

## 📋 1. Cartographie Exhaustive des Primitives SurrealQL (`functions/teams/`)

| Fonction SurrealQL | Fichier `.surql` Physique Harmonisé | Rôle & Signature |
| :--- | :--- | :--- |
| `fn::booking_create_team` | [`functions/teams/fn_create_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_create_team.surql) | Création d'une équipe avec attribution automatique du rôle `owner` |
| `fn::booking_get_teams_for_user` | [`functions/teams/fn_get_teams_for_user.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_get_teams_for_user.surql) | Liste des équipes auxquelles appartient un utilisateur |
| `fn::booking_get_team_details` | [`functions/teams/fn_get_team_details.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_get_team_details.surql) | Lecture détaillée des propriétés d'une équipe |
| `fn::booking_update_team` | [`functions/teams/fn_update_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_update_team.surql) | Modification du nom, slug et visibilité d'une équipe |
| `fn::booking_delete_team` | [`functions/teams/fn_delete_team.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_delete_team.surql) | Suppression d'une équipe avec vérification des droits `owner` |
| `fn::booking_get_team_members` | [`functions/teams/fn_get_team_members.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_get_team_members.surql) | Lecture dédiée des membres d'une équipe |
| `fn::booking_add_team_member` | [`functions/teams/fn_add_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_add_team_member.surql) | Ajout d'un membre avec rôle (`owner`, `admin`, `member`) |
| `fn::booking_update_team_member` | [`functions/teams/fn_upsert_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_upsert_team_member.surql) | Modification du rôle d'un membre d'équipe |
| `fn::booking_remove_team_member` | [`functions/teams/fn_remove_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_remove_team_member.surql) | Retrait d'un membre avec protection du dernier `owner` |
| `fn::booking_leave_team` | [`functions/teams/fn_remove_team_member.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_remove_team_member.surql) | Auto-retrait d'un membre d'une équipe (interdit pour le dernier `owner`) |
| `fn::booking_round_robin_assign` | [`functions/teams/fn_round_robin_assign.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_round_robin_assign.surql) | Algorithme d'attribution équitable des rendez-vous d'équipe |
| `fn::booking_check_collective_availability` | [`functions/teams/fn_check_collective_availability.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/teams/fn_check_collective_availability.surql) | Contrôle d'intersection temporelle pour les réunions collectives |

---

## 2. Contrats Rust DTOs & Services Neutres
- **DTOs Rust** : [`engine/src/contracts/teams.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/contracts/teams.rs) (`TeamResponse`, `CreateTeamRequest`, `UpdateTeamRequest`, `DeleteTeamResponse`, `TeamMemberResponse`, `AddTeamMemberRequest`, `UpdateTeamMemberRequest`, `RemoveTeamMemberResponse`, `LeaveTeamResponse`).
- **Service Rust Neutre** : [`engine/src/services/teams.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/teams.rs) (`create_team`, `list_user_teams`, `get_team_details`, `update_team`, `delete_team`, `get_team_members`, `add_team_member`, `remove_team_member`).

---

## 3. Handlers Axum REST API v1
- **Fichier Source** : [`engine/src/web/api/v1/teams.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/teams.rs)
- **Endpoints Axum Exposés** :
  - `GET /api/v1/teams` ➔ Liste les équipes
  - `POST /api/v1/teams` ➔ Crée une équipe
  - `GET /api/v1/teams/{id}` ➔ Détails d'une équipe
  - `PATCH /api/v1/teams/{id}` ➔ Modifie une équipe
  - `DELETE /api/v1/teams/{id}` ➔ Supprime une équipe
  - `POST /api/v1/teams/{id}/leave` ➔ Auto-retrait du membre connecté
  - `GET /api/v1/teams/{id}/members` ➔ Liste dédiée des membres
  - `POST /api/v1/teams/{id}/members` ➔ Ajoute un membre avec rôle (`owner`, `admin`, `member`)
  - `PATCH /api/v1/teams/{id}/members/{user_id}` ➔ Modifie le rôle d'un membre
  - `DELETE /api/v1/teams/{id}/members/{user_id}` ➔ Supprime un membre (avec protection du dernier `owner`)

---

## 4. SDK Client TypeScript
- **Fichiers SDK** :
  - [`workspace/sdk/teams/teams.types.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/teams/teams.types.ts)
  - [`workspace/sdk/teams/teams.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/teams/teams.client.ts)
- **Méthodes Fortement Typées** :
  - `teamsClient.listTeams()`
  - `teamsClient.getTeam(id)`
  - `teamsClient.createTeam(request)`
  - `teamsClient.updateTeam(id, request)`
  - `teamsClient.deleteTeam(id)`
  - `teamsClient.leaveTeam(id)`
  - `teamsClient.getMembers(id)`
  - `teamsClient.addMember(id, request)`
  - `teamsClient.updateMember(id, userId, request)`
  - `teamsClient.removeMember(id, userId)`

---

## 5. Composant UI React Workspace
- **Fichier Component** : [`workspace/modules/teams/TeamsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/teams/TeamsPage.tsx)
- **Montage dans le Workspace** : [`workspace/App.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/App.tsx)
- **Fonctionnalités UI de Bout en Bout** :
  - **Zéro `fetch()` direct** : Consomme **100%** le client SDK `teamsClient`.
  - Liste des équipes avec rôle de l'utilisateur, compteur de membres et liens publics d'équipe (`/team/{team_slug}`).
  - Formulaire modal de création / édition d'équipe avec génération automatique de slug.
  - Interface modale de gestion des membres d'équipe avec lecture dédiée `getMembers(id)` et attribution de rôles (`owner`, `admin`, `member`).

---

## 🔗 Chaîne de Parité Validée de Bout en Bout
```text
TeamsPage.tsx (UI React Workspace - 0 fetch direct)
        │
        ▼ (Appels SDK fortement typés)
teamsClient.ts (SDK Client TypeScript)
        │
        ▼ (Appels REST HTTP /api/v1/teams)
web/api/v1/teams.rs (Axum Handlers - 0 reqwest/crypto)
        │
        ▼ (Services Neutres Rust)
services::teams (create_team, list_user_teams, get_team_details, update_team, delete_team, get_team_members, add_team_member, remove_team_member)
        │
        ▼ (Mutations atomiques SurrealQL)
fn::booking_create_team, fn::booking_get_teams_for_user, fn::booking_get_team_members, fn::booking_add_team_member, fn::booking_round_robin_assign
```
