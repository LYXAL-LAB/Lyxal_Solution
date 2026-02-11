# Connectors Schema Analysis

## 1. Connectors (`connectors.sql`)
**Logto:** Social Login (Google, GitHub, etc.).
**Lyxal Strategy:** `connector` table.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `id` | varchar | `connector.id` | |
| `connector_id` | varchar | `connector.provider` | 'google', 'github' |
| `config` | jsonb | `connector.config` | Client ID, etc. |
| `metadata` | jsonb | `connector.metadata` | |
| `sync_profile` | bool | `connector.sync_profile` | |

## 2. SSO Connectors (`sso_connectors.sql`)
**Logto:** Enterprise SSO (SAML, OIDC).
**Lyxal Strategy:** `sso_connector` table.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `provider_name` | varchar | `sso_connector.provider` | 'AzureAD', 'Okta' |
| `domains` | jsonb | `sso_connector.domains` | Auto-redirect domains |
| `branding` | jsonb | `sso_connector.branding` | |

## Action Items
1. [ ] Create `connector` and `sso_connector` tables.
2. [ ] Implement logic to match email domain to SSO connector.
