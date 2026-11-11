# Lyxal Storage

Module du Noyau Technique de Lyxal OS : **fichiers et documents stockés**. Ce qui existe
aujourd'hui est le socle dans SurrealDB : réglages, buckets, fiche de chaque fichier, états,
droits, quotas et événements. L'écriture et la lecture des octets (disque, puis S3) arrivent
avec le crate Rust ; d'ici là aucun octet n'est stocké. Sources et étude de la gestion de fichiers
de SurrealDB : [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) ; lots suivants dans
[`ROADMAP.md`](ROADMAP.md).

| | |
| :--- | :--- |
| Identifiant | `lyxal_storage` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` |
| Hébergement | `apps/lyxal-server` (`ManifestModule`) |

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `storage_settings` | réglages de l'installation, surchargés par organisation : taille maximale d'un fichier, quota, délai d'une écriture en attente, conservation après suppression |
| `storage_bucket` | ensemble de fichiers : nom unique dans sa portée (`[a-z0-9-]`, 3 à 63 caractères), taille maximale, types MIME acceptés (vide : tous), lecture seule |
| `storage_object` | fiche d'un fichier : bucket, clé (`plans/2026/a.pdf`), propriétaire, nom d'origine, taille et type annoncés, taille, type réel et empreinte BLAKE3 posés à la fin de l'écriture, état |

Portée : champ `tenant` (organisation `lyxal_auth`, absent pour l'installation) et `scope_key`
(`installation` ou clé de l'organisation). Les buckets, les fiches et les réglages d'une
organisation sont supprimés avec elle (`REFERENCE ON DELETE CASCADE`).

**Adresse d'un fichier** : un bucket et une clé, comme la valeur `file` de SurrealDB. Une adresse
n'est occupée que par un fichier non supprimé (champ `slot`, unique par bucket) ; écrire à une
adresse occupée est refusé. Un module consommateur référence une fiche par un champ
`record<storage_object>` déclaré `REFERENCE` : un fichier référencé ne se supprime pas.

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

Toute autre transition est refusée par la base, même en écriture directe
(`STORAGE_OBJECT_STATE_INVALID`). Un bucket qui porte encore une fiche ne se supprime qu'avec
son organisation (`STORAGE_BUCKET_NOT_EMPTY`).

**Écriture en deux temps** (aucune transaction ne couvre la base et le support) :

1. `fn::storage_object_begin` vérifie les droits, les règles du bucket et le quota, puis crée la
   fiche `pending` ;
2. les octets sont écrits sur le support ;
3. `fn::storage_object_commit` enregistre la taille, le type réel et l'empreinte, revérifie les
   règles et le quota, et rend le fichier `available`.

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
| `storage_bucket_create` | **name**, `tenant`, `description`, `max_object_size`, `allowed_types`, `readonly` | bucket | gestion |
| `storage_bucket_update` | **bucket**, `description`, `max_object_size`, `allowed_types`, `readonly`, `clear` (`description`, `max_object_size`) | bucket | gestion |
| `storage_bucket_get` | **bucket** | bucket et `usage: { objects, bytes }` | lecture |
| `storage_bucket_list` | `tenant`, `limit`, `start` | `{ items, total }`, triés par nom | lecture |
| `storage_bucket_delete` | **bucket** | `{ deleted }` ; refusé s'il porte une fiche | gestion |
| `storage_object_begin` | **bucket**, **key**, **filename**, `declared_type`, `declared_size` | fiche `pending` | écriture |
| `storage_object_commit` | **object**, **size**, **content_type**, **blake3** | fiche `available` | worker, ou l'identité qui a ouvert l'écriture |
| `storage_object_get` | **object**, ou **bucket** et **key** | fiche (par adresse : fichier non supprimé) | lecture |
| `storage_object_list` | **bucket**, `prefix`, `state` (`available`), `limit`, `start` | `{ items, total }`, triés par clé | lecture |
| `storage_object_delete` | **object** | fiche `deleted` | écriture |
| `storage_object_usage` | `tenant` | `{ objects, bytes, reserved_bytes, quota_bytes }` | lecture |
| `storage_object_quarantine` | **object**, **reason** | fiche `quarantined` | worker |
| `storage_object_expire` | `limit` | `{ expired }` : écritures hors délai passées à `deleted` | worker |
| `storage_object_purge_list` | `limit` | `{ items: [{ id, bucket, bucket_name, scope_key, key, purge_after }] }` | worker |
| `storage_object_purge` | **object** | `{ purged }` : fiche supprimée, après le retrait des octets | worker |

Fonctions internes : `fn::storage_can`, `fn::storage_settings_effective`,
`fn::storage_scope_usage`, `fn::storage_object_limits`.

## 4. Erreurs (`error/<thème>/`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `STORAGE_INVALID_PARAMETERS` |
| `permissions` | `STORAGE_PERMISSION_DENIED`, `STORAGE_WRITE_FORBIDDEN` |
| `buckets` | `STORAGE_BUCKET_NOT_FOUND`, `STORAGE_BUCKET_EXISTS`, `STORAGE_BUCKET_NOT_EMPTY`, `STORAGE_BUCKET_READONLY` |
| `fichiers` | `STORAGE_OBJECT_NOT_FOUND`, `STORAGE_OBJECT_EXISTS`, `STORAGE_OBJECT_STATE_INVALID`, `STORAGE_OBJECT_IN_USE`, `STORAGE_OBJECT_TOO_LARGE`, `STORAGE_OBJECT_TYPE_REFUSED`, `STORAGE_QUOTA_EXCEEDED` |

## 5. Événements

Publiés par `fn::event_publish` dans la transaction de la mutation : `storage.object.created`
(passage à `available`), `storage.object.quarantined`, `storage.object.deleted` (sauf pour une
écriture jamais terminée). Charge utile : `object_id`, `bucket_id`, `key`, `tenant`, `size`,
`content_type` ; jamais de contenu.

## 6. Vérification

* Banc SurrealQL `tests/` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `buckets`,
  `fichiers`, `droits` ; chaque fonction est appelée, sous la session système et sous des
  identités avec et sans permission.
* `apps/lyxal-server` : module installé au démarrage (`startup.rs`).
* `scripts/ci/ci_local.sh` rejoue la CI complète.
