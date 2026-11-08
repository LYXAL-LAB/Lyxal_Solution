# Rapport d'analyse — Logto comme modèle de conception pour `lyxal_auth`

> Source analysée : dépôt Logto (MPL-2.0), commit `9b4106d5740b96be9f36b6d2303d3c1c10109325` (6 nov. 2026), dernière alteration `1.46.0`.
> Racine : `sources/logto/` (chemins ci-dessous relatifs à cette racine).
> Objectif : reprendre la **conception** (tables, champs, relations, fonctionnalités) — pas de traduction de code (MPL-2.0 = copyleft par fichier).

---

## 0. Synthèse chiffrée

| Élément | Valeur |
| :--- | :--- |
| Tables (fichiers `packages/schemas/tables/*.sql`, hors 4 scripts `_*.sql`) | **78** |
| Table `tenants` (définie à part dans `packages/schemas/src/models/tenants.ts`) | **1** |
| **Total tables recensées** | **79** |
| Types ENUM Postgres | 8 (`application_type`, `role_type`, `organization_invitation_status`, `users_password_encryption_method`, `sentinel_action_result`, `sentinel_decision`, `sign_in_mode`, `agree_to_terms_policy`) |
| Fonctions/triggers Postgres | `set_tenant_id`, `set_updated_at`, `check_application_type`, `check_role_type`, `check_organization_role_type`, `users__set_lower_columns`, `logs__set_payload_keys`, `oidc_model_instances__set_payload_keys`, `custom_profile_fields__increment_sie_order`, 4 triggers de purge des `secrets` |
| Alterations (migrations TS) | ~283 fichiers dans `packages/schemas/alterations/` |
| Connecteurs (`packages/connectors/connector-*`) | **56** : 32 Social, 12 Email, 12 SMS |
| Fournisseurs SSO entreprise (`packages/core/src/sso/`) | 6 : OIDC, SAML, AzureAD (SAML), AzureAdOidc, GoogleWorkspace, Okta |

Conventions transverses Logto :

* **Identifiants** : `varchar(21)` générés par `generateStandardId()` (nanoid 21 caractères minuscules+chiffres, `packages/shared/src/utils/id.ts`) ; `users.id` = `varchar(128)` (id 12 car. par défaut mais extensible) ; connecteurs = `varchar(128)`.
* **Multi-locataire** : **toutes** les tables métier portent `tenant_id varchar(21) not null references tenants(id) on update cascade on delete cascade`, rempli par trigger et filtré par RLS (cf. §4). Exceptions sans FK vers `tenants` : `systems` (global), `service_logs`, `daily_active_users`, `aggregated_daily_active_users`, `daily_token_usage` (tenant_id présent mais sans FK).
* **Clé primaire** : en général `id` seul (globalement unique) + index `(tenant_id, id)` ; tables de relation : PK composite commençant par `tenant_id`.
* **JSONB typé** : chaque colonne `jsonb` est annotée `/* @use TypeZod */`, typée par des gardes Zod dans `packages/schemas/src/foundations/jsonb-types/*.ts`.

---

## 1. Inventaire complet du modèle de données (79 tables)

Légende : **PK** clé primaire · **U** unique · **IDX** index · **FK** clé étrangère (cascade = `on update cascade on delete cascade` sauf mention) · **CHK** contrainte check. Toutes les tables ont `tenant_id` (FK `tenants`) sauf mention contraire.

### 1.1. Locataire, système et configuration (4 tables)

| Table | Rôle | Champs principaux (type / contraintes) | Clés, index, FK |
| :--- | :--- | :--- | :--- |
| `tenants` (`packages/schemas/src/models/tenants.ts`) | Locataire (projet) ; base de l'isolation RLS. | `id varchar(21)`, `db_user varchar(128)`, `db_user_password varchar(128)`, `name varchar(128)` déf. `'My Project'`, `tag varchar(64)` (Development/Production), `created_at timestamptz`, `is_suspended bool` | PK `id` ; U `db_user`. Pas de `tenant_id`. |
| `systems` | Clé/valeur **globale** de l'instance (hors locataire). | `key varchar(256)`, `value jsonb` | PK `key`. Pas de `tenant_id` ; accès révoqué au rôle locataire. |
| `logto_configs` | Clé/valeur de configuration **par locataire** : clés OIDC (`oidc.privateKeys`, `oidc.cookieKeys`, `oidc.session`), JWT customizer (`jwt.accessToken`, `jwt.clientCredentials`), `adminConsole`, `cloudConnection`, `sessionNotFoundRedirectUrl`, `idToken`, `signingKeyRotationState`, `messageRateLimitOverride`, `cimd` (enum `LogtoOidcConfigKey`, `LogtoJwtTokenKey`, `LogtoTenantConfigKey` dans `packages/schemas/src/types/logto-config/index.ts`). | `key varchar(256)`, `value jsonb` | PK `(tenant_id, key)` |
| `domains` | Domaines personnalisés du locataire (vérification DNS / Cloudflare). | `id`, `domain varchar(256)`, `status varchar(32)` (`DomainStatus`, déf. `PendingVerification`), `error_message varchar(1024)`, `dns_records jsonb`, `verification_files jsonb`, `cloudflare_data jsonb`, `created_at`, `updated_at` | PK `id` ; U `(tenant_id, domain)` ; IDX `(tenant_id,id)` |

### 1.2. Utilisateurs et identités (6 tables)

| Table | Rôle | Champs principaux | Clés, index, FK |
| :--- | :--- | :--- | :--- |
| `users` | Compte utilisateur final (profil, mot de passe, identités sociales, facteurs MFA). | `id varchar(128)`, `username varchar(128)`, `primary_email varchar(128)`, `primary_phone varchar(128)`, `password_encrypted varchar(256)`, `password_encryption_method` ENUM (`Argon2i`,`Argon2id`,`Argon2d`,`SHA1`,`SHA256`,`MD5`,`Bcrypt`,`Legacy`), `name`, `avatar varchar(2048)`, `profile jsonb` (claims OIDC standard : givenName, familyName, locale, address…), `application_id varchar(21)` (app d'inscription), `cimd_client_id varchar(2048)`, **`identities jsonb`** (`{ <target>: { userId, details } }` = identités sociales), `custom_data jsonb`, `logto_config jsonb` (préférences internes : MFA skip, etc.), **`mfa_verifications jsonb`** (tableau discriminé : `Totp {key, lastUsedTimeStep}`, `WebAuthn {credentialId, publicKey, counter, transports, rpId, agent, name}`, `BackupCode {codes[{code, usedAt}]}`, communs `id, createdAt, lastUsedAt`), `is_suspended bool`, `is_password_expired bool`, `last_sign_in_at`, `password_updated_at`, `created_at`, `updated_at`, `primary_email_lower varchar(384)` & `username_lower varchar(384)` (calculées par trigger) | PK `id` ; U `(tenant_id, username)`, `(tenant_id, primary_email)`, `(tenant_id, primary_phone)`, `(tenant_id, id)` ; IDX `(tenant_id,name)`, GIN `mfa_verifications`, `(tenant_id, lower(username))`, `(tenant_id, primary_email_lower)`, `(tenant_id, username_lower)` ; triggers `users__set_lower_columns`, `set_updated_at` |
| `user_sso_identities` | Identité fédérée SSO entreprise d'un utilisateur. | `id`, `user_id` FK users, `issuer varchar(256)` (issuer OIDC / entityId SAML), `identity_id varchar(128)`, `detail jsonb`, `sso_connector_id varchar(128)` FK sso_connectors, `created_at timestamp` (sans tz, bug connu), `updated_at` | PK `id` ; U `(tenant_id, issuer, identity_id)` ; trigger `set_updated_at` |
| `custom_profile_fields` | Catalogue des champs de profil personnalisés (inscription / account center). | `id`, `name varchar(128)`, `type varchar(128)` (`Text`,`Number`,`Date`,`Checkbox`,`Select`,`Url`,`Regex`,`Address`,`Fullname`…), `label`, `description varchar(256)`, `required bool`, `config jsonb`, `sie_order int2` (auto-incrément par trigger), `created_at` | PK `id` ; U `(tenant_id, name)` ; trigger `custom_profile_fields__increment_sie_order` |
| `user_geo_locations` | Dernières coordonnées connues (contrôle de vélocité géographique, MFA adaptatif). | `user_id` FK users, `latitude numeric(9,6)`, `longitude numeric(9,6)`, `updated_at` | PK `(tenant_id, user_id)` ; CHK lat/long tous deux nuls ou non |
| `user_sign_in_countries` | Pays de connexion par utilisateur (règles MFA adaptatif). | `user_id` FK, `country varchar(16)` (ISO 3166-1 α2), `last_sign_in_at` | PK `(tenant_id, user_id, country)` ; IDX `(tenant_id,user_id,last_sign_in_at desc)` |
| `personal_access_tokens` | Jetons d'accès personnels (PAT) d'un utilisateur, échangeables via token exchange. | `user_id` FK, `name varchar(256)`, `value varchar(64)`, `created_at`, `expires_at` (nullable) | PK `(tenant_id, user_id, name)` ; IDX `(tenant_id, value)` |

### 1.3. Coffre de secrets fédérés (3 tables)

| Table | Rôle | Champs principaux | Clés, index, FK |
| :--- | :--- | :--- | :--- |
| `secrets` | Coffre chiffré (enveloppe AES-256-GCM, DEK chiffrée par KEK `SECRET_VAULT_KEK`) des jeux de jetons des IdP tiers (`SecretType.FederatedTokenSet`). | `id varchar(21)`, `user_id` FK users, `type varchar(256)`, `encrypted_dek bytea`, `iv bytea`, `auth_tag bytea`, `ciphertext bytea`, `metadata jsonb`, `created_at`, `updated_at` | PK `id` ; trigger `set_updated_at` |
| `secret_social_connector_relations` | Lie un secret à un connecteur social et à l'identité sociale. | `secret_id` FK secrets (cascade), `connector_id` FK connectors (**update cascade seulement**), `target varchar(256)`, `identity_id varchar(128)` | PK `(tenant_id, secret_id)` ; U `(tenant_id, target, identity_id)` ; triggers : suppression des secrets avant suppression d'un connecteur et lors du retrait d'une identité dans `users.identities` |
| `secret_enterprise_sso_connector_relations` | Lie un secret à un connecteur SSO et à l'identité SSO. | `secret_id` FK, `sso_connector_id` FK (update cascade), `issuer`, `identity_id` | PK `(tenant_id, secret_id)` ; FK composite `(tenant_id, issuer, identity_id)` → `user_sso_identities` ; triggers de purge sur suppression connecteur SSO / identité SSO |

### 1.4. Applications / clients OAuth-OIDC (9 + 4 + 3 + 6 = 22 tables)

| Table | Rôle | Champs principaux | Clés, index, FK |
| :--- | :--- | :--- | :--- |
| `applications` | Client OAuth/OIDC/SAML enregistré. | `id`, `name varchar(256)`, `secret varchar(64)` (déprécié, validation interne oidc-provider), `description`, `type` ENUM (`Native`,`SPA`,`Traditional`,`MachineToMachine`,`Protected`,`SAML`), `oidc_client_metadata jsonb` (redirectUris, postLogoutRedirectUris, backchannelLogoutUri…), `custom_client_metadata jsonb` (corsAllowedOrigins, TTL refresh token, rotation, alwaysIssueRefreshToken…), `protected_app_metadata jsonb` (host, origin, customDomains), `custom_data jsonb`, `is_third_party bool`, `app_level_access_control_enabled bool`, `created_at` | PK `id` ; IDX `(tenant_id,id)`, `(tenant_id,is_third_party)`, `(tenant_id,type)` ; U sur `protected_app_metadata->>'host'` et `->'customDomains'->0->>'domain'` ; fonction `check_application_type()` |
| `application_secrets` | Secrets multiples (rotation) des clients confidentiels. | `application_id` FK, `name varchar(256)`, `value varchar(64)`, `created_at`, `expires_at` | PK `(tenant_id, application_id, name)` ; CHK type ∈ {M2M, Traditional, Protected} |
| `application_sign_in_experiences` | Surcharge de l'expérience de connexion par application (branding tiers). | `application_id` FK, `color jsonb`, `branding jsonb`, `custom_css`, `terms_of_use_url`, `privacy_policy_url`, `display_name` | PK `(tenant_id, application_id)` |
| `applications_roles` | Rôles globaux de type M2M attribués à une application. | `id`, `application_id` FK, `role_id` FK roles | PK `id` ; U `(tenant_id, application_id, role_id)` ; CHK `check_role_type(role_id,'MachineToMachine')` |
| `application_user_consent_user_scopes` | Scopes utilisateur (OIDC : profile, email, phone, custom_data, identities, roles, organizations…) demandables par une app tierce. | `application_id` FK, `user_scope varchar(64)` | PK `(application_id, user_scope)` |
| `application_user_consent_resource_scopes` | Permissions d'API (ressources) demandables par une app. | `application_id` FK, `scope_id` FK scopes | PK `(application_id, scope_id)` |
| `application_user_consent_organization_scopes` | Scopes d'organisation demandables par une app. | `application_id` FK, `organization_scope_id` FK | PK `(application_id, organization_scope_id)` |
| `application_user_consent_organization_resource_scopes` | Permissions d'API accordées via rôles d'organisation, demandables par une app. | `application_id` FK, `scope_id` FK scopes | PK `(application_id, scope_id)` |
| `application_user_consent_organizations` | Consentement d'un utilisateur à une app pour une organisation donnée. | `application_id` FK, `organization_id`, `user_id` | PK `(tenant_id, application_id, organization_id, user_id)` ; FK composite → `organization_user_relations` (suppression de l'adhésion ⇒ retrait du consentement) |

> Remarque : la PK des 4 tables `application_user_consent_*_scopes` ne contient pas `tenant_id` (incohérence historique).

#### Contrôle d'accès au niveau application (4 tables)

Active si `applications.app_level_access_control_enabled = true` : seuls les utilisateurs autorisés par au moins une règle peuvent se connecter à l'app.

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `application_access_control_user_relations` | Autorisation directe d'un utilisateur. | `application_id`, `user_id` | PK `(tenant_id, application_id, user_id)` |
| `application_access_control_user_role_relations` | Autorisation par rôle global (type User). | `application_id`, `role_id` | PK `(tenant_id, application_id, role_id)` ; CHK role type `User` |
| `application_access_control_organization_relations` | Autorisation par adhésion à une organisation. | `application_id`, `organization_id` | PK `(tenant_id, application_id, organization_id)` |
| `application_access_control_org_role_relations` | Autorisation par rôle dans une organisation. | `application_id`, `organization_id`, `organization_role_id` | PK `(tenant_id, application_id, organization_id, organization_role_id)` ; CHK org role type `User` |

#### Logto comme IdP SAML (3 tables)

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `saml_application_configs` | Configuration 1-1 d'une application de type SAML (Logto = IdP SAML). | `application_id` FK, `attribute_mapping jsonb`, `entity_id varchar(128)`, `acs_url jsonb`, `encryption jsonb`, `authn_request_config jsonb`, `name_id_format varchar(128)`, `static_attributes jsonb` | PK `(tenant_id, application_id)` ; CHK type `SAML` |
| `saml_application_secrets` | Paires clé privée/certificat de signature de l'IdP SAML (rotation). | `id`, `application_id` FK, `private_key text`, `certificate text`, `created_at`, `expires_at`, `active bool` | PK `(tenant_id, application_id, id)` ; U partiel 1 seul actif |
| `saml_application_sessions` | Session d'une requête AuthnRequest SAML en cours (pont SAML ↔ OIDC). | `id varchar(32)`, `application_id` FK, `saml_request_id varchar(128)`, `oidc_state varchar(32)`, `relay_state varchar(512)`, `raw_auth_request text`, `created_at`, `expires_at` | PK `(tenant_id, id)` ; CHK type `SAML` |

#### CIMD — Client ID Metadata Document (6 tables)

Clients OAuth **non enregistrés** identifiés par une URL (brouillon IETF OAuth CIMD, utile pour MCP). Activation par `logto_configs.cimd`.

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `cimd_user_scopes` | Liste blanche des scopes utilisateur demandables par les clients CIMD. | `user_scope varchar(64)` | PK `(tenant_id, user_scope)` |
| `cimd_resource_scopes` | Liste blanche des permissions d'API. | `scope_id` | PK `(tenant_id, scope_id)` ; FK `(tenant_id, scope_id)` → scopes |
| `cimd_organization_scopes` | Liste blanche des scopes d'organisation. | `organization_scope_id` | PK `(tenant_id, organization_scope_id)` ; FK → organization_scopes |
| `cimd_organization_resource_scopes` | Liste blanche des permissions d'API via rôles d'organisation. | `scope_id` | PK `(tenant_id, scope_id)` ; FK → scopes |
| `cimd_grant_client_snapshots` | Instantané de l'identité du client CIMD au moment du consentement (par Grant). | `grant_id varchar(128)`, `grant_model_name` (= `'Grant'`), `client_id varchar(2048)`, `name`, `logo_uri`, `created_at` | PK `(tenant_id, grant_id)` ; FK composite → `oidc_model_instances (tenant_id, model_name, id)` |
| `cimd_grant_organizations` | Organisation autorisée sur un Grant CIMD. | `grant_id`, `grant_model_name`, `organization_id`, `user_id` | PK `(tenant_id, grant_id)` ; FK → `oidc_model_instances` et → `organization_user_relations` ; IDX `(tenant_id, organization_id, user_id)` |

### 1.5. RBAC global : ressources d'API, permissions, rôles (5 tables)

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `resources` | API protégée (resource indicator RFC 8707 = audience du JWT). | `id`, `name text`, `indicator text`, `is_default bool`, `access_token_ttl bigint` (déf. 3600 s) | PK `id` ; U `(tenant_id, indicator)` ; U partiel une seule ressource `is_default` par locataire |
| `scopes` | Permission d'une ressource d'API (`read:orders`…). | `id`, `resource_id` FK resources, `name varchar(256)`, `description`, `created_at` | PK `id` ; U `(tenant_id, resource_id, name)`, `(tenant_id, id)` |
| `roles` | Rôle global (niveau locataire). | `id`, `name varchar(128)`, `description varchar(128)`, `type` ENUM `role_type` (`User`, `MachineToMachine`), `is_default bool` (attribué à tout nouvel utilisateur) | PK `id` ; U `(tenant_id, name)` ; IDX `(tenant_id,type)` ; fonction `check_role_type()` |
| `roles_scopes` | Permissions d'un rôle global. | `id`, `role_id` FK, `scope_id` FK | PK `id` ; U `(tenant_id, role_id, scope_id)` |
| `users_roles` | Rôles globaux d'un utilisateur. | `id`, `user_id` FK, `role_id` FK | PK `id` ; U `(tenant_id, user_id, role_id)` ; CHK role type `User` |

(+ `applications_roles` au §1.4 pour les rôles M2M.)

### 1.6. Organisations (14 tables)

Modèle « **organization template** » : rôles et scopes d'organisation sont définis **une fois par locataire** et partagés par toutes les organisations (RFC 0001 Logto) ; les affectations sont par organisation.

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `organizations` | Organisation (B2B, espace client). | `id`, `name varchar(128)`, `description varchar(256)`, `custom_data jsonb`, `is_mfa_required bool`, `is_trusted_device_allowed bool` (déf. true), `color jsonb`, `branding jsonb`, `custom_css`, `created_at` | PK `id` ; IDX `(tenant_id,id)` |
| `organization_scopes` | Permission d'organisation (template). | `id`, `name varchar(128)`, `description varchar(256)` | PK `id` ; U `(tenant_id, name)`, `(tenant_id, id)` |
| `organization_roles` | Rôle d'organisation (template). | `id`, `name varchar(128)`, `description`, `type role_type` (`User`/`MachineToMachine`) | PK `id` ; U `(tenant_id, name)` ; fonction `check_organization_role_type()` |
| `organization_role_scope_relations` | Rôle d'org → scopes d'org. | `organization_role_id`, `organization_scope_id` | PK `(tenant_id, organization_role_id, organization_scope_id)` |
| `organization_role_resource_scope_relations` | Rôle d'org → permissions d'API (scopes de ressource). | `organization_role_id`, `scope_id` | PK `(tenant_id, organization_role_id, scope_id)` |
| `organization_user_relations` | Adhésion d'un utilisateur à une organisation. | `organization_id`, `user_id` | PK `(tenant_id, organization_id, user_id)` ; FK `(tenant_id,user_id)` → `users(tenant_id,id)` ; IDX `(tenant_id,user_id)` |
| `organization_role_user_relations` | Rôles d'un membre dans une organisation. | `organization_id`, `organization_role_id`, `user_id` | PK `(tenant_id, organization_id, organization_role_id, user_id)` ; FK composite → `organization_user_relations` (sortie ⇒ perte des rôles) ; CHK type `User` |
| `organization_application_relations` | Adhésion d'une application M2M à une organisation. | `organization_id`, `application_id` | PK `(tenant_id, organization_id, application_id)` ; CHK app type `MachineToMachine` |
| `organization_role_application_relations` | Rôles d'une app M2M dans une organisation. | `organization_id`, `organization_role_id`, `application_id` | PK 4 colonnes ; FK composite → `organization_application_relations` ; CHK org role type `MachineToMachine` |
| `organization_invitations` | Invitation à rejoindre une organisation (RFC 0003). | `id`, `inviter_id` FK users (nullable), `invitee varchar(256)` (e-mail), `accepted_user_id` FK users, `organization_id` FK, `status` ENUM (`Pending`,`Accepted`,`Expired`,`Revoked`), `created_at`, `updated_at`, `expires_at` | PK `id` ; U partiel `(tenant_id, invitee, organization_id) where status='Pending'` |
| `organization_invitation_role_relations` | Rôles attribués à l'acceptation de l'invitation. | `organization_invitation_id`, `organization_role_id` | PK `(tenant_id, organization_invitation_id, organization_role_id)` |
| `organization_jit_email_domains` | Provisionnement JIT : domaines e-mail ajoutant automatiquement l'utilisateur à l'organisation. | `organization_id`, `email_domain varchar(128)` | PK `(tenant_id, organization_id, email_domain)` |
| `organization_jit_roles` | Rôles par défaut attribués lors d'une adhésion JIT. | `organization_id`, `organization_role_id` | PK `(tenant_id, organization_id, organization_role_id)` |
| `organization_jit_sso_connectors` | Provisionnement JIT via un connecteur SSO entreprise. | `organization_id`, `sso_connector_id` | PK `(tenant_id, organization_id, sso_connector_id)` |

### 1.7. Sessions, jetons et grants (4 tables)

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `oidc_model_instances` | **Stockage générique polymorphe** de l'adaptateur oidc-provider : `Session`, `Interaction`, `Grant`, `AccessToken` (opaque), `RefreshToken`, `AuthorizationCode`, `DeviceCode`, `ClientCredentials`, `PushedAuthorizationRequest`, `ReplayDetection`, `BackchannelAuthenticationRequest`… L'état d'une interaction Experience API y est aussi stocké (`provider.interactionResult`). | `model_name varchar(64)`, `id varchar(128)`, `payload jsonb`, `expires_at`, `consumed_at`, colonnes dénormalisées par trigger : `payload_grant_id`, `payload_account_id`, `payload_uid`, `payload_user_code` | PK `id` ; U `(tenant_id, model_name, id)` ; nombreux IDX partiels (Session/Grant par accountId, grantId, uid, userCode, expires_at) ; réglages autovacuum |
| `oidc_session_extensions` | Métadonnées complémentaires d'une session OIDC (liste des sessions dans l'account center / console). | `session_uid varchar(128)`, `account_id` FK users, `last_submission jsonb` (IP, UA, géo…), `client_id varchar(21)`, `cimd_client_id`, `created_at`, `updated_at` | PK `(tenant_id, session_uid)` ; IDX `account_id` |
| `subject_tokens` | Jeton sujet d'**impersonation** créé via Management API, échangé par grant `token_exchange` (RFC 8693). | `id varchar(25)`, `context jsonb`, `expires_at`, `consumed_at`, `user_id` FK, `created_at`, `creator_id varchar(32)` (user ou app, audit) | PK `id` ; IDX `(tenant_id,id)` |
| `one_time_tokens` | Jeton à usage unique par e-mail (magic link, invitation, provisioning JIT). | `id`, `email varchar(128)`, `token varchar(256)`, `context jsonb` (jitOrganizationIds…), `status` (`active`,`consumed`,`revoked`,`expired`), `created_at`, `expires_at` | PK `id` ; U `(tenant_id, token)` ; IDX `(tenant_id, email, status)` |

(+ `personal_access_tokens` au §1.2, `application_secrets` au §1.4.)

### 1.8. MFA, vérification, anti-abus (6 tables)

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `passcodes` | Codes de vérification e-mail/SMS envoyés (6 chiffres). | `id`, `interaction_jti varchar(128)`, `phone varchar(32)`, `email varchar(128)`, `type varchar(32)` (SignIn, Register, ForgotPassword, Generic, BindMfa, MfaVerification…), `code varchar(6)`, `consumed bool`, `try_count int2`, `created_at` | PK `id` ; IDX `(tenant_id, interaction_jti, type)`, `(tenant_id, email, type)`, `(tenant_id, phone, type)` |
| `verification_records` | Enregistrement de vérification (Experience API / Account API / `/verifications`) : preuve d'identité réutilisable pendant sa durée de vie. | `id`, `user_id` FK (nullable), `created_at`, `expires_at`, `data jsonb` (type : Password, EmailVerificationCode, PhoneVerificationCode, Mfa*VerificationCode, Social, EnterpriseSso, Totp, WebAuthn, SignInPasskey, BackupCode, NewPasswordIdentity, OneTimeToken) | PK `id` ; IDX `(tenant_id,id)` |
| `verification_statuses` | Ancien marqueur de « ré-authentification récente » pour opérations sensibles (`/me`, console). | `id`, `user_id` FK, `created_at`, `verified_identifier varchar(255)` | PK `id` ; IDX `(tenant_id,user_id)` |
| `trusted_devices` | Appareil de confiance révocable dispensant de MFA (« se souvenir de cet appareil »). | `id`, `user_id` FK, `secret_hash bytea`, `user_agent`, `ip`, `country`, `city`, `created_at`, `last_used_at`, `expires_at` | PK `id` ; IDX `(tenant_id,user_id,expires_at)`, `(tenant_id,expires_at)` |
| `sentinel_activities` | Journal des tentatives pour la **détection de force brute / verrouillage** (Sentinel). | `id`, `target_type varchar(32)` (`User`,`App`), `target_hash varchar(64)` (identifiant haché), `action varchar(64)` (Password, VerificationCode, OneTimeToken, MfaTotp, WebAuthn, MfaBackupCode, VerificationCodeSend, MessageSend…), `action_result` ENUM (`Success`,`Failed`), `payload jsonb`, `decision` ENUM (`Undecided`,`Allowed`,`Blocked`,`Challenge`), `decision_expires_at`, `created_at` | PK `id` ; IDX `(tenant_id,target_type,target_hash[,action,action_result,decision])`, `(created_at)` |
| `captcha_providers` | Fournisseur CAPTCHA du locataire (Turnstile, reCAPTCHA Enterprise). | `id varchar(128)`, `config jsonb`, `created_at`, `updated_at` | PK `id` ; U `tenant_id` (un seul par locataire) |

### 1.9. Connecteurs sociaux / passwordless et SSO entreprise (5 tables)

| Table | Rôle | Champs | Clés / FK |
| :--- | :--- | :--- | :--- |
| `connectors` | Instance configurée d'un connecteur (Social, Email, SMS). | `id varchar(128)`, `connector_id varchar(128)` (id de la *factory*, ex. `github-universal`), `sync_profile bool`, `enable_token_storage bool`, `config jsonb` (secrets clients en clair !), `metadata jsonb` (surcharges : target, name, logo…), `created_at` | PK `id` ; IDX `(tenant_id,id)` |
| `sso_connectors` | Connecteur SSO entreprise (OIDC/SAML/Azure/Okta/Google Workspace). | `id varchar(128)`, `provider_name varchar(128)`, `connector_name varchar(128)`, `config jsonb`, `domains jsonb` (domaines e-mail pour la découverte home-realm), `branding jsonb`, `sync_profile bool`, `enable_token_storage bool`, `created_at` | PK `id` ; U `(tenant_id, connector_name)` |
| `sso_connector_idp_initiated_auth_configs` | Configuration du SSO **initié par l'IdP** (SAML) : app cible et redirection. | `connector_id` FK, `default_application_id` FK applications, `redirect_uri`, `auth_parameters jsonb`, `auto_send_authorization_request bool`, `client_idp_initiated_auth_callback_uri`, `created_at` | PK `(tenant_id, connector_id)` ; CHK app type ∈ {Traditional, SPA, SAML} |
| `idp_initiated_saml_sso_sessions` | Assertion SAML reçue en mode IdP-initiated, en attente de consommation. | `id`, `connector_id` FK, `assertion_content jsonb`, `created_at`, `expires_at` | PK `(tenant_id, id)` |
| `saml_sso_connector_signing_keys` | Clé SP de signature des AuthnRequest SAML (rotation). | `id`, `sso_connector_id` FK, `private_key text` (PEM en clair, protégé par RLS), `certificate text`, `created_at`, `expires_at`, `active bool` | PK `(tenant_id, sso_connector_id, id)` ; U partiel 1 seul actif |

(+ `user_sso_identities` §1.2, `secret_*_connector_relations` §1.3, `organization_jit_sso_connectors` §1.6.)

### 1.10. Sign-in experience, personnalisation, account center (4 tables)

| Table | Rôle | Champs principaux | Clés |
| :--- | :--- | :--- | :--- |
| `sign_in_experiences` | **Configuration centrale** (une ligne `default` par locataire) de l'inscription/connexion et des politiques de sécurité. | `id`, `color jsonb`, `branding jsonb` (logo, favicon, dark), `hide_logto_branding`, `language_info jsonb` (autoDetect, fallbackLanguage), `terms_of_use_url`, `privacy_policy_url`, `agree_to_terms_policy` ENUM (`Automatic`,`ManualRegistrationOnly`,`Manual`), **`sign_in jsonb`** (`methods[{identifier, password, verificationCode, isPasswordPrimary}]`), **`sign_up jsonb`** (`identifiers[]`, `password`, `verify`, `secondaryIdentifiers`), `social_sign_in jsonb` (automaticAccountLinking, skipRequiredIdentifiers), `social_sign_in_connector_targets jsonb`, `sign_in_mode` ENUM (`SignIn`,`Register`,`SignInAndRegister`), `custom_css`, `custom_content`, `custom_ui_assets`, `custom_ui_csp`, `cross_origin_opener_policy`, **`password_policy jsonb`** (length min/max, characterTypes.min, rejects : pwned, repetitionAndSequence, userInfo, words), **`mfa jsonb`** (`factors[]` : Totp, WebAuthn, BackupCode, EmailVerificationCode, PhoneVerificationCode ; `policy` : Mandatory, PromptOnlyAtSignIn, PromptAtSignInAndSignUp, NoPrompt, …Mandatory ; `organizationRequiredMfaPolicy`), `adaptive_mfa jsonb`, `trusted_device jsonb` (enabled, durationDays 1–365), `single_sign_on_enabled`, `sso_branding_before_email_match`, `support_email`, `support_website_url`, `unknown_session_redirect_url`, `captcha_policy`, **`sentinel_policy jsonb`** (maxAttempts déf. 100, lockoutDuration déf. 60 min), `email_blocklist_policy` (blockDisposableAddresses, blockSubaddressing, custom allow/block lists), `verification_code_policy` (expirationDuration 60–3600 s, maxRetryAttempts 1–100), `forgot_password_methods`, `passkey_sign_in` (enabled, showPasskeyButton, allowAutofill), `sign_up_profile_fields`, `password_expiration` (enabled, validPeriodDays, enabledAt), `username_policy` (caseSensitive, min/maxLength, allowedChars) | PK `(tenant_id, id)` |
| `custom_phrases` | Traductions personnalisées de l'UI par langue. | `id`, `language_tag varchar(16)`, `translation jsonb` | PK `id` ; U `(tenant_id, language_tag)` |
| `email_templates` | Modèles d'e-mail par langue et type (SignIn, Register, ForgotPassword, OrganizationInvitation, Generic, UserPermissionValidation, BindNewIdentifier, MfaVerification, BindMfa). | `id`, `language_tag`, `template_type varchar(64)`, `details jsonb` (subject, content, contentType, replyTo, sendFrom), `created_at` | PK `(tenant_id, id)` ; U `(tenant_id, language_tag, template_type)` |
| `account_centers` | Configuration de l'account center (self-service) et de l'Account API. | `id`, `enabled bool`, `fields jsonb` (par champ : Off/ReadOnly/Edit — name, avatar, profile, email, phone, password, username, social, customData, mfa, session…), `webauthn_related_origins jsonb`, `delete_account_url`, `custom_css`, `profile_fields jsonb`, `maximum_authentication_age_in_seconds int` (déf. 600) | PK `(tenant_id, id)` |

(+ `application_sign_in_experiences` §1.4, `custom_profile_fields` §1.2.)

### 1.11. Webhooks (1 table)

| Table | Rôle | Champs | Clés |
| :--- | :--- | :--- | :--- |
| `hooks` | Webhook sortant signé HMAC-SHA256 (`logto-signature-sha-256`). | `id`, `name varchar(256)`, `event varchar(128)` (ancien, mono-événement), `events jsonb` (PostRegister, PostSignIn, PostSignInAdaptiveMfaTriggered, PostResetPassword, `User.Created/Deleted/Data.Updated/SuspensionStatus.Updated`, `TrustedDevice.*`, `Role.*`, `Role.Scopes.Updated`, `Scope.*`, `Organization.*`, `Organization.Membership.Updated`, `OrganizationRole.*`, `OrganizationScope.*`, `Identifier.Lockout`, `Message.RateLimited`, `Grant.LimitExceeded`), `config jsonb` (url, headers, retries déprécié), `signing_key varchar(64)`, `enabled bool`, `created_at` | PK `id` ; IDX `(tenant_id,id)` |

Les exécutions de webhooks sont journalisées dans `logs` (clé `TriggerHook.<event>`, `payload.hookId`).

### 1.12. Journaux, audit et statistiques (5 tables)

| Table | Rôle | Champs | Clés / index |
| :--- | :--- | :--- | :--- |
| `logs` | **Journal d'audit** par locataire (interactions, jetons, webhooks, SAML, actions, JWT customizer, trusted devices). | `id`, `key varchar(128)` (ex. `Interaction.SignIn.Submit`, `ExchangeTokenBy.AuthorizationCode`, `RevokeToken`, `TriggerHook.PostSignIn`…), `payload jsonb` (result, error, ip, userAgent, userId, applicationId, sessionId, hookId, params…), `created_at`, colonnes dénormalisées par trigger `payload_user_id`, `payload_application_id`, `payload_hook_id` | PK `id` ; IDX `(tenant_id,key)`, `(tenant_id,created_at,id)`, partiels par user/app/hook ; trigger `logs__set_payload_keys` |
| `service_logs` | Journal de service hors RLS (envoi d'e-mails/SMS hébergés, quotas) — interne/cloud. | `id`, `tenant_id` (sans FK), `type varchar(64)`, `payload jsonb`, `created_at` | PK `id` ; IDX `(tenant_id,type,created_at)`, `(created_at)`, partiels e-mail ; **pas de RLS**, accès révoqué au rôle locataire |
| `daily_active_users` | Activité quotidienne brute (DAU/MAU du tableau de bord). | `id`, `tenant_id` (sans FK), `user_id varchar(128)`, `date timestamptz` | PK `id` ; U `(user_id, date)` ; IDX `(tenant_id,date,user_id)`, BRIN `date` |
| `aggregated_daily_active_users` | Agrégat quotidien produit par un job (facturation cloud). | `tenant_id`, `activity_date date`, `user_id`, `activity_count int` | PK `(tenant_id, activity_date, user_id)` |
| `daily_token_usage` | Compteur quotidien de jetons émis (quota). | `id`, `tenant_id`, `usage bigint`, `user_token_usage`, `m2m_token_usage`, `date` | PK `id` ; U `(tenant_id, date)` |

### 1.13. Récapitulatif par domaine

| Domaine | Nb | Tables |
| :--- | :---: | :--- |
| Locataire / config | 4 | tenants, systems, logto_configs, domains |
| Utilisateurs & identités | 6 | users, user_sso_identities, custom_profile_fields, user_geo_locations, user_sign_in_countries, personal_access_tokens |
| Coffre de secrets | 3 | secrets, secret_social_connector_relations, secret_enterprise_sso_connector_relations |
| Applications (cœur + consentement) | 9 | applications, application_secrets, application_sign_in_experiences, applications_roles, application_user_consent_{user_scopes, resource_scopes, organization_scopes, organization_resource_scopes, organizations} |
| Contrôle d'accès applicatif | 4 | application_access_control_{user, user_role, organization, org_role}_relations |
| Logto IdP SAML | 3 | saml_application_{configs, secrets, sessions} |
| CIMD | 6 | cimd_{user_scopes, resource_scopes, organization_scopes, organization_resource_scopes, grant_client_snapshots, grant_organizations} |
| RBAC global | 5 | resources, scopes, roles, roles_scopes, users_roles |
| Organisations | 14 | organizations, organization_{scopes, roles, role_scope_relations, role_resource_scope_relations, user_relations, role_user_relations, application_relations, role_application_relations, invitations, invitation_role_relations, jit_email_domains, jit_roles, jit_sso_connectors} |
| Sessions / jetons | 4 | oidc_model_instances, oidc_session_extensions, subject_tokens, one_time_tokens |
| MFA / vérification / anti-abus | 6 | passcodes, verification_records, verification_statuses, trusted_devices, sentinel_activities, captcha_providers |
| Connecteurs & SSO | 5 | connectors, sso_connectors, sso_connector_idp_initiated_auth_configs, idp_initiated_saml_sso_sessions, saml_sso_connector_signing_keys |
| Sign-in experience / UI | 4 | sign_in_experiences, custom_phrases, email_templates, account_centers |
| Webhooks | 1 | hooks |
| Logs / stats | 5 | logs, service_logs, daily_active_users, aggregated_daily_active_users, daily_token_usage |
| **Total** | **79** | 4+6+3+9+4+3+6+5+14+4+6+5+4+1+5 = 79 |

---

## 2. Inventaire des fonctionnalités

Organisation du code (`packages/core/src/`) : `routes/` (API Koa : Management API `/api/*`, Experience API `/api/experience/*`, Account API `/api/my-account/*`, `/api/verifications`), `libraries/` (logique), `queries/` (SQL Slonik, un fichier par table), `oidc/` (configuration oidc-provider), `sso/` (connecteurs SSO), `sentinel/`, `saml-application/`, `event-listeners/`, `middleware/`. Les routeurs sont montés dans `packages/core/src/routes/init.ts`. L'ancienne Interaction API (`routes/interaction/`) est marquée `@deprecated` au profit de l'Experience API (`routes/experience/`).

Frontends : `packages/experience` (UI de connexion, pages `src/pages/*`), `packages/account` (account center self-service), `packages/console` (console d'administration, pages `src/pages/*`).

### 2.1. Authentification de l'utilisateur final (Experience API)

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Moteur d'interaction (événements SignIn / Register / ForgotPassword, identification, vérification, profil, soumission) | `routes/experience/index.ts`, `routes/experience/classes/experience-interaction.ts`, `routes/experience/profile-routes.ts`, `routes/experience/const.ts` (préfixes `/experience/interaction`, `/identification`, `/verification`, `/profile`, `/profile/mfa`) ; UI `packages/experience/src/pages/{SignIn,Register,IdentifierSignIn,IdentifierRegister,Continue}` | oidc_model_instances (Interaction), verification_records, users, sign_in_experiences, logs |
| Connexion / inscription par mot de passe (identifiant username / e-mail / téléphone) | `routes/experience/verification-routes/password-verification.ts`, `classes/verifications/password-verification.ts`, `libraries/user-password-verification.ts`, `libraries/user.utils.ts` (hachage **Argon2i** via `hash-wasm`, worker `workers/password-encryption-worker.ts`), vérification héritée SHA1/SHA256/MD5/Bcrypt/scrypt Firebase/sha-crypt (`utils/password.ts`, `utils/firebase-scrypt.ts`, `utils/sha-crypt.ts`) avec ré-hachage | users, sentinel_activities, logs |
| Code de vérification e-mail / SMS (passwordless, OTP) | `verification-routes/verification-code.ts`, `classes/verifications/code-verification.ts`, `libraries/passcode.ts` (envoi via connecteur, `verification_code_policy`) ; UI `pages/VerificationCode` | passcodes, connectors, email_templates, verification_records, sentinel_activities |
| Passkey (connexion sans mot de passe WebAuthn) | `verification-routes/web-authn-verification.ts`, `libraries/verification-helpers/webauthn.ts` (`@simplewebauthn/server`), `passkey_sign_in` de la SIE ; UI `pages/SignInPasskeyVerification`, `PasskeySetup` | users.mfa_verifications (WebAuthn), verification_records |
| Lien magique / jeton à usage unique | `verification-routes/one-time-token.ts`, `classes/verifications/one-time-token-verification.ts`, `libraries/one-time-token.ts`, Management API `routes/one-time-tokens.ts` ; UI `pages/OneTimeToken` | one_time_tokens, organization_user_relations (JIT) |
| Mot de passe oublié | `classes/experience-interaction.ts` (événement ForgotPassword), `forgot_password_methods` ; UI `pages/ForgotPassword`, `ResetPassword*` | passcodes, users |
| Politique de mot de passe (longueur, types de caractères, HaveIBeenPwned, répétitions/séquences, infos utilisateur, mots interdits) | `packages/toolkit/core-kit/src/password-policy.ts` (`PasswordPolicyChecker`), `routes/experience/classes/libraries/password-validator.ts` | sign_in_experiences.password_policy |
| Expiration du mot de passe | `libraries/password-expiration.ts`, `PATCH /users/:userId/password/expiration` (`routes/admin-user/basics.ts`) | users.is_password_expired, password_updated_at, sign_in_experiences.password_expiration |
| Politique de nom d'utilisateur | `routes/sign-in-experience/username-policy.ts` | sign_in_experiences.username_policy |
| Champs de profil obligatoires / personnalisés à l'inscription | `classes/profile.ts`, `classes/libraries/profile-validator.ts`, `libraries/custom-profile-fields/`, `routes/custom-profile-fields.ts` | custom_profile_fields, users.profile/custom_data |
| CGU / consentement à l'inscription | `agree_to_terms_policy` ; `classes/libraries/sign-in-experience-validator.ts` | sign_in_experiences |
| Liste noire d'e-mails (jetables, sous-adressage) | `libraries/sign-in-experience/email-blocklist-policy.ts` | sign_in_experiences.email_blocklist_policy |
| CAPTCHA | `classes/libraries/captcha-validator.ts`, `routes/captcha-provider/index.ts` | captcha_providers, sign_in_experiences.captcha_policy |
| Verrouillage anti-force brute (Sentinel) | `sentinel/basic-sentinel.ts` (actions mutualisées/isolées, décision Blocked + expiration), `sentinel/message-rate-guard.ts` (limitation d'envoi), `classes/libraries/sentinel-guard.ts`, `routes/sentinel-activities.ts` | sentinel_activities, sign_in_experiences.sentinel_policy, hooks (`Identifier.Lockout`) |
| Connexion directe / bascule de compte / step-up (`acr_values`, `max_age`) | `routes/experience/anonymous-routes/`, `classes/libraries/step-up-eligibility.ts`, `oidc/interaction-policy.ts` ; UI `pages/DirectSignIn`, `SwitchAccount`, `StepUp` | oidc_model_instances |
| Anciennes routes d'interaction (déprécié) | `routes/interaction/*` | idem |

### 2.2. MFA

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| TOTP (enrôlement, vérification, anti-rejeu `lastUsedTimeStep`) | `verification-routes/totp-verification.ts`, `libraries/verification-helpers/totp-validation.ts` (`otplib`), `classes/mfa.ts` | users.mfa_verifications |
| WebAuthn (clé de sécurité / biométrie) | `verification-routes/web-authn-verification.ts`, `libraries/verification-helpers/webauthn.ts` | users.mfa_verifications, account_centers.webauthn_related_origins |
| Codes de secours (génération, consommation) | `verification-routes/backup-code-verification.ts`, `libraries/verification-helpers/backup-code-validation.ts` | users.mfa_verifications |
| OTP e-mail / SMS comme facteur MFA | `classes/verifications/code-verification.ts` (types `MfaEmailVerificationCode`, `MfaPhoneVerificationCode`) | passcodes, verification_records |
| Politique MFA (obligatoire, invite à l'inscription/connexion, non proposée) et MFA obligatoire par organisation | `libraries/sign-in-experience/mfa-policy.ts`, `mfa.ts`, `classes/libraries/mfa-validator.ts`, `libraries/mfa.ts` ; UI `pages/MfaBinding`, `MfaOnboarding`, `MfaVerification` ; console `pages/Mfa` | sign_in_experiences.mfa, organizations.is_mfa_required |
| MFA adaptatif (nouveau pays, vélocité géographique) | `routes/experience/classes/libraries/adaptive-mfa-validator/` | user_sign_in_countries, user_geo_locations, sign_in_experiences.adaptive_mfa, hooks (`PostSignInAdaptiveMfaTriggered`) |
| Appareils de confiance | `routes/experience/classes/trusted-device.ts`, `libraries/trusted-device.ts`, `libraries/trusted-device-policy.ts`, routes `account/trusted-device.ts`, `admin-user/trusted-device.ts` ; UI `pages/TrustedDevice` | trusted_devices, organizations.is_trusted_device_allowed |
| Gestion admin des facteurs | `routes/admin-user/mfa-verifications.ts` | users |

### 2.3. Connecteurs sociaux et SSO entreprise

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Connexion sociale (OAuth2/OIDC/SAML/SIWE), liaison automatique de compte | `verification-routes/social-verification.ts`, `libraries/verification-helpers/social-verification.ts`, `libraries/social.ts`, `libraries/connector.ts`, `routes/connector/` ; UI `pages/SocialLanding`, `SocialLinkAccount`, `SocialSignInWebCallback` | connectors, users.identities, sign_in_experiences.social_sign_in |
| Sign-In With Ethereum | `libraries/verification-helpers/siwe.ts`, `connector-siwe` | users.identities |
| Stockage des jetons tiers (federated token set) | `utils/secret-encryption.ts` (AES-256-GCM, DEK+KEK), `routes/secret.ts`, `routes/account/third-party-tokens.ts` | secrets, secret_*_relations |
| SSO entreprise OIDC / SAML (SP-initiated), découverte par domaine e-mail | `routes/experience/verification-routes/enterprise-sso-verification.ts`, `libraries/verification-helpers/single-sign-on*.ts`, `libraries/sso-connector.ts`, `routes/sso-connector/index.ts`, `sso/{OidcSsoConnector,SamlSsoConnector,AzureAdSsoConnector,AzureOidcSsoConnector,GoogleWorkspaceSsoConnector,OktaSsoConnector}` (`samlify`) ; UI `pages/SingleSignOn*` ; console `pages/EnterpriseSso*` | sso_connectors, user_sso_identities, saml_sso_connector_signing_keys |
| SSO initié par l'IdP (SAML) | `routes/sso-connector/idp-initiated-auth-config.ts` | sso_connector_idp_initiated_auth_configs, idp_initiated_saml_sso_sessions |
| Provisionnement JIT en organisation (domaine e-mail, SSO) | `routes/organization/jit/*`, `routes/experience/classes/libraries/provision-library.ts` | organization_jit_* , organization_user_relations, organization_role_user_relations |
| Synchronisation de profil à chaque connexion | `sync_profile` (connectors, sso_connectors) | users |

### 2.4. Applications, OIDC / OAuth 2.x, M2M

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Fournisseur OIDC (authorization code + PKCE, refresh token, userinfo, introspection, révocation, back-channel logout, RP-initiated logout, device flow, resource indicators, PAR) | `oidc/init.ts` (features), `oidc/adapter.ts` (adaptateur polymorphe, `Client` lu depuis `applications`), `oidc/grants/{refresh-token,client-credentials}.ts`, `oidc/device-flow.ts`, `oidc/resource.ts`, `oidc/scope.ts`, `oidc/extra-token-claims.ts` ; dépendance fork `logto-io/node-oidc-provider` | oidc_model_instances, applications, resources, scopes, logto_configs (clés) |
| Types d'applications (Native, SPA, Traditional, M2M, Protected app, SAML), secrets multiples, données personnalisées | `routes/applications/*.ts`, `libraries/application.ts`, `libraries/protected-app.ts` ; console `pages/Applications`, `ApplicationDetails` | applications, application_secrets |
| Machine-to-machine (client_credentials, rôles M2M, appartenance organisation) | `oidc/grants/client-credentials.ts`, `routes/applications/application-role.ts`, `routes/applications/application-organization.ts`, `routes/organization/application/` | applications_roles, organization_application_relations, organization_role_application_relations |
| Applications tierces & écran de consentement | `routes/applications/application-user-consent-*.ts`, `routes/interaction/consent/`, `libraries/session/consent.ts` ; UI `pages/Consent` | application_user_consent_* |
| Contrôle d'accès par application | `libraries/application-access-control.ts`, `oidc/application-access-control.ts`, `routes/applications/application-access-control.ts` | application_access_control_* |
| Logto en IdP SAML | `saml-application/SamlApplication/`, `routes/saml-application/{index,anonymous}.ts`, `libraries/saml-application/` | saml_application_* |
| Clients CIMD (MCP / clients non enregistrés) | `oidc/cimd/`, `routes/cimd.ts`, `routes/logto-config/cimd.ts`, `libraries/session/cimd-grant-records.ts` | cimd_*, logto_configs.cimd |
| Personnalisation des claims JWT (script utilisateur) / Actions | `libraries/jwt-customizer.ts`, `libraries/action.ts`, `libraries/script-runner/`, `routes/logto-config/{jwt-customizer,action}.ts` ; console `pages/CustomizeJwt*`, `Actions` | logto_configs (`jwt.*`), logs |
| Claims ID token étendus | `routes/logto-config/id-token.ts` | logto_configs.idToken |
| Rotation des clés de signature OIDC / cookies | `libraries/oidc-private-key.ts`, `routes/logto-config/index.ts` | logto_configs |

### 2.5. Autorisation (RBAC)

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Ressources d'API et permissions | `routes/resource.ts`, `routes/resource.scope.ts`, `libraries/scope.ts` ; console `pages/ApiResources*` | resources, scopes |
| Rôles globaux utilisateur / M2M, rôle par défaut | `routes/role.ts`, `role.scope.ts`, `role.user.ts`, `role.application.ts`, `libraries/role-scope.ts` ; console `pages/Roles`, `RoleDetails` | roles, roles_scopes, users_roles, applications_roles |
| Calcul des scopes du jeton (filtrage par rôles) | `oidc/resource.ts` (`getResourceServerInfo`), `oidc/client-scope.ts` | idem + organization_* |
| Management API protégée par le RBAC (ressource `…/api`, scope `all`) | `middleware/koa-auth/`, seeds `packages/schemas/src/seeds/management-api.ts` | resources, scopes, roles |

### 2.6. Organisations (multi-tenancy B2B)

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| CRUD organisations, membres, rôles des membres | `routes/organization/index.ts`, `routes/organization/user/{index,role-relations}.ts`, `queries/organization/*`, utilitaires génériques `utils/SchemaRouter.ts`, `utils/RelationQueries.ts` ; console `pages/Organizations`, `OrganizationDetails` | organizations, organization_user_relations, organization_role_user_relations |
| Template d'organisation (rôles, scopes, permissions d'API) | `routes/organization-role/index.ts`, `routes/organization-scope/index.ts` ; console `pages/OrganizationTemplate`, `OrganizationRoleDetails` | organization_roles, organization_scopes, organization_role_scope_relations, organization_role_resource_scope_relations |
| Jetons d'organisation (`organization_id`, `urn:logto:scope:organizations`) | `oidc/init.ts` (`getResourceServerInfo` avec organizationId), `oidc/grants/refresh-token.ts` | idem |
| Invitations (création, e-mail, statut, acceptation) | `routes/organization-invitation/index.ts` (`POST /`, `PUT /:id/status`, `POST /:id/message`), `libraries/organization-invitation.ts` ; console `pages/AcceptInvitation` | organization_invitations, organization_invitation_role_relations, one_time_tokens, email_templates |
| JIT (domaines e-mail, SSO, rôles par défaut) | `routes/organization/jit/` | organization_jit_* |
| MFA obligatoire / branding par organisation | `organizations.is_mfa_required`, `branding`, `color`, `custom_css` | organizations |

### 2.7. Gestion des utilisateurs (Management API) et self-service (Account API)

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| CRUD utilisateurs, recherche avancée, suspension, mot de passe, profil, custom data | `routes/admin-user/{basics,search}.ts`, `libraries/user.ts`, `utils/search.ts` ; console `pages/Users`, `UserDetails` | users |
| Identités sociales / SSO d'un utilisateur | `routes/admin-user/{social,enterprise-sso}.ts` | users.identities, user_sso_identities |
| Rôles et organisations d'un utilisateur | `routes/admin-user/{role,organization}.ts` | users_roles, organization_user_relations |
| Sessions et grants (liste, révocation) | `routes/admin-user/{session,grants}.ts`, `libraries/session/` ; console `pages/UserSessionDetails` | oidc_model_instances, oidc_session_extensions |
| PAT | `routes/admin-user/personal-access-token.ts`, `routes/account/personal-access-tokens.ts` | personal_access_tokens |
| Impersonation (subject token + token exchange RFC 8693, `act.sub`) | `routes/subject-token.ts` (`POST /subject-tokens`), `oidc/grants/token-exchange/{index,actor-token,account}.ts` | subject_tokens, personal_access_tokens, logs |
| Account API `/api/my-account` (profil, e-mail/téléphone, mot de passe, identités, MFA, sessions, grants, appareils de confiance, avatar) avec ré-authentification par `verification_records` | `routes/account/*.ts`, `routes/verification/index.ts` (`/api/verifications`), `routes/account-center/index.ts` ; frontend `packages/account/src/pages/*` | account_centers, verification_records, users, trusted_devices |
| Ancienne API `/me` (console) | `packages/core/src/routes-me/*` | verification_statuses, users |

### 2.8. Webhooks, journaux, observabilité

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Webhooks (interaction, data hooks Management API, exceptions), signature HMAC, 3 tentatives, test | `libraries/hook/{index,utils,context-manager}.ts`, `utils/sign.ts`, `middleware/koa-management-api-hooks.ts`, `routes/hook.ts` ; console `pages/Webhooks`, `WebhookDetails` | hooks, logs |
| Journal d'audit (filtres user/app/clé, détail) | `middleware/koa-audit-log.ts`, `routes/log.ts`, types `packages/schemas/src/types/log/*.ts` ; console `pages/AuditLogs`, `AuditLogDetails` | logs |
| Tableau de bord (utilisateurs, DAU/MAU, nouveaux comptes) | `routes/dashboard.ts`, `event-listeners/record-active-users.ts` | daily_active_users, users |
| Quotas / usage (cloud) | `libraries/quota.ts`, `queries/daily-token-usage.ts`, `queries/tenant-usage/` | daily_token_usage, aggregated_daily_active_users, service_logs |
| Écouteurs d'événements oidc-provider (grant, session, interaction) | `event-listeners/*.ts` | logs, oidc_session_extensions |

### 2.9. Personnalisation et configuration

| Fonctionnalité | Implémentation | Tables |
| :--- | :--- | :--- |
| Sign-in experience (branding, méthodes, CSS/CSP, UI personnalisée) | `routes/sign-in-experience/*`, `libraries/sign-in-experience/*` ; console `pages/SignInExperience`, `Security` | sign_in_experiences, application_sign_in_experiences |
| i18n (phrases personnalisées) | `routes/custom-phrase.ts`, `libraries/phrase.ts`, packages `phrases`, `phrases-experience` | custom_phrases |
| Modèles d'e-mail | `routes/email-template/index.ts`, `middleware/koa-email-i18n.ts` | email_templates |
| Domaines personnalisés | `routes/domain.ts`, `libraries/domain.ts`, `utils/cloudflare/` | domains |
| Configuration système / multi-locataire | `routes/system.ts`, `tenants/`, `routes-me/tenant*.ts` (cloud) | systems, tenants |

---

## 3. Connecteurs (`packages/connectors`)

### 3.1. Inventaire (56 connecteurs + `templates/`)

| Catégorie | Nb | Connecteurs |
| :--- | :---: | :--- |
| **Social** | 32 | alipay-native, alipay-web, amazon, apple, azuread, dingtalk-web, discord, facebook, feishu-web, github, gitlab, google (One Tap), huggingface, kakao, kook, line, linkedin, logto-social-demo, mock-social, naver, **oauth2** (générique), **oidc** (générique), patreon, qq, **saml** (générique), siwe, slack, wechat-native, wechat-web, wecom, x, xiaomi |
| **Email** | 12 | aliyun-dm, aws-ses, http-email, logto-email (service cloud), mailgun, mailjunky, mock-email, mock-email-alternative, postmark, sendgrid-email, smtp, smtp2go-email |
| **SMS** | 12 | aliyun-sms, aliyun-sms-mas, gatewayapi-sms, http-sms, mock-sms, smsaero, smsbao-sms, tencent-sms, twilio-sms, vonage-sms, whatsapp, yunpian-sms |

Hors connecteurs, les **SSO entreprise** sont intégrés au cœur : `packages/core/src/sso/` (OIDC, SAML, AzureAD, AzureAdOidc, GoogleWorkspace, Okta), enum `SsoProviderName` dans `packages/schemas/src/types/sso-connector.ts`.

### 3.2. Description d'un connecteur (`packages/toolkit/connector-kit/src/types/`)

| Élément | Fichier | Contenu |
| :--- | :--- | :--- |
| `ConnectorType` | `foundation.ts` | `Email`, `Sms`, `Social` |
| `BaseConnector<T>` | `foundation.ts` | `{ type, metadata: ConnectorMetadata, configGuard: ZodType }` |
| `ConnectorMetadata` | `metadata.ts` | `id` (id de factory unique, ex. `github-universal`), `target` (fournisseur ; une identité sociale par target et par utilisateur), `platform` (`Native`/`Universal`/`Web`, social), `isStandard` (OIDC/OAuth2/SAML génériques multi-instances), `isTokenStorageSupported`, `name` et `description` (i18n, `en` obligatoire), `logo`, `logoDark`, `readme`, `configTemplate`, **`formItems`** (formulaire de configuration généré dans la console : `key`, `label`, `type` ∈ Text/Number/MultilineText/Switch/Select/MultiSelect/Json, `required`, `placeholder`, `description`, `showConditions`), `customData` |
| `SocialConnector` | `social.ts` | `getAuthorizationUri(payload{state, redirectUri, connectorId, connectorFactoryId, jti, headers}, setSession)`, `getUserInfo(data, getSession) → SocialUserInfo {id, email?, phone?, name?, avatar?, rawData?}`, optionnels `getTokenResponseAndUserInfo`, `getAccessTokenByRefreshToken`, `validateSamlAssertion` ; session connecteur (`ConnectorSession`) pour state/nonce/PKCE |
| `EmailConnector` / `SmsConnector` | `passwordless.ts` | `sendMessage({ to, type: TemplateType, payload{code?, link?, locale?, …}, ip? }, config?)`, `getUsage?(startFrom)` ; `TemplateType` : SignIn, Register, ForgotPassword, OrganizationInvitation, Generic, UserPermissionValidation, BindNewIdentifier, MfaVerification, BindMfa |
| Erreurs | `error.ts` | `ConnectorError` + `ConnectorErrorCodes` normalisés |
| Instance persistée | table `connectors` | `connector_id` (factory) + `config` (validé par `configGuard`) + `metadata` (surcharges) + `sync_profile`, `enable_token_storage` |

Chaque paquet a la forme `connector-xxx/src/{index.ts, constant.ts (defaultMetadata), types.ts (configGuard Zod)}` + `logo.svg` + `README.md` ; chargement dynamique par `packages/core/src/utils/connectors/` et `libraries/connector.ts`.

---

## 4. Points d'attention pour une transcription vers SurrealDB 3.3.4 / Rust

### 4.1. Dépendances fortes à PostgreSQL

| Mécanisme Postgres | Où | Transposition SurrealDB / Lyxal |
| :--- | :--- | :--- |
| **RLS multi-locataire** : rôle `logto_tenant_<db>`, politique restrictive `tenant_id = (select id from tenants where db_user = current_user)` sur chaque table, `tenants` en RLS `db_user = current_user` | `tables/_after_each.sql`, `_after_all.sql`, `_before_all.sql` | Pas d'équivalent « rôle DB par locataire ». Options : `PERMISSIONS FOR select, create, update, delete WHERE tenant = $auth.tenant` (ou `$token`) sur chaque table, ou **un namespace/database SurrealDB par locataire**. À trancher (ADR) ; le module Lyxal accède via `fn::auth_*` et `$params`. |
| Trigger `set_tenant_id` (remplit `tenant_id` depuis `current_user`) | `_functions.sql` | `DEFINE FIELD tenant ... VALUE $auth.tenant` / `DEFAULT` ou passage explicite par les fonctions `fn::auth_*`. |
| Trigger `set_updated_at` | `_functions.sql` | `DEFINE FIELD updated_at ON ... VALUE time::now()` |
| Contraintes CHECK appelant des fonctions (`check_role_type`, `check_organization_role_type`, `check_application_type`) | `roles.sql`, `organization_roles.sql`, `applications.sql` | `DEFINE FIELD ... ASSERT` avec sous-requête sur l'enregistrement lié (`$value.type = 'User'`), ou contrôle dans la fonction métier (et dans `DEFINE EVENT` si besoin). |
| **Clés étrangères composites + cascades** (ex. rôles d'org ⇢ adhésion, consentement ⇢ adhésion, CIMD ⇢ Grant) | `organization_role_user_relations.sql`, `application_user_consent_organizations.sql`, `cimd_grant_*.sql` | SurrealDB 3 : `TYPE record<table> REFERENCE ON DELETE CASCADE/REJECT/UNSET` (références simples). Les FK composites deviennent soit des **ID composites** (`organization_member:[org, user]`), soit des tables `TYPE RELATION` (`user ->member_of-> organization` avec `ENFORCED`), soit des `DEFINE EVENT ... WHEN $event = "DELETE"` de nettoyage. Attention à la règle Lyxal « pas de `TYPE RELATION` sur les tables existantes » (ici tables neuves : à arbitrer). |
| Index uniques **partiels** (`where status='Pending'`, `where active`, `where is_default`) | `organization_invitations.sql`, `saml_*`, `resources.sql` | Pas d'index partiel : champ calculé (ex. `pending_key = IF status='Pending' THEN [invitee, org] ELSE NONE END`) + `UNIQUE`, ou contrôle transactionnel dans la fonction. |
| Index d'expression / GIN / BRIN, colonnes dénormalisées par trigger (`*_lower`, `payload_*`) | `users.sql`, `logs.sql`, `oidc_model_instances.sql` | Champs `VALUE string::lowercase(...)` / `VALUE $this.payload.userId` + `DEFINE INDEX`. Recherche full-text : `DEFINE ANALYZER` + `SEARCH`. |
| Triggers de purge des secrets (connecteur / identité supprimés, diff du JSON `identities`) | `secret_social_connector_relations.sql`, `secret_enterprise_sso_connector_relations.sql` | `DEFINE EVENT` sur `connector`/`sso_connector`/`user_sso_identity` ; préférer une **table `user_identity` normalisée** plutôt que `users.identities` JSON (rend la purge simple). |
| Trigger de séquence `sie_order` | `custom_profile_fields.sql` | Calcul dans `fn::auth_custom_profile_field_create` (max+1). |
| ENUM Postgres | 8 types | `ASSERT $value INSIDE [...]` ou `TYPE "A" \| "B"` (littéraux). |
| `bytea` (secrets, hash d'appareil) | `secrets.sql`, `trusted_devices.sql` | `bytes`, ou enveloppe `enc:v2:...` (`string`) produite par `lyxal_crypto` — **ne pas** reprendre le schéma DEK/IV/tag éclaté. |
| `jsonb` typé par Zod (`@use`) | partout | `TYPE object` + `DEFINE FIELD` imbriqués (`sign_in.methods[*]`…) ; normaliser ce qui est requêté (MFA, identités). |
| Purges par âge, autovacuum, agrégation DAU par job | `oidc_model_instances`, `sentinel_activities`, `service_logs`, `aggregated_daily_active_users` | Worker `LyxalWorker` (ou `lyxal_scheduler`) de purge `expires_at < time::now()` ; SurrealDB n'a pas de TTL natif. |
| Alterations TypeScript (~283) | `packages/schemas/alterations/` | Non pertinent en pré-production Lyxal : un seul `0001_initial.surql` à l'état cible. |
| Secrets en clair en base (`connectors.config`, `saml_*_secrets.private_key`, `application_secrets.value`, `personal_access_tokens.value`, `hooks.signing_key`) protégés uniquement par RLS | divers | Chiffrer via `lyxal_crypto` (`CryptoEngine::seal` + `SecretContext::with_tenant`), stocker des **hachages** pour PAT/secrets clients/one-time tokens (SHA-256/BLAKE3) plutôt que la valeur. |

### 4.2. Dépendances à Node.js / oidc-provider

| Élément | Où | Conséquence pour Lyxal (Rust) |
| :--- | :--- | :--- |
| **`oidc-provider` (fork `logto-io/node-oidc-provider`)** : tout le protocole OIDC/OAuth (endpoints, grants, PKCE, device flow, PAR, introspection, révocation, logout, resource indicators), cookies de session, interactions | `packages/core/src/oidc/*`, `package.json` | Aucun équivalent direct. En Rust : bibliothèque de primitives (`openidconnect`/`oxide-auth`, `jsonwebtoken`/`josekit`) + implémentation propre des endpoints dans le module. Le **modèle de stockage polymorphe `oidc_model_instances`** est imposé par l'adaptateur oidc-provider : préférer des tables typées (`auth_session`, `auth_grant`, `auth_authorization_code`, `auth_refresh_token`, `auth_device_code`, `auth_interaction`) avec `expires_at`, `consumed_at`. |
| `applications.secret` « interne » doublonnant `application_secrets` | `applications.sql` | Limitation oidc-provider (un seul secret par client) : ne pas reproduire. |
| Hachage Argon2i via `hash-wasm` dans un pool de workers ; vérification des formats hérités (MD5/SHA1/Bcrypt/scrypt Firebase/sha-crypt) | `libraries/user.utils.ts`, `workers/`, `utils/password.ts` | `lyxal_crypto::password` (Argon2id) ; formats hérités inutiles en pré-production (pas de migration d'utilisateurs) — à signaler au CTO si import de comptes externes est requis. |
| TOTP `otplib`, WebAuthn `@simplewebauthn/server`, SAML `samlify` + `xmllint`, HMAC `node:crypto` | `libraries/verification-helpers/*`, `sso/`, `utils/sign.ts` | HMAC/SHA/AES via `lyxal_crypto`. **TOTP (HMAC-SHA1), WebAuthn (ECDSA P-256/Ed25519/RSA), signature/chiffrement XML SAML (RSA)** ne sont **pas** couverts par `lyxal_crypto` (Ed25519/asymétrique hors scope) ⇒ **besoins crypto à signaler au CTO** avant implémentation. Signature JWT (RS256/ES256) idem. |
| Scripts utilisateur (JWT customizer, Actions) exécutés en worker isolé ou Cloudflare | `libraries/jwt-customizer.ts`, `libraries/script-runner/`, `libraries/action.ts` | Exécution de code arbitraire : à exclure ou à remplacer par des règles déclaratives SurrealQL. |
| Connecteurs = paquets npm chargés dynamiquement (Zod `configGuard`, HTTP sortant) | `packages/connectors/*`, `core/src/utils/connectors/` | En Lyxal, les envois e-mail/SMS relèvent de **`lyxal_notification`** (événements `auth.*` consommés) ; les connecteurs sociaux/SSO = trait Rust `SocialConnector` / `SsoConnector` dans `lyxal_auth` avec métadonnées déclaratives (copier la forme `ConnectorMetadata` + `formItems`). |
| Webhooks HTTP sortants directs depuis les routes | `libraries/hook/` | Remplacer par `DEFINE EVENT` → `fn::event_publish` (`auth.user.created`…) ; webhooks = consommateur `lyxal_event`. La taxonomie d'événements Logto (§1.11) est une bonne base pour `auth.<entite>.<action>`. |
| Koa, Slonik, Zod, i18next, sessions par cookies | partout | Validation d'entrée ⇒ `lyxal_core` (`fn::validation_object_execute`) ; i18n ⇒ `lyxal_i18n` ; erreurs ⇒ master data `AUTH_*`. |
| Fonctionnalités **cloud uniquement** (quotas, DAU agrégés, `service_logs`, `routes-me/tenant*`, `logto-email`, Cloudflare domaines) | `libraries/quota.ts`, `subscription.ts`, `utils/cloudflare/` | Hors périmètre `lyxal_auth` V1. |

### 4.3. Recommandations de découpage pour `lyxal_auth`

1. **V1 (cœur)** : `tenant`/`auth_config`, `user` (+ `user_identity` normalisée sociale/SSO, `user_mfa_factor` normalisé au lieu de `mfa_verifications` JSON), `role`/`permission`/`resource` + relations, `organization` + template (rôles/scopes), adhésions, invitations, `application` + secrets hachés, sessions/grants/codes typés, `verification_code`, `verification_record`, `sentinel_activity` (verrouillage), `sign_in_policy` (scinder l'énorme `sign_in_experiences` : politique mot de passe, MFA, sentinel, code de vérification, branding).
2. **V2** : `trusted_device`, MFA adaptatif (`user_sign_in_country`, `user_geo_location`), contrôle d'accès par application, consentement tiers, PAT, impersonation (`subject_token`), account center.
3. **V3 / hors scope** : SSO entreprise SAML, Logto-IdP SAML, CIMD, JWT customizer scripté, coffre de jetons fédérés, domaines personnalisés, CAPTCHA, stats cloud.
4. Hors `lyxal_auth` : envoi e-mail/SMS et modèles (`lyxal_notification`), traductions (`lyxal_i18n`), webhooks/audit asynchrone (`lyxal_event`), purges planifiées (`lyxal_scheduler`), chiffrement (`lyxal_crypto`).
