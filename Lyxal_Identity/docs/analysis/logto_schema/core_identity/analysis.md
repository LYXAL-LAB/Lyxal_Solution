# Core Identity Schema Analysis

## 1. Users (`users.sql`)
**Logto:** Central table for all users.
**Lyxal Strategy:** Split between `identity` (public/indexable) and `vault` (private/sovereign).

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `id` | varchar | `identity.id` | Use SurrealDB Record ID |
| `username` | varchar | `identity.username` | Optional, unique index |
| `primary_email` | varchar | `identity.email` | **Critical**, unique index |
| `primary_phone` | varchar | `identity.phone` | Add to schema |
| `password_encrypted` | varchar | `vault.secret.password_hash` | **MOVE TO VAULT** |
| `password_encryption_method` | enum | `vault.secret.algo` | Store algo with hash |
| `name` | varchar | `identity.name` | Display name |
| `avatar` | varchar | `identity.avatar` | Public URL |
| `profile` | jsonb | `identity.profile` | Standard OIDC claims |
| `custom_data` | jsonb | `vault.data` | Private user data? Or `identity.custom_data`? |
| `identities` | jsonb | `identity.social_identities` | Linked accounts (Google, etc.) |
| `mfa_verifications` | jsonb | `vault.mfa` | **MOVE TO VAULT** (Security) |
| `is_suspended` | bool | `identity.status` | Mapped to `identity_status` |
| `last_sign_in_at` | timestamp | `identity.timestamp.last_login` | Audit |
| `created_at` | timestamp | `identity.timestamp.created_at` | |

## 2. User SSO Identities (`user_sso_identities.sql`)
**Logto:** Links users to Enterprise SSO (SAML/OIDC).
**Lyxal Strategy:** Store in `identity` as a list of linked identities or a separate table `identity_sso`.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `issuer` | varchar | `identity.sso_links[].issuer` | |
| `identity_id` | varchar | `identity.sso_links[].sub` | Provider's User ID |
| `detail` | jsonb | `identity.sso_links[].profile` | Cached profile data |

## 3. Passcodes (`passcodes.sql`)
**Logto:** OTP codes (Email/SMS).
**Lyxal Strategy:** Ephemeral table `auth_flow` or `otp_codes` (TTL).

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `code` | varchar | `otp_codes.code` | Hashed? |
| `type` | varchar | `otp_codes.type` | 'email', 'sms' |
| `consumed` | bool | `otp_codes.consumed` | Prevent replay |

## 4. Verification Records (`verification_records.sql`)
**Logto:** Proof that a user verified an email/phone.
**Lyxal Strategy:** `identity.verifications` array or separate table.

## 5. One Time Tokens (`one_time_tokens.sql`)
**Logto:** Magic links, password reset tokens.
**Lyxal Strategy:** `pwreset` table (already exists) or generic `magic_link` table.

## 6. Personal Access Tokens (`personal_access_tokens.sql`)
**Logto:** API Keys for users.
**Lyxal Strategy:** `vault.api_keys`? Or `identity.api_keys` (hashed).

## Action Items
1. [ ] Update `identity` schema to add `username`, `phone`, `name`, `avatar`, `profile`.
2. [ ] Create `otp_codes` table (SurrealDB with TTL).
3. [ ] Refine `vault` schema to hold `mfa` and `custom_data`.
