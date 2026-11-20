# `lyxal-server` — Hôte de processus de Lyxal OS

`lyxal-server` est le binaire qui fait tourner Lyxal OS : il charge la configuration, se connecte
à SurrealDB, installe et démarre les modules par `lyxal_runtime`, puis sert l'API HTTP système.
Il ne contient aucune logique métier (`AGENTS.md` §5.8.5).

Le code commun aux hôtes (chargement de la configuration en couches, connexion à la base et refus
de l'accès anonyme, santé et routes `/live`, `/ready`, `/health`, journal, signal d'arrêt,
adresse réelle du client, service HTTP avec délai d'écriture, modules embarqués et installation
du socle, aide de `build.rs`) est dans [`lyxal_host`](../../crates/lyxal_host/README.md) ;
`lyxal-server` garde ses routes, son contexte (`AppContext`), ses modules et leurs services, sa
configuration, sa ligne de commande et ses erreurs `SERVER_*` (les erreurs de `lyxal_host` y
sont traduites dans le code `SERVER_*` correspondant).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3.

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Démarrage

```text
configuration (config/*.toml + variables LYXAL__*)
  → journalisation
  → connexion SurrealDB (lyxal_surreal)
  → LyxalRuntime de l'hôte `lyxal_server` (store SurrealDB, baux, moteur d'événements)
  → socle sous bail (lyxal_core, lyxal_error, schéma du runtime ; empreinte enregistrée, socle
    non réinstallé si la base porte déjà celle du binaire), puis définitions SERVER_*
  → services des modules (workers, consommateurs d'événements, sondes de santé, handlers des
    tâches de fond de l'hôte)
  → install_packages : tous les modules hébergés (releases, migrations sous bail)
  → services dépendant des modules installés (accès JWT, tâches de fond de l'hôte et leurs
    planifications, abonnements)
  → start_all : modules, présence du nœud (runtime_node), workers, EventWorker et ramasse-miettes
  → HTTP
arrêt (SIGINT / SIGTERM) → stop_all (workers puis modules, ordre inverse, puis retrait du nœud)
```

**Hôte `lyxal_server`.** Le nom d'hôte est une constante du binaire (`modules::HOST_ID`, égal à
l'`id` de `manifest.toml`), la même pour toutes ses copies, sans clé de configuration
(`application.instance_id` reste une étiquette de journal). Il est passé au runtime
(`RuntimeConfig::new`), au moteur d'événements (`EventEngineConfig::new`), au planificateur
(`SchedulerEngine::new`) et aux abonnements que l'hôte enregistre (`lyxal_notification`,
`lyxal_pipeline_ingestion`). Plusieurs copies de `lyxal-server` se partagent le travail (un seul
chef des événements pour l'hôte, un seul planificateur élu pour la base). Un autre hôte peut
partager la même base (prévu : `lyxal-groupware`) : l'`EventWorker` de `lyxal-server` ne lit que
les livraisons des abonnements de `lyxal_server` (bail `event_stream_lease:lyxal_server`), et les
trois tâches de fond de l'hôte ne sont exécutées que par ses nœuds, seuls à en avoir le code ;
`lyxal-server` arrêté, elles attendent son retour sans échec. Les deux hôtes se déploient du même
commit. La commande `runtime migrations` installe le socle par le même chemin que le démarrage
(`lyxal_runtime::schema::install_foundation`, sous bail).

Un module déjà installé dans la même version n'est pas réinstallé et son hook `install` n'est
pas rejoué ; une release de même version au contenu différent fait refuser le démarrage
(`RUNTIME_RELEASE_CHECKSUM_MISMATCH`) ; une installation interrompue est reprise en rejouant ses
ressources (toutes rejouables). La sonde de santé de `lyxal_core` passe à « dégradé » si un autre
binaire a remplacé le socle de la base. Un échec d'installation
ou de démarrage arrête le serveur.

---

## 2. Modules hébergés

`build.rs` lit le `manifest.toml` de chaque module hébergé et **embarque dans le binaire** le
manifeste et les fichiers déclarés dans `[resources]` (`lyxal_host::build::embed_modules`). La compilation échoue si un fichier
déclaré manque.

| Module | Inclus | Implémentation |
| :--- | :--- | :--- |
| `lyxal_core` | toujours | `ManifestModule` de `lyxal_host` (SurrealQL seul) |
| `lyxal_error` | toujours | `ManifestModule` |
| `lyxal_event` | toujours | `ManifestModule` ; moteur démarré par le runtime |
| `lyxal_auth` | toujours | `AuthModule`, `AuthHealthCheck` ; purge `AuthPurge` exécutée par le planificateur (tâche `auth.purge`) |
| `lyxal_notification` | toujours | `NotificationModule` (son installation crée la planification horaire `notification-purge` du planificateur), `NotificationConsumer` (événements `auth.*`), `NotificationEmailWorker` (envoi par les intégrations, identifiants lus dans `lyxal_secrets` ; avec les liens de désabonnement), trois `NotificationChannelWorker` (SMS, messagerie d'équipe, adresse web), `NotificationPushWorker` (Web Push, FCM, APNs ; identifiants lus dans `lyxal_secrets`), le `NotificationChannelWorker` du fil (`in_app`, toujours, sans clé), `FeedHubWorker` (requête `LIVE SELECT` du fil répartie par `FeedHub` vers les flux SSE, toujours), `NotificationBroadcastWorker`, `NotificationStepWorker` (attentes des parcours confiées au planificateur), `NotificationHealthCheck` ; routes `/api/v1/notification/*` (désabonnement, aperçu, retours des fournisseurs, essai d'une intégration, adresses de messagerie et web, appareils push et clé VAPID, fil dans l'application et son flux SSE) |
| `lyxal_storage` | toujours | `StorageModule`, `StorageHealthCheck` ; nettoyage `StorageCleanup` exécuté par le planificateur (tâche `storage.cleanup` ; sans support configuré, l'exécution ne fait rien) ; supports disque et S3 ; envoi reprenable |
| `lyxal_secrets` | toujours | `SecretsModule`, `SecretsHealthCheck` ; maintenance `SecretsMaintenance` (purge, rescellement) exécutée par le planificateur (tâche `secrets.maintenance`) ; trousseau maître du coffre-fort ; `SecretsClient` pour les modules hébergés |
| `lyxal_scheduler` | toujours | `SchedulerModule`, `SchedulerLeaderWorker` (planificateur élu par le bail `leader` du runtime), un `SchedulerExecutorWorker` par file (enregistré après l'installation, une fois les files connues), `SchedulerHealthCheck` ; registre des handlers (`SchedulerHost::handlers`) où l'hôte inscrit ceux de ses tâches de fond (`modules/tasks.rs`) |
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
| `notification` | `public_url` (facultative : adresse publique de l'hôte, qui active les liens de désabonnement en un clic avec la clé applicative, et l'adresse des retours de livraison demandée message par message aux fournisseurs de SMS ; elle sert aussi à vérifier la signature des retours Twilio) |
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

Les notifications (`lyxal_notification`) envoient par des **intégrations** (fournisseur d'un
canal pour une organisation, ou pour l'installation en repli : e-mail par SMTP, Brevo, Mailgun,
Postmark, Resend ; SMS par Brevo, Twilio, Vonage ; messageries Slack, Teams, Discord,
Mattermost, Google Chat, Telegram ; appel signé d'une adresse web), dont les identifiants sont
rangés dans le coffre-fort `lyxal_secrets`. Un worker par canal envoie les étapes de son canal ;
les messageries et les adresses web sont appelées par un client sortant contrôlé (HTTPS seulement,
hôtes officiels ou publics, nom résolu et vérifié à chaque envoi, connexion à l'adresse vérifiée,
sans mandataire ni redirection : `crates/lyxal_notification/README.md`). L'hôte n'a aucun
réglage d'envoi ; il demande la clé applicative (secrets scellés des messages) et la clé
maîtresse du coffre-fort (lecture des identifiants). La clé applicative AES-256 (32 octets en
Base64 canonique, 44 caractères) ne figure dans aucun fichier : `LYXAL__CRYPTO__APPLICATION_KEY`,
lue par `lyxal_crypto::EnvironmentKeyProvider`, avec son identifiant
`LYXAL__CRYPTO__APPLICATION_KEY_ID` (ex. `app-2026`, inscrit dans chaque enveloppe `enc:v2`).
Sans l'une des deux clés, aucun e-mail n'est envoyé : les abonnements aux événements `auth.*`
restent suspendus (les événements attendent en file) et la sonde du module est dégradée. Une
installation neuve n'envoie aucun e-mail tant qu'un administrateur de la plateforme n'a pas créé
l'intégration e-mail de l'installation (marche à suivre : `crates/lyxal_notification/README.md`,
§ Exploitation) : les e-mails déclenchés entre-temps attendent en file et la sonde est dégradée.
Les diffusions (sujet ou tous les abonnés) sont découpées en déclenchements par le worker des
diffusions dans tous les cas. Les attentes et regroupements des parcours sont confiés à
`lyxal_scheduler` par le worker d'étapes (exécutions différées de la tâche
`notification.run_resume`, exécutées par l'exécuteur de la file `default`) ; la purge est la
planification horaire `notification-purge` (tâche `notification.purge`), créée à l'installation
du module : `lyxal_secrets` et `lyxal_scheduler` sont installés avant `lyxal_notification`
(dépendances du manifeste).

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
(`STORAGE_BACKEND_UNKNOWN`), le nettoyage ne fait rien sur ce nœud (son exécution se termine
avec le résultat `{ skipped: "no_backend" }`) et la sonde du module est dégradée. La sonde écrit, relit et retire un fichier témoin sur chaque support.

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
  connexion du serveur (`lyxal_host::http::serve`) : un client qui cesse de lire sa réponse est
  déconnecté, ce qui libère le fichier ouvert et sa place dans la limite de requêtes simultanées.
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
la maintenance (tâche `secrets.maintenance` du planificateur, toutes les 10 minutes) rescelle les clés des organisations, la sonde
annonce la fin du rescellement (« l'ancienne clé maîtresse … peut être retirée »), puis retirer
l'ancienne et redémarrer. La même maintenance purge les secrets supprimés à échéance, rescelle les
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

**Tâches de fond de l'hôte** (`src/modules/tasks.rs`, `seeds/server_tasks.surql`). La purge de
`lyxal_auth`, le nettoyage de `lyxal_storage` et la maintenance de `lyxal_secrets` ne sont pas des
workers : le planificateur les exécute, une seule fois à la fois pour toute l'installation.
`lyxal_scheduler` dépend de `lyxal_auth`, donc aucun de ces trois modules ne peut dépendre du
planificateur : c'est l'hôte qui déclare leurs tâches, inscrit leur handler (qui appelle
l'opération publique du module et rend son bilan comme résultat de l'exécution) et crée leur
planification si elle est absente, après l'installation des modules (rejouable, sans doublon).

| Tâche | Planification | Rythme | Délai maximal | Opération |
| :--- | :--- | :--- | :--- | :--- |
| `auth.purge` | `auth-purge` | 15 min | 5 min | `AuthPurge::run` |
| `storage.cleanup` | `storage-cleanup` | 10 min | 30 min | `StorageCleanup::run` |
| `secrets.maintenance` | `secrets-maintenance` | 10 min | 15 min | `SecretsMaintenance::run` |

File `default`, portée installation, chevauchement `skip`, décalage aléatoire de 30 s au plus,
3 tentatives (échec passager : nouvelle tentative après 30 s à 5 min). À l'arrêt du nœud ou au
délai maximal, l'opération s'interrompt entre deux paquets (résultat `interrupted`) ; le reste
est fait à l'exécution suivante. Chaque tâche a sa permission propre (`auth.purge.run`,
`storage.cleanup.run`, `secrets.maintenance.run`), déclarée par l'hôte et attribuée à aucun
rôle : seule la session système de l'hôte planifie, déclenche, rejoue ou relance ces tâches ; un
administrateur de la plateforme peut les mettre en pause, pas les reprendre. Le suivi (bilan,
échecs, tentatives) se lit dans les exécutions du planificateur.

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
| 🔒 `GET /api/v1/system/modules` | Hôte (`host`) et nœud (`node_id`) de ce processus ; modules hébergés (`modules` : identifiant, nom, version, état) ; nœuds vivants de la base, de tous les hôtes (`nodes` : `node_id`, `host`, `modules` démarrés, `started_at`, `seen_at`, `current` pour ce processus ; battement de moins de 30 s), du plus récent au plus ancien. |
| 🔒 `GET /api/v1/system/migrations/interrupted` | Migrations interrompues ou abandonnées (`?module=` pour un seul module) : module, migration, version, script, nœud, état, début, dernière décision. |
| 🔒 `POST /api/v1/system/migrations/resolve` | Décision sur une migration interrompue : `{ module, migration, action, reason }`, `action` valant `retry` (rejouée à la prochaine installation du module) ou `abandon` (installation refusée tant qu'un `retry` ne l'a pas remise à rejouer). |

**Administration de l'installation** (`src/http/system.rs`, `seeds/server_permissions.surql`).
Les trois routes 🔒 `/api/v1/system/*` demandent le droit `server.installation.manage`.
`/api/v1/system/modules` décrit les modules hébergés et les nœuds vivants (sans paramètre
d'adresse ; données dans `data`). Les deux routes `/api/v1/system/migrations/*` exposent la
reprise guidée d'une migration interrompue de `lyxal_runtime` (procédure et refus :
`crates/lyxal_runtime/README.md` §4.1).
`lyxal_runtime` est sous `lyxal_auth` : il ne contrôle aucun droit et ses tables ne sont lisibles
que par la session système. L'hôte déclare donc le droit `server.installation.manage` (portée
installation, attribué au rôle `platform_admin`) et, pour chaque requête, contrôle le jeton
d'accès (`Authorization: Bearer`), demande à `fn::auth_has_permission`, sur une session au nom
de l'appelant, s'il détient ce droit, puis seulement appelle le runtime sur la session système.
L'auteur de la décision (identité, ou application pour un compte de service) et son motif
(obligatoire, 1 000 caractères au plus, ni secret ni donnée personnelle) sont gardés avec la
décision et écrits au journal du runtime. Réponses `LyxalResult` avec `Cache-Control: no-store` ;
corps borné par `server.body_limit_bytes`.

| Refus | Code | HTTP |
| :--- | :--- | :--- |
| Sans jeton, jeton refusé | `AUTH_SESSION_REQUIRED` | 401 |
| Sans le droit `server.installation.manage` | `AUTH_PERMISSION_DENIED` | 403 |
| Corps ou paramètre illisible, champ inconnu, `action` inconnue | `SERVER_INVALID_REQUEST` | 400 |
| Champ vide ou trop long | `RUNTIME_INVALID_PARAMETERS` | 400 |
| Migration inconnue, en cours ou dans un autre état | `RUNTIME_MIGRATION_NOT_INTERRUPTED` | 409 |
| Bail d'installation du module détenu par un autre nœud, ou par une installation en cours | `RUNTIME_LEASE_FENCED` | 412 |

Ces routes sont servies par un nœud démarré. Un nœud dont l'installation d'un module échoue sur
la migration interrompue ne démarre pas (`SERVER_MODULE_INSTALL_FAILED`) : sur un serveur seul,
ou quand aucun autre nœud ne répond, la décision se prend **en ligne de commande, serveur
arrêté** (`lyxal-server runtime migrations list|resolve`, ci-dessous), puis le serveur est
relancé. Sur une installation à plusieurs nœuds, elle peut aussi se prendre par ces routes depuis
un nœud démarré.

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
| `GET /app-passwords` 🔒 | — | ses mots de passe d'application (sans secret, état `active`, `expired` ou `revoked`, dernier usage) |
| `GET /app-passwords/permissions` 🔒 | — | permissions qu'il peut donner à un mot de passe d'application (détenues dans l'organisation active et déclarées utilisables par leur module) |
| `POST /app-passwords` 🔒✱ | `name`, `permissions`, `expires_at` (RFC 3339, facultatif) | `201` : `app_password`, `username` (identifiant à saisir dans le logiciel) et `password`, rendu **une seule fois** |
| `DELETE /app-passwords/{id}` 🔒 | — | révoque un de ses mots de passe d'application (`revoked`) |
| `DELETE /app-passwords` 🔒 | — | révoque tous ses mots de passe d'application de l'organisation active |
| `GET /app-passwords/{id}/uses?limit=` 🔒 | — | journal des connexions (protocole, adresse IP, logiciel, première et dernière connexion, nombre) |
| `GET /identities/{identity}/app-passwords` 🔒 | — | administrateur (`auth.identity.manage`, ou `auth.member.manage` pour ceux de son organisation active) : mots de passe d'une identité |
| `DELETE /identities/{identity}/app-passwords/{id}`, `DELETE /identities/{identity}/app-passwords` 🔒✱ | — | administrateur : révocation d'un mot de passe ou de tous (`revoked`) |

✱ : action sensible — AAL la plus haute disponible et authentification de moins de 15 min
(politique), sinon `AUTH_AAL_INSUFFICIENT` ou `AUTH_REAUTHENTICATION_REQUIRED` (avec les
méthodes de réauthentification) ; `/password`, `/address-change` et `DELETE /sessions/{session}`
le sont aussi. Le double facteur exigé (politique, organisation, rôle — `platform_admin` par
défaut) répond `status: action_required` avec `configure_mfa` : l'interface enrôle alors un TOTP
ou une passkey avec `login_flow`, puis reprend `POST /flows/{flow}/actions`. Les identifiants
placés dans le chemin (`auth_flow:…`, `auth_session:…`, `auth_app_password:…`) sont encodés en
pourcentage.

Mots de passe d'application (`lyxal_auth` README §3 ter) : ils servent aux logiciels de
courrier, d'agenda et de contacts, par les serveurs des protocoles de `lyxal-groupware` (à
venir) ; **aucune** authentification HTTP Basic n'est ajoutée à `lyxal-server` : un mot de passe
d'application n'ouvre pas l'API de la plateforme. Les listes et le journal sont lus au nom de
l'appelant (règles des tables) ; création et révocation passent par la session système, qui
transmet l'acteur dont la base revérifie les droits, l'AAL et l'ancienneté. Révoquer ses
propres mots de passe n'est pas une action sensible ; en révoquer pour quelqu'un d'autre l'est.

Jetons : `access_token` (JWT HS256, `expires_in` secondes), `refresh_token` (opaque, usage
unique), `session`, `organization`, `permissions`.

Commandes d'administration (`src/cli.rs` ; installation existante : serveur démarré au moins une
fois, même configuration et mêmes variables d'environnement — sauf `runtime migrations`, faites
pour un serveur qui ne démarre pas) :

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

```bash
lyxal-server runtime migrations list [--module lyxal_auth]
lyxal-server runtime migrations resolve --module lyxal_auth --migration 0001_initial \
    --action retry --reason "tables absentes, script rejouable"
```

Reprise d'une migration interrompue, **serveur arrêté** (procédure :
`crates/lyxal_runtime/README.md` §4.1). Une migration interrompue empêche un serveur seul de
démarrer, donc de servir les routes `/api/v1/system/migrations/*` : ces deux commandes font les
mêmes opérations sans lui.

* `list` affiche les migrations interrompues ou abandonnées, de tous les modules ou d'un seul :
  module, migration, version, script, nœud, état, début, dernière décision.
* `resolve` prend la décision : `--action retry` (la migration est rejouée au prochain démarrage)
  ou `abandon` (le démarrage reste refusé tant qu'un `retry` ne l'a pas remise à rejouer) ;
  `--reason` est obligatoire (1 000 caractères au plus, ni secret ni donnée personnelle). Les
  quatre options sont obligatoires, dans un ordre libre.

Elles se connectent à la base de la configuration, installent le socle comme au démarrage
(`lyxal_core`, `lyxal_error`, schéma et fonctions du runtime, sous le bail du socle, réinstallé
seulement si la base porte une autre empreinte), puis les définitions `SERVER_*` (première étape
de tout démarrage, rejouable, qui garantit que les fonctions de reprise présentes en base sont
celles du binaire), **n'installent ni ne démarrent aucun module hébergé**, puis appellent
`LyxalRuntime::interrupted_migrations` / `resolve_migration` : mêmes contrôles et même trace au
journal du runtime que les routes. Elles fonctionnent aussi sur une base qui n'a jamais démarré.

* **Nœud** : comme un serveur, chaque exécution reçoit un identifiant de nœud propre. Le bail
  d'installation de la release est pris sans attendre ; s'il est encore détenu (serveur en cours
  d'installation sur un autre nœud, ou arrêté brutalement depuis moins de la durée de son bail),
  la commande est refusée (`RUNTIME_LEASE_FENCED`) : la relancer une fois le bail échu.
* **Auteur tracé** : il n'y a pas d'appelant authentifié. L'auteur gardé avec la décision et au
  journal est `cli:<application.instance_id>` (ex. `cli:local`) — la ligne de commande de
  l'instance, jamais une personne ; le nœud et la date sont gardés à côté. Le motif dit qui a
  décidé si l'exploitation le demande.
* **Accès** : comme les autres commandes, aucun droit `lyxal_auth` n'est contrôlé. Peut décider
  qui peut lancer le binaire avec la configuration du serveur et les identifiants de la base.
* **Refus** : sortie en erreur (`SERVER_COMMAND_FAILED`), message commençant par le code du
  runtime — `RUNTIME_MIGRATION_NOT_INTERRUPTED` (migration inconnue, en cours, ou dans un autre
  état), `RUNTIME_INVALID_PARAMETERS` (motif vide ou trop long), `RUNTIME_LEASE_FENCED`. Une
  `--action` autre que `retry` ou `abandon`, une option absente, inconnue ou répétée sont refusées
  avant toute connexion (`SERVER_CONFIGURATION_INVALID`, avec l'aide).

Désabonnement (`/api/v1/notification`, sans session ; le jeton signé est vérifié en temps
constant avant toute lecture de la base ; réponses `Cache-Control: no-store`) :

| Route | Réponse |
| :--- | :--- |
| `GET /unsubscribe?t=<jeton>` | petite page de confirmation (HTML sans script, `Referrer-Policy: no-referrer`) dont le bouton fait le `POST` ; ne désabonne pas (un lien ouvert par un antivirus de messagerie reste sans effet) ; jeton refusé : `400` |
| `POST /unsubscribe?t=<jeton>` | désabonnement en un clic (corps `List-Unsubscribe=One-Click` du client de messagerie, RFC 8058) : e-mail coupé pour la catégorie du parcours (ou le parcours) ; `200` sans contenu, ou une page pour un navigateur (`Accept: text/html`) ; rejouable ; jeton refusé, abonné, catégorie ou parcours supprimés : `400` ; base indisponible : `503` |

Liens non configurés : `404`. Le débit de ces routes est borné par la limite de concurrence de
l'hôte (aucune lecture de la base pour un jeton refusé).

Retours des fournisseurs (`/api/v1/notification`, sans session ; adresse à régler chez le
fournisseur, une par intégration ; réponses sans corps ni détail, `Cache-Control: no-store`) :

| Route | Réponse |
| :--- | :--- |
| `POST /webhooks/{intégration}` | `{intégration}` : clé de l'enregistrement de l'intégration (`notification_integration:<clé>`). Corps de 256 Kio au plus. Vérification par le secret des retours de l'intégration, lu dans `lyxal_secrets` : Mailgun (HMAC-SHA256 de l'horodatage et du jeton), Resend (en-têtes `svix-*`, HMAC-SHA256), Postmark et Brevo, e-mail et SMS (identifiants `Authorization: Basic` comparés en temps constant) ; horodatage signé à moins de 5 minutes ; SMS : Twilio (`X-Twilio-Signature`, HMAC-SHA1 de `{notification.public_url}` suivie du chemin et de la requête, puis des paramètres du formulaire triés), Vonage (paramètre `sig`, HMAC-SHA256 des paramètres triés, horodatage `timestamp` à moins de 5 minutes). `200` : retour enregistré, déjà connu (dédoublonné) ou ignoré (ouverture, clic) ; `400` corps illisible ; `401` signature, identifiants ou horodatage refusés ; `404` intégration inconnue ou sans secret des retours ; `413` corps trop volumineux ; `503` secret illisible, coffre-fort sans clé maîtresse ou base indisponible (le fournisseur réessaie) |

Essai d'une intégration (`/api/v1/notification`, jeton d'accès `Authorization: Bearer` ; session
au nom de l'appelant) :

| Route | Réponse |
| :--- | :--- |
| `POST /integrations/{intégration}/test` | corps `{ to }` (4 Kio au plus : e-mail ; SMS : numéro E.164 ; messagerie et adresse web : identifiant d'une adresse du même service, `notification_endpoint:<clé>`) ; droit de gestion de la portée de l'intégration exigé par `fn::notification_integration_test` (autre organisation : `NOTIFICATION_INTEGRATION_NOT_FOUND`) ; un message d'essai part par le vrai fournisseur (adresse scellée lue par la session système, `fn::notification_endpoint_resolve`) ; `200` et `{ accepted, code }` (code `NOTIFICATION_*` d'un refus, jamais de secret), issue notée sur l'intégration (`last_test`) ; coffre-fort sans clé maîtresse : `503` (`NOTIFICATION_CONFIGURATION_INVALID`) ; sans jeton : `401` |

Adresses de messagerie et web des abonnés (`/api/v1/notification`, jeton d'accès
`Authorization: Bearer` ; session au nom de l'appelant ; `Cache-Control: no-store`). L'hôte
scelle l'adresse (`enc:v2`, clé applicative, contexte `with_tenant(<organisation>,
"lyxal_notification", "notification_endpoint", <clé de l'adresse>, "url")`) **avant** l'appel de
la fonction : elle n'entre en base que scellée et n'est jamais renvoyée (l'hôte seulement) :

| Route | Réponse |
| :--- | :--- |
| `POST /endpoints` | corps `{ tenant, subscriber_id, channel : chat ou webhook, provider, name, url, chat_id (Telegram), active }` (8 Kio au plus) ; `fn::notification_endpoint_create` (droit de gestion) ; `201` et `{ endpoint : { id, subscriber, channel, provider, name, host, chat_id, active, signed }, signing_secret }` : pour une adresse web, la clé de signature (32 octets en hexadécimal, `rand_core::OsRng`) est montrée **une seule fois**, puis scellée (champ `signing_secret`) ; refus : `NOTIFICATION_ENDPOINT_INVALID` (`400` : HTTP, adresse IP, nom local, hôte non officiel ou hors `allowed_hosts`, limite de 10), `NOTIFICATION_PERMISSION_DENIED` (`403`) ; `subscriber_id` absent : `400` ; clé applicative absente : `503` (`NOTIFICATION_CONFIGURATION_INVALID`) ; sans jeton : `401` |
| `POST /my/endpoints` | mêmes champs sans `subscriber_id` : adresse de la personne connectée (`fn::notification_my_endpoint_create`, abonné `auth:<identité>` créé au besoin ; une application sans identité : `NOTIFICATION_PERMISSION_DENIED`) |

Notifications push (`/api/v1/notification`, jeton d'accès `Authorization: Bearer` ; lot 6) :

| Route | Contrat |
| :--- | :--- |
| `POST /my/devices` | corps (8 Kio au plus) `{ tenant, provider : "webpush", name, subscription : { endpoint, keys : { p256dh, auth } } }` (`PushSubscription.toJSON()` du navigateur) ou `{ tenant, provider : "fcm" \| "apns", platform, name, token }` ; l'hôte calcule l'empreinte du jeton (SHA-256, `lyxal_crypto`), **scelle** jeton et clés (`enc:v2`, clé applicative, contexte `with_tenant(<organisation>, "lyxal_notification", "notification_endpoint", <empreinte>, "token" \| "p256dh" \| "auth")`) puis appelle `fn::notification_my_device_register` au nom de la personne ; `201` (nouvel appareil) ou `200` (même jeton : appareil mis à jour) et `{ created, device : { id, provider, platform, name, host, active } }`, jamais le jeton ; refus : `NOTIFICATION_DEVICE_INVALID` (`400` : service push inconnu, HTTP, jeton ou clés mal formés), `NOTIFICATION_DEVICE_LIMIT` (`409`, 10 appareils), `NOTIFICATION_PERMISSION_DENIED` (`403` : autre organisation, application sans identité) ; corps illisible : `400` ; clé applicative absente : `503` ; sans jeton : `401` |
| `GET /push/vapid-key?tenant=` | clé publique VAPID (`{ public_key }`, Base64url : `applicationServerKey`) de l'intégration Web Push de l'organisation active de la personne, sinon de l'installation ; personne vérifiée dans sa session, clé lue par la session système (`fn::notification_push_vapid_key`) ; aucune : `NOTIFICATION_INTEGRATION_UNAVAILABLE` |
| `POST /integrations/{intégration}/vapid` | paire VAPID P-256 neuve (`lyxal_crypto`, aléa du système) pour une intégration `webpush` : clé privée rangée **directement** dans son secret des identifiants (`{ "private_key": "<PKCS#8 PEM>" }`, nouvelle version écrite au nom de l'appelant : droit d'écriture du coffre-fort), jamais montrée ; clé publique notée dans `settings.vapid_public_key` (`fn::notification_integration_update` au nom de l'appelant : droit de gestion et de lecture du secret) ; `200` et `{ integration, public_key }` ; autre intégration : `400` |

L'essai d'une intégration push (`POST /integrations/{intégration}/test`, `{ "to": "notification_endpoint:<clé>" }`) envoie une notification d'essai à un appareil du même service et de la même organisation.
| `POST /endpoints/{adresse}/rotate`, `POST /my/endpoints/{adresse}/rotate` | corps `{ tenant }` ; `{adresse}` : clé de l'enregistrement ; nouvelle clé de signature d'une adresse web, montrée une fois (`{ endpoint, signing_secret }`) ; l'ancienne ne signe plus |

Aperçu d'une étape de parcours (`/api/v1/notification`, jeton d'accès `Authorization: Bearer` ;
session SurrealDB au nom de l'appelant ; réponses `Cache-Control: no-store`) :

| Route | Réponse |
| :--- | :--- |
| `POST /preview` | corps `{ workflow, step_key, payload, locale, digest: { count, events } }` (64 Kio au plus, aucun autre champ : aucun secret accepté) ; `200` et `{ subject, html, text }` rendus par le moteur du worker avec les données d'exemple (une variable absente s'affiche vide), sans écriture ; `notification.read` exigée par `fn::notification_step_preview` (parcours illisible : `NOTIFICATION_WORKFLOW_NOT_FOUND`) ; étape qui n'est pas un canal : `404` ; corps illisible ou champ inconnu : `400` (`SERVER_INVALID_REQUEST`) ; corps trop volumineux : `413` ; sans jeton : `401` |

Fil dans l'application (`/api/v1/notification`, jeton d'accès `Authorization: Bearer` de la
personne ; session SurrealDB à son nom : seul **son** fil, dans son organisation active, est lu
et modifié, par les fonctions `fn::notification_feed_*` et les permissions de
`notification_inbox` ; réponses `Cache-Control: no-store`). Un message d'une autre personne
reçoit la même réponse qu'un message absent (`404`, `NOTIFICATION_FEED_ITEM_NOT_FOUND`) ; une
session sans compte (compte de service) : `403` (`NOTIFICATION_FEED_NO_ACCOUNT`) ; sans jeton :
`401` :

| Route | Réponse |
| :--- | :--- |
| `GET /feed/stream` | flux SSE (`text/event-stream`, `X-Accel-Buffering: no`) : `event: counts` (`{ unseen, unread, total }`) d'abord, puis `event: notification` (nouveau message, même vue que la liste) et `event: counts` à chaque changement de son fil (relus par `fn::notification_feed_counts` dans sa session) et toutes les minutes ; commentaire `: keep-alive` toutes les 25 s, à chaque fois le jeton et la session sont revérifiés (session expirée ou révoquée, jeton expiré : le flux se ferme, le client se reconnecte avec un jeton frais) ; 5 flux au plus par personne (`429`, `NOTIFICATION_FEED_STREAM_LIMIT`) ; flux fermés à l'arrêt de l'hôte et pour un client qui ne lit plus. Un `EventSource` natif n'envoie pas d'en-tête `Authorization` : lecture par `fetch` |
| `GET /feed` | paramètres `limit` (1 à 100, 20), `cursor` (dernier message reçu), onglet : `tags` et `severity` (listes séparées par des virgules), `archived`, `read` (`true` / `false`), `data.<clé>=<valeur>` ; `200` et `{ items, next_cursor }` (du plus récent au plus ancien, sans les messages en sommeil) |
| `GET /feed/counts` | mêmes filtres ; `200` et `{ unseen, unread, total }` |
| `POST /feed/mark` | corps `{ ids, state }` ou `{ all: true, filter, state }` (`state` : `seen`, `read`, `unread`, `archived`, `unarchived`) ; `200` et `{ state, updated }` |
| `POST /feed/snooze` | corps `{ id, until }` (date RFC 3339, 3 minutes à 90 jours, sinon `400` `NOTIFICATION_SNOOZE_INVALID`) ; sans `until` : réveil immédiat ; `200` et le message |
| `POST /feed/delete` | corps `{ id }` ou `{ all: true, filter }` ; `200` et `{ deleted }` |
| `POST /feed/{id}/action` | corps `{ action : primary ou secondary, status : done ou reverted }` ; `200` et le message ; bouton absent : `400` (`NOTIFICATION_FEED_ACTION_INVALID`) |

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
installées au démarrage ; un test vérifie leur correspondance. `manifest.toml` de l'hôte
déclare ce fichier et ses seeds (droit d'administration de l'installation, tâches de fond) :
l'hôte n'est pas un module du runtime.

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
service absent ; mots de passe d'application : création refusée sans authentification récente
puis acceptée après réauthentification, mot de passe rendu une seule fois et `no-store`, liste
sans secret, journal, révocations par le titulaire et les administrateurs, autre organisation et
simple membre refusés, jeton de clé d'API refusé), routes `/api/v1/system/migrations/*` (liste, abandon puis reprise par un administrateur de la plateforme, refus sans jeton, sans droit, sur requête illisible, migration non interrompue, bail d'installation détenu ailleurs, auteur et motif au journal du runtime), commandes `runtime migrations` serveur arrêté (`tests/it/runtime_cli.rs` : un module d'essai déclarant une migration est hébergé avec les modules embarqués ; migration laissée « en cours », démarrage de l'hôte refusé, liste, refus sur motif invalide et bail détenu ailleurs, abandon puis démarrage encore refusé, reprise puis démarrage réussi et migration rejouée, rien à décider sur une installation saine ou jamais démarrée, auteur `cli:<instance>` au journal ; les fonctions des commandes sont appelées sur la base embarquée du test, sans passer par la lecture de la configuration). `tests/scheduler_http.rs` parcourt les routes `/api/v1/scheduler/*` avec le
moteur réel (handler d'essai inscrit par le test) : planification contrôlée, prévision,
déclenchement, rejeu, exécution différée exécutée puis annulée et relancée, droits, `no-store`,
absence des routes du moteur. `tests/notification_http.rs` parcourt les routes de désabonnement
(clé applicative et `notification.public_url` fournies) : page sans effet, un clic rejouable,
page pour un navigateur, jeton modifié ou absent (`400`), abonné supprimé (`400`), liens non
configurés (`404`). `tests/notification_preview_http.rs` parcourt la route d'aperçu (rendu au nom
de l'appelant sans écriture, droits, corps refusé, `no-store`) et vérifie la planification de la
purge créée par l'installation. `tests/notification_webhooks_http.rs` parcourt les routes des
retours (signatures Mailgun et Resend, identifiants Postmark et Brevo, signature fausse,
horodatage trop ancien, rejeu dédoublonné, corps trop grand, intégration inconnue ; rejet
définitif qui supprime l'adresse) et d'essai (droits, faux fournisseur local, issue notée) ;
`tests/notification_push_http.rs` parcourt les routes push (paire VAPID rangée dans le
coffre-fort et clé publique notée, clé publique donnée à la personne de l'organisation seule,
inscription d'un navigateur, d'un Android et d'un iPhone avec jeton et clés scellés, inscription
renvoyée mise à jour, service push inconnu, autre organisation, sans jeton) ;
`tests/notification_channels_http.rs` parcourt les routes des adresses (adresse scellée par
l'hôte et ouverte par son seul contexte, jamais renvoyée, clé de signature montrée une fois puis
renouvelée, droits, hôte refusé) et le retour Twilio signé (accepté, signature fausse refusée,
rejeu dédoublonné) ; `tests/notification_feed_http.rs` parcourt le fil dans l'application
(flux SSE reçu par la seule personne concernée, compteurs poussés après « lu », routes du fil
au nom de la personne, `404` pour une autre personne, limite de 5 flux, session sans compte,
fermeture du flux à l'expiration de la session, reprise de la requête `LIVE SELECT` après
`KILL`, fermeture des flux à l'arrêt du worker ; signes de vie donnés à la main, sans fenêtre
de temps réelle) ;
`tests/it/startup.rs` démarre l'hôte sans aucun réglage d'envoi (sonde des notifications
dégradée). `tests/it/host_tasks.rs` vérifie les tâches de fond de l'hôte : tâches, permissions
et planifications présentes après l'installation, sans doublon au redémarrage ; exécution
déclenchée par le moteur réel (session expirée marquée, écriture abandonnée retirée, secret échu
purgé ; nettoyage sans support : rien) ; déclenchement et reprise refusés à un administrateur de
la plateforme, mise en pause acceptée. `tests/it/two_hosts.rs` démarre `lyxal-server` à côté
d'un second hôte d'essai (`lyxal_peer` : `lyxal_scheduler` et ses dépendances, planificateur et
exécuteur sans handler) sur la même base : modules trouvés installés, hook `install` non rejoué ;
route des modules listant les nœuds vivants des deux hôtes ; les trois tâches de fond exécutées
une fois chacune, en une tentative ; `lyxal-server` arrêté, les exécutions déclenchées attendent
(`queued`, aucune tentative) pendant que le second hôte réserve dans la même file, puis sont
faites au redémarrage de `lyxal-server`.
`scripts/ci/ci_local.sh` rejoue la CI complète.
