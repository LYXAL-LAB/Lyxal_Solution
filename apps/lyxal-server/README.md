# `lyxal-server` — Hôte de processus de Lyxal OS

`lyxal-server` est le binaire qui fait tourner Lyxal OS : il charge la configuration, se connecte
à SurrealDB, installe et démarre les modules par `lyxal_runtime`, puis sert l'API HTTP système.
Il ne contient aucune logique métier (`AGENTS.md` §5.8.5).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3.

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Démarrage

```text
configuration (config/*.toml + variables LYXAL__*)
  → journalisation
  → connexion SurrealDB (lyxal_surreal)
  → installation rejouable : lyxal_core, lyxal_error, définitions SERVER_*, schéma du runtime
  → LyxalRuntime (store SurrealDB, baux, moteur d'événements)
  → services des modules (workers, consommateurs d'événements, sondes de santé)
  → install_packages : tous les modules hébergés (releases, migrations sous bail)
  → services dépendant des modules installés (accès JWT, abonnements)
  → start_all : modules, workers, EventWorker et ramasse-miettes
  → HTTP
arrêt (SIGINT / SIGTERM) → stop_all (workers puis modules, ordre inverse)
```

L'`EventWorker` traite toutes les livraisons de la base de l'instance : les événements émis par
la base (`DEFINE EVENT`) ne portent pas l'identifiant de l'instance hôte, et chaque instance a sa
propre base.

Un module déjà installé dans la même version n'est pas réinstallé ; une installation
interrompue est reprise en rejouant ses ressources (toutes rejouables). Un échec d'installation
ou de démarrage arrête le serveur.

---

## 2. Modules hébergés

`build.rs` lit le `manifest.toml` de chaque module hébergé et **embarque dans le binaire** le
manifeste et les fichiers déclarés dans `[resources]`. La compilation échoue si un fichier
déclaré manque.

| Module | Inclus | Implémentation |
| :--- | :--- | :--- |
| `lyxal_core` | toujours | `ManifestModule` (SurrealQL seul) |
| `lyxal_error` | toujours | `ManifestModule` |
| `lyxal_event` | toujours | `ManifestModule` ; moteur démarré par le runtime |
| `lyxal_auth` | toujours | `AuthModule`, `AuthHealthCheck` |
| `lyxal_notification` | toujours | `NotificationModule`, `NotificationConsumer` (événements `auth.*`), `NotificationEmailWorker`, `NotificationPurgeWorker`, `NotificationHealthCheck` |
| `lyxal_storage` | toujours | `StorageModule`, `StorageCleanupWorker` (si un support est configuré), `StorageHealthCheck` |
| `lyxal_base` | toujours | `ManifestModule` |
| `lyxal_catalogue` | toujours | `ManifestModule` (SurrealQL seul) |
| `lyxal_pipeline_ingestion` | fonctionnalité `module-ingestion` (par défaut) | `PipelineIngestionModule`, `IngestionWorker`, `IngestionHealthCheck` |

Ajouter un module : l'inscrire dans `MODULES` de `build.rs` (ordre des dépendances), et, s'il a
du code Rust, déclarer son implémentation et ses services dans `src/modules/` (`auth.rs`,
`notification.rs`, `storage.rs`, `ingestion.rs`).

---

## 3. Configuration

`config/default.toml`, puis `config/<LYXAL_ENV>.toml`, puis les variables d'environnement
`LYXAL__<SECTION>__<CLÉ>`. Toute clé inconnue est refusée.

| Section | Clés |
| :--- | :--- |
| `application` | `name`, `environment`, `instance_id`, `version` |
| `server` | `host`, `port`, `request_timeout_seconds`, `graceful_shutdown_seconds`, `max_concurrency`, `body_limit_bytes`, `trusted_proxies` (facultative : proxys inverses de confiance) |
| `database` | `endpoint` (`ws://`, `wss://`, `mem://`), `namespace`, `database`, `username`, `password`, `connect_timeout_seconds` |
| `runtime` | `module_install_timeout_seconds`, `module_start_timeout_seconds`, `module_stop_timeout_seconds` |
| `observability` | `log_filter`, `json_logs`, `include_target`, `include_thread_ids` |
| `cors` | `enabled`, `allow_credentials`, `allowed_origins`, `allowed_methods`, `allowed_headers` |
| `crypto` | `application_key` (facultative, variable d'environnement seulement), `application_key_id` |
| `auth` | `public_url` (facultative : adresse publique de l'interface, pour les liens des messages et l'origine des passkeys), `passkey_rp_id` (facultatif : domaine des passkeys, défaut : hôte de `public_url`) |
| `notification.smtp` | `host`, `port`, `security` (`tls`, `starttls`, `local_plain`), `username`, `password`, `from_address`, `from_name`, `timeout_seconds` (section facultative) |
| `storage.disk` | `root` (section facultative : dossier du support de fichiers `default`) |

Les identifiants Root ne figurent dans aucun fichier : `LYXAL__DATABASE__USERNAME` et
`LYXAL__DATABASE__PASSWORD` (mot de passe en `SecretString`, masqué). Une connexion `ws://` ou
`wss://` sans identifiants est refusée. Le serveur refuse aussi de démarrer si la base distante
accepte les connexions anonymes (`surreal start --allow-guests`) : SurrealDB n'y distingue pas un
invité de la session système de l'hôte, qui a tous les droits.

Derrière un proxy inverse (terminaison TLS, répartiteur), `server.trusted_proxies` liste ses
adresses ou réseaux (`["10.0.0.0/8", "192.0.2.10"]`, ou
`LYXAL__SERVER__TRUSTED_PROXIES=10.0.0.0/8,192.0.2.10`). L'adresse du client, utilisée par
l'anti-force-brute de `lyxal_auth`, est alors lue dans `X-Forwarded-For` : l'adresse la plus à
droite qui n'est pas un proxy de confiance. Une connexion venant d'une autre adresse n'est jamais
crue sur cet en-tête. Vide par défaut : adresse de la connexion.

Les réponses des routes `/api/v1/auth/*` portent `Cache-Control: no-store`. Les liens envoyés
par e-mail (installation, récupération, vérification, invitation) transmettent leur jeton dans
le fragment (`#token=…`), jamais envoyé au serveur web ni écrit dans ses journaux.

La publication du pipeline d'ingestion vers le catalogue passe par le compte de service
`lyxal_auth` `lyxal-catalogue-sync` (rôle `catalogue_sync`, créé par les seeds de
`lyxal_pipeline_ingestion`). L'hôte ouvre ses sessions par sa session système, sans secret
(`AccessService::internal_service_token`) : un jeton d'accès frais par publication, aucune clé
partagée à configurer. La publication est active, et abonnée à `ingestion.manifest.approved`,
quand le service de connexion est configuré (clé applicative et `auth.public_url`) ; sinon elle
est désactivée, les approbations attendent en file et la sonde de santé du pipeline est
dégradée. Le test `tests/publication.rs` (exécutable séparé, il fournit la clé applicative par
variable d'environnement) la vérifie de bout en bout.

Les notifications (`lyxal_notification`) demandent la clé applicative de l'hôte et un relais
SMTP. La clé AES-256 (32 octets en Base64 canonique, 44 caractères) ne figure dans aucun
fichier : `LYXAL__CRYPTO__APPLICATION_KEY`, lue par `lyxal_crypto::EnvironmentKeyProvider`, avec
son identifiant `LYXAL__CRYPTO__APPLICATION_KEY_ID` (ex. `app-2026`, inscrit dans chaque
enveloppe `enc:v2`). Le relais : `LYXAL__NOTIFICATION__SMTP__HOST`, `__PORT`, `__SECURITY`,
`__FROM_ADDRESS`, et si besoin `__USERNAME` / `__PASSWORD` (variable d'environnement seulement).
`local_plain` (sans chiffrement) n'est accepté que pour un relais de la boucle locale. Sans clé
ou sans relais, aucun e-mail n'est envoyé : les abonnements aux événements `auth.*` restent
suspendus (les événements attendent en file) et la sonde du module est dégradée.

Le stockage des fichiers (`lyxal_storage`) écrit sous un dossier du serveur :
`LYXAL__STORAGE__DISK__ROOT` (créé s'il n'existe pas ; à placer sur un volume sauvegardé, hors
du dossier de l'application). C'est le support `default` des buckets. Sans dossier, le serveur
démarre : aucun fichier n'est écrit ni lu (`STORAGE_BACKEND_UNKNOWN`), le worker de nettoyage
n'est pas lancé et la sonde du module est dégradée. Les routes d'envoi et de téléchargement
arrivent avec le lot suivant du module.

La connexion (`lyxal_auth`) demande la clé applicative et `auth.public_url`
(`LYXAL__AUTH__PUBLIC_URL`, ex. `https://console.example.com`). Au démarrage, l'hôte crée les
clés de signature absentes (scellées par la clé applicative) et définit les accès SurrealDB
`lyxal_auth_a` / `lyxal_auth_b`. Sans clé ou sans adresse, les routes `/api/v1/auth/*`
répondent `SERVER_AUTH_DISABLED` (503) et la sonde du module est dégradée.

```bash
LYXAL__DATABASE__ENDPOINT=ws://127.0.0.1:8000 \
LYXAL__DATABASE__USERNAME=root LYXAL__DATABASE__PASSWORD=root \
cargo run -p lyxal-server
```

---

## 4. Routes

| Route | Réponse |
| :--- | :--- |
| `GET /`, `GET /api/v1/system/info` | Nom, version, environnement, instance. |
| `GET /live` | `204` tant que le processus répond. |
| `GET /ready` | `204` si le serveur et la base sont opérationnels, sinon `503`. |
| `GET /health` | Statuts des composants (serveur, base) et des modules (sondes `ModuleHealthCheck` évaluées par le runtime), sans détail interne ; `503` si un module est en panne. |
| `GET /metrics` | Compteurs de requêtes et durée de fonctionnement. |
| `GET /api/v1/system/modules` | Modules hébergés : identifiant, nom, version, état. |

Connexion (`/api/v1/auth`, JSON, réponses `LyxalResult`, erreurs `AUTH_*` sans détail sur
l'existence d'un compte ; langue des messages par `Accept-Language`). Les routes marquées 🔒
exigent `Authorization: Bearer <jeton d'accès>` : signature vérifiée avec la clé de son
emplacement, puis session contrôlée par la base (révocation, expiration, version des droits).
Sauf `/logout`, elles demandent une session **interactive** : le jeton d'une clé d'API ou d'un
compte de service ne gère pas le compte (`AUTH_PERMISSION_DENIED`).

| Route | Corps | Réponse |
| :--- | :--- | :--- |
| `POST /login` | `identifier`, `password`, `organization` | jetons (`status: authenticated`) ou `status: action_required` avec `flow` et `actions` |
| `POST /flows/{flow}/actions` | `new_password`, `accept_terms` | jetons, ou actions restantes (relues en base) |
| `POST /flows/{flow}/verification` | — | code de vérification d'adresse pour un parcours qui attend `verify_email` (`202`), à présenter à `/verification/complete` |
| `POST /token/refresh` | `refresh_token` | nouveaux jetons (réutilisation → session révoquée) |
| `POST /logout` 🔒 | — | session courante révoquée |
| `GET /sessions` 🔒 | — | sessions de l'identité (`current` pour la courante) |
| `DELETE /sessions/{session}` 🔒 | — | révoque une de ses sessions |
| `POST /session/organization` 🔒 | `organization` | nouvelle session dans l'organisation (membre actif) |
| `POST /registration/start` | `token`, `setup` | parcours d'inscription (invitation ou lien d'installation) |
| `POST /registration/complete` | `flow`, `password`, `traits` | identité créée, jetons (`201`) |
| `POST /recovery` | `email` | `202`, même réponse que l'adresse existe ou non |
| `POST /recovery/complete` | `flow` + `code`, ou `token` (lien) ; `new_password` | toutes les sessions révoquées ; mot de passe contrôlé avant de consommer le code, aucune reprise sans code |
| `POST /verification` 🔒 | — | code envoyé à l'adresse principale (`202`) |
| `POST /verification/complete` | `flow` + `code`, ou `token` | adresse vérifiée |
| `POST /address-change` 🔒 | `password`, `new_address` | code envoyé à la nouvelle adresse (`202`) |
| `POST /address-change/complete` | `flow` + `code`, ou `token` | nouvelle adresse |
| `POST /password` 🔒 | `current_password`, `new_password` | mot de passe changé, autres sessions révoquées |
| `POST /service/token` | `client_id`, `client_secret` | jeton d'un compte de service (sans renouvellement) |
| `POST /api-keys/exchange` | `api_key` | jeton aux permissions de la clé |
| `POST /flows/{flow}/mfa` | `method` (`totp`, `recovery_code`, `passkey`), `code` ou `response` | second facteur d'une connexion `mfa_required` → jetons AAL2 |
| `POST /flows/{flow}/mfa/passkey/options` | — | défi passkey de ce parcours |
| `POST /passkey/login/options` | — | défi de connexion sans mot de passe (`flow`, `options`) |
| `POST /passkey/login` | `flow`, `response` | jetons (AAL2), ou actions imposées |
| `GET /mfa` 🔒 | — | ses seconds facteurs (TOTP, passkeys, codes restants, niveau atteignable) |
| `POST /mfa/totp` 🔒✱ | `login_flow` (au lieu du jeton, pour configurer le double facteur exigé) | `otpauth_uri` à afficher en QR code, une seule fois |
| `POST /mfa/totp/confirm` 🔒✱ | `code`, `login_flow` | TOTP actif (session en AAL2) |
| `DELETE /mfa/totp` 🔒✱ | — | TOTP retiré (refusé s'il est le dernier facteur exigé) |
| `POST /mfa/passkeys/options` 🔒✱ | `login_flow` | défi d'enregistrement (`flow`, `options`) |
| `POST /mfa/passkeys` 🔒✱ | `flow`, `response`, `label`, `login_flow` | passkey enregistrée |
| `PATCH /mfa/passkeys/{credential}` 🔒 | `label` | passkey renommée |
| `DELETE /mfa/passkeys/{credential}` 🔒✱ | — | passkey retirée |
| `POST /mfa/recovery-codes` 🔒✱ | `login_flow` | 10 codes de secours affichés une seule fois (remplacent les précédents) |
| `POST /session/reauthenticate/options` 🔒 | — | défi passkey de réauthentification |
| `POST /session/reauthenticate` 🔒 | `method` (`password`, `totp`, `recovery_code`, `passkey`), `code` ou `flow` + `response` | nouveau jeton (AAL2 par un second facteur) |
| `POST /identities/{identity}/mfa/reset` 🔒✱ | — | remise à zéro des seconds facteurs d'une identité par un administrateur |

✱ : action sensible — AAL la plus haute disponible et authentification de moins de 15 min
(politique), sinon `AUTH_AAL_INSUFFICIENT` ou `AUTH_REAUTHENTICATION_REQUIRED` (avec les
méthodes de réauthentification) ; `/password`, `/address-change` et `DELETE /sessions/{session}`
le sont aussi. Le double facteur exigé (politique, organisation, rôle — `platform_admin` par
défaut) répond `status: action_required` avec `configure_mfa` : l'interface enrôle alors un TOTP
ou une passkey avec `login_flow`, puis reprend `POST /flows/{flow}/actions`. Les identifiants
placés dans le chemin (`auth_flow:…`, `auth_session:…`) sont encodés en pourcentage.

Jetons : `access_token` (JWT HS256, `expires_in` secondes), `refresh_token` (opaque, usage
unique), `session`, `organization`, `permissions`.

Commandes d'administration (installation existante : serveur démarré au moins une fois, même
configuration et mêmes variables d'environnement) :

```bash
lyxal-server admin setup --email admin@example.com
```

Affiche une seule fois le lien d'installation du premier administrateur (valable 1 h ; refusé
s'il existe déjà un administrateur de la plateforme).

```bash
lyxal-server auth rotate-signing-key
```

Active une nouvelle clé de signature des jetons dans l'emplacement inactif ; refusé tant que des
jetons signés par l'ancienne clé de cet emplacement peuvent être valides. `--force` (clé
compromise) l'écrase et invalide ces jetons.

```bash
lyxal-server i18n export --locale en --output en.json
lyxal-server i18n import --locale en --file en.json --dry-run
lyxal-server i18n check
```

Textes de `lyxal_i18n` (session système) : `export` écrit les textes d'une langue dans un
fichier (`--format json` par défaut ou `xliff`, `--namespace`, `--tenant` pour les surcharges
d'une organisation) ; `import` les relit et affiche son rapport (créés, modifiés, inchangés,
ignorés, invalides, illisibles ; `--tenant`, `--overwrite-reviewed` pour écraser un texte relu,
`--dry-run` pour ne rien écrire) ; `check` liste les textes que le rendu refuse. `import` et
`check` sortent en erreur (`SERVER_COMMAND_FAILED`) si un texte est invalide ou illisible.

Chaque requête porte un identifiant `x-request-id` (repris de la requête ou généré). Couches :
limite de corps, délai, limite de concurrence, rattrapage des paniques, CORS paramétré.

---

## 5. Erreurs (`error/server.surql`)

Une erreur HTTP suit le contrat `LyxalResult` : `{ "ok": false, "data": null, "error": { … } }`.
Le client reçoit le message générique du code et `error.details.trace_id`, égal à
`x-request-id` ; le détail interne est journalisé avec ce même identifiant. Une erreur du runtime
garde son code `RUNTIME_*`.

| Code | Catégorie | HTTP |
| :--- | :--- | :--- |
| `SERVER_CONFIGURATION_INVALID` | `internal` | 500 |
| `SERVER_DATABASE_UNAVAILABLE` | `dependency` | 503 (réessayable) |
| `SERVER_MODULE_INSTALL_FAILED` | `internal` | 500 |
| `SERVER_BIND_FAILED` | `internal` | 500 |
| `SERVER_HTTP_SERVE_FAILED` | `internal` | 500 |
| `SERVER_SHUTDOWN_SIGNAL_FAILED` | `internal` | 500 |
| `SERVER_TELEMETRY_INIT_FAILED` | `internal` | 500 |
| `SERVER_AUTH_DISABLED` | `dependency` | 503 |
| `SERVER_COMMAND_FAILED` | `business` | 422 |

Les définitions sont générées depuis le catalogue `SERVER_ERROR_CATALOG` (`src/error.rs`) et
installées au démarrage ; un test vérifie leur correspondance. `manifest.toml` de l'hôte ne
déclare que ce fichier : l'hôte n'est pas un module du runtime.

---

## 6. Image

```bash
docker build -f apps/lyxal-server/Dockerfile .
```

Image `rust:1.97` (version du workspace) puis `debian:bookworm-slim`, utilisateur non root,
configuration copiée dans `/app/config`. Liste de contrôle avant production :
[`docs/PRODUCTION-CHECKLIST.md`](docs/PRODUCTION-CHECKLIST.md).

---

## 7. Vérification

```bash
cargo test -p lyxal-server
```

Les tests démarrent réellement le serveur sur une base embarquée : installation et démarrage de
tous les modules, routes système, `fn::error_result` de `lyxal_error` intact, redémarrage sur une
base installée (une release par module), rejeu des
ressources de chaque module, définitions `SERVER_*`, corps des réponses d'erreur, routes
`/api/v1/auth/*` de bout en bout (premier administrateur, connexion, sessions, déconnexion,
service absent).
`scripts/ci/ci_local.sh` rejoue la CI complète.
