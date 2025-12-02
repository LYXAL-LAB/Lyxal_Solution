# RBAC Schema Analysis

## 1. Roles (`roles.sql`)
**Logto:** Global roles (User vs M2M).
**Lyxal Strategy:** `role` table.

## 2. Resources (`resources.sql`)
**Logto:** API Resources (Audience).
**Lyxal Strategy:** `resource` table.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `indicator` | text | `resource.uri` | API Identifier (Audience) |
| `access_token_ttl` | bigint | `resource.ttl` | |

## 3. Scopes (`scopes.sql`)
**Logto:** Permissions within a resource (e.g. `read:users`).
**Lyxal Strategy:** `scope` table linked to `resource`.

## 4. Relations (`users_roles`, `roles_scopes`)
**Logto:** Join tables.
**Lyxal Strategy:** Graph edges in SurrealDB.
- `user -> has_role -> role`
- `role -> has_scope -> scope`

## Action Items
1. [ ] Create `role`, `resource`, `scope` tables.
2. [ ] Define graph edges for RBAC.
