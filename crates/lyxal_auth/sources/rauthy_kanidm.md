# Rapport d'analyse — Rauthy & Kanidm pour `lyxal_auth`

> Sources lues (lecture seule) :
> - **Rauthy** `0.37.3` (Apache-2.0) — `sources/rauthy` : 32 migrations Postgres (`migrations/postgres/V1..V32`) et 37 migrations Hiqlite/SQLite (`migrations/hiqlite/1..37`), 12 crates (`src/*`, ~96 000 lignes Rust).
> - **Kanidm** `1.13.0-dev` (MPL-2.0) — `sources/kanidm` : référence de conception uniquement (pas de copie de code).
>
> Chemins relatifs à la racine de chaque dépôt. Rauthy : code réutilisable **avec mention** (en-tête de copyright + `NOTICE`, Apache-2.0 §4).

---

## 1. Rauthy — inventaire complet du modèle de données

### 1.0 Constats transverses

| Constat | Détail | Conséquence pour `lyxal_auth` |
| :--- | :--- | :--- |
| Deux moteurs, même schéma | Postgres (`V*.sql`) et Hiqlite (SQLite Raft, `N_*.sql`) : 54 tables identiques ; Hiqlite ajoute `colors` (table de thème retirée en `4_themes.sql`) et deux tables temporaires `*_dg_tmp` (recréation SQLite). | Le schéma Postgres `V1`+deltas est la référence. Une seule `0001_initial.surql` à l'état cible (régime §0). |
| Identifiants | `varchar` aléatoire alphanumérique 24 car. (`common/src/utils.rs::get_rand`), pas d'UUID. | Utiliser `rand::uuid::v7()` / `RecordId` SurrealDB. |
| Horodatages | `bigint` (secondes Unix ; parfois micros : `created_micros`). | `datetime` SurrealDB. |
| Listes en CSV | `users.roles`, `users.groups`, `clients.redirect_uris`, `scopes`, `flows_enabled`… stockés en chaînes séparées par des virgules. | `array<string>` ou relations (`record<auth_role>`). |
| Blobs sérialisés | `config.data`, `api_keys.access`, `groups.meta`, `clients.claims`, `user_attr_values.value` = `bytea` (bincode/JSON). | `object` / `option<object>` typés et validés par `lyxal_core`. |
| Secrets chiffrés | `clients.secret`, `api_keys.secret`, `jwks.jwk`, `auth_providers.secret`, `clients_scim.bearer_token`, `one_time_password.secret`, `kv_access.secret`, `pam_hosts.secret` : chiffrés par la crate `cryptr` (**ChaCha20-Poly1305**) avec colonne `enc_key_id`/`secret_kid` pour la rotation. | Remplacer par `lyxal_crypto::CryptoEngine::seal` (AES-256-GCM, `enc:v2:<key_id>:…`, `SecretContext::with_tenant`). |
| Données éphémères hors SQL | Codes d'autorisation, device codes, nonces DPoP, état WebAuthn, liste noire IP, rate limits, PoW, OTP en cours, détection credential-stuffing, clients dynamiques/éphémères : **cache distribué Hiqlite** (`data/src/database.rs::enum Cache`, 23 caches). | En SurrealDB : tables à TTL (`expires_at` + purge par worker) ou cache mémoire Rust supervisé. |

### 1.1 Utilisateurs & profil

| Table | Rôle | Champs principaux | Contraintes / index |
| :--- | :--- | :--- | :--- |
| `users` | Compte utilisateur | `id`, `email`, `given_name`, `family_name`, `password` (PHC Argon2id), `roles` (CSV), `groups` (CSV), `enabled`, `email_verified`, `password_expires`, `created_at`, `last_login`, `last_failed_login`, `failed_login_attempts`, `language`, `webauthn_user_id`, `user_expires`, `auth_provider_id`, `federation_uid`, `picture_id` | PK `id` ; `UNIQUE(email)` ; `UNIQUE(webauthn_user_id)` ; `UNIQUE(auth_provider_id, federation_uid)` ; FK `auth_provider_id → auth_providers ON DELETE SET NULL` ; index `created_at` |
| `users_values` | Attributs OIDC standard optionnels (1-1) | `id`(=user), `birthdate`, `phone`, `street`, `zip` (varchar depuis V11), `city`, `country`, `preferred_username`, `tz` | PK/FK `users` CASCADE ; `UNIQUE(preferred_username)` |
| `user_attr_config` | Définition d'attributs personnalisés | `name` (PK), `desc`, `default_value` (bytea), `typ`, `user_editable` | index `user_editable` |
| `user_attr_values` | Valeurs d'attributs personnalisés | `user_id`, `key`, `value` (bytea) | PK `(user_id, key)` ; FK CASCADE vers `users` et `user_attr_config` |
| `pictures` | Avatars | `id`, `content_type`, `storage` (db/fichier/S3), `data` | — |
| `webids` | Profil Solid WebID | `user_id`, `custom_triples` (Turtle), `expose_email` | PK/FK `users` CASCADE |
| `recent_passwords` | Historique pour la règle « pas récemment utilisé » | `user_id`, `passwords` (hashes concaténés) | PK/FK `users` CASCADE |
| `pwd_exp_mails` | Suivi des e-mails « mot de passe bientôt expiré » | `user_id`, `mail_sent_ts` | PK/FK `users` CASCADE |
| `user_revoke` | Code de révocation envoyé par e-mail (« ce n'était pas moi ») | `user_id`, `code` | PK/FK `users` CASCADE |
| `login_locations` | Appareils/lieux connus (alerte « nouvelle localisation ») | `user_id`, `browser_id`, `ip`, `last_seen`, `user_agent`, `location` (GeoIP) | PK `(user_id, ip, browser_id)` ; index `last_seen` |
| `user_consents` | Consentements OAuth par client/ressource | `user_id`, `client_id`, `resource`, `scopes`, `content_hash`, `created`, `updated`, `ip`, `user_agent` | PK `(user_id, client_id, resource)` ; pas de FK `client_id` (clients éphémères) |
| `tos` | Versions des CGU | `ts` (PK), `author`, `is_html`, `opt_until`, `content` | index unique `ts DESC` |
| `tos_user_accept` | Acceptation des CGU | `user_id`, `tos_ts`, `accept_ts`, `location` | PK `(user_id, tos_ts)` ; FK CASCADE |
| `magic_links` | Liens à usage unique (reset mot de passe, vérification e-mail, nouvel utilisateur, changement e-mail) | `id`, `user_id`, `csrf_token`, `cookie`, `exp`, `used`, `usage` | FK `users` CASCADE ; index `exp`, `user_id` |

### 1.2 Groupes, rôles, scopes

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `groups` | Groupes (claim `groups`) | `id`, `name`, `meta` (bytea, V22) | PK `id` |
| `roles` | Rôles (claim `roles` ; `rauthy_admin` = admin) | `id`, `name`, `meta` | PK `id` |
| `scopes` | Scopes OAuth personnalisés et mapping d'attributs | `id`, `name`, `attr_include_access`, `attr_include_id` (CSV d'attributs à injecter dans access/id token), `claims_at_root` | PK `id` ; seeds : `openid`, `email`, `profile`, `groups`, `address`, `phone` |

> Pas de table d'association : appartenance stockée en CSV dans `users.roles/groups`. À remplacer par des relations SurrealDB (`RELATE user->auth_member_of->auth_group`) ou `array<record<…>>`.

### 1.3 Clients OIDC / OAuth2

| Table | Rôle | Champs principaux | Contraintes |
| :--- | :--- | :--- | :--- |
| `clients` | Client OIDC (RP) | `id`, `name`, `enabled`, `confidential`, `secret` (chiffré), `secret_kid`, `redirect_uris`, `post_logout_redirect_uris`, `allowed_origins`, `flows_enabled` (CSV : `authorization_code`, `client_credentials`, `password`, `refresh_token`, `urn:ietf:params:oauth:grant-type:device_code`…), `access_token_alg`, `id_token_alg` (RS256/384/512/EdDSA), `auth_code_lifetime`, `access_token_lifetime`, `scopes`, `default_scopes`, `challenge` (`S256`,`plain`), `force_mfa`, `client_uri`, `contacts`, `backchannel_logout_uri` (V5), `restrict_group_prefix` (V9), `claims` + `claims_at_root` (V25), `allowed_resources` + `default_aud` (V26, RFC 8707), `created_micros` (V31) | PK `id` ; index `client_uri`, `backchannel_logout_uri` |
| `clients_dyn` | Métadonnées des clients enregistrés dynamiquement (RFC 7591/7592) | `id`, `created`, `last_used`, `registration_token` (chiffré), `token_endpoint_auth_method` | PK/FK `clients` CASCADE ; index `last_used` (purge) |
| `clients_scim` | Configuration SCIM sortante d'un client | `client_id`, `bearer_token` (chiffré), `base_endpoint`, `sync_groups`, `group_sync_prefix` | PK/FK `clients` CASCADE |
| `client_logos` | Logos/favicons de client | `client_id`, `res`, `content_type`, `data`, `updated` | PK `(client_id, res)` |
| `themes` | Thème de la page de login par client | `client_id`, `last_update`, `version`, `light`, `dark`, `border_radius` | PK/FK `clients` CASCADE |
| `failed_backchannel_logouts` | File de retry du back-channel logout | `client_id`, `sub`, `sid`, `retry_count` | PK `(client_id, sub, sid)` |
| `failed_scim_tasks` | File de retry SCIM | `client_id`, `action`, `retry_count` | PK `(client_id, action)` |

### 1.4 Sessions & état de connexion

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `sessions` | Session SSO navigateur (cookie `__Host-RauthySession`) | `id`, `csrf_token`, `user_id`, `roles`, `groups`, `is_mfa`, `state` (`Init`/`Auth`/`LoggedOut`), `exp`, `last_seen`, `remote_ip` | FK `users` CASCADE ; index `exp` |
| `user_login_states` | Clients auxquels un utilisateur s'est connecté pendant une session (pour logout RP-initiated / back-channel) | `timestamp`, `user_id`, `client_id`, `session_id` | PK `(timestamp, user_id)` ; UNIQUE `(user_id, client_id, session_id)` ; FK RESTRICT |
| `devices` | Appareils autorisés via device flow | `id`, `client_id`, `user_id`, `created`, `access_exp`, `refresh_exp`, `peer_ip`, `name`, `client_created_micros` | FK CASCADE ; index `(access_exp, refresh_exp)` |

### 1.5 Jetons de renouvellement & jetons émis

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `refresh_tokens` | Refresh tokens (à usage unique, rotation) | `id`, `user_id`, `nbf`, `exp`, `scope`, `is_mfa`, `session_id` (V5), `access_token_jti` (V19), `client_id` + `client_created_micros` (V31) | FK `users` CASCADE ; index `exp`, `user_id`, `session_id`, `access_token_jti`, `(user_id, client_id)` |
| `refresh_tokens_devices` | Refresh tokens liés à un appareil (device flow) | `id`, `device_id`, `user_id`, `nbf`, `exp`, `scope`, `access_token_jti` | FK `devices`/`users` CASCADE |
| `issued_tokens` | Registre des access tokens émis, pour révocation (RFC 7009) | `jti` (PK), `user_id`, `did` (device), `sid` (session), `exp`, `revoked` | index `user_id`, `sid`, `exp` |

> `client_created_micros` permet d'invalider les jetons d'un client supprimé puis recréé sous le même `id`.

### 1.6 Passkeys / WebAuthn & métadonnées FIDO

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `passkeys` | Passkeys d'un utilisateur | `user_id`, `name`, `passkey_user_id`, `passkey` (JSON `webauthn_rs::Passkey`), `credential_id`, `registered`, `last_used`, `user_verified`, `resident_key` (V28), `aaguid` (V30) | PK `(user_id, name)` ; UNIQUE `credential_id` ; FK `aaguid → fido_mds_entries SET NULL` |
| `fido_mds_metadata` | Version du blob FIDO MDS3 | `current_blob_no`, `next_update` | PK |
| `fido_mds_certs` | Certificats d'attestation | `hash`, `cert_der` | PK `hash` |
| `fido_mds_entries` | Authentificateurs connus (AAGUID) | `aaguid`, `description`, `key_protection`, `attachment_hint`, `attestation_types`, `cert_level` | PK `aaguid` |
| `fido_mds_entry_certs` | Lien entrée ↔ certificat | `aaguid`, `cert_hash` | PK composite ; FK CASCADE |

### 1.7 MFA (hors passkeys)

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `one_time_password` | Facteurs OTP : `kind` = `email`, `phone`, `time` (TOTP) | `id`, `user_id`, `name`, `secret` (chiffré), `last_used` (anti-rejeu), `kind`, `is_active` | FK `users` CASCADE ; index `user_id` |

### 1.8 Clés de signature JWKS

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `jwks` | Paires de clés de signature (privée chiffrée) | `kid`, `created_at`, `signature` (`RS256`/`RS384`/`RS512`/`EdDSA`), `enc_key_id`, `jwk` (PKCS#8 DER chiffré) | PK `kid` ; index `(signature, created_at)` |

### 1.9 Fournisseurs amont (fédération)

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `auth_providers` | IdP amont (Google, GitHub, OIDC générique, Custom) | `id`, `enabled`, `name`, `typ`, `issuer`, `authorization_endpoint`, `token_endpoint`, `userinfo_endpoint`, `jwks_endpoint` (V4), `client_id`, `secret` (chiffré), `scope`, `admin_claim_path/value`, `mfa_claim_path/value` (JSONPath), `use_pkce`, `client_secret_basic`, `client_secret_post`, `auto_onboarding`, `auto_link` (V14) | PK `id` ; index `issuer` |
| `auth_provider_logos` | Logos des IdP | `auth_provider_id`, `res`, `content_type`, `data`, `updated` | PK composite ; FK CASCADE |

### 1.10 API keys

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `api_keys` | Clés d'API d'administration | `name` (PK), `secret` (chiffré), `created`, `expires`, `enc_key_id`, `access` (bytea : liste `{group, access_rights}` — groupes `Users`, `Clients`, `Groups`, `Roles`, `Sessions`, `Events`, `Blacklist`, `Secrets`, `ApiKeys`, `AuthProviders`, `Pam`… × droits `read/create/update/delete`) | index `enc_key_id`, `expires` |

### 1.11 Événements / audit

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `events` | Journal d'événements de sécurité | `id`, `timestamp`, `typ` (25 types : `InvalidLogins`, `IpBlacklisted`, `JwksRotated`, `NewUserRegistered`, `NewRauthyAdmin`, `UserPasswordReset`, `UserEmailChange`, `ForcedLogout`, `UserLoginRevoke`, `SuspiciousApiScan`, `LoginNewLocation`, `TokenIssued`, `CredentialStuffing`, `BackchannelLogoutFailed`, `ScimTaskFailed`, `ConsentRevoked`…), `level` (`Info`/`Notice`/`Warning`/`Critical`), `ip`, `data`, `text` | PK `(id, timestamp)` ; index `timestamp DESC` |

### 1.12 Configuration, stockage générique, e-mails

| Table | Rôle | Champs |
| :--- | :--- | :--- |
| `config` | Configuration dynamique clé → blob (ex. `password_policy`) | `id`, `data` |
| `kv_ns` / `kv_values` / `kv_access` | Magasin clé-valeur générique par espace de noms, valeurs éventuellement chiffrées, accès par secret | `ns`, `public` / `ns`, `key`, `encrypted`, `value` / `id`, `ns`, `secret`, `enabled`, `name` |
| `email_jobs` | Campagnes d'e-mails aux utilisateurs (filtrées, planifiées) | `id`, `scheduled`, `status`, `updated`, `last_user_ts`, `filter`, `content_type`, `subject`, `body` |

### 1.13 Autres : PAM / SSH (hors périmètre probable)

| Table | Rôle |
| :--- | :--- |
| `pam_groups` | Groupes POSIX (gid ≥ 100 000) |
| `pam_hosts`, `pam_hosts_ips`, `pam_hosts_aliases` | Hôtes Linux autorisés (secret chiffré, `force_mfa`, `local_password_only`) |
| `pam_users`, `pam_rel_groups_users` | Comptes POSIX liés à `users.email`, shell, `home_dir`, appartenance et `wheel` |
| `ssh_auth_keys`, `ssh_auth_keys_used` | Clés SSH autorisées (expiration) et anti-rejeu |

---

## 2. Rauthy — inventaire des fonctionnalités (chemins `src/`)

### 2.1 OIDC / OAuth 2.x

| Fonctionnalité | Chemins | Notes |
| :--- | :--- | :--- |
| Authorization Code + PKCE (`S256`, `plain` configurable par client) | `service/src/oidc/authorize.rs`, `service/src/oidc/grant_types/authorization_code.rs`, `service/src/oidc/validation.rs`, `data/src/entity/auth_codes.rs` | Code stocké en cache, nonce, `state`, `resource` (RFC 8707) |
| Refresh token (rotation à usage unique, invalidation si client différent) | `service/src/oidc/grant_types/refresh_token.rs`, `service/src/oidc/validation.rs::validate_and_refresh_token`, `data/src/entity/refresh_tokens.rs` | `find_delete` = rotation ; le RT ne peut pas élargir la ressource |
| Client Credentials | `service/src/oidc/grant_types/client_credentials.rs` | |
| Resource Owner Password (déconseillé) | `service/src/oidc/grant_types/password.rs` | |
| Device Authorization Grant (RFC 8628) | `service/src/oidc/grant_types/device_code.rs`, `api/src/oidc.rs` (`/oidc/device`, `/oidc/device/verify`), `data/src/entity/devices.rs`, `data/src/entity/ip_rate_limit.rs` | Rate limit par IP |
| Token Exchange (RFC 8693) | `service/src/oidc/grant_types/token_exchange.rs` | |
| DPoP (RFC 9449) | `data/src/entity/dpop_proof.rs` | Nonces en cache, `cnf` dans les jetons |
| Introspection (RFC 7662), Userinfo, Révocation (RFC 7009) | `service/src/oidc/token_info.rs`, `userinfo.rs`, `token_revocation.rs` ; routes `/oidc/introspect`, `/oidc/userinfo`, `/oidc/token/revoke` | Révocation via `issued_tokens` |
| Discovery & JWKS | `data/src/entity/well_known.rs`, `data/src/entity/jwk.rs` ; `/.well-known/openid-configuration`, `/.well-known/oauth-authorization-server`, `/oidc/certs` | |
| Logout RP-initiated + Back-Channel Logout | `service/src/oidc/logout.rs`, `service/src/oidc/bcl_logout_token.rs`, `schedulers/src/backchannel_logout.rs` | Retry dans `failed_backchannel_logouts` |
| Dynamic Client Registration (RFC 7591/7592) | `api/src/clients.rs` (`/clients_dyn`), `data/src/entity/clients_dyn.rs`, `schedulers/src/dyn_clients.rs` | Purge des clients inactifs |
| Clients éphémères (client_id = URL de document JSON) | `data/src/entity/clients.rs` (`is_ephemeral`), config `[ephemeral_clients]` | Type « Solid / CIMD » |
| Consentements | `data/src/entity/user_consents.rs`, `api/src/users.rs` (`/users/{id}/consents`) | |
| Claims personnalisés, audiences, scopes → attributs | `data/src/entity/scopes.rs`, `data/src/entity/clients.rs`, `src/jwt/src/claims.rs`, `service/src/token_set.rs` | |
| Forward-auth (reverse-proxy) | `service/src/forward_auth.rs`, `data/src/entity/forward_auth.rs`, `/oidc/forward_auth` | |
| FedCM (navigateur) | `api/src/fed_cm.rs`, `data/src/entity/fed_cm.rs` | |
| Connexion ATProto (Bluesky) | `api/src/atproto.rs`, `data/src/entity/atproto.rs` | |

### 2.2 Authentification & comptes

| Fonctionnalité | Chemins | Notes |
| :--- | :--- | :--- |
| Hachage Argon2id avec pool de threads dédié + mesure des temps | `common/src/password_hasher.rs`, `api/src/generic.rs` (`/password_hash_times`) | Canal `flume`, paramètres globaux `ARGON2_PARAMS` |
| Politique de mot de passe | `data/src/entity/password.rs` (`PasswordPolicy` : `length_min/max`, `include_lower/upper/digits/special`, `valid_days`, `not_recently_used`), `/password_policy` | Stockée dans `config` |
| Passkeys (inscription, authentification, clés résidentes / discoverable) | `data/src/entity/webauthn/{register,authenticate,authenticate_rk,ceremony,passkey,rk_token,aaguid}.rs`, routes `/users/{id}/webauthn/*`, `/users/webauthn_start|finish` | `webauthn-rs 0.5` |
| Comptes sans mot de passe (passkey-only) | `api/src/users.rs` (`/users/{id}/self/convert_passkey`) | |
| MFA : passkey comme 2e facteur, TOTP, OTP e-mail/téléphone | `data/src/entity/one_time_password.rs`, routes `/users/{id}/otp`, `/users/otp_start|resend|finish`, `data/src/entity/mfa_mod_token.rs`, `mfa_cookie.rs` | `force_mfa` par client, MFA imposée via claim IdP amont |
| Inscription libre + vérification e-mail | `api/src/users.rs` (`/users/register`), `data/src/entity/magic_links.rs` | PoW anti-bot |
| Réinitialisation de mot de passe / changement d'e-mail | `service/src/password_reset.rs`, `/users/request_reset`, `/users/{id}/reset/*`, `/users/{id}/email_confirm/*` | Liens magiques |
| « Ce n'était pas moi » (révocation par lien e-mail) | `data/src/entity/user_revoke.rs`, `/users/{id}/revoke/{code}` | |
| Expiration de comptes / mots de passe | `schedulers/src/users.rs`, `schedulers/src/passwords.rs`, `data/src/entity/pwd_exp_mails.rs` | |
| CGU versionnées | `data/src/entity/tos.rs`, `tos_user_accept.rs`, `api/src/tos.rs` | |
| Attributs utilisateurs personnalisés & valeurs OIDC | `data/src/entity/user_attr.rs`, `users_values.rs`, `service/src/user_values_validator.rs` | |
| Suppression de compte en libre-service | `/users/{id}/self/delete` | |

### 2.3 Sessions & révocation

| Fonctionnalité | Chemins |
| :--- | :--- |
| Sessions SSO + CSRF | `data/src/entity/sessions.rs`, `middlewares/src/csrf_protection.rs`, `middlewares/src/principal.rs` |
| Administration des sessions (liste, révocation par utilisateur / par id) | `api/src/sessions.rs` |
| Purge des sessions/jetons expirés | `schedulers/src/sessions.rs`, `tokens.rs`, `issued_tokens.rs`, `devices.rs`, `user_login_states.rs`, `magic_links.rs` |
| Révocation des jetons émis (jti) | `data/src/entity/issued_tokens.rs`, `service/src/oidc/token_revocation.rs` |
| Identifiant navigateur + nouvelle localisation | `data/src/entity/browser_id.rs`, `login_locations.rs`, `data/src/ipgeo/maxmind.rs` |

### 2.4 Fournisseurs amont

| Fonctionnalité | Chemins |
| :--- | :--- |
| Login via Google, GitHub, OIDC générique, Custom (PKCE, JWKS amont, mapping admin/MFA par JSONPath) | `service/src/oidc/auth_providers/{login_start,login_finish}.rs`, `data/src/entity/auth_providers.rs`, `auth_provider_cust_impls.rs`, `api/src/auth_providers.rs` |
| Auto-onboarding, liaison/déliaison de compte | `auth_providers.auto_onboarding/auto_link`, `/providers/{id}/link`, `/providers/link` |

### 2.5 Provisioning, notifications, événements

| Fonctionnalité | Chemins | Notes |
| :--- | :--- | :--- |
| SCIM v2 **sortant** (Rauthy pousse utilisateurs/groupes vers les clients) | `data/src/entity/clients_scim.rs`, `scim_types.rs`, `schedulers/src/scim_tasks.rs` | Pas de serveur SCIM entrant |
| Journal d'événements + flux SSE + notifications (e-mail, Matrix, Slack) | `data/src/events/{event,listener,notifier,health_watch}.rs`, `api/src/events.rs` (`/events/stream`), `notify/src/{matrix,slack}.rs`, `schedulers/src/events.rs` | Niveaux et seuils configurables |
| E-mails transactionnels et campagnes | `data/src/email/`, `data/src/entity/email_jobs.rs`, `email_rate_limit.rs`, `schedulers/src/email_jobs.rs` | |

### 2.6 Sécurité opérationnelle

| Fonctionnalité | Chemins |
| :--- | :--- |
| Bannissement d'IP (liste noire en cache, API admin) | `data/src/entity/ip_blacklist.rs`, `middlewares/src/ip_blacklist.rs`, `api/src/blacklist.rs` |
| Délai de login progressif / temps constant | `service/src/login_delay.rs`, `data/src/entity/failed_login_counter.rs` |
| Détection de credential stuffing (SHA-256 de `email/password` par IP → blacklist) | `data/src/entity/cred_stuff_detect.rs` |
| Blocage des scans d'API suspects | `service/src/suspicious_request_block.rs` |
| Proof-of-Work anti-bot (`spow`) | `data/src/entity/pow.rs`, `/pow` |
| Rotation JWKS planifiée | `data/src/entity/jwk.rs::JWKS::rotate`, `schedulers/src/jwks.rs` |
| Rotation de la clé de chiffrement des secrets | `service/src/encryption.rs::migrate_encryption_alg`, `/encryption/migrate` |
| API keys à droits fins | `data/src/entity/api_keys.rs`, `api/src/api_keys.rs`, `middlewares/src/principal.rs` |
| Sauvegardes (local/S3) | `api/src/backup.rs` |

### 2.7 Autres

| Fonctionnalité | Chemins |
| :--- | :--- |
| PAM / NSS / clés SSH Linux | `api/src/pam.rs`, `data/src/entity/pam/*`, `schedulers/src/authorized_keys.rs` |
| Magasin KV générique | `api/src/kv.rs`, `data/src/entity/kv.rs` |
| Thèmes, logos, i18n | `api/src/themes.rs`, `data/src/entity/{theme,logos}.rs`, `data/src/language.rs` |
| OpenAPI (utoipa) | `api/src/openapi.rs` |
| Client Rust pour RP (hors workspace) | `rauthy-client/src/` (provider, device_code, backchannel_logout, scim, principal) |

---

## 3. Rauthy — dépendances crates clés

### 3.1 Dépendances crypto / identité (workspace `Cargo.toml`, utilisées par crate)

| Crate | Version | Crates Rauthy | Usage | Recouvrement `lyxal_crypto` |
| :--- | :--- | :--- | :--- | :--- |
| `argon2` | 0.6 | `common`, `data`, `bin`, `error` | Hachage mots de passe Argon2id | **Oui** → `lyxal_crypto::password::{hash_password, verify_password}` |
| `cryptr` | 0.12 | `api`, `bin`, `data`, `service`, `error` | Chiffrement des secrets en base (ChaCha20-Poly1305, clés `ENC_KEYS`/`ENC_KEY_ACTIVE`) | **Oui** (fonction) → `CryptoEngine::seal/open` AES-256-GCM ; ChaCha20 hors périmètre |
| `chacha20poly1305` | 0.11 | `error` | Via `cryptr` | **Hors périmètre** (CTO) |
| `hmac-sha256` / `hmac-sha512` | 1.1 | `data` | SHA-256/384/512 pour signatures RSA et HMAC | **Oui** pour SHA-256/HMAC-SHA256 ; SHA-384/512 non couverts |
| `ring` | 0.17 | `common`, `data`, `service`, `error` | Hash SHA-256 (`sha256!`), aléa | **Oui** → `lyxal_crypto::hash::sha256` |
| `rsa` (+ `sha2`) | 0.9 | `data`, `error` | Génération/signature RS256/384/512 (PKCS#1 v1.5) | **Non couvert** (asymétrique) |
| `ed25519-compact` | 2.0 | `data`, `error` | Signature EdDSA des jetons (**algorithme par défaut**) | **Hors périmètre** (Ed25519 = validation CTO) |
| `openssl` (vendored) | 0.10 | toutes | TLS/x509 annexes | Non |
| `rcgen` | 0.14 | `data` | Certificats auto-signés (CA interne) | Non |
| `constant_time_eq` | 0.6 | `api`, `data`, `service` | Comparaisons de secrets | À fournir par `lyxal_crypto` (vérif. HMAC/mots de passe) |
| `rand` 0.10 / `rand_core` 0.10 / `rand 0.8` | — | `common`, `data` | `rand::rng()` pour identifiants ; `rand_08::thread_rng()` pour RSA | **Contraire à la règle** `OsRng` |
| `zeroize` | 1.8 | plusieurs | Effacement mémoire | Couvert par `SecretBytes/SecretString` |
| `webauthn-rs` (`danger-allow-state-serialisation`, `danger-credential-internals`, `resident-key-support`) + `webauthn-rs-proto` | 0.5 | `data`, `api_types` | Passkeys | Hors `lyxal_crypto` (dépendance protocolaire à valider CTO) |
| `serde_cbor_2` | 0.13 | `data` | Parsing CBOR WebAuthn / FIDO MDS | Non |
| `spow` | 0.7 | `api`, `bin`, `data` | Proof-of-Work | Non |
| `atrium-*` | 0.2/0.26 | `data`, `service` | Login ATProto | Non |
| `hiqlite`, `tokio-postgres`, `deadpool-postgres`, `rusqlite` | — | `data`… | Persistance | Remplacé par SurrealDB |

### 3.2 JWT, OIDC, algorithmes

| Point | Constat |
| :--- | :--- |
| Bibliothèque JWT | **Aucune** (pas de `jsonwebtoken`/`josekit`) : implémentation maison `src/jwt/src/token.rs` (`JwtToken::build`, `validate_claims_into`) + `data/src/entity/jwk.rs` (`JwkKeyPair::sign/verify_token`) |
| Algorithmes de signature | `RS256`, `RS384`, `RS512`, `EdDSA`/`Ed25519` (RFC 8812/9864) — `jwk.rs::JwkKeyPairAlg`. Défaut : **EdDSA** (clients seed `rauthy`, `init_client`). **Pas d'ECDSA (ES256), pas de HS256.** |
| Rotation JWKS | `JWKS::rotate` génère un jeu complet (RSA 2048/3072/4096 + Ed25519), clé privée chiffrée, `kid` aléatoire 24 car. |
| En-tête | `typ` = `JWT` (ID/refresh/logout) ou `at+jwt` (access, RFC 9068) |
| Bibliothèque OIDC | Aucune crate tierce côté serveur ; implémentation directe des RFC |

> **Point bloquant CTO** : aucun algorithme JWS standard n'est réalisable avec les primitives actuelles de `lyxal_crypto` si les jetons doivent être vérifiables par des tiers via JWKS. HS256 (HMAC-SHA256) est possible mais impose le partage du secret (inutilisable pour un IdP OIDC public). Il faut une décision CTO : **EdDSA (Ed25519)** — le plus simple, défaut de Rauthy — ou **ES256/RS256** (compatibilité maximale, choix par défaut de Kanidm = ES256).

---

## 4. Rauthy — code le plus intéressant à reprendre (stockage SurrealDB)

| Priorité | Élément | Chemin | Ce qu'on reprend | Adaptation Lyxal |
| :--- | :--- | :--- | :--- | :--- |
| ★★★ | Modèle de données | `migrations/postgres/V1..V32` | Schéma des §1.1–1.11 | `0001_initial.surql` SCHEMAFULL, relations au lieu de CSV, `datetime`, `record<>` |
| ★★★ | Validation authorize / PKCE / redirect_uri | `service/src/oidc/validation.rs`, `service/src/oidc/authorize.rs`, `data/src/entity/auth_codes.rs` | Logique RFC 6749/7636/8707 | Règles de données en SurrealQL (`fn::auth_*`), validation d'entrée via `lyxal_core` |
| ★★★ | Rotation des refresh tokens et liens session/jti | `service/src/oidc/validation.rs::validate_and_refresh_token`, `data/src/entity/refresh_tokens.rs` (`discard_txn`), `issued_tokens.rs` | Usage unique, invalidation sur client incohérent, révocation par session | Transaction SurrealQL unique `fn::auth_refresh_rotate` |
| ★★★ | Machine d'état passkeys | `data/src/entity/webauthn/*.rs` | Cérémonies register/auth/rk, sérialisation de l'état | État en table TTL ; `webauthn-rs` à faire valider |
| ★★ | Construction/validation JWT sans dépendance | `src/jwt/src/token.rs`, `src/jwt/src/claims.rs` | Format compact, limites de taille, `typ`, compatibilité `alg/kid` | Signature déléguée à `lyxal_crypto` (après décision CTO) |
| ★★ | Gestion JWKS | `data/src/entity/jwk.rs` (`rotate`, `find_latest`, cache, `JWKSPublicKey::fetch_remote`) | Rotation, publication, validation de JWKS amont | Clés privées scellées `enc:v2`, `SecretContext::global("auth.jwks")`, worker `LyxalWorker` |
| ★★ | Politique de mot de passe | `data/src/entity/password.rs` | Champs + contrôle `not_recently_used` | Contrôles de format via `lyxal_core` ; historique en table dédiée |
| ★★ | Protection brute-force | `service/src/login_delay.rs`, `data/src/entity/cred_stuff_detect.rs`, `ip_blacklist.rs`, `failed_login_counter.rs` | Délai adaptatif, détection credential stuffing, bannissement temporaire | Tables TTL SurrealDB ; hash via `lyxal_crypto::hash` |
| ★★ | Fédération amont | `service/src/oidc/auth_providers/{login_start,login_finish}.rs`, `data/src/entity/auth_providers.rs` | PKCE amont, mapping claims, liaison de comptes | Secret amont scellé |
| ★★ | Événements de sécurité | `data/src/events/event.rs` (types, niveaux) | Catalogue d'événements | Émission via `fn::event_publish` (`auth.user.registered`, `auth.jwks.rotated`…) |
| ★ | API keys à droits fins | `data/src/entity/api_keys.rs` | Modèle `group × rights` | Secret haché/HMAC, pas chiffré |
| ★ | Back-channel logout + retries | `service/src/oidc/bcl_logout_token.rs`, `schedulers/src/backchannel_logout.rs` | | Worker supervisé |
| ★ | Device flow, DCR, DPoP, token exchange | `service/src/oidc/grant_types/*.rs`, `data/src/entity/dpop_proof.rs` | V2+ | |
| ★ | Planificateurs de purge | `schedulers/src/*.rs` | Liste exhaustive des purges | `LyxalWorker` + `CancellationToken` (pas de `tokio::spawn` sauvage) |

**À ne pas reprendre tel quel** : `cryptr`/ChaCha20, `rand_08::thread_rng()` (RSA), `ring`/`hmac-sha*` directs, `.unwrap()`/`expect()` dans les chemins de rotation (`jwk.rs`, `From<Row>`), stockage CSV, cache Hiqlite.

---

## 5. Kanidm — modèle conceptuel et fonctionnalités (référence de conception, MPL-2.0)

### 5.1 Modèle « entrée / classe / attribut » (type LDAP)

| Concept | Description | Fichiers de référence |
| :--- | :--- | :--- |
| **Entrée** (`Entry`) | Objet unique identifié par UUID, porteur d'attributs multivalués typés (`ValueSet`) ; cycle de vie *live → recycled → tombstone*, réplication par CID | `server/lib/src/entry.rs`, `value.rs`, `valueset/`, `server/recycle.rs`, `repl/` |
| **Classe** (`SchemaClass`) | Définit `systemmust` / `systemmay` ; une entrée cumule plusieurs classes | `server/lib/src/schema.rs`, `migration_data/dl_1_13/schema.rs` |
| **Attribut** (`SchemaAttribute`) | Syntaxe typée (`Utf8String`, `EmailAddress`, `Credential`, `Session`, `Oauth2Session`, `SshKey`…), `indexed`, `unique`, `multivalue` | `proto/src/attribute.rs`, `migration_data/*/schema.rs` |
| **Plugins d'intégrité** | `refint` (intégrité référentielle), `memberof` (appartenance transitive), `dyngroup`, `attrunique`, `session` (cohérence/expiration des sessions), `namehistory`, `keyobject`… | `server/lib/src/plugins/*.rs` |
| **Contrôle d'accès** | Profils d'accès déclaratifs (search/modify/create/delete) ciblant des filtres | `server/lib/src/server/access/`, `migration_data/dl_1_13/access.rs` |

Classes principales (extraites de `migration_data/dl_1_13/schema.rs`) :

| Classe | MUST | MAY (extrait) |
| :--- | :--- | :--- |
| `Account` | `DisplayName`, `Spn` | `AccountExpire`, `AccountValidFrom`, `NameHistory`, `AccountSoftlockExpire` |
| `Person` | `Name` | `PrimaryCredential`, `PassKeys`, `AttestedPasskeys`, `CredentialUpdateIntentToken`, `SshPublicKey`, `UserAuthTokenSession`, `OAuth2Session`, `OAuth2ConsentScopeMap`, `Mail`, `LegalName`, `ApplicationPassword`, `PasswordChangedTime` |
| `ServiceAccount` | `Name` | `ApiTokenSession`, `PrimaryCredential`, `SshPublicKey` |
| `Group` / `DynGroup` | `Spn` / `DynGroupFilter` | `Member`, `Mail`, `Description` / `DynMember` |
| `AccountPolicy` (appliquée via un groupe) | — | `AuthSessionExpiry`, `PrivilegeExpiry`, `AuthPasswordMinimumLength`, `CredentialTypeMinimum`, `WebauthnAttestationCaList`, `AllowPrimaryCredFallback` |
| `OAuth2ResourceServer` (+ `Basic` confidentiel / `Public`) | `OAuth2RsOriginLanding`, `Name` | `OAuth2RsScopeMap`, `OAuth2RsSupScopeMap`, `OAuth2RsClaimMap`, `OAuth2RsOrigin`, `OAuth2StrictRedirectUri`, `OAuth2DeviceFlowEnable`, `OAuth2ConsentPromptEnable`, `OAuth2RefreshTokenExpiry`, `OAuth2JwtLegacyCryptoEnable` ; `Basic` : `OAuth2RsBasicSecret`, `OAuth2AllowInsecureClientDisablePkce` |
| `OAuth2Client` / `OAuth2Account` | Fédération amont (IdP externe) | endpoints, `OAuth2AccountUniqueUserId/Sub` |
| `KeyProvider` / `KeyObject*` | Objets de clés : `JwtEs256`, `JwtRs256`, `JwtHs256`, `JweA128GCM`, `JweA256GCM`, `HkdfS256` | `server/lib/src/server/keys/` |
| `SystemConfig`, `DomainInfo` | Badlist de mots de passe, durées de session, nom de domaine | |
| `PosixAccount` / `PosixGroup`, `Application`, `ClientCertificate`, `AccountSignupRequest`, `OutboundMessage`, `Memorial`, `AssertionNonce` | | |

### 5.2 Credentials, sessions, jetons

| Élément | Modèle Kanidm | Fichier |
| :--- | :--- | :--- |
| Credential primaire | `enum CredentialType { Password, GeneratedPassword, PasswordMfa(Password, TOTP map, SecurityKey map, BackupCodes), Webauthn(Passkeys) }` — un seul credential primaire typé, MFA intégrée | `server/lib/src/credential/mod.rs`, `totp.rs`, `apppwd.rs` |
| Hachage | `kanidm_lib_crypto` : `Kdf::{ARGON2ID, TPM_ARGON2ID, PBKDF2…}` (formats legacy pour import) | `libs/crypto/src/lib.rs` |
| Verrouillage | Soft-lock à états, backoff par credential (pas par IP) | `server/lib/src/credential/softlock.rs` |
| Mise à jour de credentials | Session de mise à jour transactionnelle + jeton d'intention (invitation/reset) | `server/lib/src/idm/credupdatesession.rs` |
| Session utilisateur (`UserAuthTokenSession`) | `Session { label, state: RevokedAt|ExpiresAt|NeverExpires, issued_at, issued_by, cred_id, scope: ReadOnly|ReadWrite|PrivilegeCapable, type_ }` stockée **comme valeur d'attribut de l'entrée personne** | `server/lib/src/value.rs` (l. ~1100–1320) |
| Session OAuth2 | `Oauth2Session { parent (session utilisateur), state, issued_at, rs_uuid }` — révocation en cascade parent → enfants | `value.rs`, `plugins/session.rs` |
| Jetons d'API | `ApiToken { label, expiry, issued_at, issued_by, scope }` sur les comptes de service | `value.rs`, `idm/serviceaccount.rs` |
| Ré-authentification / privilèges temporaires | `PrivilegeExpiry`, `idm/reauth.rs` | |

### 5.3 Fonctionnalités notables

| Fonctionnalité | Fichiers |
| :--- | :--- |
| OAuth2/OIDC : Authorization Code + PKCE obligatoire (sauf dérogation explicite), Refresh, Client Credentials, Token Exchange, Device Code, consentement, scope maps par groupe, claim maps | `server/lib/src/idm/oauth2.rs`, `proto/src/oauth2.rs` (`GrantTypeReq`) |
| JWT via `compact_jwt` : **ES256 par défaut**, RS256 « legacy » activable par client, HS256 interne, JWE A128/A256GCM | `server/lib/src/server/keys/`, `Cargo.toml` |
| Passkeys et passkeys attestées (liste CA d'attestation par politique) | `webauthn-rs 0.6.2`, `credential/`, `idm/credupdatesession.rs` |
| Politiques de compte héritées des groupes | `server/lib/src/idm/accountpolicy.rs` |
| Liste de mots de passe interdits (rockyou) | `server/lib/src/constants/rockyou_3_10.json` |
| SCIM (serveur, sync entrant), LDAP en lecture, RADIUS, PAM/NSS Unix | `idm/scim.rs`, `libs/scim_proto`, `idm/ldap.rs`, `idm/radius.rs`, `unix_integration/` |
| Audit, recycle bin, historique de noms, réplication multi-nœuds | `idm/audit.rs`, `server/recycle.rs`, `plugins/namehistory.rs`, `repl/` |
| Fédération OAuth2 amont | `idm/oauth2_client.rs`, `idm/authsession/handler_oauth2_client.rs` |

### 5.4 Idées de conception à retenir pour `lyxal_auth`

| Idée Kanidm | Transposition SurrealDB |
| :--- | :--- |
| Sessions OAuth2 enfants d'une session SSO, révocation en cascade | Relation `auth_oauth_session.parent → auth_session` + `DEFINE EVENT` de révocation |
| État de session ordonné `RevokedAt < ExpiresAt < NeverExpires` | Champ `state` + `revoked_at`/`expires_at` |
| Politiques de compte attachées à des groupes | Table `auth_account_policy` liée à `auth_group` |
| Soft-lock par credential | Compteur + `locked_until` par facteur |
| Credential primaire typé (enum) plutôt que colonnes éparses | `credential.kind` + objet typé, MFA rattachée |
| Objets de clés par usage (JWS, JWE, HKDF) avec fournisseur | Table `auth_signing_key` avec `usage`, `alg`, `status`, scellée par `lyxal_crypto` |
| PKCE obligatoire par défaut | Rejeter `plain` et l'absence de PKCE sauf dérogation explicite |
