# Rapport d'analyse — Ory Kratos & Keycloak pour `lyxal_auth`

> Sources analysées (licence Apache-2.0, réutilisation de conception et de code possible avec mention « Portions inspired by / derived from Ory Kratos (© Ory Corp) / Keycloak (© Red Hat, Inc.), Apache-2.0 ») :
> - **Ory Kratos** (Go) — `sources/kratos` : `persistence/sql/migrations/sql/` (≈3 480 fichiers, dernière migration `20260703…`), structs Go `identity/`, `session/`, `selfservice/`, `courier/`, `continuity/`, `embedx/*.schema.json`.
> - **Keycloak** (Java) — `sources/keycloak` : le dépôt est un clone partiel (`blob:none`) dont la liste sparse-checkout est **vide** (aucun fichier de `model/jpa` ni `server-spi*` dans l'arbre de travail). Les fichiers ont été lus via `git show HEAD:<chemin>` (récupération paresseuse des blobs dans `.git/objects`, arbre de travail inchangé) : 78 entités JPA de `model/jpa/src/main/java` et 30 interfaces/modèles de `server-spi` / `server-spi-private`.
>
> Pour Kratos, l'« état final » des tables est établi à partir des **structs Go à tags `db:"…"`** (qui reflètent le schéma courant utilisé par le persister Pop) recoupés avec les migrations (index uniques, clés étrangères, ajouts récents).

---

## Partie 1 — Kratos : modèle de données (état final)

### 1.0. Conventions transverses Kratos

| Convention | Détail |
| :--- | :--- |
| Clé primaire | `id UUID` (v4) sur toutes les tables. |
| Multi-locataire | Colonne **`nid UUID NOT NULL`** sur *toutes* les tables métier, FK → `networks(id)` `ON DELETE CASCADE`. Toutes les requêtes du persister filtrent `WHERE nid = ?` ; les index composites commencent par `nid` (ex. `(nid, identifier)`). La table `networks` (`id, created_at, updated_at`) est le registre des locataires. |
| Horodatage | `created_at`, `updated_at` partout ; `expires_at` / `issued_at` sur les objets éphémères. |
| JSON | Données souples en JSON(B) : `traits`, `metadata_*`, `config` des credentials, `ui` et `internal_context` des flux. |
| Tables historiques | `selfservice_*_requests`, `*_request_methods`, `selfservice_profile_management_*`, tables `_*_tmp` : **renommées/supprimées** par des migrations ultérieures (ancienne nomenclature « request » → « flow »). Non reprises ci-dessous. |
| Organisation (B2B) | `organization_id UUID NULL` sur `identities`, `selfservice_login_flows`, `selfservice_registration_flows`, `selfservice_settings_flows` (migrations `20230907…`, `20260430…`). |

### 1.1. Domaine Identités

| Table | Rôle | Champs (état final) | Contraintes / index notables |
| :--- | :--- | :--- | :--- |
| `identities` | Personne/compte. Les attributs de profil (« traits ») sont un document JSON validé par un **schéma d'identité JSON** référencé par `schema_id`. | `id`, `nid`, `schema_id`, `traits` (JSON), `state` (`active`/`inactive`), `state_changed_at`, `metadata_public` (JSON, lisible par l'utilisateur), `metadata_admin` (JSON, admin uniquement), `available_aal` (`aal0`/`aal1`/`aal2`, AAL max atteignable selon les credentials configurés), `external_id` (identifiant d'un système tiers), `organization_id`, `created_at`, `updated_at` | Unique partiel `(nid, external_id) WHERE external_id IS NOT NULL` (`identities_nid_external_id_idx`). |
| `identity_pending_traits_changes` | Changement d'adresse (e-mail/téléphone) **en attente de vérification** : les traits proposés ne sont appliqués qu'après vérification de la nouvelle adresse. | `id`, `nid`, `identity_id`, `new_address_value`, `new_address_via`, `original_traits_hash` (détection de modification concurrente), `proposed_traits` (JSONB), `verification_flow_id`, `status` (`pending`…), `session_id`, `origin_settings_flow_id`, `created_at`, `updated_at` | FK identité, réseau, flux de vérification (CASCADE). **Unique partiel `(nid, identity_id) WHERE status='pending'`** : un seul changement en attente par identité. |

Code : `identity/identity.go`, `identity/pending_traits_change.go`, `identity/manager.go`, `identity/validator.go`, `identity/handler_import.go` (import en masse, y compris hash de mots de passe existants).

### 1.2. Domaine Credentials et identifiants

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `identity_credential_types` | Référentiel des types de credentials (seed). | `id`, `name` | Unique `name`. Valeurs : `password`, `oidc`, `totp`, `lookup_secret`, `webauthn`, `code`, `passkey`, `profile`, `saml`, `deviceauthn` (+ types virtuels `link_recovery`, `code_recovery`, `identifier_first`). |
| `identity_credentials` | Un credential d'une identité, d'un type donné ; la configuration spécifique au type est un JSON. | `id`, `nid`, `identity_id`, `identity_credential_type_id`, `config` (JSON), `version` (version du format de config), `created_at`, `updated_at` | FK identité (CASCADE) ; un seul credential par (identité, type) en pratique (map `Credentials[type]`). |
| `identity_credential_identifiers` | **Identifiants de connexion** extraits du credential (e-mail, username, `provider:subject` OIDC, user handle WebAuthn…), indexés pour la recherche au login. | `id`, `nid`, `identifier`, `identity_id`, `identity_credential_id`, `identity_credential_type_id`, `created_at`, `updated_at` | **Unique `(nid, identity_credential_type_id, identifier)`** : un identifiant n'appartient qu'à une identité par type et par locataire. `identity_id` ajouté en `20251104…` (dénormalisation). |

Contenu de `config` par type (structs `identity/credentials_*.go`) :

| Type | Champs JSON de `config` |
| :--- | :--- |
| `password` | `hashed_password` (PHC : argon2id, bcrypt, pbkdf2, scrypt… — `hash/hasher_*.go`), `use_password_migration_hook` (migration paresseuse depuis un système externe). |
| `oidc` | `providers[]` : `subject`, `provider`, `organization`, `initial_id_token`, `initial_access_token`, `initial_refresh_token` (chiffrés), `use_auto_link`. |
| `saml` | même structure que OIDC (`providers[]`). |
| `totp` | `totp_url` (otpauth:// avec secret). |
| `lookup_secret` | `recovery_codes[]` : `code`, `used_at`. |
| `webauthn` / `passkey` | `credentials[]` : `id`, `public_key`, `attestation_type`, `authenticator` (aaguid, sign_count, clone_warning), `display_name`, `added_at`, `is_passwordless`, `flags` (user_present, user_verified, backup_eligible, backup_state), `transport[]`, `attestation` ; `user_handle`. |
| `code` | `addresses[]` : `channel` (`email`/`sms`), `address`. |
| `deviceauthn` | clés d'appareil attestées (`selfservice/strategy/deviceauthn/key.go`, `attestation.go`). |

### 1.3. Domaine Adresses vérifiables et de récupération

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `identity_verifiable_addresses` | Adresses (e-mail/SMS) déclarées vérifiables par le schéma (`ory.sh/kratos.verification.via`). | `id`, `nid`, `identity_id`, `value`, `via` (`email`/`sms`), `verified` (bool), `status` (`pending`/`sent`/`completed`), `verified_at`, `created_at`, `updated_at` | Unique `(nid, via, value)`. |
| `identity_recovery_addresses` | Adresses utilisables pour la récupération de compte (`ory.sh/kratos.recovery.via`). | `id`, `nid`, `identity_id`, `value`, `via`, `break_glass_for_organization` (adresse de secours « bris de glace » d'une organisation SSO, `20260327…`), `created_at`, `updated_at` | Unique `(nid, via, value)`. |

Code : `identity/identity_verification.go`, `identity/identity_recovery.go`, `identity/extension_verification.go`, `identity/extension_recovery.go`, `identity/address.go`.

### 1.4. Domaine Sessions et dispositifs

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `sessions` | Session authentifiée d'une identité (cookie ou jeton API). | `id`, `nid`, `identity_id`, `active`, `issued_at`, `authenticated_at`, `expires_at`, `aal` (niveau atteint), `authentication_methods` (JSON = AMR : liste `{method, aal, completed_at, provider, organization, upstream_acr, upstream_amr}`), `token` (jeton de session opaque `ory_st_…`), `logout_token` (`ory_lo_…`), `created_at`, `updated_at` | Unique `token` ; unique `logout_token` ; index `(identity_id, nid)`, `(nid, created_at)`. |
| `session_devices` | Dispositifs/connexions associés à une session (traçabilité « où suis-je connecté »). | `id`, `nid`, `session_id`, `identity_id`, `ip_address`, `user_agent`, `location` (ville/pays via en-têtes CDN), `created_at`, `updated_at` | FK session (CASCADE). |
| `session_token_exchanges` | Échange de code pour remettre un jeton de session à une application native après un flux navigateur (OIDC sur mobile). | `id`, `nid`, `flow_id`, `session_id`, `init_code`, `return_to_code`, `created_at`, `updated_at` | Index `(nid, flow_id)`, `(nid, init_code, return_to_code)`. |

Code : `session/session.go` (`SetAuthenticatorAssuranceLevel`, `CompletedLoginFor*`, `Refresh`), `session/manager_http.go` (`DoesSessionSatisfy`), `session/tokenizer.go` (conversion session → JWT par gabarits).

### 1.5. Domaine Flux self-service

Tous les flux partagent : `id`, `nid`, `type` (`browser`/`api`), `issued_at`, `expires_at`, `request_url`, `ui` (JSON : conteneur de formulaire — action, méthode, nœuds, messages), `internal_context` (JSON privé), `active_method`, `state`, `csrf_token`, `created_at`, `updated_at`.

| Table | Rôle | Champs spécifiques |
| :--- | :--- | :--- |
| `selfservice_login_flows` | Connexion (1er facteur ou montée en AAL). | `forced` (réauthentification forcée), `requested_aal`, `oauth2_login_challenge_data` (intégration Hydra/OAuth2), `identity_schema_id`, `organization_id`, `test_flow` (`20260417…`). |
| `selfservice_registration_flows` | Inscription. | `oauth2_login_challenge_data`, `identity_schema_id`, `organization_id`. |
| `selfservice_settings_flows` | Gestion du profil/credentials par l'utilisateur connecté. | `identity_id` (obligatoire), `organization_id`. |
| `selfservice_recovery_flows` | Récupération de compte. | `recovered_identity_id`, `skip_csrf_check`. |
| `selfservice_verification_flows` | Vérification d'une adresse. | `oauth2_login_challenge`. |
| `selfservice_errors` | Erreurs de flux présentées à l'UI. | `errors` (JSON), `seen_at`, `was_seen`, `csrf_token`. |

États (`selfservice/flow/state.go`) : `choose_method` → `sent_email` → `passed_challenge` ; `show_form`, `success` ; recovery v2 : `recovery_awaiting_address`, `recovery_awaiting_address_choice`, `recovery_confirming_address`, `recovery_awaiting_code` (diagrammes `state_recovery_v1/v2.mermaid`).

### 1.6. Domaine Codes et jetons à usage unique

| Table | Rôle | Champs | Contraintes |
| :--- | :--- | :--- | :--- |
| `identity_login_codes` | Code OTP de connexion sans mot de passe / MFA par code. | `id`, `nid`, `identity_id`, `selfservice_login_flow_id`, `address`, `address_type` (`email`/`sms`), `code` (HMAC), `used_at`, `issued_at`, `expires_at` | FK flux. |
| `identity_registration_codes` | Code d'inscription par code. | `id`, `nid`, `selfservice_registration_flow_id`, `address`, `address_type`, `code`, `used_at`, `issued_at`, `expires_at` | — |
| `identity_verification_codes` | Code de vérification d'adresse. | `id`, `nid`, `selfservice_verification_flow_id`, `identity_verifiable_address_id`, `code_hmac`, `used_at`, `issued_at`, `expires_at` | — |
| `identity_recovery_codes` | Code de récupération. | `id`, `nid`, `identity_id`, `selfservice_recovery_flow_id`, `identity_recovery_address_id`, `code` (HMAC), `code_type` (utilisateur / admin), `used_at`, `issued_at`, `expires_at` | Index `flow_id`. |
| `identity_verification_tokens` | Lien magique de vérification (stratégie `link`). | `id`, `nid`, `token`, `identity_verifiable_address_id`, `selfservice_verification_flow_id`, `issued_at`, `expires_at` | Unique `token`. |
| `identity_recovery_tokens` | Lien magique de récupération. | `id`, `nid`, `token`, `token_type` (utilisateur/admin), `identity_id`, `identity_recovery_address_id`, `selfservice_recovery_flow_id`, `issued_at`, `expires_at` | Unique `token`. |

Principe : seuls les **HMAC** des codes sont stockés (`code_hmac`), avec `used_at` pour l'usage unique, `max_submissions` (config) contre la force brute.

### 1.7. Domaine Courrier sortant

| Table | Rôle | Champs |
| :--- | :--- | :--- |
| `courier_messages` | File d'attente (outbox) des e-mails/SMS. | `id`, `nid`, `status` (`queued`=1, `sent`=2, `processing`=3, `abandoned`=4), `type` (email/sms), `channel` (canal nommé configurable), `recipient`, `subject`, `body`, `template_type` (`recovery_valid`, `recovery_code_valid`, `verification_code_valid`, `login_code_valid`, `registration_code_valid`, `verifiable_address_changed`, `authenticator_key_added`, … et variantes `_invalid`), `template_data` (JSON), `request_headers` (`20251215…`), `send_count`, `created_at`, `updated_at`. Index `(nid, status, created_at)`. |
| `courier_message_dispatches` | Journal de chaque tentative d'envoi. | `id`, `nid`, `message_id`, `status` (succès/échec), `error` (JSON), `created_at`, `updated_at`. |

Code : `courier/message.go`, `courier/courier_dispatcher.go` (retry `message_retries`, abandon), `courier/smtp_channel.go`, `courier/http_channel.go` (envoi délégué à un webhook), `courier/sms.go`, `courier/template/` (gabarits Go surchargeables).

### 1.8. Domaine Continuity

| Table | Rôle | Champs |
| :--- | :--- | :--- |
| `continuity_containers` | Conteneur d'état temporaire survivant à une redirection externe (ex. aller-retour chez un fournisseur OIDC) lié à un cookie. | `id`, `nid`, `name`, `identity_id` (optionnel), `payload` (JSON), `expires_at`, `created_at`, `updated_at`. |

---

## Partie 2 — Kratos : fonctionnalités

### 2.1. Schéma d'identité JSON configurable

| Élément | Détail | Chemin |
| :--- | :--- | :--- |
| Schémas multiples | `identity.schemas[]` (id + URL), `identity.default_schema_id` ; chaque identité porte `schema_id`. | `embedx/config.schema.json`, `identity/validator.go` |
| Extension `ory.sh/kratos` | Annotation par propriété JSON Schema : `credentials.password.identifier`, `credentials.webauthn.identifier`, `credentials.passkey.display_name`, `credentials.totp.account_name`, `credentials.code.identifier` + `via` (`email`/`sms`), `verification.via`, `recovery.via`, `organizations.matcher`. | `embedx/identity_extension.schema.json`, `identity/extension_credentials.go`, `extension_verification.go`, `extension_recovery.go` |
| Effet | La validation des traits **dérive automatiquement** : identifiants de login (→ `identity_credential_identifiers`), adresses vérifiables, adresses de récupération. Aucune colonne « email » en dur. | `identity/manager.go` |
| Sécurité | `security.disallow_ref_in_identity_schemas`, `security.account_enumeration` (anti-énumération). | config |

### 2.2. Méthodes d'authentification

| Méthode | Clé config `selfservice.methods.*` | AAL | Implémentation |
| :--- | :--- | :--- | :--- |
| Mot de passe | `password` (HIBP `haveibeenpwned_enabled`, `max_breaches`, `min_password_length`, `identifier_similarity_check_enabled`, `migrate_hook`) | aal1 | `selfservice/strategy/password/`, `hash/` (argon2, bcrypt, pbkdf2, scrypt, comparateur multi-formats) |
| Code (OTP e-mail/SMS) | `code` (`passwordless_enabled`, `mfa_enabled`, `lifespan`, `max_submissions`, `missing_credential_fallback_enabled`) | aal1 ou aal2 (MFA) | `selfservice/strategy/code/` |
| Lien magique | `link` (récupération/vérification) | — | `selfservice/strategy/link/` |
| WebAuthn (clé de sécurité 2FA ou passwordless) | `webauthn` | aal2 (ou aal1 passwordless) | `selfservice/strategy/webauthn/` |
| Passkey | `passkey` | aal1 (résident, vérifié) | `selfservice/strategy/passkey/` |
| TOTP | `totp` | aal2 | `selfservice/strategy/totp/` |
| Codes de secours | `lookup_secret` | aal2 | `selfservice/strategy/lookup/` |
| OIDC / social | `oidc` (≈30 fournisseurs : Google, Apple, Microsoft, GitHub, GitLab, Facebook, LinkedIn, Auth0, Salesforce, Slack, Discord, X, VK, Yandex, generic OIDC, Jackson SSO…) ; mapping des claims par **Jsonnet** ; `acr`/`amr` amont peuvent porter l'AAL2 | aal1 / aal2 | `selfservice/strategy/oidc/provider_*.go` |
| SAML | `saml` (login/registration/settings) | aal1 / aal2 | `selfservice/strategy/saml/` |
| Profil | `profile` (édition des traits, inscription en deux étapes) | — | `selfservice/strategy/profile/` |
| Identifier-first | style `identifier_first` du login | — | `selfservice/strategy/idfirst/` |
| Device authn | clés d'appareil attestées | — | `selfservice/strategy/deviceauthn/` |

### 2.3. Parcours self-service

| Flux | Options clés (config) | Chemin |
| :--- | :--- | :--- |
| Login | `lifespan`, `style` (unifié / identifier-first), `before`/`after` hooks, `refresh` (réauth), `aal` demandé | `selfservice/flow/login/` |
| Registration | `enabled`, `login_hints`, `style`, `enable_legacy_one_step` | `selfservice/flow/registration/` |
| Settings | `privileged_session_max_age` (opérations sensibles exigent une authentification récente), `required_aal` | `selfservice/flow/settings/` |
| Recovery | `use` (`code`/`link`), `notify_unknown_recipients` | `selfservice/flow/recovery/` |
| Verification | `use`, `notify_unknown_recipients` | `selfservice/flow/verification/` |
| Logout | `clear_browser_data`, `after` | `selfservice/flow/logout/` |
| Erreurs | `error.ui_url` | `selfservice/errorx/` |

Deux modes : **browser** (cookies + CSRF) et **api** (clients natifs, jeton de session). L'UI est découplée : Kratos renvoie un conteneur `ui` (nœuds de formulaire) rendu par n'importe quel frontend.

### 2.4. Sessions et AAL (Authenticator Assurance Level, NIST 800-63)

| Concept | Règle (code) |
| :--- | :--- |
| Niveaux | `aal0` (aucun), `aal1` (un facteur), `aal2` (deux facteurs) — `identity/credentials.go:40`. |
| AAL de session | Calculé depuis l'AMR : aal1 + aal2 ⇒ aal2 ; OIDC/SAML avec MFA amont ⇒ aal2 seul (`session/session.go:243`). |
| AAL disponible de l'identité | `available_aal` = aal2 si un credential MFA actif existe, sinon aal1 si un 1er facteur, sinon aal0 (`identity/identity.go:390`). |
| Exigence | `required_aal` = `aal1` ou `highest_available` sur `/sessions/whoami` et sur settings ; `DoesSessionSatisfy` renvoie une erreur invitant à monter en AAL (`session/manager_http.go:337`). |
| Durées | `session.lifespan`, `earliest_possible_extend`, cookies ; révocation par `logout_token`, révocation des autres sessions (hook `revoke_active_sessions`). |
| Tokenizer | Gabarits convertissant une session en JWT signé (`session/tokenizer.go`). |

### 2.5. Hooks

`before` / `after` par flux et par méthode (`selfservice/hook/hooks.go`) :

| Clé | Effet |
| :--- | :--- |
| `session` | Émettre une session après inscription (connexion automatique). |
| `revoke_active_sessions` | Révoquer les autres sessions (après login/recovery/settings). |
| `require_verified_address` | Refuser le login tant que l'adresse n'est pas vérifiée. |
| `verification` | Lancer un flux de vérification après inscription/settings. |
| `show_verification_ui` | Rediriger vers l'UI de vérification. |
| `verify_new_address` | Mettre un changement d'adresse en attente (`identity_pending_traits_changes`). |
| `notify_previous_addresses` | Prévenir l'ancienne adresse d'un changement. |
| `web_hook` | Appel HTTP (Jsonnet pour le corps, `auth` basic/api-key, `can_interrupt` = le webhook peut bloquer le flux et renvoyer des erreurs de validation, `response.parse` = le webhook peut modifier les traits/metadata, `response.ignore` = asynchrone). |
| `password_migration_hook` | Vérifier un mot de passe auprès d'un système historique puis le rehacher localement. |
| `b2bSSOHook` | Routage SSO organisation. |

### 2.6. Courrier

File d'attente persistée (`courier_messages`) + worker (`watch-courier`), canaux SMTP / HTTP / SMS nommés, gabarits par type et par langue surchargeables, `message_retries` puis `abandoned`, journal `courier_message_dispatches`.

---

## Partie 3 — Keycloak : modèle de données (entités JPA)

> Multi-locataire : le **realm** est l'unité d'isolation ; quasiment toutes les tables portent `REALM_ID`. Beaucoup de propriétés extensibles sont des tables clé/valeur (`*_ATTRIBUTE`, `*_CONFIG`).

### 3.1. Realm et configuration

| Entité / table | Rôle | Champs principaux | Relations |
| :--- | :--- | :--- | :--- |
| `RealmEntity` / `REALM` | Locataire, porte toute la politique de sécurité. | `name` (unique), `enabled`, `ssl_required`, `registration_allowed`, `reg_email_as_username`, `verify_email`, `reset_password_allowed`, `login_with_email_allowed`, `duplicate_emails_allowed`, `remember_me`, `password_policy` (chaîne de règles), `otp_policy_*` (type, alg, digits, window, period, counter), `edit_username_allowed`, durées (`sso_idle_timeout`, `sso_max_lifespan`, `*_remember_me`, `offline_session_idle_timeout`, `access_token_lifespan`, `access_code_lifespan`, `user_action_lifespan`, `login_lifespan`), `revoke_refresh_token`, `refresh_token_max_reuse`, `not_before`, thèmes (login/account/admin/email), `display_name`, `events_enabled`, `events_expiration`, `admin_events_enabled`, `admin_events_details_enabled`, `default_role`, **liaisons de flux** (`browser_flow`, `registration_flow`, `direct_grant_flow`, `reset_credentials_flow`, `client_auth_flow`, `docker_auth_flow`), `internationalization_enabled`, `default_locale` | Collections : `REALM_SMTP_CONFIG`, `REALM_DEFAULT_GROUPS`, `REALM_EVENTS_LISTENERS`, `REALM_ENABLED_EVENT_TYPES`, `REALM_SUPPORTED_LOCALES`. |
| `RealmAttributeEntity` / `REALM_ATTRIBUTE` | Attributs clé/valeur additionnels du realm (brute force, WebAuthn policy, etc.). | `realm_id`, `name`, `value` | PK (realm, name). |
| `RealmLocalizationTextsEntity` / `REALM_LOCALIZATIONS` | Surcharges de traductions par langue. | `realm_id`, `locale`, `texts` (map JSON) | — |
| `RequiredCredentialEntity` / `REALM_REQUIRED_CREDENTIAL` | Types de credentials exigés. | `type`, `input`, `secret`, `form_label` | → realm |
| `ComponentEntity` + `ComponentConfigEntity` / `COMPONENT`, `COMPONENT_CONFIG` | Instances de fournisseurs génériques (fédération LDAP, clés, user profile, politiques…). | `name`, `provider_type`, `provider_id`, `parent_id`, `sub_type` ; config `name/value` | → realm |

### 3.2. Utilisateurs

| Entité / table | Rôle | Champs principaux | Relations |
| :--- | :--- | :--- | :--- |
| `UserEntity` / `USER_ENTITY` | Utilisateur. | `username`, `email`, `email_constraint` (astuce d'unicité conditionnelle), `email_verified`, `first_name`, `last_name`, `enabled`, `created_timestamp`, `last_modified_timestamp`, `federation_link` (fournisseur externe LDAP…), `service_account_client_link` (compte de service d'un client), `not_before` (révocation globale des jetons), `realm_id` | Uniques `(realm, username)`, `(realm, email_constraint)`. 1-N : attributs, required actions, credentials, identités fédérées. |
| `UserAttributeEntity` / `USER_ATTRIBUTE` | Attributs de profil libres (EAV), multi-valués. | `name`, `value`, `long_value` + `long_value_hash`, `long_value_hash_lower_case` (recherche sur valeurs longues) | → user |
| `UserRequiredActionEntity` / `USER_REQUIRED_ACTION` | Actions que l'utilisateur doit accomplir à sa prochaine connexion. | `user_id`, `required_action` (alias) | PK (user, action). |
| `CredentialEntity` / `CREDENTIAL` | Credential d'un utilisateur. | `type` (`password`, `otp`/`totp`/`hotp`, `webauthn`, `webauthn-passwordless`, `recovery-authn-codes`…), `user_label`, `created_date`, `secret_data` (JSON secret : hash, secret OTP), `credential_data` (JSON public : algorithme, itérations, digits…), `priority` (ordre de préférence), `salt`, `version` (verrou optimiste) | → user. **Séparation secret/public** des données. |
| `FederatedIdentityEntity` / `FEDERATED_IDENTITY` | Lien entre un utilisateur et un compte chez un fournisseur d'identité externe. | `identity_provider` (alias), `federated_user_id`, `federated_username`, `token` (jetons IdP stockés), `realm_id` | PK (user, identity_provider). |
| `UserConsentEntity` + `UserConsentClientScopeEntity` | Consentements OAuth accordés à un client et scopes associés. | `client_id`, `created_date`, `last_updated_date` ; `scope_id`, `parameter` | Unique (user, client). |
| `UserRoleMappingEntity` / `USER_ROLE_MAPPING` | Rôles directement attribués. | `user_id`, `role_id` | — |
| `UserGroupMembershipEntity` / `USER_GROUP_MEMBERSHIP` | Appartenance à un groupe. | `user_id`, `group_id`, `membership_type` (MANAGED/UNMANAGED pour les organisations) | — |
| `LoginFailureEntity` / `LOGIN_FAILURE` | État anti-force-brute par utilisateur. | `num_failures`, `num_temporary_lockouts`, `failed_login_not_before`, `last_failure`, `last_ip_failure`, `num_secondary_auth_failures` | PK (realm, user). |
| `FED_USER_*` (`FederatedUser`, attributs, credentials, rôles, groupes, required actions, consentements) | Stockage local de données pour des utilisateurs dont la source est externe (LDAP…). | mêmes champs + `storage_provider_id` | — |
| `UserFederationProviderEntity`, `UserFederationMapperEntity` | (Ancienne) configuration de fédération LDAP/Kerberos. | `provider_name`, `priority`, `full_sync_period`, `changed_sync_period`, `last_sync`, config | → realm |
| `BrokerLinkEntity` / `BROKER_LINK` | Lien IdP pour utilisateurs fédérés. | `identity_provider`, `broker_user_id`, `broker_username`, `token` | — |

### 3.3. Rôles et groupes

| Entité / table | Rôle | Champs | Relations |
| :--- | :--- | :--- | :--- |
| `RoleEntity` / `KEYCLOAK_ROLE` | Rôle de realm ou rôle de client. | `name`, `description`, `realm_id`, `client_role` (bool), `client`, `client_realm_constraint` | Unique `(name, client_realm_constraint)` ; attributs `ROLE_ATTRIBUTE`. |
| `CompositeRoleEntity` / `COMPOSITE_ROLE` | **Rôle composite** : un rôle en contient d'autres (héritage transitif). | `composite` (parent), `child_role` | N-N rôle↔rôle. |
| `GroupEntity` / `KEYCLOAK_GROUP` | Groupe hiérarchique. | `name`, `description`, `parent_group` (arbre), `realm_id`, `type` (realm / organisation), `org_id`, timestamps | Unique `(realm, parent_group, name)` ; attributs `GROUP_ATTRIBUTE`. |
| `GroupRoleMappingEntity` / `GROUP_ROLE_MAPPING` | Rôles hérités par les membres du groupe. | `group_id`, `role_id` | — |

### 3.4. Clients, scopes, mappers

| Entité / table | Rôle | Champs principaux | Relations |
| :--- | :--- | :--- | :--- |
| `ClientEntity` / `CLIENT` | Application relying party (OIDC/SAML). | `client_id` (unique par realm), `name`, `enabled`, `secret`, `client_authenticator_type`, `public_client`, `bearer_only`, `protocol`, `consent_required`, `standard_flow_enabled`, `implicit_flow_enabled`, `direct_access_grants_enabled`, `service_accounts_enabled`, `full_scope_allowed`, `frontchannel_logout`, `root_url`, `base_url`, `not_before` | `WEB_ORIGINS`, `REDIRECT_URIS`, `CLIENT_ATTRIBUTES`, `CLIENT_AUTH_FLOW_BINDINGS` (surcharge des flux par client), `SCOPE_MAPPING` (rôles visibles dans les jetons). |
| `ClientScopeEntity` / `CLIENT_SCOPE` | Scope réutilisable (profil, email, rôles…) regroupant mappers et rôles. | `name` (unique par realm), `protocol`, `description` | `CLIENT_SCOPE_ATTRIBUTES`, `CLIENT_SCOPE_ROLE_MAPPING`. |
| `ClientScopeClientMappingEntity` / `CLIENT_SCOPE_CLIENT` | Scopes affectés à un client (par défaut ou optionnels). | `scope_id`, `client_id`, `default_scope` | — |
| `DefaultClientScopeRealmMappingEntity` / `DEFAULT_CLIENT_SCOPE` | Scopes par défaut affectés aux nouveaux clients. | `scope_id`, `realm_id`, `default_scope` | — |
| `ProtocolMapperEntity` / `PROTOCOL_MAPPER` | Transforme des données utilisateur en claims de jeton. | `name`, `protocol`, `protocol_mapper` (type), config clé/valeur | → client **ou** client scope. |
| `ClientInitialAccessEntity` | Jeton d'enregistrement dynamique de clients. | `timestamp`, `expiration`, `count`, `remaining_count` | → realm |

### 3.5. Fournisseurs d'identité (brokering)

| Entité / table | Rôle | Champs | Relations |
| :--- | :--- | :--- | :--- |
| `IdentityProviderEntity` / `IDENTITY_PROVIDER` | IdP externe (OIDC, SAML, social). | `provider_alias`, `provider_id` (type), `provider_display_name`, `enabled`, `trust_email`, `store_token`, `link_only`, `hide_on_login`, `add_token_role`, `authenticate_by_default`, **`first_broker_login_flow_id`**, **`post_broker_login_flow_id`**, config (`IDENTITY_PROVIDER_CONFIG`) | → realm. |
| `IdentityProviderMapperEntity` / `IDENTITY_PROVIDER_MAPPER` | Mappe les claims/attributs IdP vers l'utilisateur local (attribut, rôle, groupe…). | `name`, `idp_alias`, `idp_mapper_name`, config | → IdP par alias. |

### 3.6. Sessions

| Entité / table | Rôle | Champs |
| :--- | :--- | :--- |
| `PersistentUserSessionEntity` / `OFFLINE_USER_SESSION` | Session utilisateur persistée (en ligne et hors ligne). | `user_session_id`, `realm_id`, `user_id`, `created_on`, `last_session_refresh`, `broker_session_id`, `offline_flag`, `data` (JSON : notes, IP, méthode d'auth, état `LOGGED_IN`/`LOGGING_OUT`/`LOGGED_OUT`/…), `remember_me`, `session_bucket`, `version` |
| `PersistentClientSessionEntity` / `OFFLINE_CLIENT_SESSION` | Session par client au sein d'une session utilisateur. | `user_session_id`, `client_id`, `external_client_id`, `offline_flag`, `timestamp`, `data`, `realm_id` |
| `RootAuthenticationSessionEntity` / `ROOT_AUTH_SESSION` + `AuthenticationSessionEntity` / `AUTH_SESSION` | **Session d'authentification en cours** (équivalent des flux Kratos), une par onglet (`tab_id`). | `client_uuid`, `auth_user_id`, `redirect_uri`, `action`, `protocol`, `client_scopes`, `execution_status` (état de chaque exécution du flux), `client_notes`, `auth_notes`, `required_actions`, `user_session_notes`, `version` |
| `RevokedTokenEntity` / `REVOKED_TOKEN` | Liste de révocation des jetons. | `id`, `expire` |
| `SingleUseObjectEntity` / `SINGLE_USE_OBJECT` | Objets à usage unique (codes d'action, nonces). | `id`, `notes`, `expire` |

### 3.7. Flux d'authentification et required actions

| Entité / table | Rôle | Champs | Relations |
| :--- | :--- | :--- | :--- |
| `AuthenticationFlowEntity` / `AUTHENTICATION_FLOW` | Flux nommé (arbre). | `alias`, `provider_id` (`basic-flow`, `form-flow`, `client-flow`), `description`, `top_level`, `built_in` | → realm ; 1-N exécutions. |
| `AuthenticationExecutionEntity` / `AUTHENTICATION_EXECUTION` | Étape d'un flux : un authenticator **ou** un sous-flux. | `flow_id` (parent), `authenticator` (provider), `auth_config` (→ config), `auth_flow_id` (sous-flux), `authenticator_flow` (bool), **`requirement`** (`REQUIRED`, `CONDITIONAL`, `ALTERNATIVE`, `DISABLED`), `priority` | → flow parent. |
| `AuthenticatorConfigEntity` / `AUTHENTICATOR_CONFIG` | Paramètres d'une exécution. | `alias`, config clé/valeur | → realm |
| `RequiredActionProviderEntity` / `REQUIRED_ACTION_PROVIDER` | Catalogue des required actions activées pour le realm. | `alias`, `name`, `provider_id`, `enabled`, `default_action` (assignée aux nouveaux utilisateurs), `priority`, config (`REQUIRED_ACTION_CONFIG`) | → realm |

### 3.8. Organisations (B2B)

| Entité / table | Rôle | Champs | Relations |
| :--- | :--- | :--- | :--- |
| `OrganizationEntity` / `ORG` | Organisation cliente dans un realm. | `name`, `alias`, `enabled`, `description`, `redirect_url`, `realm_id`, `group_id` (groupe technique portant les membres) | 1-N domaines, IdP, groupes. |
| `OrganizationDomainEntity` / `ORG_DOMAIN` | Domaines e-mail de l'organisation. | `name`, `verified`, `auto_redirect`, `idp_id` | → org, → IdP. |
| `OrganizationIdentityProviderEntity` / `ORG_IDENTITY_PROVIDER` | IdP rattachés à l'organisation (SSO). | `identity_provider_id`, `auto_membership`, `membership_type` (défaut `UNMANAGED`) | → org |
| `OrganizationInvitationEntity` / `ORG_INVITATION` | Invitation d'un membre. | `organization_id`, `email`, `first_name`, `last_name`, `created_at`, `expires_at`, `invite_link` | — |

### 3.9. Événements et outbox

| Entité / table | Rôle | Champs |
| :--- | :--- | :--- |
| `EventEntity` / `EVENT_ENTITY` | Événements utilisateur (login, register, update_password…). | `event_time`, `type`, `realm_id`, `client_id`, `user_id`, `session_id`, `ip_address`, `error`, `details_json` |
| `AdminEventEntity` / `ADMIN_EVENT_ENTITY` | Audit des opérations d'administration. | `admin_event_time`, `operation_type` (`CREATE`/`UPDATE`/`DELETE`/`ACTION`), `resource_type` (≈40 types : USER, GROUP, CLIENT, ORGANIZATION…), `resource_path`, `auth_realm_id`, `auth_client_id`, `auth_user_id`, `ip_address`, `representation` (JSON de l'objet), `error`, `details_json` |
| `OutboxEntryEntity` / `OUTBOX_ENTRY` | Outbox transactionnelle récente. | `entry_kind`, `realm_id`, `owner_id`, `container_id`, `correlation_id`, `entry_type`, `payload`, `metadata`, `status`, `attempts`, `next_attempt_at`, `last_error`, `created_at`, `delivered_at` |
| `WorkflowStateEntity` / `WORKFLOW_STATE` | Workflows planifiés sur ressources (ex. désactivation après inactivité). | `execution_id`, `resource_id`, `resource_type`, `workflow_id`, `scheduled_step_id`, `scheduled_step_timestamp` |

Hors périmètre identité (non détaillés) : Authorization Services (`RESOURCE_SERVER*`, `POLICY`, `PERMISSION_TICKET`), verifiable credentials (`USER_VER_CREDENTIAL`, `ISSUED_VER_CREDENTIAL`), `CLUSTER_EVENT`, `SERVER_CONFIG`, `MIGRATION_MODEL`.

---

## Partie 4 — Keycloak : fonctionnalités clés (SPI)

| Fonctionnalité | Contrat SPI | Ce qu'il apporte |
| :--- | :--- | :--- |
| **Flux d'authentification configurables** | `Authenticator` (`authenticate`, `action`, `requiresUser`, `configuredFor`, `setRequiredActions`) ; `FormAction` (`buildPage`, `validate`, `success`) ; `AuthenticationFlowContext` ; `AuthenticationExecutionModel.Requirement` ; `AuthenticationFlowError` (`INVALID_CREDENTIALS`, `USER_TEMPORARILY_DISABLED`, `CREDENTIAL_SETUP_REQUIRED`, `IDENTITY_PROVIDER_ERROR`…) | Arbre de flux persistant en base, composé d'exécutions REQUIRED/ALTERNATIVE/CONDITIONAL/DISABLED ; le moteur parcourt l'arbre, chaque authenticator signale succès/échec/challenge ; `configuredFor` déclenche une required action si le credential manque. Flux liés au realm (browser, registration, reset, direct grant, client auth) et surchargeables par client et par IdP (first/post broker login). |
| **Required actions** | `RequiredActionProvider` (`evaluateTriggers`, `requiredActionChallenge`, `processAction`, `initiatedActionSupport`, `getMaxAuthAge`) ; `UserModel.RequiredAction` = `VERIFY_EMAIL`, `UPDATE_PROFILE`, `CONFIGURE_TOTP`, `CONFIGURE_RECOVERY_AUTHN_CODES`, `UPDATE_PASSWORD`, `TERMS_AND_CONDITIONS`, `VERIFY_PROFILE`, `UPDATE_EMAIL` | Tâches imposées après authentification et avant émission de session ; déclenchables par l'admin, par politique (`evaluateTriggers` : ex. mot de passe expiré) ou par l'application (AIA, `kc_action`) avec exigence d'authentification récente (`max_auth_age`). |
| **Credentials** | `CredentialProvider` (`createCredential`, `deleteCredential`, `getCredentialFromModel`, `getCredentialTypeMetadata`) ; `CredentialModel` (`secret_data` / `credential_data`) ; `PasswordPolicy`, `OTPPolicy`, `WebAuthnPolicy` | Types de credentials enfichables, politique de mots de passe composable (longueur, historique, expiration, hash), politiques OTP/WebAuthn au niveau realm. |
| **Brute force** | `BruteForceProtector` (`failedLogin`, `successfulLogin`, `isTemporarilyDisabled`, `isPermanentlyLockedOut`) | Verrouillage temporaire/permanent, compteurs dans `LOGIN_FAILURE`. |
| **User Profile déclaratif** | `UserProfileProvider` (`create`, `getConfiguration` → `UPConfig`), `AttributeMetadata` (`required`, `readAllowed`, `writeAllowed` par contexte, `validators`, `annotations`, `multivalued`, `group`, `guiOrder`) | Équivalent du schéma d'identité Kratos : attributs, validateurs, permissions lecture/écriture par contexte (admin, compte, inscription, IdP). |
| **Organisations** | `OrganizationProvider` (`create`, `getByDomainName`, `addMember`, `addManagedMember`, `updateMembershipType`, `getMembersStream`, `getByMember`, `createGroup`, `getTopLevelGroups`…) | Multi-organisation dans un realm : domaines, IdP SSO par organisation, membres gérés (créés par l'IdP) vs non gérés, invitations, groupes d'organisation. |
| **Brokering d'identité** | `IdentityProvider<C>` ; `IdentityProviderMapper` (`preprocessFederatedIdentity`, `importNewUser`, `updateBrokeredUser`, `supportsSyncMode`) | Connexion via IdP externes, flux « first broker login » (création/liaison de compte, revue de profil), synchronisation des attributs (modes IMPORT/FORCE/LEGACY). |
| **Mappers de protocole** | `ProtocolMapper` | Construction des claims de jetons OIDC/SAML depuis attributs, rôles, groupes. |
| **Événements** | `EventListenerProvider` (`onEvent(Event)`, `onEvent(AdminEvent, includeRepresentation)`) ; `EventType` (≈70 types × `_ERROR`), `OperationType`, `ResourceType` | Deux flux d'audit distincts (utilisateur / admin), chacun stocké et diffusé à des listeners enfichables ; liste d'événements activés par realm, rétention (`events_expiration`). |

---

## Partie 5 — Synthèse comparative et recommandations pour `lyxal_auth`

### 5.1. Comparaison des concepts

| Concept | Kratos | Keycloak | Logto (pour mémoire, non analysé ici — à vérifier) | Intérêt pour `lyxal_auth` |
| :--- | :--- | :--- | :--- | :--- |
| Isolation locataire | `nid` sur toutes les tables | `realm_id` | `tenant_id` | Indispensable ; aligner sur le tenant Lyxal (`SecretContext::with_tenant`). |
| Profil extensible | **Schéma JSON** par identité, annotations dérivant identifiants/adresses | **User Profile** déclaratif avec permissions par contexte | Champs fixes + `custom_data` | Fort : schéma de traits versionné validé par `lyxal_core` (`fn::validation_object_execute`). |
| Identifiants de login | Table dédiée `identity_credential_identifiers` unique par (tenant, type, identifiant) | Colonnes `username`/`email` + `FEDERATED_IDENTITY` | Colonnes `username`/`primary_email`/`primary_phone` | Fort : index unique générique, multi-identifiants. |
| Credentials | 1 ligne par type, `config` JSON versionné | 1 ligne par credential, `secret_data` / `credential_data` séparés, `priority`, `user_label` | Colonnes dédiées (`password_encrypted`, `mfa_verifications`) | Combiner : 1 ligne par credential (plusieurs clés WebAuthn) + séparation secret/public. |
| Adresses vérifiables / de récupération | Tables dédiées, statut `pending/sent/completed` | `email_verified` seul | Booléens/horodatage | Fort : adresses multiples, vérification indépendante. |
| **AAL** | `aal0/1/2`, AMR dans la session, `available_aal`, `required_aal=highest_available` | Niveaux d'authentification (LoA) via flux conditionnels | MFA présent mais modèle AAL non explicite | **Très fort** : montée en assurance (step-up) standardisée. |
| **Sessions privilégiées** | `privileged_session_max_age` | `max_auth_age` des required actions | Vérification d'identité pour actions sensibles | Fort. |
| **Required actions** | Partiel (hooks `require_verified_address`, `verification`) | **Natif**, catalogue par realm + liste par utilisateur | Partiel (règles d'inscription) | **Très fort** : CGU, changement de mot de passe, configuration MFA imposée. |
| **Flux configurables** | Hooks `before/after` + styles | **Arbre de flux persistant** REQUIRED/ALTERNATIVE/CONDITIONAL | Expérience de connexion configurable (non arborescente) | Moyen à fort : commencer par des hooks déclaratifs, garder la porte ouverte à un arbre. |
| Flux self-service persistés | Tables de flux avec `ui`, `state`, `csrf_token`, `expires_at` | `AUTH_SESSION` par onglet | Interaction en cache/session | Fort : état d'un parcours rejouable, API sans UI imposée. |
| Changement d'adresse sécurisé | `identity_pending_traits_changes` | Required action `UPDATE_EMAIL` | — | Fort. |
| Codes OTP | Tables par usage, **HMAC stocké**, `used_at`, `max_submissions` | `SINGLE_USE_OBJECT` | Codes de vérification en table | Fort. |
| Anti-force-brute | Limitation par flux | **`LOGIN_FAILURE`** + verrouillages | Verrouillage de compte récent | Fort. |
| Rôles / groupes | Absent (délégué à Keto) | **Rôles composites**, groupes hiérarchiques, rôles de client | Rôles, permissions (scopes), organisations | Fort (si l'autorisation est dans `lyxal_auth`). |
| Organisations | `organization_id`, SSO B2B, `break_glass_for_organization` | **ORG / ORG_DOMAIN / ORG_INVITATION / membership managed** | Organisations natives | Fort pour Lyxal multi-entreprises. |
| Audit | Pas de table d'audit (logs) | **EVENT_ENTITY + ADMIN_EVENT_ENTITY** typés | Journaux d'audit | Fort, via `lyxal_event`. |
| Courrier | Outbox `courier_messages` + dispatches | SMTP synchrone | Connecteurs | À **déléguer** à `lyxal_notification` via événements (§5.6.1 AGENTS). |
| Hooks externes | `web_hook` avec `can_interrupt` / `response.parse` | SPI Java | Webhooks | Fort : via `lyxal_event` (asynchrone) et un hook synchrone bloquant optionnel. |
| Migration de mots de passe | `password_migration_hook`, comparateur multi-hash | Fédération LDAP | Import | Utile pour reprise d'existants. |

### 5.2. Recommandations — modèle de données cible `lyxal_auth` (proposition à soumettre au CTO)

| Table Lyxal (préfixe `auth_`) | Inspirée de | Contenu recommandé |
| :--- | :--- | :--- |
| `auth_identity` | Kratos `identities` + Keycloak `USER_ENTITY` | `tenant`, `schema_id`, `traits` (objet validé), `state` (`active`/`inactive`/`locked`), `state_changed_at`, `metadata_public`, `metadata_admin`, `available_aal`, `external_id` (unique partiel par tenant), `organization`, `not_before` (révocation globale). |
| `auth_identity_schema` | Kratos schémas + Keycloak `AttributeMetadata` | Définition des traits : règles `lyxal_core`, `required`, `identifier` (login), `verification_via`, `recovery_via`, permissions lecture/écriture par contexte (`self`, `admin`, `registration`). |
| `auth_credential` | Kratos `identity_credentials` + Keycloak `CREDENTIAL` | `identity`, `type` (référentiel), `label`, `priority`, `credential_data` (public), `secret_data` (**chiffré `lyxal_crypto` enc:v2**, AAD = tenant/module/resource/record/field), `version`, `last_used_at`. Une ligne par credential (plusieurs passkeys). |
| `auth_credential_identifier` | Kratos | `identifier` normalisé (`fn::sanitize_*`), `credential_type`, `identity`, `credential` ; **index unique (tenant, type, identifier)**. |
| `auth_address` (ou `auth_verifiable_address` + `auth_recovery_address`) | Kratos | `value`, `via`, `verified`, `verified_at`, `status`, `usage` (verification / recovery / break-glass). |
| `auth_pending_address_change` | Kratos | changement de traits en attente de vérification, unicité « un seul pending par identité ». |
| `auth_flow` | Kratos `selfservice_*_flows` + Keycloak `AUTH_SESSION` | Une table unifiée avec `kind` (`login`, `registration`, `settings`, `recovery`, `verification`), `type` (`browser`/`api`), `state`, `requested_aal`, `active_method`, `forced`, `context` (privé), `csrf_hash`, `expires_at`, `organization`. |
| `auth_one_time_code` | Kratos codes/tokens | `flow`, `purpose`, `address`, `channel`, `code_hmac` (`lyxal_crypto::hmac`), `attempts`, `used_at`, `expires_at`. |
| `auth_session` | Kratos `sessions` + Keycloak sessions | `identity`, `token_hash` (jamais le jeton en clair), `logout_token_hash`, `aal`, `amr` (liste des méthodes avec `aal`, `completed_at`, `provider`), `authenticated_at`, `expires_at`, `idle_expires_at`, `remember_me`, `active`. |
| `auth_session_device` | Kratos | `ip_address`, `user_agent`, `location`, `last_seen_at`. |
| `auth_required_action_definition` + `auth_identity_required_action` | Keycloak | catalogue par tenant (`alias`, `enabled`, `default_action`, `priority`, `config`, `max_auth_age`) et liste par identité. |
| `auth_login_failure` | Keycloak `LOGIN_FAILURE` | compteurs et verrouillages temporaires/permanents. |
| `auth_identity_provider` + `auth_identity_provider_mapper` + `auth_federated_identity` | Keycloak brokering + Kratos `oidc` | IdP OIDC/SAML par tenant/organisation, `trust_email`, `link_only`, mapping des claims (règles déclaratives), liens `provider:subject`, jetons IdP chiffrés. |
| `auth_role`, `auth_role_composite`, `auth_group`, `auth_membership` | Keycloak | si l'autorisation est confiée à `lyxal_auth` ; rôles composites via `RELATE` SurrealDB (nouvelles tables : `TYPE RELATION` permis). |
| `auth_organization`, `auth_organization_domain`, `auth_organization_invitation` | Keycloak | domaines vérifiés, `membership_type` (`managed`/`unmanaged`), invitations expirantes. |
| (pas de table courrier ni audit local) | — | Émettre `auth.identity.created`, `auth.session.created`, `auth.code.issued`, `auth.login.failed`… via `fn::event_publish` ; `lyxal_notification` envoie les messages, un consommateur d'audit stocke l'historique (types inspirés de `EventType`/`OperationType`). |

### 5.3. Concepts prioritaires à reprendre

1. **AAL + AMR (Kratos)** : niveau d'assurance calculé en SurrealQL depuis la liste des méthodes de la session ; `available_aal` sur l'identité ; exigence `aal1 | highest_available` par opération ; `privileged_session_max_age` pour les opérations sensibles.
2. **Schéma d'identité déclaratif (Kratos + Keycloak User Profile)** : traits validés par le moteur `lyxal_core` ; les annotations dérivent automatiquement identifiants, adresses vérifiables et de récupération — zéro colonne `email` en dur.
3. **Table d'identifiants unique par (tenant, type, identifiant)** (Kratos) : recherche au login en O(1), support multi-identifiants et liens OIDC `provider:subject`.
4. **Required actions (Keycloak)** : catalogue par tenant + liste par identité, traitées avant émission de session ; couvre CGU, MFA obligatoire, mot de passe expiré, vérification d'e-mail.
5. **Flux persistés avec machine à états (Kratos)** et, plus tard, **arbre d'exécutions REQUIRED/ALTERNATIVE/CONDITIONAL (Keycloak)** pour des parcours configurables par tenant/client.
6. **Séparation `secret_data` / `credential_data` (Keycloak)**, avec chiffrement `lyxal_crypto` de la partie secrète ; codes et jetons stockés en **HMAC/hash** uniquement (Kratos).
7. **Changement d'adresse en attente de vérification** et **notification de l'ancienne adresse** (Kratos `verify_new_address` / `notify_previous_addresses`).
8. **Anti-force-brute persistant (Keycloak `LOGIN_FAILURE`)** + `max_submissions` par code (Kratos).
9. **Organisations B2B (Keycloak)** : domaines vérifiés, IdP par organisation, membres gérés/non gérés, invitations, accès « bris de glace » (Kratos).
10. **Audit typé (Keycloak Event/AdminEvent)** porté par `lyxal_event` plutôt que par une table interne ; courrier délégué à `lyxal_notification` (respect du découplage producteur/consommateur).

### 5.4. Points d'attention pour l'intégration Lyxal

| Sujet | Recommandation |
| :--- | :--- |
| Crypto | Hash mots de passe : `lyxal_crypto::password` (Argon2id) ; comparateurs bcrypt/pbkdf2/scrypt pour import = **besoin crypto à signaler au CTO** (hors scope actuel). TOTP (HMAC-SHA1) et WebAuthn/Passkey (ECDSA P-256, Ed25519, RSA) = **primitives non couvertes par `lyxal_crypto`**, validation CTO obligatoire avant toute implémentation. |
| SurrealQL / Rust | Règles de données (validation des traits, unicité des identifiants, calcul AAL, transitions d'état de flux, required actions) en SurrealQL ; protocoles (OIDC, SAML, WebAuthn, envoi) en Rust. |
| Core | Normalisation des identifiants (e-mail minuscule, trim, E.164) via `fn::sanitize_*` ; validation des traits via `fn::validation_object_execute`. Une règle manquante (ex. E.164) est un besoin d'extension Core à signaler. |
| Événements | Ne jamais référencer `lyxal_notification` : publier des événements de domaine (`auth.verification.code_issued`…) consommés par lui. |
| Hors scope initial suggéré | Authorization Services UMA, verifiable credentials, fédération LDAP, tokenizer JWT par gabarits (à reconsidérer en V2/V3). |
| Licence | Mentionner l'origine Apache-2.0 (Ory Kratos, Keycloak) dans le `README.md` de `lyxal_auth` et un fichier `NOTICE` si du code est repris. |
