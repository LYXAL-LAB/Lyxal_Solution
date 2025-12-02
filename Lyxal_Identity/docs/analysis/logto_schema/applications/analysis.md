# Applications Schema Analysis

## 1. Applications (`applications.sql`)
**Logto:** Represents a client application (OIDC Client).
**Lyxal Strategy:** `applications` table in `CORE` database.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `id` | varchar | `application.id` | Client ID |
| `name` | varchar | `application.name` | |
| `secret` | varchar | `application.secret` | Hashed? |
| `type` | enum | `application.type` | Native, SPA, M2M... |
| `oidc_client_metadata` | jsonb | `application.oidc_metadata` | Redirect URIs, etc. |
| `custom_client_metadata` | jsonb | `application.custom_metadata` | |
| `is_third_party` | bool | `application.is_third_party` | |

## 2. Application Secrets (`application_secrets.sql`)
**Logto:** Rotatable secrets for M2M apps.
**Lyxal Strategy:** `application_secrets` table or embedded list in `application`.

## Action Items
1. [ ] Create `application` table in SurrealDB.
2. [ ] Define `application_type` enum.
3. [ ] Implement secret rotation logic.
