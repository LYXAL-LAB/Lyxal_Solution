# Organizations Schema Analysis

## 1. Organizations (`organizations.sql`)
**Logto:** Multi-tenancy unit (B2B).
**Lyxal Strategy:** `organization` table.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `id` | varchar | `organization.id` | |
| `name` | varchar | `organization.name` | |
| `description` | varchar | `organization.description` | |
| `custom_data` | jsonb | `organization.custom_data` | |
| `branding` | jsonb | `organization.branding` | Logo, colors |

## 2. Organization User Relations (`organization_user_relations.sql`)
**Logto:** Membership table.
**Lyxal Strategy:** Graph relation `RELATION<member_of>` in SurrealDB.
`user:A -> member_of -> organization:B`

## 3. Organization Roles (`organization_roles.sql`)
**Logto:** Roles specific to an org.
**Lyxal Strategy:** `role` table linked to `organization`.

## Action Items
1. [ ] Create `organization` table.
2. [ ] Define `member_of` relation for efficient graph queries.
