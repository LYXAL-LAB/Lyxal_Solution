# Plan d'implémentation — `lyxal_auth`, lot 3 (connexion, sessions, jetons)

Plan détaillé du lot 3 du programme `lyxal_auth` V1 (`implementation_plan.md` à la racine, §6).
Il rend le module utilisable : mots de passe, parcours (inscription sur invitation, connexion,
vérification d'adresse, récupération, changement d'adresse et de mot de passe), émission et
révocation des sessions et jetons, accès SurrealDB `lyxal_auth`, anti-force-brute, actions
imposées, applications et comptes de service, clés d'API, routes HTTP `/auth/*`, premier
administrateur, purge. Modèle : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) (Kratos pour les
parcours et codes, Keycloak pour les actions imposées et l'anti-force-brute, Rauthy pour la
rotation des jetons de renouvellement, Logto pour les applications et clés d'API). Aucun code
avant validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Suite : lot 4 (double facteur), lot 5 (bascule de `lyxal_catalogue` et
`lyxal_pipeline_ingestion`).

## 0. Écarts au plan du programme (à valider)

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | Clé de signature des jetons d'accès : **chaîne aléatoire de 32 caractères** (`A-Z a-z 0-9 _ -`, 192 bits, `OsRng`) utilisée telle quelle comme clé HS256, au lieu d'une clé binaire | `DEFINE ACCESS … KEY '…'` attend un texte ; même choix que la clé `catalogue_sync` déjà en place. La signature passe par `lyxal_crypto::hmac` (`HmacKey` de 32 octets = les 32 caractères) |
| E2 | **Deux accès SurrealDB en alternance** (`lyxal_auth_a`, `lyxal_auth_b`) au lieu d'un seul `lyxal_auth` | Une rotation de clé sans couper les sessions : la nouvelle clé va dans l'accès inactif, qui devient actif ; l'ancien reste valable le temps de vie d'un jeton d'accès (15 min). SurrealDB n'accepte qu'une clé par accès |
| E3 | Appareil de la session (adresse IP, agent, dernière activité) dans un objet `client` de `auth_session`, sans table `auth_session_device` | Une ligne par session, aucune requête de jointure ; la table séparée n'apportait rien en V1 |
| E4 | `auth_session` porte un **sujet** : identité **ou** application (`identity` devient optionnel, `application` ajouté) | Les comptes de service (`client_credentials`) et les clés d'API obtiennent des sessions contrôlées par le même `fn::auth_session_valid` |
| E5 | Codes et liens à usage unique publiés comme l'invitation du lot 2 : champ transitoire `delivery` (illisible) publié par `DEFINE EVENT` puis effacé | Le secret scellé (`{ action_url, code }`) n'est jamais stocké, même chiffré ; même mécanisme éprouvé au lot 2 |

## 1. Périmètre

**Dans le lot 3** :

* mots de passe Argon2id (`lyxal_crypto::password`), politique (longueur, classes, historique),
  changement ;
* parcours persistés (`auth_flow`) : connexion, inscription sur invitation, inscription par lien
  d'installation (premier administrateur), vérification d'adresse, récupération, changement
  d'adresse ;
* codes à usage unique (6 chiffres) et liens (jeton de 32 octets), publiés scellés vers
  `lyxal_notification` ;
* sessions : émission, renouvellement à usage unique avec détection de réutilisation,
  révocation (une, toutes, par administrateur), changement d'organisation active, liste ;
* jetons d'accès JWT HS256 vérifiés par SurrealDB (`DEFINE ACCESS … AUTHENTICATE`), clés en
  rotation (E1, E2) ;
* anti-force-brute par identifiant et par adresse IP, verrouillage temporaire ;
* actions imposées (adresse à vérifier, mot de passe à changer, CGU à accepter) ;
* applications (navigateur, mobile, machine), secrets client, comptes de service
  (`client_credentials`), clés d'API personnelles ;
* rattachement automatique par domaine vérifié ;
* routes HTTP `/auth/*` de `lyxal-server`, commande de l'hôte pour le premier administrateur ;
* worker de purge.

**Hors lot 3** : double facteur et AAL2 (lot 4) ; bascule des autres modules (lot 5) ;
connexion par fournisseur externe, Lyxal fournisseur OIDC (V2).

## 2. Modèle de données (`schema/`, préfixe `auth_`)

Entités `TYPE NORMAL SCHEMAFULL`, clés UUID v7 hexadécimales, écriture par les fonctions
seulement (session système ou permission vérifiée), lecture limitée au sujet ou à
`auth.identity.manage`.

| Table | Champs principaux | Index et gardes |
| :--- | :--- | :--- |
| `auth_credential` | `identity` (`REFERENCE`, cascade), `type` (`password` ; `totp`, `passkey`, `recovery_code` au lot 4), `public_data` (objet), `secret_data` (`enc:v2`, **illisible** : permission de champ réservée à la session système), `created_at`, `last_used_at` | unique (`identity`, `type`) pour `password` |
| `auth_flow` | `type` (`login`, `registration`, `verification`, `recovery`, `address_change`), `state` (machine d'état par type, §3), `identity` (option), `organization` (option), `invitation` (option), `required_actions` (tableau), `attempts`, `client` (`{ ip, user_agent }`), `expires_at` | expiration courte (15 min, politique) |
| `auth_one_time_code` | `flow` (`REFERENCE`, cascade), `purpose` (`verification`, `recovery`, `address_change`, `setup`), `channel` (`email`), `address`, `code_hash` (HMAC-SHA256 du code avec la clé `code_pepper`), `link_hash` (BLAKE3 du jeton de lien), `attempts` (≤ 5), `consumed_at`, `expires_at`, `delivery` (transitoire, E5) | un code actif par (`flow`, `purpose`) |
| `auth_session` (étendue) | + `application` (E4), `kind` (`interactive`, `service`, `api_key`), `client` (E3), `refresh_family` (UUID), `access_slot` (`a`, `b`) | `identity` **ou** `application` obligatoire |
| `auth_refresh_token` | `session` (`REFERENCE`, cascade), `family`, `token_hash` (BLAKE3), `state` (`active`, `used`, `revoked`), `used_at`, `expires_at` | unique `token_hash` ; un seul `active` par session |
| `auth_login_failure` | `key_hash` (BLAKE3 de l'identifiant normalisé, ou de l'adresse IP), `kind` (`identifier`, `ip`), `failures`, `window_start`, `locked_until` | unique (`kind`, `key_hash`) ; aucune donnée en clair |
| `auth_required_action` | `identity` (`REFERENCE`, cascade), `action` (`verify_email`, `update_password`, `accept_terms` ; `configure_mfa` au lot 4), `reason`, `created_at` | unique (`identity`, `action`) |
| `auth_application` | `tenant` (option), `client_id` (texte public aléatoire), `name`, `type` (`spa`, `native`, `machine`), `redirect_uris` (tableau, contrôlé par `lyxal_core`), `token_ttl` (objet), `state` | unique `client_id` |
| `auth_application_secret` | `application` (`REFERENCE`, cascade), `secret_hash` (BLAKE3), `prefix` (8 caractères affichables), `expires_at`, `revoked_at` | plusieurs par application (rotation sans coupure) |
| `auth_api_key` | `identity` (`REFERENCE`, cascade), `name`, `key_hash` (BLAKE3), `prefix`, `permissions` (sous-ensemble des droits du propriétaire), `organization` (option), `expires_at`, `last_used_at`, `revoked_at` | unique `key_hash` |
| `auth_signing_key` | `purpose` (`access_token`, `code_pepper`), `slot` (`a`, `b`, pour `access_token`), `secret` (`enc:v2` sous `SecretContext::global("lyxal_auth.<purpose>")`, illisible), `state` (`active`, `previous`, `retired`), `activated_at` | un seul `active` par `purpose` |
| `auth_pending_address_change` | `identity` (`REFERENCE`, cascade), `new_address`, `flow`, `expires_at` | une seule en attente par identité |

Relation : `auth_has_role` étendue — `IN auth_identity | auth_member_of | auth_application`
(rôle d'installation pour une application sans locataire, rôle de son organisation sinon).

Seeds : politique de l'installation complétée (`code.ttl_seconds` 900, `code.max_attempts` 5,
`lockout.ip_max_failures` 50, `refresh.ttl_seconds` 2 592 000), permissions
`auth.application.manage` (installation), `auth.organization.application.manage`,
`auth.session.manage` (organisation), `auth.self.manage` (installation, accordée par défaut à
toute identité pour ses propres sessions, clés d'API et adresses).

## 3. Parcours

| Parcours | États | Résultat |
| :--- | :--- | :--- |
| `login` | `started` → `action_required` (actions imposées) → `completed` | session et jetons |
| `registration` | `started` (jeton d'invitation ou lien d'installation vérifié) → `completed` | identité, mot de passe, adhésion (invitation acceptée), session |
| `verification` | `code_sent` → `completed` | `auth_address.verified_at`, action `verify_email` levée, rattachement par domaine |
| `recovery` | `code_sent` → `code_verified` → `completed` | nouveau mot de passe, **toutes les sessions révoquées** (`not_before`) |
| `address_change` | `code_sent` (vers la nouvelle adresse) → `completed` | identifiant, adresse et trait remplacés ; événement vers l'ancienne adresse |

Règles :

* **Aucune énumération des comptes** : connexion avec identifiant inconnu → même erreur
  (`AUTH_CREDENTIALS_INVALID`) et même durée (vérification contre une empreinte factice) ;
  récupération et vérification répondent toujours « envoyé si l'adresse existe ».
* **Anti-force-brute** (Keycloak) : échec compté par identifiant (même inconnu) et par adresse
  IP ; au seuil de la politique (10 / 15 min par défaut), identifiant verrouillé
  `lockout.lock_seconds` (`AUTH_TOO_MANY_ATTEMPTS`, sans dire si le compte existe) ; une
  connexion réussie remet le compteur de l'identifiant à zéro.
* **Actions imposées** : à la connexion, une action en attente met le parcours en
  `action_required` ; aucune session n'est émise avant que les actions soient faites dans le
  parcours (`auth_flow_submit`).
* **Rattachement par domaine** : adresse vérifiée dont le domaine est vérifié et `auto_join` →
  adhésion avec les rôles par défaut du domaine.
* Récupération et changement de mot de passe révoquent les autres sessions ; changement
  d'adresse demande le mot de passe actuel.

## 4. Sessions et jetons

```text
Connexion réussie (session système de l'hôte)
  auth_session (state active, aal 1, amr [{ method: "password", at }], client, refresh_family)
  jeton d'accès JWT HS256 (15 min, clé de l'accès actif)
     { ac: "lyxal_auth_a|b", ns, db, id: "auth_session:<clé>", sub: identité ou application,
       tenant: organisation active, permissions: fn::auth_identity_permissions, pv, aal, jti, iat, exp }
  jeton de renouvellement opaque (32 octets OsRng, Base64 URL), empreinte BLAKE3 en base

Renouvellement (Rauthy)
  jeton présenté → empreinte → auth_refresh_token
    active  → marqué used, nouveau jeton de la même famille, nouveau jeton d'accès (permissions recalculées)
    used    → RÉUTILISATION : session et famille révoquées (AUTH_REFRESH_REUSED), événement
    absent / expiré / session invalide → AUTH_REFRESH_INVALID

SurrealDB
  DEFINE ACCESS lyxal_auth_a|b ON DATABASE TYPE RECORD WITH JWT ALGORITHM HS256 KEY '<clé>'
    AUTHENTICATE { IF !fn::auth_session_valid({}).valid { THROW "AUTH_SESSION_REVOKED" }; RETURN $auth; }
    DURATION FOR SESSION 15m
  + contrôle à chaque opération par fn::auth_session_valid (lot 2, inchangé)
```

* Durées : politique (`session.access_seconds`, `idle_seconds`, `absolute_seconds`) ; le
  renouvellement repousse `idle_expires_at`, jamais `expires_at`.
* Changement d'organisation active : nouvelle session pour la même identité (membre actif
  exigé), l'ancienne révoquée.
* Comptes de service : `client_id` + secret → session `service` sans jeton de renouvellement.
* Clés d'API : échange contre une session `api_key` dont les permissions sont l'intersection de
  celles de la clé et de celles du propriétaire.
* Rotation des clés : commande de l'hôte ou fonction système ; la clé est générée en Rust
  (`OsRng`), scellée, l'accès inactif redéfini, puis marqué actif. Chaque instance relit la clé
  active (cache de 30 s) ; un jeton signé avec l'ancienne clé reste accepté par l'ancien accès.

## 5. Fonctions publiques (`functions/`, `fn::auth_*($params: object)`)

Entrées par le moteur `lyxal_core`, retour `fn::result_ok` / `fn::error_result`, écriture
vérifiée (`AUTH_WRITE_FORBIDDEN`). Les fonctions de parcours et de session ne sont appelables
que par la **session système** de l'hôte (elles reçoivent des empreintes et des résultats de
vérification calculés en Rust) ; les fonctions « soi-même » par l'identité connectée.

| Domaine | Fonctions | Appelant |
| :--- | :--- | :--- |
| Mot de passe | `auth_password_credential_get` (empreinte scellée ou factice), `auth_password_set` (empreinte scellée, historique contrôlé en Rust à partir des empreintes renvoyées), `auth_password_policy_get` | système |
| Parcours | `auth_flow_start`, `auth_flow_get`, `auth_flow_submit` (transition contrôlée par type et état), `auth_flow_expire` | système |
| Codes | `auth_code_issue` (empreintes, secret scellé et `event_id` pour la publication, E5), `auth_code_verify` (empreinte présentée, tentatives) | système |
| Anti-force-brute | `auth_login_failure_record`, `auth_login_failure_check`, `auth_login_failure_reset` | système |
| Sessions | `auth_session_create`, `auth_session_refresh`, `auth_session_revoke`, `auth_session_revoke_all`, `auth_session_switch_organization` | système |
| Sessions (soi-même et gestion) | `auth_session_list` (les siennes ; celles d'une organisation avec `auth.session.manage`), `auth_session_revoke_own` | identité ; administrateur |
| Actions imposées | `auth_required_action_add`, `_list`, `_complete` | administrateur ; système |
| Applications | `auth_application_create`, `_update`, `_list`, `_secret_add` (empreinte), `_secret_revoke`, `auth_service_session_create` | `auth.application.manage` / `auth.organization.application.manage` ; système |
| Clés d'API | `auth_api_key_create` (empreinte), `_list`, `_revoke`, `auth_api_key_session_create` | identité (`auth.self.manage`) ; système |
| Adresses | `auth_address_change_request`, `auth_address_change_confirm`, `auth_address_verify` | système |
| Clés de signature | `auth_signing_key_get_active`, `auth_signing_key_rotate` (secret scellé fourni par Rust) | système |
| Premier administrateur | `auth_setup_start` (refus s'il existe déjà un `platform_admin` : `AUTH_SETUP_DONE`) | système |
| Purge | `auth_purge` (parcours, codes, sessions expirées, jetons, compteurs, invitations expirées, identités `deleted` au-delà de la conservation) | système |

## 6. Contrats Rust (`src/`)

Store `AuthStore` étendu (un wrapper `call_fn` par fonction, `XxxParams` / `XxxResult` dans
`models/` : `credential.rs`, `flow.rs`, `session.rs`, `application.rs`, `api_key.rs`). Exemples :

```rust
pub struct LoginRequest { pub identifier: String, pub password: SecretString, pub organization: Option<String>, pub client: ClientInfo }
pub enum LoginOutcome { Authenticated(IssuedTokens), ActionRequired { flow_id: AuthRecordId, actions: Vec<RequiredAction> } }
pub struct IssuedTokens { pub access_token: SecretString, pub refresh_token: Option<SecretString>, pub expires_in: u32, pub session: AuthRecordId }
pub struct SessionCreateParams { pub identity: Option<String>, pub application: Option<String>, pub organization: Option<String>,
                                 pub kind: SessionKind, pub amr: Vec<AuthMethod>, pub client: ClientInfo,
                                 pub refresh_token_hash: Option<String>, pub access_slot: String }
pub struct SessionRefreshParams { pub token_hash: String, pub new_token_hash: String }
pub struct CodeIssueParams { pub flow: String, pub purpose: CodePurpose, pub address: String, pub code_hash: String,
                             pub link_hash: String, pub event_id: String, pub secret: String /* enc:v2 */ }
```

Services (logique système ; les règles restent en SurrealQL) :

* `PasswordService` : hachage et vérification (`lyxal_crypto::password`), empreinte factice
  pour les identifiants inconnus, politique (longueur 12 à 128, classes, historique), `needs_rehash`.
* `TokenIssuer` : clé active (cache 30 s), JWT HS256 par `lyxal_crypto::hmac`, jetons de
  renouvellement (`OsRng`, `blake3_hex`).
* `FlowService` : connexion, inscription, vérification, récupération, changement d'adresse ;
  codes (6 chiffres, `OsRng`, HMAC `code_pepper`), liens (32 octets), secret
  `{ action_url, code }` scellé sous le contexte du contrat de `lyxal_notification` (README §4).
* `ApplicationService`, `ApiKeyService` : secrets et clés générés (`OsRng`), affichés une seule
  fois, stockés en empreinte.
* `SigningKeyService` : génération, scellement, redéfinition des accès `lyxal_auth_a|b`.
* `AuthPurgeWorker` (`LyxalWorker`, 15 min).
* Aucun secret dans un modèle public ; `Debug` masqué ; aucun `panic!`.

Dépendances : inchangées (aucune crate cryptographique ajoutée).

## 7. Hôte (`apps/lyxal-server`)

Routes JSON (réponses `LyxalResult`, erreurs `AUTH_*` sans détail interne) :

| Route | Rôle |
| :--- | :--- |
| `POST /auth/login` | connexion (`identifier`, `password`, `organization`) → jetons ou parcours `action_required` |
| `POST /auth/flows/{id}` | étape d'un parcours (action imposée, code, nouveau mot de passe) |
| `POST /auth/token/refresh` | renouvellement |
| `POST /auth/logout` | révocation de la session courante |
| `GET /auth/sessions`, `DELETE /auth/sessions/{id}` | sessions de l'identité |
| `POST /auth/session/organization` | changement d'organisation active |
| `POST /auth/registration` | inscription par jeton d'invitation ou lien d'installation |
| `POST /auth/recovery`, `POST /auth/verification`, `POST /auth/address-change` | démarrage (réponse identique que l'adresse existe ou non) |
| `POST /auth/password` | changement (mot de passe actuel exigé) |
| `POST /auth/service/token` | `client_credentials` |
| `POST /auth/api-keys/exchange` | clé d'API → jeton d'accès |

* L'identité de l'appelant des routes protégées : jeton d'accès vérifié par une session
  SurrealDB ouverte avec ce jeton (`authenticate`), jamais décodé seul par l'hôte.
* Au démarrage : clés de signature créées si absentes, accès `lyxal_auth_a|b` définis ;
  configuration `auth.public_url` (liens des messages). La clé applicative
  `LYXAL__CRYPTO__APPLICATION_KEY` (lot 2 bis) est obligatoire pour activer les routes ; sans
  elle, les routes `/auth/*` répondent `SERVER_AUTH_DISABLED` et la sonde est dégradée.
* Commandes : `lyxal-server admin setup --email <adresse>` (lien d'installation à usage unique,
  1 h, affiché une fois) ; `lyxal-server auth rotate-signing-key`.

## 8. Master data (`error/`, préfixe `AUTH_`)

Nouveaux codes : `AUTH_CREDENTIALS_INVALID` (message unique), `AUTH_PASSWORD_POLICY_VIOLATION`,
`AUTH_PASSWORD_REUSED`, `AUTH_TOO_MANY_ATTEMPTS`, `AUTH_IDENTITY_LOCKED`, `AUTH_REFRESH_INVALID`,
`AUTH_REFRESH_REUSED`, `AUTH_FLOW_NOT_FOUND`, `AUTH_FLOW_EXPIRED`, `AUTH_FLOW_INVALID_STATE`,
`AUTH_CODE_INVALID`, `AUTH_CODE_EXPIRED`, `AUTH_REQUIRED_ACTION_PENDING`,
`AUTH_REGISTRATION_CLOSED`, `AUTH_SETUP_DONE`, `AUTH_SETUP_TOKEN_INVALID`,
`AUTH_APPLICATION_NOT_FOUND`, `AUTH_CLIENT_CREDENTIALS_INVALID`, `AUTH_API_KEY_INVALID`,
`AUTH_API_KEY_EXPIRED`, `AUTH_ADDRESS_CHANGE_PENDING`, `AUTH_SIGNING_KEY_UNAVAILABLE` (fr et en,
catégorie, statut HTTP, réessayable). Hôte : `SERVER_AUTH_DISABLED`.

## 9. Événements

`auth.session.created`, `auth.session.revoked`, `auth.login.failed` (empreinte de
l'identifiant, jamais l'identifiant), `auth.identity.locked`, `auth.refresh.reused`,
`auth.verification.requested`, `auth.recovery.requested` (contrat de `lyxal_notification`,
secret scellé, E5), `auth.password.changed`, `auth.address.changed` (vers l'ancienne adresse),
`auth.application.created`, `auth.api_key.created`, `auth.api_key.revoked`. Aucun code, jeton ni
mot de passe dans une charge utile.

## 10. Fonctions Core réutilisées et besoins signalés

Réutilisées : `fn::validation_object_execute` (`email`, `required_string`, `uuid_v7`, `enum`,
`record`, `http_url`, `array_of_strings`, `integer`, `ip`), `fn::sanitize_object_execute`
(`email`, `trim`). Aucune fonction Core manquante identifiée. Crypto :
`hash_password`, `verify_password`, `PasswordHash::needs_rehash`, `sign_hmac_sha256`,
`blake3_hex`, `CryptoEngine::seal` / `open`, `OsRng` ; **aucun besoin nouveau**.

## 11. Tests

* **Banc SurrealQL** : chaque fonction publique ; machines d'état des parcours (transition
  interdite, expiration) ; codes (tentatives, expiration, usage unique, lien) ; anti-force-brute
  (seuil, verrouillage, remise à zéro, identifiant inconnu compté pareil) ; renouvellement
  (rotation, réutilisation → famille révoquée) ; révocations (une, toutes, `not_before`) ;
  changement d'organisation (non-membre refusé) ; applications, secrets, clés d'API
  (permissions limitées au propriétaire) ; actions imposées ; rattachement par domaine ;
  fonctions système refusées à une identité ; écritures filtrées → `AUTH_WRITE_FORBIDDEN` ;
  aucun secret lisible (champs illisibles).
* **Rust** : politique de mot de passe, empreinte factice (durée comparable), JWT (format,
  claims, signature vérifiée par SurrealDB embarqué), rotation de clé (ancien jeton accepté
  jusqu'à son expiration), parcours complets avec horloge contrôlée, codes reçus par le
  consommateur de `lyxal_notification` (bout en bout jusqu'au serveur SMTP de test).
* **Serveur réel SurrealDB 3.3.4** : connexion d'un client avec le jeton émis (accès
  `lyxal_auth_a`), refus après révocation **sur la connexion WebSocket restée ouverte**,
  rotation des accès ; routes HTTP de bout en bout.
* Revue de sécurité ciblée (OWASP ASVS niveau 2, chapitres authentification et sessions) avant
  la PR ; `scripts/ci/ci_local.sh` complet.

## 12. Fichiers

`crates/lyxal_auth/` : `schema/` (tables du §2), `functions/` (`credential/`, `flow/`,
`session/`, `application/`, `signing/`), `events/`, `error/` (thèmes `credentials`, `flows`),
`seeds/`, `tests/`, `src/` (`models/`, `services/`, `worker.rs`), `README.md`, `ROADMAP.md`.
Hôte : `src/modules/auth.rs`, `src/http/auth/` (routes), `src/config.rs` (`auth.public_url`),
commandes. Racine : plan du programme (lot 3 réalisé). Ce plan est supprimé une fois exécuté.

## 13. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | Écarts E1 à E5 (§0) | Valider |
| Q2 | Le premier administrateur reçoit un **lien d'installation** affiché par la commande de l'hôte (pas de mot de passe en argument ni par défaut) | Oui : aucun secret dans l'historique du terminal ni dans le dépôt |
| Q3 | Clés d'API personnelles dès ce lot (outil en ligne de commande, intégrations) | Oui : modèle Logto, permissions bornées par celles du propriétaire |
| Q4 | Comptage des échecs aussi **par adresse IP** (en plus de l'identifiant) | Oui : protège contre le test d'un mot de passe sur de nombreux comptes |
