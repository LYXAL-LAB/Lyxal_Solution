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
| `lyxal_base` | toujours | `ManifestModule` |
| `lyxal_catalogue` | toujours | `ManifestModule` (SurrealQL seul) |
| `lyxal_pipeline_ingestion` | fonctionnalité `module-ingestion` (par défaut) | `PipelineIngestionModule`, `IngestionWorker`, `IngestionHealthCheck` |

Ajouter un module : l'inscrire dans `MODULES` de `build.rs` (ordre des dépendances), et, s'il a
du code Rust, déclarer son implémentation et ses services dans `src/modules/` (`auth.rs`,
`notification.rs`, `ingestion.rs`).

---

## 3. Configuration

`config/default.toml`, puis `config/<LYXAL_ENV>.toml`, puis les variables d'environnement
`LYXAL__<SECTION>__<CLÉ>`. Toute clé inconnue est refusée.

| Section | Clés |
| :--- | :--- |
| `application` | `name`, `environment`, `instance_id`, `version` |
| `server` | `host`, `port`, `request_timeout_seconds`, `graceful_shutdown_seconds`, `max_concurrency`, `body_limit_bytes` |
| `database` | `endpoint` (`ws://`, `wss://`, `mem://`), `namespace`, `database`, `username`, `password`, `connect_timeout_seconds` |
| `runtime` | `module_install_timeout_seconds`, `module_start_timeout_seconds`, `module_stop_timeout_seconds` |
| `observability` | `log_filter`, `json_logs`, `include_target`, `include_thread_ids` |
| `cors` | `enabled`, `allow_credentials`, `allowed_origins`, `allowed_methods`, `allowed_headers` |
| `catalogue_sync` | `signing_key` (facultative) |
| `crypto` | `application_key` (facultative, variable d'environnement seulement), `application_key_id` |
| `notification.smtp` | `host`, `port`, `security` (`tls`, `starttls`, `local_plain`), `username`, `password`, `from_address`, `from_name`, `timeout_seconds` (section facultative) |

Les identifiants Root ne figurent dans aucun fichier : `LYXAL__DATABASE__USERNAME` et
`LYXAL__DATABASE__PASSWORD` (mot de passe en `SecretString`, masqué). Une connexion `ws://` ou
`wss://` sans identifiants est refusée.

La publication du pipeline d'ingestion vers le catalogue utilise un jeton de service
`catalogue_sync_agent` signé par l'hôte (HS256). Sa clé, 32 caractères `A-Z a-z 0-9 _ -`, ne
figure dans aucun fichier : `LYXAL__CATALOGUE_SYNC__SIGNING_KEY`. Au démarrage, l'hôte définit
avec elle l'accès JWT `lyxal_catalogue_sync` et abonne la publication à
`ingestion.manifest.approved`. Sans clé, la publication est désactivée et la sonde de santé du
pipeline est dégradée.

Les notifications (`lyxal_notification`) demandent la clé applicative de l'hôte et un relais
SMTP. La clé AES-256 (32 octets en Base64 canonique, 44 caractères) ne figure dans aucun
fichier : `LYXAL__CRYPTO__APPLICATION_KEY`, lue par `lyxal_crypto::EnvironmentKeyProvider`, avec
son identifiant `LYXAL__CRYPTO__APPLICATION_KEY_ID` (ex. `app-2026`, inscrit dans chaque
enveloppe `enc:v2`). Le relais : `LYXAL__NOTIFICATION__SMTP__HOST`, `__PORT`, `__SECURITY`,
`__FROM_ADDRESS`, et si besoin `__USERNAME` / `__PASSWORD` (variable d'environnement seulement).
`local_plain` (sans chiffrement) n'est accepté que pour un relais de la boucle locale. Sans clé
ou sans relais, aucun e-mail n'est envoyé : les abonnements aux événements `auth.*` restent
suspendus (les événements attendent en file) et la sonde du module est dégradée.

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
ressources de chaque module, définitions `SERVER_*`, corps des réponses d'erreur.
`scripts/ci/ci_local.sh` rejoue la CI complète.
