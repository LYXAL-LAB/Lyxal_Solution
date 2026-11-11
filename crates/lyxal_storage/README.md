# Lyxal Storage

Module du Noyau Technique de Lyxal OS : **fichiers et documents stockés**. Les règles sont dans
SurrealDB (réglages, buckets, fiche de chaque fichier, états, droits, quotas, événements) ; le
crate Rust écrit et lit les octets en flux sur un support (disque local, mémoire pour les
tests), calcule leur empreinte et retire les octets devenus inutiles. Les routes HTTP d'envoi et
de téléchargement, puis S3, sont dans la [`ROADMAP.md`](ROADMAP.md). Sources et étude de la
gestion de fichiers de SurrealDB : [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md).

| | |
| :--- | :--- |
| Identifiant | `lyxal_storage` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` |
| Dépendances Rust | `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto` ; `object_store` 0.13 |
| Hébergement | `apps/lyxal-server` (`StorageModule`, `StorageCleanupWorker`, `StorageHealthCheck`) |

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `storage_settings` | réglages de l'installation, surchargés par organisation : taille maximale d'un fichier, quota, délai d'une écriture en attente, conservation après suppression |
| `storage_bucket` | ensemble de fichiers : nom unique dans sa portée (`[a-z0-9-]`, 3 à 63 caractères), taille maximale, types MIME acceptés (vide : tous), lecture seule, support (`backend`, `default` par défaut, fixé à la création) |
| `storage_object` | fiche d'un fichier : bucket, clé (`plans/2026/a.pdf`), propriétaire, nom d'origine, taille et type annoncés, taille, type réel et empreinte BLAKE3 posés à la fin de l'écriture, état, support et emplacement des octets (`backend`, `path`) |
| `storage_reclaim` | préfixe d'octets à retirer après la suppression d'un bucket |

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
| `storage_settings_set` | `tenant`, `max_object_size`, `quota_bytes`, `pending_ttl_seconds`, `deleted_retention_days`, `clear` | réglages ; champ fourni remplacé, champ dans `clear` effacé | gestion |
| `storage_bucket_create` | **name**, `tenant`, `description`, `max_object_size`, `allowed_types`, `readonly`, `backend` (`default`) | bucket | gestion |
| `storage_bucket_update` | **bucket**, `description`, `max_object_size`, `allowed_types`, `readonly`, `clear` (`description`, `max_object_size`) | bucket | gestion |
| `storage_bucket_get` | **bucket** | bucket et `usage: { objects, bytes }` | lecture |
| `storage_bucket_list` | `tenant`, `limit`, `start` | `{ items, total }`, triés par nom | lecture |
| `storage_bucket_delete` | **bucket** | `{ deleted }` ; refusé s'il porte une fiche | gestion |
| `storage_object_begin` | **bucket**, **key**, **filename**, `declared_type`, `declared_size` | fiche `pending` et `max_size` (taille maximale acceptée) | écriture |
| `storage_object_commit` | **object**, **size**, **content_type**, **blake3** | fiche `available` | worker, ou l'identité qui a ouvert l'écriture |
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

Fonctions internes : `fn::storage_can`, `fn::storage_settings_effective`,
`fn::storage_scope_usage`, `fn::storage_object_limits`, `fn::storage_object_update_refusal`.

## 4. Erreurs (`error/<thème>/`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `STORAGE_INVALID_PARAMETERS` |
| `permissions` | `STORAGE_PERMISSION_DENIED`, `STORAGE_WRITE_FORBIDDEN` |
| `buckets` | `STORAGE_BUCKET_NOT_FOUND`, `STORAGE_BUCKET_EXISTS`, `STORAGE_BUCKET_NOT_EMPTY`, `STORAGE_BUCKET_READONLY` |
| `fichiers` | `STORAGE_OBJECT_NOT_FOUND`, `STORAGE_OBJECT_EXISTS`, `STORAGE_OBJECT_STATE_INVALID`, `STORAGE_OBJECT_IN_USE`, `STORAGE_OBJECT_TOO_LARGE`, `STORAGE_OBJECT_TYPE_REFUSED`, `STORAGE_QUOTA_EXCEEDED` |
| `supports` | `STORAGE_BACKEND_UNKNOWN`, `STORAGE_BACKEND_UNAVAILABLE` (à réessayer), `STORAGE_OBJECT_NOT_AVAILABLE`, `STORAGE_CONTENT_MISMATCH`, `STORAGE_INTEGRITY_FAILED` |

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
| `Backends`, `BackendConfig` | supports nommés : `Disk { root }` (tout est écrit sous `root`) et `Memory` (tests) |
| `StorageService` | `put` (écriture en flux), `open` (lecture en flux, en entier ou sur une plage d'octets), `delete`, `verify` (relit les octets et compare taille et empreinte à la fiche) |
| `StorageCleanupWorker` | worker supervisé : écritures abandonnées, fichiers supprimés hors délai, octets des buckets supprimés |
| `StorageModule`, `StorageHealthCheck` | module `LyxalModule` ; la sonde écrit, relit et retire un fichier témoin sur chaque support |
| `StorageError` | erreur SurrealQL ou du support ; `code()`, `is_retryable()` |

* **Flux** : `put` reçoit un flux d'octets et l'écrit par parties de 8 Mo ; rien d'autre n'est
  gardé en mémoire. L'empreinte BLAKE3 (`lyxal_crypto`) et la taille sont calculées au passage.
* **Taille** : l'écriture s'arrête dès que le contenu dépasse `max_size` ou la taille annoncée ;
  une taille annoncée doit être exacte (`STORAGE_CONTENT_MISMATCH`).
* **Type** : le type enregistré est le type annoncé, sinon `application/octet-stream`.
* **Échec** (support, taille, flux interrompu, fin d'écriture refusée) : les octets écrits sont
  retirés, la fiche passe à `deleted`, l'erreur est rendue. Une écriture coupée par l'arrêt du
  serveur est retirée par le worker à la fin de son délai.
* **Lecture** : seul un fichier `available` est servi (`fn::storage_object_open`).
* **Nettoyage** : les octets d'abord, la fiche ou la ligne ensuite ; des octets déjà absents ne
  sont pas une erreur. Un élément en échec (support inconnu ou injoignable) est journalisé,
  repris au passage suivant, et ne retient pas les éléments qui le suivent. Sur disque, les
  fichiers d'écriture en cours laissés par un arrêt brutal du serveur sont retirés avec la fiche
  ou le bucket. L'annulation est vérifiée entre deux fichiers.
* **Sans support configuré** : `put` et `open` rendent `STORAGE_BACKEND_UNKNOWN`, la sonde est
  « dégradée ».

## 7. Vérification

* Banc SurrealQL `tests/` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `buckets`,
  `fichiers`, `droits` ; chaque fonction est appelée, sous la session système et sous des
  identités avec et sans permission.
* Tests Rust `tests/it/` (base embarquée, supports mémoire et disque) : fichier écrit puis relu
  à l'identique, plage d'octets, fichier de 64 Mo sans dépasser trois parties en mémoire, échecs
  nettoyés, fichier altéré détecté, worker, sonde, appels du store.
* `apps/lyxal-server` : démarrage avec et sans dossier de stockage (`startup.rs`).
* `scripts/ci/ci_local.sh` rejoue la CI complète.
