# Consent Schema Analysis

## 1. Application User Consent (`application_user_consent_*.sql`)
**Logto:** Tracks what a user has consented to share with an app.
**Lyxal Strategy:** `consent` table or graph edge `user -> consented_to -> application`.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `application_id` | varchar | `consent.application` | |
| `user_id` | varchar | `consent.user` | |
| `scopes` | jsonb | `consent.scopes` | List of granted scopes |

## Action Items
1. [ ] Create `consent` table/edge.
