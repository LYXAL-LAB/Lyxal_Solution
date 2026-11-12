# Lyxal Storage

Module du Noyau Technique de Lyxal OS : **fichiers et documents stockés**. Les règles sont dans
SurrealDB (réglages, buckets, fiche de chaque fichier, états, droits, quotas, événements) ; le
crate Rust écrit et lit les octets en flux sur un support (disque local, service S3 ou
compatible, mémoire pour les tests), calcule leur empreinte, reconnaît leur type réel, les fait
analyser par un antivirus s'il y en a un, et retire les octets devenus inutiles. L'hôte expose l'envoi et le téléchargement par HTTP (`apps/lyxal-server/README.md`).
Les lots suivants sont dans la [`ROADMAP.md`](ROADMAP.md). Sources et étude de la
gestion de fichiers de SurrealDB : [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md).

| | |
| :--- | :--- |
| Identifiant | `lyxal_storage` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` |
| Dépendances Rust | `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto` ; `object_store` 0.13, `infer`, `clamav-client` |
| Hébergement | `apps/lyxal-server` (`StorageModule`, `StorageCleanupWorker`, `StorageHealthCheck`) |

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `storage_settings` | réglages de l'installation, surchargés par organisation : taille maximale d'un fichier, quota, délai d'une écriture en attente, délai d'un envoi reprenable, conservation après suppression, types refusés |
| `storage_bucket` | ensemble de fichiers : nom unique dans sa portée (`[a-z0-9-]`, 3 à 63 caractères), taille maximale, types MIME acceptés (vide : tous), lecture seule, support (`backend`, `default` par défaut, fixé à la création) |
| `storage_object` | fiche d'un fichier : bucket, clé (`plans/2026/a.pdf`), auteur (`owner` : identité ; `owner_application` : application d'un compte de service), nom d'origine, taille et type annoncés, taille, type réel et empreinte BLAKE3 posés à la fin de l'écriture, état, support et emplacement des octets (`backend`, `path`) |
| `storage_reclaim` | préfixe d'octets à retirer : bucket supprimé, ou parties d'un envoi reprenable qui n'est plus en cours |
| `storage_upload_part` | partie reçue d'un envoi reprenable : envoi, position, taille, nom de ses octets sur le support ; une seule partie par position (index unique) |

Portée : champ `tenant` (organisation `lyxal_auth`, absent pour l'installation) et `scope_key`
(`installation` ou clé de l'organisation). Les buckets, les fiches et les réglages d'une
organisation sont supprimés avec elle (`REFERENCE ON DELETE CASCADE`).

**Adresse d'un fichier** : un bucket et une clé, comme la valeur `file` de SurrealDB. Une adresse
n'est occupée que par un fichier non supprimé (champ `slot`, unique par bucket) ; écrire à une
adresse occupée est refusé. Un module consommateur référence une fiche par un champ
`record<storage_object>` déclaré `REFERENCE` : un fichier référencé ne se supprime pas.

**Emplacement des octets** : `<portée>/<clé du bucket>/<clé de la fiche>` sur le support du
bucket. La clé de la fiche, pas celle du fichier : un fichier supprimé et son remplaçant à la
même adresse coexistent jusqu'à la purge. Les octets d'une organisation sont sous un seul
préfixe.

**États** :

```text
pending ──► available ──► quarantined ──► deleted
   │            └─────────────────────────►  ▲
   └─────────────────────────────────────────┘
```

* `pending` : écriture ouverte, jamais servie, abandonnée après son délai ;
* `available` : seul état où le fichier peut être servi ;
* `quarantined` : retiré du service par le worker (contrôle du contenu), toujours compté ;
* `deleted` : adresse libérée ; la fiche reste jusqu'au retrait des octets par le worker.

Toute autre transition est refusée par la base (`STORAGE_OBJECT_STATE_INVALID`). Les règles des
fonctions valent aussi pour une écriture directe dans la table : une garde
(`storage_object_update_guard`, `fn::storage_object_update_refusal`) vérifie à chaque
modification l'identité de l'appelant (worker, auteur de l'écriture), le délai, le contenu posé,
les règles du bucket, les références et la durée de conservation. Hors transition, seul le
worker modifie les champs posés par les fonctions (taille, type, empreinte, dates). Un bucket qui porte encore une fiche ne se supprime qu'avec
son organisation (`STORAGE_BUCKET_NOT_EMPTY`).

**Écriture en deux temps** (aucune transaction ne couvre la base et le support) :

1. `fn::storage_object_begin` vérifie les droits, les règles du bucket et le quota, puis crée la
   fiche `pending` ;
2. les octets sont écrits sur le support (`StorageService::put`) ;
3. `fn::storage_object_commit` enregistre la taille, le type et l'empreinte, revérifie les
   règles et le quota, et rend le fichier `available`.

**Bucket supprimé** : l'événement `storage_bucket_reclaim` écrit, dans la transaction de la
suppression, le préfixe de ses octets dans `storage_reclaim`. Il vaut aussi pour un bucket
supprimé avec son organisation, dont les fiches partent en cascade : le worker retire alors les
octets au passage suivant.

**Envoi reprenable** (fichier reçu en plusieurs requêtes, repris après une coupure) :

1. `fn::storage_object_begin` avec `resumable` crée la fiche `pending` ; la taille est annoncée
   et le délai est celui des envois reprenables (`upload_ttl_seconds`, 24 h par défaut, de
   1 minute à 7 jours, non prolongé par l'activité) ;
2. chaque partie écrite sur le support, sous `<emplacement du fichier>.parts/`, est inscrite par
   `fn::storage_upload_part_add`. La position de l'envoi est la somme des tailles inscrites :
   la base est la seule vérité. Une partie n'est inscrite qu'à la position courante ; l'index
   unique (envoi, position) départage deux requêtes simultanées. 10 000 parties au plus ;
3. quand tous les octets sont reçus, l'assembleur (l'auteur de l'envoi, ou le worker) réserve
   l'assemblage (`fn::storage_upload_claim` : un seul assembleur, plus aucune partie acceptée,
   pas d'expiration pendant la réservation), relit les parties dans l'ordre, écrit le fichier et
   termine par `fn::storage_object_commit`, qui exige un envoi complet ;
4. dès que l'envoi n'est plus en cours (assemblé, abandonné, expiré, supprimé avec son
   organisation), l'événement `storage_object_upload_parts` retire ses lignes de parties et
   inscrit le dossier de leurs octets dans `storage_reclaim`, dans la même transaction : le
   worker le retire du support.

Seul l'auteur de l'envoi (ou le worker) le consulte et le poursuit. Une partie écrite directement
dans la table suit les mêmes règles (garde `storage_upload_part_guard`) ; une partie inscrite ne
se modifie pas.

**Types** : le type enregistré (`content_type`) est le type réel du fichier, reconnu dans son
contenu (§6) ; les types acceptés du bucket (`allowed_types`) et les types refusés des réglages
(`blocked_types`) s'appliquent au type annoncé à l'ouverture de l'écriture, puis au type réel à
sa fin. Par défaut, les programmes exécutables (Windows, Linux, macOS) sont refusés partout ;
la liste se règle par installation et par organisation.

**Limites** : 100 Mo par fichier par défaut, réglable par installation, organisation et bucket
(5 Go au plus) ; quota par portée, absent par défaut. Le quota compte les fichiers disponibles ou
en quarantaine et les tailles annoncées des écritures en attente.

## 2. Droits

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `storage.object.read` | organisation | lire les fiches et les fichiers de son organisation |
| `storage.object.write` | organisation | écrire et supprimer des fichiers (et les lire) |
| `storage.bucket.manage` | organisation | créer et régler les buckets et les réglages de son organisation (et lire) |
| `storage.installation.manage` | installation | buckets, fichiers et réglages de l'installation |
| `storage.worker` | installation | compte de service : lire et écrire toute portée, terminer une écriture, expirer, purger, mettre en quarantaine |

`organization_admin` reçoit les trois permissions d'organisation, `platform_admin` reçoit
`storage.installation.manage` ; `storage.worker` n'est attribuée à aucun rôle. Contrôle unique :
`fn::storage_can({ action, tenant })`, utilisé par les permissions des tables et par les
fonctions. Une fiche invisible de l'appelant est « introuvable ». Les réglages de l'installation
(limites) sont lisibles de toute session : ils servent de repli à chaque organisation.

## 3. Fonctions publiques (`fn::storage_*($params: object)`)

Entrées validées par `lyxal_core` ; retour `fn::result_ok` ou `fn::error_result` ; paramètre
commun `language` (`fr` par défaut). Paramètres obligatoires en gras ; `tenant` absent désigne
l'installation.

| Fonction | Paramètres | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `storage_settings_get` | `tenant` | `{ own, effective }` | lecture |
| `storage_settings_set` | `tenant`, `max_object_size`, `quota_bytes`, `pending_ttl_seconds`, `upload_ttl_seconds`, `deleted_retention_days`, `blocked_types`, `clear` | réglages ; champ fourni remplacé, champ dans `clear` effacé | gestion |
| `storage_bucket_create` | **name**, `tenant`, `description`, `max_object_size`, `allowed_types`, `readonly`, `backend` (`default`) | bucket | gestion |
| `storage_bucket_update` | **bucket**, `description`, `max_object_size`, `allowed_types`, `readonly`, `clear` (`description`, `max_object_size`) | bucket | gestion |
| `storage_bucket_get` | **bucket** | bucket et `usage: { objects, bytes }` | lecture |
| `storage_bucket_list` | `tenant`, `limit`, `start` | `{ items, total }`, triés par nom | lecture |
| `storage_bucket_delete` | **bucket** | `{ deleted }` ; refusé s'il porte une fiche | gestion |
| `storage_object_begin` | **bucket**, **key**, **filename**, `declared_type`, `declared_size`, `resumable` (envoi reprenable : `declared_size` obligatoire) | fiche `pending` et `max_size` (taille maximale acceptée) | écriture |
| `storage_object_commit` | **object**, **size**, **content_type**, **blake3** | fiche `available` | worker, ou l'appelant qui a ouvert l'écriture (son identité, ou son application pour un compte de service) |
| `storage_object_get` | **object**, ou **bucket** et **key** | fiche (par adresse : fichier non supprimé) | lecture |
| `storage_object_open` | **object**, ou **bucket** et **key** | fiche d'un fichier à servir ; refus s'il n'est pas `available` | lecture |
| `storage_object_list` | **bucket**, `prefix`, `state` (`available`), `limit`, `start` | `{ items, total }`, triés par clé | lecture |
| `storage_object_delete` | **object** | fiche `deleted` | écriture |
| `storage_object_usage` | `tenant` | `{ objects, bytes, reserved_bytes, quota_bytes }` | lecture |
| `storage_object_quarantine` | **object**, **reason** | fiche `quarantined` | worker |
| `storage_object_expire` | `limit` | `{ expired }` : écritures hors délai passées à `deleted` | worker |
| `storage_object_purge_list` | `limit`, `start` | `{ items: [{ id, backend, path, purge_after }] }` | worker |
| `storage_object_purge` | **object** | `{ purged }` : fiche supprimée, après le retrait des octets | worker |
| `storage_reclaim_list` | `limit`, `start` | `{ items: [{ id, backend, prefix, created_at }] }` | worker |
| `storage_reclaim_done` | **reclaim** | `{ done }` : ligne retirée, après le retrait des octets | worker |
| `storage_upload_get` | **object** | état d'un envoi reprenable : `{ id, state, backend, path, declared_type, length, offset, complete, max_size, expires_at }` ; introuvable s'il est abandonné, refusé s'il est hors délai | auteur de l'envoi, ou worker |
| `storage_upload_part_add` | **object**, **offset**, **size**, **name** (UUID) | état de l'envoi après l'inscription de la partie | auteur de l'envoi, ou worker |
| `storage_upload_part_list` | **object** | `{ items: [{ offset, size, name }] }`, dans l'ordre du fichier | auteur de l'envoi, ou worker |
| `storage_upload_claim` | **object**, `seconds` (1800), `release` | état de l'envoi ; assemblage réservé, ou réservation rendue | auteur de l'envoi, ou worker |
| `storage_upload_ready_list` | `limit` | `{ items }` : envois complets dont l'assemblage n'est ni fait ni en cours | worker |

Fonctions internes : `fn::storage_can`, `fn::storage_settings_effective`,
`fn::storage_scope_usage`, `fn::storage_object_limits`, `fn::storage_object_is_author`,
`fn::storage_object_update_refusal`, `fn::storage_upload_offset`, `fn::storage_upload_claimed`,
`fn::storage_upload_allowed`, `fn::storage_upload_view`, `fn::storage_upload_part_refusal`.

## 4. Erreurs (`error/<thème>/`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `STORAGE_INVALID_PARAMETERS` |
| `permissions` | `STORAGE_PERMISSION_DENIED`, `STORAGE_WRITE_FORBIDDEN` |
| `buckets` | `STORAGE_BUCKET_NOT_FOUND`, `STORAGE_BUCKET_EXISTS`, `STORAGE_BUCKET_NOT_EMPTY`, `STORAGE_BUCKET_READONLY` |
| `fichiers` | `STORAGE_OBJECT_NOT_FOUND`, `STORAGE_OBJECT_EXISTS`, `STORAGE_OBJECT_STATE_INVALID`, `STORAGE_OBJECT_IN_USE`, `STORAGE_OBJECT_TOO_LARGE`, `STORAGE_OBJECT_TYPE_REFUSED`, `STORAGE_QUOTA_EXCEEDED`, `STORAGE_RANGE_NOT_SATISFIABLE` |
| `supports` | `STORAGE_BACKEND_UNKNOWN`, `STORAGE_BACKEND_UNAVAILABLE` (à réessayer), `STORAGE_OBJECT_NOT_AVAILABLE`, `STORAGE_CONTENT_MISMATCH`, `STORAGE_INTEGRITY_FAILED`, `STORAGE_OBJECT_INFECTED`, `STORAGE_SCANNER_UNAVAILABLE` (à réessayer) |
| `envois` | `STORAGE_UPLOAD_OFFSET_MISMATCH` (position courante dans `details.offset`), `STORAGE_UPLOAD_EXPIRED`, `STORAGE_UPLOAD_BUSY` (à réessayer), `STORAGE_UPLOAD_TOO_MANY_PARTS`, `STORAGE_UPLOAD_INVALID_REQUEST`, `STORAGE_UPLOAD_VERSION_UNSUPPORTED` |

## 5. Événements

Publiés par `fn::event_publish` dans la transaction de la mutation : `storage.object.created`
(passage à `available`), `storage.object.quarantined`, `storage.object.deleted` (sauf pour une
écriture jamais terminée). Charge utile : `object_id`, `bucket_id`, `key`, `tenant`, `size`,
`content_type` ; jamais de contenu.

## 6. Crate Rust

| Élément | Rôle |
| :--- | :--- |
| `StorageStore` | un appel typé par fonction publique (`LyxalSurrealCall::call_fn`) ; la session du client détermine les droits |
| `models` | `XxxParams` et résultats nommés de chaque fonction |
| `Backends`, `BackendConfig` | supports nommés : `Disk { root }` (tout est écrit sous `root`), `S3 { endpoint, region, bucket, access_key_id, secret_access_key, path_style, allow_http }` (service S3 ou compatible, par `object_store` ; clé secrète en `SecretString`) et `Memory` (tests) |
| `StorageService` | `put` (écriture en flux), `stat` (fiche d'un fichier à servir), `open` (lecture en flux, en entier ou sur une plage `ByteRange` validée contre la taille de la fiche), `delete`, `verify` (relit les octets et compare taille et empreinte à la fiche) ; `with_scanner` branche un antivirus |
| `content::detect` | type réel d'un fichier, reconnu à ses premiers octets (`infer`) |
| `ContentScanner`, `ClamAvScanner`, `ScannerConfig` | antivirus branché sur l'écriture : service `clamd` de ClamAV, en TCP ou par socket Unix (`clamav-client`) |
| `StorageService` (`upload`) | envoi reprenable : `upload_create`, `upload_status`, `upload_append` (octets à une position), `upload_complete` (assemblage), `upload_terminate` |
| `StorageCleanupWorker` | worker supervisé : écritures abandonnées, envois reprenables complets restés sans assemblage, fichiers supprimés hors délai, octets des buckets supprimés et des parties d'envois terminés |
| `StorageModule`, `StorageHealthCheck` | module `LyxalModule` ; la sonde écrit, relit et retire un fichier témoin sur chaque support |
| `StorageError` | erreur SurrealQL ou du support ; `code()`, `is_retryable()` |

* **Flux** : `put` reçoit un flux d'octets et l'écrit par parties de 8 Mo ; rien d'autre n'est
  gardé en mémoire. L'empreinte BLAKE3 (`lyxal_crypto`) et la taille sont calculées au passage.
* **Taille** : l'écriture s'arrête dès que le contenu dépasse `max_size` ou la taille annoncée ;
  une taille annoncée doit être exacte (`STORAGE_CONTENT_MISMATCH`).
* **Type réel** : le type enregistré est celui reconnu dans les premiers octets du fichier ;
  sinon le type annoncé, s'il n'est pas de ceux que le contenu permet de reconnaître (texte,
  CSV, JSON…) ; sinon `application/octet-stream`. Un type annoncé que le contenu dément n'est
  pas cru : le fichier est accepté, jugé et servi sous son type réel.
* **Antivirus** (optionnel) : chaque morceau écrit est transmis à `clamd` dans le même
  passage, sans tâche de fond ni relecture. Menace reconnue : `STORAGE_OBJECT_INFECTED`, rien
  n'est conservé. Antivirus injoignable, muet ou fichier au-delà de sa limite
  (`StreamMaxLength` de `clamd`, à régler au moins à la taille maximale des fichiers) :
  `STORAGE_SCANNER_UNAVAILABLE`, l'envoi est refusé. Sans antivirus configuré, seul le type
  réel est contrôlé. ClamAV (GPL) reste un service séparé : aucun code GPL n'est lié.
* **Envoi reprenable** : `upload_append` vérifie la position, puis écrit les octets reçus par
  parties de 8 Mo au plus (une partie en mémoire) et inscrit chacune. Ce qui est reçu avant une
  coupure du flux est conservé ; une partie refusée par la base est retirée du support. La
  requête qui apporte le dernier octet assemble le fichier : les parties sont relues en flux et
  passent par l'écriture d'un envoi simple (taille, empreinte, type réel, antivirus) ; pendant
  cette étape le fichier occupe deux fois sa place. Contenu refusé (type interdit, virus) :
  l'envoi est abandonné. Échec passager (support, antivirus ou base indisponible), ou arrêt du
  serveur : l'envoi reste complet et le worker l'assemble à son passage suivant (au plus tard
  30 minutes après un arrêt en cours d'assemblage, durée de la réservation).
* **Échec** (support, taille, flux interrompu, fin d'écriture refusée) : les octets écrits sont
  retirés, la fiche passe à `deleted`, l'erreur est rendue. Une écriture coupée par l'arrêt du
  serveur est retirée par le worker à la fin de son délai.
* **Lecture** : seul un fichier `available` est servi (`fn::storage_object_open`).
* **Nettoyage** : les octets d'abord, la fiche ou la ligne ensuite ; des octets déjà absents ne
  sont pas une erreur. Un élément en échec (support inconnu ou injoignable) est journalisé,
  repris au passage suivant, et ne retient pas les éléments qui le suivent. Sur disque, les
  fichiers d'écriture en cours laissés par un arrêt brutal du serveur sont retirés avec la fiche
  ou le bucket. L'annulation est vérifiée entre deux fichiers.
* **S3** : un bucket du service porte les octets de tous les buckets Lyxal qui nomment ce
  support, sous les mêmes emplacements que sur disque. Service de référence : Bunny Storage
  (`RECHERCHE_SOURCES.md` §7) ; adresses de la forme `/<bucket>/<clé>` par défaut. Les erreurs
  passagères et les réponses `503` sont retentées par `object_store` ; un service injoignable ou
  des identifiants refusés rendent `STORAGE_BACKEND_UNAVAILABLE`, sans identifiant dans le
  message. Un envoi en plusieurs parties coupé par un arrêt brutal du serveur n'est pas retiré
  par le worker : c'est le service qui l'efface. Bunny le fait seul après 10 jours ; **sur un
  autre service S3 (AWS, par exemple), une règle de cycle de vie qui abandonne les envois en
  plusieurs parties incomplets (`AbortIncompleteMultipartUpload`) doit être posée sur le
  bucket**, sans quoi ces parties restent stockées et facturées.
* **Sans support configuré** : `put` et `open` rendent `STORAGE_BACKEND_UNKNOWN`, la sonde est
  « dégradée ».

## 7. Vérification

* Banc SurrealQL `tests/` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `buckets`,
  `fichiers`, `droits`, `envois` ; chaque fonction est appelée, sous la session système et sous des
  identités avec et sans permission.
* Tests Rust `tests/it/` (base embarquée ; supports mémoire, disque et S3 sur un serveur S3 de
  test `s3s-fs` lancé dans les tests) : fichier écrit puis relu
  à l'identique, plage d'octets, fichier de 64 Mo sans dépasser trois parties en mémoire, échecs
  nettoyés, fichier altéré détecté, worker, sonde, appels du store ; type réel et types refusés ;
  envoi reprenable (plusieurs requêtes, coupure, mauvaise position, deux requêtes simultanées,
  contenu refusé à l'assemblage, assemblage terminé par le worker, abandon, expiration) ;
  antivirus sur un faux service `clamd` lancé dans les tests (fichier sain, signature de test
  EICAR, limite de taille, service injoignable ou muet). Un essai sur un vrai service ClamAV
  n'est pas dans les contrôles automatiques : `ClamAvScanner` sur `127.0.0.1:3310` après
  `clamd` démarré, à lancer à la main.
* Non couvert par un test : le refus au-delà de 10 000 parties (`STORAGE_UPLOAD_TOO_MANY_PARTS`).
* Essai réel sur un service S3 (`tests/it/real_s3.rs`, ignoré par défaut) : variables
  `LYXAL_TEST_S3_*`, puis `cargo test -p lyxal_storage --test it real_s3 -- --ignored`.
* `apps/lyxal-server` : démarrage avec et sans dossier de stockage (`startup.rs`) ; routes des
  fichiers de bout en bout, sur disque et sur S3 (`storage_routes.rs`).
* `scripts/ci/ci_local.sh` rejoue la CI complète.
