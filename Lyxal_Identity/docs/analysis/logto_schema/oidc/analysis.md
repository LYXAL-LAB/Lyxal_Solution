# OIDC Schema Analysis

## 1. OIDC Model Instances (`oidc_model_instances.sql`)
**Logto:** Stores OIDC session state (Grants, Codes, Tokens).
**Lyxal Strategy:** `auth_flow` (ephemeral) or `oidc_session` table.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `model_name` | varchar | `oidc_session.type` | 'Grant', 'AuthorizationCode' |
| `payload` | jsonb | `oidc_session.data` | |
| `expires_at` | timestamp | `oidc_session.expires_at` | TTL index needed |

## Action Items
1. [ ] Create `oidc_session` table with TTL support.
