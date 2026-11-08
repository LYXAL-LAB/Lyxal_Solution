# `lyxal_connect` (proposition) — connexions vers les services externes

Proposition de module, pas encore inscrite dans [`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md) :
sa création et sa place (après `lyxal_secrets` et `lyxal_scheduler`) sont soumises au CTO. Le
dossier ne contient que ce document ; aucun code avant un `implementation_plan.md` validé.

## Analyse de Composio, Activepieces et Nango

> Analyse en lecture seule des dépôts clonés (état au 2026-11-08). Les chemins cités sont relatifs à la racine de chaque dépôt. Rien n'a été modifié dans les dépôts.

---

## 1. Ce que contient réellement chaque dépôt

| | **Composio** | **Activepieces** | **Nango** |
|---|---|---|---|
| Licence | MIT (`LICENSE`, © 2025 Sampark Inc.), pour tout le dépôt | MIT Expat **sauf** `packages/ee/` et `packages/server/api/src/app/ee/`, sous licence Enterprise propriétaire (`packages/ee/LICENSE`) | Elastic License 2.0 pour tout le dépôt (`LICENSE`, `LICENSE_SHORT` « © Nango Inc, all rights reserved ») ; aucun sous-dossier sous une autre licence (13 `package.json` renvoient au fichier LICENSE, 2 déclarent `Elastic-2.0`) |
| Langage | TypeScript (`ts/packages/*`) + Python (`python/`) | TypeScript (Node / Bun), PostgreSQL ou SQLite via TypeORM, Redis | TypeScript (Node), PostgreSQL via Knex, Redis |
| Nature | **SDK client et CLI seulement** | **Plateforme complète** : API, worker, moteur d'exécution en bac à sable, interface web, catalogue | **Plateforme complète** : serveur, tâches, orchestrateur, runner, interface web, CLI, client |
| Serveur inclus ? | **Non.** Le SDK appelle l'API hébergée `https://backend.composio.dev` (`ts/packages/core/src/composio.ts`) via `@composio/client` | Oui (`packages/server/api`, `worker`, `engine`, `sandbox`) | Oui (`packages/server`, `jobs`, `orchestrator`, `runner`…) |
| Catalogue de connecteurs | **Pas d'implémentation.** Seulement un fichier de métadonnées pour la documentation : `docs/public/data/toolkits.json` (30 Mo, 1 718 toolkits, environ 77 000 noms d'outils et 716 déclencheurs) : slug, nom, description, catégorie, modes d'authentification, champs à saisir, scopes par défaut. Aucune URL d'autorisation ni de jeton, aucun code d'action | **Inclus** : `packages/pieces/community/*` (745 connecteurs) + `packages/pieces/core/*` (28 utilitaires) | **Définitions d'authentification incluses** : `packages/providers/providers.yaml` (≈ 1 200 fournisseurs). Les scripts d'actions et de synchronisation (« integration templates ») sont dans un **autre dépôt**, `NangoHQ/integration-templates` (cf. `scripts/sanity-templates-sync.ts`) |
| Gestion des comptes connectés | **Côté API hébergée uniquement.** Le SDK expose `connectedAccounts.list/get/refresh/revoke/updateStatus` et `authConfigs.*` (`ts/packages/core/src/models/ConnectedAccounts.ts`, `AuthConfigs.ts`), qui ne font que des appels HTTP. Stockage, chiffrement et renouvellement des jetons : tout est chez Composio | Dans le dépôt (`packages/server/api/src/app/app-connection/`) | Dans le dépôt (`packages/shared/lib/services/connection.service.ts`, `connections/credentials/refresh.ts`) |

**Conclusion pour Composio** : le dépôt ne contient ni les définitions des toolkits, ni la gestion OAuth, ni le stockage des comptes connectés. Il ne sert qu'à **lire un vocabulaire** : les statuts et les modes d'authentification exposés par les types Zod du SDK. Ce vocabulaire est décrit en §2.3.

---

## 2. Modèle de données des connexions

### 2.1. Activepieces (entités TypeORM, 414 migrations PostgreSQL)

| Entité / table | Champs principaux | Rôle | Licence |
|---|---|---|---|
| `app_connection` (`app-connection/app-connection.entity.ts`) | `id`, `created`, `updated`, `externalId` (clé fonctionnelle), `displayName`, `type` (enum ci-dessous), `status` (`ACTIVE` / `MISSING` / `ERROR`), `platformId`, `projectIds[]` (index GIN), `scope` (`PROJECT` / `PLATFORM`), `pieceName`, `pieceVersion`, `ownerId` → `user`, **`value` (jsonb chiffré `{iv, data}`)**, `metadata`, `preSelectForNewProjects`. Index `(platformId, externalId)` | Compte connecté : identifiants, jetons et état de la connexion | MIT |
| `oauth_app` (`ee/oauth-apps/oauth-app.entity.ts`) | `platformId`, `pieceName`, `clientId`, `clientSecret` (jsonb chiffré) ; unicité `(platformId, pieceName)` | Application OAuth propre au locataire (client_id et secret par connecteur) | **EE, propriétaire** |
| `piece_metadata` (`pieces/metadata/piece-metadata-entity.ts`) | `name`, `version`, `displayName`, `logoUrl`, `description`, `authors`, `platformId`, `minimum/maximumSupportedRelease`, **`auth` (jsonb)**, **`actions` (jsonb)**, **`triggers` (jsonb)**, `pieceType`, `packageType`, `categories`, `deprecated`, `archiveId` | Catalogue des connecteurs installés, avec leur description sérialisée | MIT |
| `app_event_routing` (`trigger/app-event-routing/…`) | `appName`, `projectId`, `flowId`, `identifierValue`, `event` ; unicité sur les cinq colonnes | Routage des webhooks d'application (stratégie `APP_WEBHOOK`) vers les flux abonnés | MIT |
| `trigger_event` | événements reçus par déclencheur | Historique des déclenchements | MIT |
| `secret_manager` (`ee/secret-managers/`) | — | Coffres externes (Vault, etc.) | **EE** |

Types de `value` (`packages/core/shared/src/lib/automation/app-connection/app-connection.ts`) :

| `type` | Contenu chiffré |
|---|---|
| `OAUTH2` | `client_id`, `client_secret`, `redirect_url`, `access_token`, `refresh_token`, `token_type`, `expires_in`, `claimed_at`, `scope`, `token_url`, `authorization_method`, `grant_type`, `props`, `data` |
| `CLOUD_OAUTH2` | identique sans `client_secret` : l'application OAuth appartient à Activepieces, et le jeton est renouvelé par `https://secrets.activepieces.com/refresh` (service fermé) |
| `PLATFORM_OAUTH2` | identique, avec l'application OAuth du locataire (EE) |
| `SECRET_TEXT` | `secret_text` (clé API) |
| `BASIC_AUTH` | `username`, `password` |
| `CUSTOM_AUTH` | `props` libres, plus `access_token` et `token_refresh_at` si le connecteur sait renouveler son jeton |
| `OIDC`, `NO_AUTH` | `props` ; rien |

### 2.2. Nango (290 migrations Knex dans `packages/database/lib/migrations`, types dans `packages/types/lib`)

| Table | Champs principaux | Rôle |
|---|---|---|
| `_nango_accounts` / `_nango_environments` | compte (équipe) → environnements (prod, dev…) | Locataire et cloisonnement |
| `_nango_configs` (`IntegrationConfig`, `integration/db.ts`) | `unique_key` (clé d'intégration), `provider` (renvoie à `providers.yaml`), `oauth_client_id`, `oauth_client_secret` + `_iv` + `_tag` (chiffrés), `oauth_scopes`, `app_link`, `custom` (paramètres propres au fournisseur), `missing_fields`, `display_name`, `forward_webhooks`, `allow_unverified_webhooks`, `shared_credentials_id`, `environment_id` | **Intégration** (« auth config ») : application OAuth configurée par environnement |
| `providers_shared_credentials` | identifiants OAuth gérés par Nango, avec un indicateur `enabled` | Applications OAuth mutualisées |
| `_nango_connections` (`DBConnection`, `connection/db.ts`) | `connection_id` (identifiant fonctionnel), `config_id`, `environment_id`, `end_user_id`, `tags`, `connection_config` (scopes, paramètres d'autorisation, sous-domaine…), `metadata`, **`credentials.encrypted_credentials` + `credentials_iv` + `credentials_tag`**, `credentials_expires_at`, `last_fetched_at`, **`last_refresh_success`, `last_refresh_failure`, `refresh_attempts`, `refresh_exhausted`**, `webhook_url_override`, horodatages, suppression logique | **Compte connecté** |
| `_nango_end_users` (`DBEndUser`) | `end_user_id`, `email`, `display_name`, `organization_id`, `organization_display_name`, `tags` | Utilisateur final du client SaaS qui possède la connexion |
| `_nango_oauth_sessions` (`DBOAuthSession`) | `id` (sert de `state`), `provider_config_key`, `provider`, `connection_id`, `callbackUrl`, `authMode`, `connect_session_id`, `connection_config`, **`code_verifier`** (PKCE), `request_token_secret` (OAuth 1.0a), `web_socket_client_id`, `activity_log_id` | État temporaire de la danse OAuth (contre le CSRF, PKCE) |
| `connect_sessions` | jeton de session de l'interface de connexion | Lien de connexion délivré à l'utilisateur final |
| `_nango_sync_configs` (`DBSyncConfig`) | `sync_name`, `nango_config_id`, `type` (sync / action), `version`, `models`, `models_json_schema`, `runs` (fréquence), `track_deletes`, `auto_start`, `webhook_subscriptions`, `input`, `enabled`, `file_location` | Définition déployée d'une synchronisation ou d'une action |
| `_nango_syncs` (`DBSync`) | `nango_connection_id`, `name`, `variant`, `sync_config_id`, `frequency`, `last_sync_date`, `last_fetched_at` | Instance de synchronisation par connexion |
| `records` (paquet `records`) | enregistrements synchronisés, par modèle | Cache des données synchronisées |
| webhooks | `forward_webhooks` sur l'intégration ; scripts `webhook_routing_script` déclarés dans `providers.yaml` ; webhooks sortants vers le client (création, renouvellement, échec de connexion) | Webhooks entrants et sortants |

### 2.3. Composio (vocabulaire visible dans le SDK seulement ; le schéma réel est fermé)

| Entité | Champs exposés par le SDK |
|---|---|
| Auth config | `type` (`use_custom_auth` ou `use_composio_managed_auth`), `authScheme` (15 valeurs : `OAUTH2`, `OAUTH1`, `API_KEY`, `BASIC`, `BEARER_TOKEN`, `GOOGLE_SERVICE_ACCOUNT`, `SERVICE_ACCOUNT`, `SAML`, `DCR_OAUTH`, `CIMD_OAUTH`, `S2S_OAUTH2`, `NO_AUTH`…), `credentials`, `proxyConfig`, `toolsAvailableForExecution` |
| Connected account | `id`, `userId`, `status` (`INITIALIZING`, `INITIATED`, `ACTIVE`, `FAILED`, `EXPIRED`, `INACTIVE`, `REVOKED`), `statusReason`, `accountType` (`PRIVATE` ou `SHARED`, avec une liste d'accès `allowAllUsers` / `allowedUserIds`), `authConfig` |
| Trigger, webhook | abonnements gérés côté API |

Le cycle d'états `INITIATED → ACTIVE → EXPIRED / FAILED / REVOKED` et la notion de compte partagé avec liste d'accès sont de bonnes idées de conception à reprendre.

---

## 3. Catalogue de connecteurs

| | Activepieces | Nango | Composio |
|---|---|---|---|
| Volume | 745 connecteurs communautaires + 28 de base | ≈ 1 200 fournisseurs (définitions d'authentification et de proxy) | 1 718 toolkits (métadonnées seulement) |
| Organisation | un paquet npm par connecteur : `packages/pieces/community/<nom>/src/index.ts` et `src/lib/{auth.ts, actions/*.ts, triggers/*.ts, common/}` | un seul fichier `packages/providers/providers.yaml` | `docs/public/data/toolkits.json` |
| Format | Code TypeScript : `createPiece({ auth, actions, triggers, categories, logoUrl, minimumSupportedRelease })`, `createAction({ name, auth, props, run, classification })`, `createTrigger({ type: POLLING \| WEBHOOK \| APP_WEBHOOK \| MANUAL, onEnable, onDisable, run, test, onRenew, renewConfiguration, handshakeConfiguration, sampleData })` | YAML déclaratif : `display_name`, `categories`, `auth_mode`, `authorization_url`, `token_url`, `default_scopes`, `authorization_params`, `token_params`, `refresh_params`, `disable_pkce`, `token_expiration_buffer`, `proxy.base_url`, `proxy.retry`, `proxy.paginate`, `webhook_routing_script`, `post_connection_script`, `docs` | JSON : `slug`, `authSchemes`, `authConfigDetails.fields` (champs requis et facultatifs, scopes par défaut), liste `tools` et `triggers` (nom et description) |
| Modes d'authentification | `PieceAuth.SecretText` (571 connecteurs), `CustomAuth` (243), **`OAuth2` (125)**, `None` (24), `BasicAuth` (12), `OIDC` | `API_KEY` 464, **`OAUTH2` 315**, `BASIC` 115, `OAUTH2_CC` 111, `TWO_STEP` 71, `MCP_OAUTH2` 39, `OAUTH1` 5, `JWT` 4, et d'autres plus rares (`AWS_SIGV4`, `APP`, `SIGNATURE`, `TBA`, `BILL`…) | 15 valeurs `authScheme` |
| Définition OAuth | dans le code de chaque connecteur, par exemple `gmail/src/lib/auth.ts` : `PieceAuth.OAuth2({ authUrl, tokenUrl, scope: [...], prompt, pkce, pkceMethod, authorizationMethod, grantType, extra, props })`, avec des URL paramétrables par `{prop}` | dans le YAML, par exemple `microsoft:` avec `authorization_url: https://login.microsoftonline.com/common/oauth2/v2.0/authorize`, `token_url`, `default_scopes: [offline_access, .default]`, `refresh_params` | scopes par défaut seulement |
| Connecteurs utiles à Lyxal présents | `google-*` (Calendar, Drive, Sheets, Docs, Contacts…), `microsoft-*` (Outlook, Teams, SharePoint, OneDrive, Excel 365, Dynamics BC), `slack`, `dropbox`, `odoo`, `sage-accounting`, `quickbooks`, `xero` | équivalents, plus de nombreux ERP et logiciels de comptabilité | — |
| **Réutilisable sous MIT ?** | **Oui** (hors `ee/`). Le code est en TypeScript, donc pas exécutable dans Lyxal (Rust et SurrealQL) ; en revanche les **définitions d'authentification** (URL, scopes, paramètres) et la structure actions / déclencheurs peuvent être extraites et converties en seeds Lyxal, avec mention du copyright MIT | **Non.** ELv2 : référence de conception seulement. Ne pas copier `providers.yaml` dans Lyxal ; vérifier chaque URL dans la documentation officielle du fournisseur | Techniquement MIT, mais de faible valeur : métadonnées sans URL ni code, extraites d'une API fermée |

---

## 4. Mécanique OAuth

| Aspect | Activepieces | Nango |
|---|---|---|
| Chiffrement des jetons | `helper/encryption.ts` : **AES-256-CBC**, IV de 16 octets, **sans authentification** (pas de tag), une seule clé globale `AP_ENCRYPTION_KEY`, sans rotation ni AAD. Tout l'objet `value` est chiffré d'un bloc | `utils/lib/encryption.ts` : **AES-256-GCM** avec `iv` et `tag` stockés en colonnes, clé `NANGO_ENCRYPTION_KEY` (rotation refusée : `encryption.manager.ts`), enveloppe KMS facultative (`packages/kms`, Azure Key Vault et AWS) |
| Renouvellement | **Paresseux, à l'usage** : `lockAndRefreshConnection` avec un verrou distribué Redis de 60 s ; seuil `isExpired` = expiration − **15 min** (`oauth2-util.ts`) ; un `CUSTOM_AUTH` est renouvelé par une tâche du moteur (`EXECUTE_TOKEN_REFRESH`) | **À l'usage et en tâche de fond** : verrou Redis `lock:refresh:{env}:{intégration}:{connexion}` ; marge de **15 min** (`REFRESH_MARGIN_MS`, réglable par fournisseur avec `token_expiration_buffer`) ; tâche planifiée `server/lib/crons/refreshConnections.ts` qui renouvelle, sous un verrou global, les connexions non consultées depuis un jour |
| Gestion des erreurs | `invalid_grant` est la seule erreur considérée comme une erreur utilisateur : la connexion passe en `status = ERROR`. Les autres erreurs sont relancées. Sur expiration du délai du moteur, les identifiants existants sont conservés (avec un avertissement) | Délai de 30 s après un échec (`connection_refresh_backoff`) ; compteur `refresh_attempts` ; au bout de **4 jours consécutifs d'échec**, `refresh_exhausted = true` (`connection_refresh_exhausted`) ; horodatages du dernier succès et du dernier échec ; webhook sortant et alerte Slack |
| Multi-locataire | `platformId` → `projectIds[]`, avec une portée `PROJECT` ou `PLATFORM` ; application OAuth par plateforme (EE) | compte → environnement → intégration → connexion → utilisateur final (`end_user_id`, organisation) |
| Danse OAuth | `oauth2-service.ts`, `oauth2-discovery.ts` (découverte), PKCE, `client_credentials` | table `_nango_oauth_sessions` (state, `code_verifier`), sessions de connexion, OAuth 1.0a, PKCE désactivable par fournisseur |

**À retenir** : Nango a la meilleure conception (GCM, colonnes de santé du renouvellement, abandon après N jours, renouvellement de fond). Le chiffrement CBC non authentifié d'Activepieces ne doit **pas** servir de modèle. Dans Lyxal, le chiffrement passera de toute façon par `lyxal_crypto` (`CryptoEngine::seal`, enveloppe `enc:v2`, AAD `SecretContext::with_tenant`).

---

## 5. Recommandation pour Lyxal

### 5.1. Quoi reprendre

| Source | Usage recommandé |
|---|---|
| **Activepieces (MIT, hors `ee/`)** | **Seule base dont on peut réutiliser des éléments.** (1) Extraire par script les définitions `PieceAuth.*` (URL d'autorisation et de jeton, scopes, `pkce`, `authorizationMethod`, `extra`, champs des `CustomAuth` et `SecretText`) des connecteurs prioritaires (Google, Microsoft 365, Slack, Odoo, Sage, Xero, QuickBooks, Dropbox) vers un seed SurrealQL du catalogue. Conserver l'avis de copyright MIT dans le module. (2) Reprendre les noms d'actions et de déclencheurs et les stratégies de déclenchement (`POLLING`, `WEBHOOK`, `APP_WEBHOOK`, renouvellement de webhook, poignée de main). (3) S'inspirer du routage `app_event_routing`. Ne pas reprendre `ee/` (applications OAuth par plateforme, gestionnaires de secrets) ni le chiffrement CBC |
| **Nango (ELv2)** | **Conception seulement, aucun code ni fichier copié.** Modèle intégration / connexion / utilisateur final / session OAuth ; colonnes de santé du renouvellement (`last_refresh_success`, `last_refresh_failure`, `refresh_attempts`, `refresh_exhausted`, `credentials_expires_at`) ; tâche de renouvellement de fond ; format déclaratif d'un fournisseur (bon modèle pour un catalogue en données plutôt qu'en code) |
| **Composio (MIT)** | Vocabulaire seulement : cycle d'états des comptes connectés, compte privé ou partagé avec liste d'accès, liste des modes d'authentification. Rien d'exécutable : tout est côté API hébergée |

Le code TypeScript n'étant pas exécutable dans Lyxal, la « reprise » est une **reprise de données et de conception**, convertie en schéma SurrealQL et en Rust. Exécuter des connecteurs Activepieces tels quels supposerait un moteur Node.js en bac à sable : c'est un choix d'architecture distinct, à soumettre au CTO.

### 5.2. Module proposé : `lyxal_connect` (ou `lyxal_integration`)

Il se placerait dans le **Noyau technique**, après `lyxal_secrets` et `lyxal_scheduler`. Ses dépendances : `lyxal_auth`, `lyxal_secrets`, `lyxal_crypto`, `lyxal_event`, `lyxal_scheduler`. Les modules métiers le consomment.

| Couche | Contenu |
|---|---|
| Données SurrealQL | `connect_provider` (catalogue déclaratif : `auth_mode`, URL, scopes, paramètres, `proxy_base_url`, stratégie de déclenchement ; seedé depuis les définitions MIT extraites) ; `connect_integration` (application OAuth par locataire ; `client_secret` → référence `lyxal_secrets`) ; `connect_account` (compte connecté : `tenant`, `owner` vers une identité `lyxal_auth`, `provider`, `status` `pending` / `active` / `error` / `expired` / `revoked`, `scopes`, `expires_at`, `last_refresh_success`, `last_refresh_failure`, `refresh_attempts`, `refresh_exhausted`, `secret_ref` vers `lyxal_secrets`, `visibility` privée ou partagée) ; `connect_oauth_session` (state, `code_verifier` PKCE, expiration courte) ; `connect_webhook_route` |
| Rust | danse OAuth 2.0 (autorisation, échange, PKCE, `client_credentials`), renouvellement (`LyxalWorker` de fond et renouvellement à l'usage sous bail distribué, sur le modèle des baux `lyxal_runtime`), proxy HTTP authentifié, réception des webhooks |
| Événements | `connect.account.created`, `connect.account.refresh_failed`, `connect.account.revoked`, `connect.webhook.received`, vers `lyxal_notification` et les modules métiers |
| Hors périmètre initial | synchronisations de données et actions métier par fournisseur : elles relèvent des modules métiers ou d'une phase V3 ; sinon il faudrait un moteur de scripts, à soumettre au CTO |

### 5.3. Frontières avec `lyxal_auth` et `lyxal_secrets`

| Besoin | Module propriétaire | Remarque |
|---|---|---|
| Un utilisateur **se connecte à Lyxal** avec Google ou Microsoft (connexion entrante) | **`lyxal_auth`** (fédération OIDC : `id_token`, lien entre identité externe et identité Lyxal) | Ne crée **pas** de compte connecté et ne conserve pas de jeton d'API |
| Lyxal **agit pour le compte** d'un utilisateur ou d'un locataire chez un tiers (connexion sortante : lire l'agenda, envoyer un e-mail, synchroniser la comptabilité) | **`lyxal_connect`** | Le propriétaire du compte connecté est une identité `lyxal_auth` ; l'autorisation d'usage suit `lyxal_auth` |
| Stockage des `access_token`, `refresh_token`, `client_secret` et clés API | **`lyxal_secrets`** (chiffrés par `lyxal_crypto`, enveloppe `enc:v2`, AAD `with_tenant(tenant, "lyxal_connect", "connect_account", id, "credentials")`) | `lyxal_connect` ne garde qu'une **référence** et les métadonnées non sensibles (expiration, scopes, état) |

Le catalogue `connect_provider` peut servir aux deux modules : `lyxal_auth` lirait les URL OIDC d'un fournisseur par la fonction publique `fn::connect_provider_get`. Le CTO peut aussi décider de garder une configuration OIDC propre à `lyxal_auth`, pour éviter que l'identité dépende d'un module situé au-dessus d'elle. C'est à trancher dans le plan, conformément au §6 : un composant ne dépend jamais d'un composant de niveau supérieur, et `lyxal_auth` est en dessous de `lyxal_connect`.

### 5.4. Points à soumettre au CTO

1. Licence : confirmer que l'extraction des définitions d'authentification d'Activepieces (MIT) est acceptée, avec conservation de l'avis de copyright, et que Nango (ELv2) reste une référence de conception seulement.
2. Catalogue en données (seeds SurrealQL) plutôt qu'en code par connecteur ; périmètre initial limité à environ 10 fournisseurs prioritaires.
3. Ordre de la feuille de route : `lyxal_connect` après `lyxal_secrets` et `lyxal_scheduler` (mise à jour de `docs/14-roadmap/ROADMAP_NOYAU.md`).
4. Aucun nouveau besoin cryptographique : AES-256-GCM et l'enveloppe existent déjà ; PKCE (SHA-256) est couvert par `lyxal_crypto::hash::sha256` ; la génération du state et du `code_verifier` passe par `OsRng`.
