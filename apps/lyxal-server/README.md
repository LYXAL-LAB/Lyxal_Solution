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
| `lyxal_notification` | toujours | `NotificationModule` (son installation crée la planification horaire `notification-purge` du planificateur), `NotificationConsumer` (événements `auth.*`), `NotificationEmailWorker` (avec les liens de désabonnement), `NotificationBroadcastWorker`, `NotificationStepWorker` (attentes des parcours confiées au planificateur), `NotificationHealthCheck` ; routes `/api/v1/notification/*` |
| `lyxal_storage` | toujours | `StorageModule`, `StorageCleanupWorker` (si un support est configuré), `StorageHealthCheck` ; supports disque et S3 ; envoi reprenable |
| `lyxal_secrets` | toujours | `SecretsModule`, `SecretsMaintenanceWorker` (purge, rescellement), `SecretsHealthCheck` ; trousseau maître du coffre-fort ; `SecretsClient` pour les modules hébergés |
| `lyxal_scheduler` | toujours | `SchedulerModule`, `SchedulerLeaderWorker` (planificateur élu par le bail `leader` du runtime), un `SchedulerExecutorWorker` par file (enregistré après l'installation, une fois les files connues), `SchedulerHealthCheck` ; registre des handlers ouvert aux modules hébergés (`SchedulerHost::handlers`, aucun inscrit pour l'instant) |
| `lyxal_base` | toujours | `ManifestModule` |
| `lyxal_catalogue` | toujours | `ManifestModule` (SurrealQL seul) |
| `lyxal_pipeline_ingestion` | fonctionnalité `module-ingestion` (par défaut) | `PipelineIngestionModule`, `IngestionWorker` (lit les fichiers sources des lots dans `lyxal_storage`), `IngestionHealthCheck` ; bucket `ingestion-sources` créé au démarrage |

Ajouter un module : l'inscrire dans `MODULES` de `build.rs` (ordre des dépendances), et, s'il a
du code Rust, déclarer son implémentation et ses services dans `src/modules/` (`auth.rs`,
`notification.rs`, `storage.rs`, `secrets.rs`, `scheduler.rs`, `ingestion.rs`).

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
| `secrets` | `master_key` (facultative, variable d'environnement seulement), `master_key_id`, `previous_master_key` (pendant une rotation, variable d'environnement seulement), `previous_master_key_id` |
| `scheduler` | `workers` (places de chaque exécuteur de file sur ce nœud, 1 à 64, 4 par défaut) |
| `auth` | `public_url` (facultative : adresse publique de l'interface, pour les liens des messages et l'origine des passkeys), `passkey_rp_id` (facultatif : domaine des passkeys, défaut : hôte de `public_url`) |
| `notification.smtp` | `host`, `port`, `security` (`tls`, `starttls`, `local_plain`), `username`, `password`, `from_address`, `from_name`, `timeout_seconds` (section facultative) |
| `notification` | `public_url` (facultative : adresse publique de l'hôte, qui active les liens de désabonnement en un clic avec la clé applicative) |
| `storage` | `disk.root` (facultatif : dossier du support de fichiers `default`), `s3.<nom>` (facultatif : `endpoint`, `region`, `bucket`, `access_key_id`, `secret_access_key` par variable d'environnement seulement, `path_style`, `allow_http`), `antivirus` (facultatif : `address` ou `socket`, `timeout_seconds`), `idle_timeout_seconds` (délai d'inactivité d'un envoi ou d'un téléchargement, 5 à 600, 60 par défaut) |

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
suspendus (les événements attendent en file) et la sonde du module est dégradée. Les diffusions
(sujet ou tous les abonnés) sont découpées en déclenchements par le worker des diffusions dans
tous les cas. Les attentes et regroupements des parcours sont confiés à `lyxal_scheduler` par le
worker d'étapes (exécutions différées de la tâche `notification.run_resume`, exécutées par
l'exécuteur de la file `default`) ; la purge est la planification horaire `notification-purge`
(tâche `notification.purge`), créée à l'installation du module : `lyxal_scheduler` est installé
avant `lyxal_notification` (dépendance du manifeste).

Liens de désabonnement en un clic : avec la clé applicative et
`LYXAL__NOTIFICATION__PUBLIC_URL` (adresse publique de l'hôte, `https://…`), chaque e-mail non
critique porte un lien `{public_url}/api/v1/notification/unsubscribe?t=<jeton>` et les en-têtes
`List-Unsubscribe` / `List-Unsubscribe-Post` (RFC 8058). Le jeton est signé HMAC-SHA256 par une
clé dérivée de la clé applicative (HKDF-SHA256, `lyxal_crypto`) : changer la clé applicative
invalide les liens déjà envoyés. Sans l'une des deux, aucun lien n'est mis et les routes
répondent `404`.

Le stockage des fichiers (`lyxal_storage`) écrit sous un dossier du serveur :
`LYXAL__STORAGE__DISK__ROOT` (créé s'il n'existe pas ; à placer sur un volume sauvegardé, hors
du dossier de l'application). C'est le support `default` des buckets.

Un bucket peut aussi être porté par un service S3 ou compatible (Bunny Storage en référence),
déclaré sous un nom de support : celui que le bucket reçoit à sa création (`backend`).

```text
LYXAL__STORAGE__S3__<NOM>__ENDPOINT            https://de-s3.storage.bunnycdn.com
LYXAL__STORAGE__S3__<NOM>__REGION              de
LYXAL__STORAGE__S3__<NOM>__BUCKET              nom de la zone
LYXAL__STORAGE__S3__<NOM>__ACCESS_KEY_ID       nom de la zone
LYXAL__STORAGE__S3__<NOM>__SECRET_ACCESS_KEY   mot de passe de la zone
```

`<NOM>` est en minuscules, chiffres et `_`. `__PATH_STYLE` (vrai par défaut : adresses
`/<bucket>/<clé>`, seule forme admise par Bunny) et `__ALLOW_HTTP` (faux par défaut) sont
facultatifs. La clé secrète ne se lit que dans l'environnement : écrite dans un fichier de
configuration, elle arrête le démarrage. Disque et S3 coexistent ; un support S3 peut s'appeler
`default` s'il n'y a pas de dossier disque. Chez Bunny, l'API S3 se choisit à la création de la
zone de stockage. Sur un autre service S3 que Bunny, posez sur le bucket une règle de cycle de
vie qui abandonne les envois en plusieurs parties incomplets (`AbortIncompleteMultipartUpload`,
quelques jours) : un envoi coupé par un arrêt brutal du serveur n'est effacé que par le service.

Sans aucun support, le serveur démarre : aucun fichier n'est écrit ni lu
(`STORAGE_BACKEND_UNKNOWN`), le worker de nettoyage n'est pas lancé et la sonde du module est
dégradée. La sonde écrit, relit et retire un fichier témoin sur chaque support.

Routes des fichiers, sous `/api/v1/storage` (`{bucket}` : clé du bucket, `{clé}` : clé du
fichier, par exemple `plans/2026/a.pdf`) :

| Méthode et chemin | Effet |
| :--- | :--- |
| `PUT /buckets/{bucket}/objects/{clé}` | envoie un fichier : le corps de la requête est son contenu ; `201` et sa fiche |
| `GET /buckets/{bucket}/objects/{clé}` | télécharge le fichier, en entier ou sur une plage (`Range`) |
| `GET /buckets/{bucket}/objects/{clé}?metadata` | fiche du fichier, quel que soit son état |
| `HEAD /buckets/{bucket}/objects/{clé}` | en-têtes du téléchargement, sans contenu |
| `DELETE /buckets/{bucket}/objects/{clé}` | supprime le fichier |
| `GET /buckets/{bucket}/objects?prefix=&limit=&start=` | liste les fichiers disponibles |
| `OPTIONS /uploads` | envoi reprenable (tus 1.0) : version, extensions (`creation`, `termination`, `expiration`) et taille maximale ; sans authentification |
| `POST /uploads` | ouvre un envoi reprenable : `Upload-Length` (taille), `Upload-Metadata` (`bucket` : clé du bucket, `key` : clé du fichier, `filename` et `filetype` facultatifs) ; `201`, `Location`, `Upload-Expires` |
| `HEAD /uploads/{id}` | position de l'envoi : `Upload-Offset`, `Upload-Length` |
| `PATCH /uploads/{id}` | écrit le corps à la position `Upload-Offset` (`Content-Type: application/offset+octet-stream`) ; `204` et la nouvelle position |
| `DELETE /uploads/{id}` | abandonne l'envoi ; `204` |

* **Droits** : jeton d'accès de l'appelant (`Authorization: Bearer`), de toute session valide
  (utilisateur, clé d'API, compte de service). Chaque requête s'exécute sous une session
  SurrealDB à son nom : les fonctions `fn::storage_*` et les permissions des tables décident ;
  l'hôte ne recopie aucune règle. Sans service de connexion : `SERVER_AUTH_DISABLED`.
* **Envoi** : `Content-Type` est le type annoncé, `Content-Length` la taille annoncée,
  `X-Lyxal-Filename` (texte encodé en pourcent) le nom d'origine, sinon le dernier segment de
  la clé. Une adresse occupée est refusée (`STORAGE_OBJECT_EXISTS`).
* **Téléchargement** : `ETag` (empreinte BLAKE3), `Last-Modified`, `Accept-Ranges`, une plage
  par requête (`206`, `416` hors du fichier), `If-None-Match` (`304`), `If-Range`. Le fichier
  est proposé à l'enregistrement (`Content-Disposition: attachment`) ; avec `?inline`, une
  image PNG, JPEG, GIF ou WebP ou un PDF est affiché par le navigateur (SVG et HTML, qui
  peuvent contenir du code, jamais). Toujours : `X-Content-Type-Options: nosniff`,
  `Content-Security-Policy: default-src 'none'; sandbox`, `Cache-Control: private, no-store`.
* **Contrôle du contenu** : le type enregistré est le type réel du fichier ; les programmes
  exécutables sont refusés par défaut (`STORAGE_OBJECT_TYPE_REFUSED`). Avec un antivirus
  (`LYXAL__STORAGE__ANTIVIRUS__ADDRESS=hôte:port` ou `__SOCKET=chemin`, service `clamd` de
  ClamAV ; `__TIMEOUT_SECONDS`, 30 par défaut), tout fichier envoyé est analysé pendant son
  écriture : infecté, il est refusé (`STORAGE_OBJECT_INFECTED`) et rien n'est conservé ;
  antivirus injoignable ou fichier au-delà de sa limite (`StreamMaxLength`), l'envoi est refusé
  (`STORAGE_SCANNER_UNAVAILABLE`) et la sonde du module est dégradée.
* **Limites** : ces routes ne sont pas soumises à `server.body_limit_bytes` ni au délai total
  d'une requête ; la taille est bornée par le bucket (100 Mo par défaut, 5 Go au plus), vérifiée
  pendant l'écriture. Un envoi ou une lecture du support qui ne transmet plus rien pendant
  `storage.idle_timeout_seconds` est coupé. Ce même délai est le délai d'écriture de toute
  connexion du serveur (`src/serve.rs`) : un client qui cesse de lire sa réponse est déconnecté,
  ce qui libère le fichier ouvert et sa place dans la limite de requêtes simultanées.
* **Envoi reprenable** (protocole tus 1.0, pour les gros fichiers) : après une coupure, le
  client demande la position (`HEAD`) et reprend (`PATCH`). Toute requête, sauf `OPTIONS`, porte
  `Tus-Resumable: 1.0.0` (sinon `412`). Seul l'appelant qui a ouvert l'envoi le poursuit. Une
  mauvaise position est refusée (`409`, `STORAGE_UPLOAD_OFFSET_MISMATCH`, position courante
  dans `Upload-Offset`). La requête qui apporte le dernier octet assemble le fichier, le
  contrôle (type réel, antivirus) et le rend disponible : sa réponse peut prendre le temps de
  relire le fichier, et un contenu refusé l'est à ce moment. Un envoi inachevé est retiré après
  son délai (`Upload-Expires`, 24 h par défaut). Les réponses de succès suivent le protocole
  (corps vide). Si CORS est activé, les en-têtes du protocole sont autorisés et lisibles ; les
  méthodes du protocole (`HEAD`, `PATCH`, `DELETE`) sont dans la liste par défaut de
  `cors.allowed_methods` et doivent y rester si cette liste est remplacée.
* **Réponses** : contrat `LyxalResult`, sauf le contenu d'un fichier ; erreurs `STORAGE_*` dans
  la langue de la requête.

Le coffre-fort des secrets (`lyxal_secrets`) a **sa propre clé maîtresse**, distincte de la
clé applicative partagée par `lyxal_auth` et `lyxal_notification` : une clé AES-256 (32 octets
en Base64 canonique, 44 caractères), `LYXAL__SECRETS__MASTER_KEY`, lue par
`lyxal_crypto::EnvironmentKeyProvider`, avec son identifiant `LYXAL__SECRETS__MASTER_KEY_ID`
(ex. `vault-2026`). Elle scelle la clé de chaque organisation, qui scelle elle-même les valeurs.
Une clé écrite dans un fichier de configuration arrête le démarrage. Sans clé, le serveur
démarre : les fiches restent consultables, aucune valeur n'est écrite ni lue
(`SECRETS_CRYPTO_UNAVAILABLE`) et la sonde du module est dégradée.

```text
LYXAL__SECRETS__MASTER_KEY                nouvelle clé (Base64, 44 caractères)
LYXAL__SECRETS__MASTER_KEY_ID             vault-2027
LYXAL__SECRETS__PREVIOUS_MASTER_KEY       ancienne clé, en lecture seule pendant la rotation
LYXAL__SECRETS__PREVIOUS_MASTER_KEY_ID    vault-2026
```

Changer la clé maîtresse : fournir la nouvelle comme clé active et l'ancienne à côté, redémarrer ;
le worker de maintenance (toutes les 10 minutes) rescelle les clés des organisations, la sonde
annonce la fin du rescellement (« l'ancienne clé maîtresse … peut être retirée »), puis retirer
l'ancienne et redémarrer. Le même worker purge les secrets supprimés à échéance, rescelle les
versions après la rotation de la clé d'une organisation et détruit les clés devenues inutiles.
Le test `tests/secrets.rs` (exécutable séparé : il fournit la clé maîtresse par variable
d'environnement) vérifie l'écriture et la relecture d'une valeur par un module hébergé.

Le planificateur (`lyxal_scheduler`) tourne sur la session système de l'hôte. Un seul nœud
planifie (bail `leader`, clé `scheduler`, 30 s renouvelé toutes les 10 s) ; chaque nœud exécute,
pour chaque file, au plus `LYXAL__SCHEDULER__WORKERS` tâches à la fois (4 par défaut, de 1 à 64 ;
hors bornes, le démarrage s'arrête). La concurrence globale de chaque file et celle de chaque
organisation restent tenues par la base. À l'arrêt, les tâches en cours reçoivent l'annulation et
ont 30 s pour finir ; au-delà, leur bail expire et une autre tentative les reprend.

```text
LYXAL__SCHEDULER__WORKERS    places par file et par nœud (4 par défaut, 1 à 64)
```

Routes du planificateur, sous `/api/v1/scheduler` (JSON, réponses `LyxalResult`, erreurs
`SCHEDULER_*` dans la langue de la requête) :

| Méthode et chemin | Fonction | Droit |
| :--- | :--- | :--- |
| `GET /settings?tenant=`, `PUT /settings` | `settings_get`, `settings_set` | lecture / réglages |
| `GET /tasks?module=&state=&limit=&start=`, `GET /tasks/{nom}` | `task_list`, `task_get` | lecture |
| `GET /queues` ; `POST /queues/{nom}/pause` (`reason`), `POST /queues/{nom}/resume` | `queue_list`, `queue_pause`, `queue_resume` | lecture / installation |
| `GET /calendars?tenant=`, `POST /calendars` ; `GET`, `PATCH`, `DELETE /calendars/{id}` | `calendar_list`, `_create`, `_get`, `_update`, `_delete` | lecture / calendriers |
| `GET /schedules?tenant=&task=&state=&paused=`, `POST /schedules` ; `GET`, `PATCH`, `DELETE /schedules/{id}` | `schedule_list`, `_create` et `_update` contrôlées par `SchedulerService`, `_get`, `_delete` | lecture / écriture et permission de la tâche |
| `POST /schedules/{id}/pause` (`reason`), `/resume`, `/trigger` (`overlap`), `/backfill` (`from`, `to`, `overlap`) | `schedule_pause`, `_resume`, `_trigger`, `_backfill` | écriture ; permission de la tâche sauf pour la pause ; `trigger` avec `cancel_other` : aussi exécutions |
| `GET /schedules/{id}/forecast?count=` | prochaines échéances (10 par défaut, 100 au plus), heure locale comprise | lecture |
| `POST /specs/validate` (`tenant`, `spec`, `calendars`, `created_at`) | contrôle d'une règle de dates sans écriture, avec les mêmes règles de forme que l'écriture (`fn::scheduler_spec_validate`) puis le calcul des dates : `{ valid: true }` ou `SCHEDULER_SPEC_INVALID` | lecture |
| `GET /runs?tenant=&schedule=&task=&state=&since=`, `POST /runs` (`task`, `tenant`, `args`, `run_at` ou `delay`, `priority`, `unique_key` ; 201, ou 200 avec l'exécution existante quand l'unicité la rend, `duplicate`) ; `GET /runs/{id}` | `run_list`, `run_enqueue`, `run_get` | lecture / écriture et permission de la tâche |
| `POST /runs/{id}/cancel` (`reason`), `POST /runs/{id}/retry` | `run_cancel`, `run_retry` | exécutions ; relance : aussi permission de la tâche |
| `GET /audit?tenant=&schedule=&action=&since=` | `audit_list` | lecture |

* **Droits** : jeton d'accès de l'appelant ; chaque requête s'exécute sous une session
  SurrealDB à son nom, et les fonctions `fn::scheduler_*` décident (permission propre d'une
  tâche, isolation des organisations). L'hôte ne recopie aucune règle et n'utilise jamais sa
  session système pour ces routes. Aucune route n'appelle une fonction du moteur (échéances,
  réservation, bail, fin, reprise, élagage, activation d'une tâche) : elles restent réservées
  aux workers de l'hôte.
* **Paramètres** : ceux des `XxxParams` de `lyxal_scheduler`, dans le corps JSON (écritures) ou
  dans l'adresse (listes : `limit`, `start`) ; identifiants `table:clé` (ou la seule clé dans le
  chemin), dates RFC 3339, durées SurrealQL (`30m`, `1h`). Un corps ou un paramètre illisible
  rend `SERVER_INVALID_REQUEST` (400).
* **Exécutions** : désignées par la forme texte de leur identifiant (`RunRef`), l'identifiant
  SurrealQL complet en base64url sans remplissage, y compris les échéances
  `scheduler_run:[planification, date]` ; dans les adresses comme dans les réponses (`id`,
  `retry_of`, `last_run`, `recent_runs`, `run` du journal). Aucune autre forme n'est acceptée
  (`SCHEDULER_INVALID_PARAMETERS`).
* **Règles de dates** : une règle refusée rend `SCHEDULER_SPEC_INVALID` avec
  `error.details.fields.rule` (`cron[0]`, `timezone`, `calendars[1].rules[2]`…) et `reason`
  (`cron_syntax`, `timezone`, `min_interval`…).
* **Cache** : toutes les réponses portent `Cache-Control: no-store` et `Pragma: no-cache`
  (arguments et résultats de tâches), y compris le 404 d'une adresse inconnue sous
  `/api/v1/scheduler`.

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

Désabonnement (`/api/v1/notification`, sans session ; le jeton signé est vérifié en temps
constant avant toute lecture de la base ; réponses `Cache-Control: no-store`) :

| Route | Réponse |
| :--- | :--- |
| `GET /unsubscribe?t=<jeton>` | petite page de confirmation (HTML sans script, `Referrer-Policy: no-referrer`) dont le bouton fait le `POST` ; ne désabonne pas (un lien ouvert par un antivirus de messagerie reste sans effet) ; jeton refusé : `400` |
| `POST /unsubscribe?t=<jeton>` | désabonnement en un clic (corps `List-Unsubscribe=One-Click` du client de messagerie, RFC 8058) : e-mail coupé pour la catégorie du parcours (ou le parcours) ; `200` sans contenu, ou une page pour un navigateur (`Accept: text/html`) ; rejouable ; jeton refusé, abonné, catégorie ou parcours supprimés : `400` ; base indisponible : `503` |

Liens non configurés : `404`. Le débit de ces routes est borné par la limite de concurrence de
l'hôte (aucune lecture de la base pour un jeton refusé).

Aperçu d'une étape de parcours (`/api/v1/notification`, jeton d'accès `Authorization: Bearer` ;
session SurrealDB au nom de l'appelant ; réponses `Cache-Control: no-store`) :

| Route | Réponse |
| :--- | :--- |
| `POST /preview` | corps `{ workflow, step_key, payload, locale, digest: { count, events } }` (64 Kio au plus, aucun autre champ : aucun secret accepté) ; `200` et `{ subject, html, text }` rendus par le moteur du worker avec les données d'exemple (une variable absente s'affiche vide), sans écriture ; `notification.read` exigée par `fn::notification_step_preview` (parcours illisible : `NOTIFICATION_WORKFLOW_NOT_FOUND`) ; étape qui n'est pas un canal : `404` ; corps illisible ou champ inconnu : `400` (`SERVER_INVALID_REQUEST`) ; corps trop volumineux : `413` ; sans jeton : `401` |

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
| `SERVER_SHUTDOWN_SIGNAL_FAILED` | `internal` | 500 |
| `SERVER_TELEMETRY_INIT_FAILED` | `internal` | 500 |
| `SERVER_AUTH_DISABLED` | `dependency` | 503 |
| `SERVER_COMMAND_FAILED` | `business` | 422 |
| `SERVER_INVALID_REQUEST` | `validation` | 400 |

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
service absent). `tests/scheduler_http.rs` parcourt les routes `/api/v1/scheduler/*` avec le
moteur réel (handler d'essai inscrit par le test) : planification contrôlée, prévision,
déclenchement, rejeu, exécution différée exécutée puis annulée et relancée, droits, `no-store`,
absence des routes du moteur. `tests/notification_http.rs` parcourt les routes de désabonnement
(clé applicative et `notification.public_url` fournies) : page sans effet, un clic rejouable,
page pour un navigateur, jeton modifié ou absent (`400`), abonné supprimé (`400`), liens non
configurés (`404`). `tests/notification_preview_http.rs` parcourt la route d'aperçu (rendu au nom
de l'appelant sans écriture, droits, corps refusé, `no-store`) et vérifie la planification de la
purge créée par l'installation.
`scripts/ci/ci_local.sh` rejoue la CI complète.
