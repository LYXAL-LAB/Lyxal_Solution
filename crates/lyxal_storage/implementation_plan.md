# Plan d'implémentation — `lyxal_storage`, lot 1 : socle SurrealQL

Premier lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décisions S1 à
S6). Il crée le module et tout ce qui vit dans SurrealDB : réglages, buckets, fiches de fichiers,
états, droits, quotas, événements. Aucun octet n'est encore écrit : le support (disque) arrive au
lot 2. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **F1** | L'empreinte d'un fichier est une empreinte BLAKE3. La règle `checksum` de `lyxal_core` ne la connaît pas (elle connaît `crc32`, `md5`, `sha1`, `sha256`, `sha384`, `sha512`). | **Ajouter `blake3` à la règle `checksum`** (64 caractères hexadécimaux). Extension minime du Core (§5.7.7), plutôt qu'un contrôle écrit dans le module |
| **F2** | Limites par défaut | Taille maximale d'un fichier : **100 Mo**, modifiable par bucket jusqu'à 5 Go. Quota d'une organisation : **aucun par défaut**, réglable |
| **F3** | Qui lit un fichier ? | Dans ce lot : **les membres de l'organisation qui ont la permission**. Les buckets publics (lisibles sans session) sont inscrits à la feuille de route |
| **F4** | Écrire à une adresse déjà occupée | **Refusé** : il faut supprimer le fichier d'abord. Les versions d'un fichier sont inscrites à la feuille de route |

## 2. Module

Structure canonique (§4) : `manifest.toml` (dépendances `lyxal_core`, `lyxal_error`,
`lyxal_event`, `lyxal_auth`), `schema/`, `functions/`, `events/`, `error/`, `seeds/`, `tests/`,
`README.md`, `ROADMAP.md`. Pas de migration (régime pré-production), version `0.1.0`. Aucun code
Rust dans ce lot : l'hôte porte le module par un `ManifestModule` (`build.rs`).

## 3. Schéma (`TYPE NORMAL SCHEMAFULL`)

| Table | Champs | Règles |
| :--- | :--- | :--- |
| `storage_settings` | `tenant` (option, `REFERENCE ON DELETE CASCADE`), `scope_key`, `max_object_size`, `quota_bytes`, `pending_ttl_seconds`, `deleted_retention_days`, `updated_at` | une ligne par portée (`installation` ou organisation) ; valeurs effectives : organisation, sinon installation, sinon défauts (100 Mo, sans quota, 24 h, 7 jours) |
| `storage_bucket` | `tenant`, `scope_key`, `name`, `description`, `max_object_size`, `allowed_types`, `readonly`, `created_at`, `updated_at` | (`scope_key`, `name`) unique ; `name` par la règle `lyxal_bucket_name` ; jamais supprimé s'il contient un fichier |
| `storage_object` | `bucket` (`REFERENCE ON DELETE REJECT`), `tenant`, `scope_key`, `key`, `owner` (identité, `REFERENCE ON DELETE UNSET`), `filename`, `declared_type`, `content_type`, `size`, `declared_size`, `blake3`, `state`, `pending_expires_at`, `deleted_at`, `purge_after`, `created_at`, `updated_at` | (`bucket`, `key`) unique parmi les fichiers non supprimés ; `key` par la règle `lyxal_storage_path` ; `size`, `content_type` et `blake3` posés au `commit` seulement |

États de `storage_object` : `pending` → `available` → `deleted` ; `available` → `quarantined` →
`deleted` ; `pending` → `deleted` (écriture abandonnée). Aucune autre transition. Un fichier
référencé par un autre module (champ `REFERENCE`) ne peut pas être supprimé
(`STORAGE_OBJECT_IN_USE`).

Permissions des tables : lecture par `fn::storage_can` (§4) ; écritures par les fonctions,
vérifiées (`STORAGE_WRITE_FORBIDDEN`). La table `storage_upload` (envoi reprenable) est créée au
lot 6.

## 4. Droits

Permissions `lyxal_auth` créées en seed :

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `storage.object.read` | organisation | lire les fiches et les fichiers de son organisation |
| `storage.object.write` | organisation | écrire et supprimer des fichiers |
| `storage.bucket.manage` | organisation | créer et régler les buckets et les réglages de son organisation |
| `storage.installation.manage` | installation | buckets et réglages de l'installation |
| `storage.worker` | installation | compte de service : terminer une écriture, expirer, purger, mettre en quarantaine |

Rôles : `organization_admin` reçoit les trois permissions d'organisation ; `platform_admin` reçoit
`storage.installation.manage` ; `storage.worker` n'est donnée à aucun rôle. Contrôle unique :
`fn::storage_can({ action, tenant })` (interne), comme `fn::notification_can`.

## 5. Fonctions publiques (`fn::storage_*($params: object)`)

Toutes renvoient `fn::result_ok` ou `fn::error_result`. Entrées par
`fn::validation_object_execute` ; règles Core : `record`, `lyxal_bucket_name`,
`lyxal_storage_path`, `filename`, `mime_type`, `checksum` (`blake3`, F1), `integer`, `boolean`,
`optional_string`, `array_of_strings`, `language_code`.

| Fonction | Paramètres (**obligatoires**) | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `storage_settings_get` | `tenant` | `{ own, effective }` | lecture |
| `storage_settings_set` | `tenant`, `max_object_size`, `quota_bytes`, `pending_ttl_seconds`, `deleted_retention_days`, `clear` | réglages | gestion |
| `storage_bucket_create` | **name**, `tenant`, `description`, `max_object_size`, `allowed_types`, `readonly` | bucket | gestion |
| `storage_bucket_update` | **bucket**, `description`, `max_object_size`, `allowed_types`, `readonly`, `clear` | bucket | gestion |
| `storage_bucket_get` | **bucket** | bucket et son volume `{ objects, bytes }` | lecture |
| `storage_bucket_list` | `tenant`, `limit`, `start` | `{ items, total }` | lecture |
| `storage_bucket_delete` | **bucket** | `{ deleted }` ; refusé s'il contient un fichier | gestion |
| `storage_object_begin` | **bucket**, **key**, **filename**, `declared_type`, `declared_size` | fiche `pending` | écriture |
| `storage_object_commit` | **object**, **size**, **content_type**, **blake3** | fiche `available` | worker ou auteur de l'écriture |
| `storage_object_get` | `object` ou (`bucket`, `key`) | fiche | lecture |
| `storage_object_list` | **bucket**, `prefix`, `state`, `limit`, `start` | `{ items, total }` | lecture |
| `storage_object_delete` | **object** | fiche `deleted` | écriture |
| `storage_object_usage` | `tenant` | `{ objects, bytes, quota_bytes }` | lecture |
| `storage_object_quarantine` | **object**, **reason** | fiche `quarantined` | worker |
| `storage_object_expire` | `limit` | `{ expired }` : écritures `pending` hors délai passées à `deleted` | worker |
| `storage_object_purge_list` | `limit` | fichiers `deleted` dont le délai de conservation est écoulé | worker |
| `storage_object_purge` | **object** | `{ purged }` : fiche supprimée, après le retrait des octets | worker |

Règles de `storage_object_begin` : bucket en lecture seule refusé ; adresse occupée refusée (F4) ;
taille déclarée au-delà de la limite du bucket ou du quota de l'organisation refusée ; type
déclaré hors des types autorisés du bucket refusé. `storage_object_commit` revérifie la taille
réelle, le type réel et le quota, et refuse une fiche qui n'est plus `pending`.

Types Rust `XxxParams` / `XxxResult` et wrappers `store.call_fn` : définis au lot 2, avec le
crate Rust.

## 6. Erreurs (`error/<thème>/`, préfixe `STORAGE_`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `STORAGE_INVALID_PARAMETERS` |
| `permissions` | `STORAGE_PERMISSION_DENIED`, `STORAGE_WRITE_FORBIDDEN` |
| `buckets` | `STORAGE_BUCKET_NOT_FOUND`, `STORAGE_BUCKET_EXISTS`, `STORAGE_BUCKET_NOT_EMPTY`, `STORAGE_BUCKET_READONLY` |
| `fichiers` | `STORAGE_OBJECT_NOT_FOUND`, `STORAGE_OBJECT_EXISTS`, `STORAGE_OBJECT_STATE_INVALID`, `STORAGE_OBJECT_IN_USE`, `STORAGE_OBJECT_TOO_LARGE`, `STORAGE_OBJECT_TYPE_REFUSED`, `STORAGE_QUOTA_EXCEEDED` |

## 7. Événements (`fn::event_publish`, résultat vérifié)

`storage.object.created` (passage à `available`), `storage.object.deleted`,
`storage.object.quarantined` : identifiant, bucket, clé, organisation, taille, type ; jamais de
contenu.

## 8. Core (F1)

`fn::validation_checksum` : algorithme `blake3` ajouté (64 caractères hexadécimaux), avec son
test dans la suite de `lyxal_core`. Aucune autre extension.

## 9. Hôte

`apps/lyxal-server/build.rs` : `lyxal_storage` embarqué ; tests de démarrage mis à jour
(nombre de modules hébergés).

## 10. Documents

`README.md` et `ROADMAP.md` du module ; `.agents/AGENTS.md` §6 et
`docs/14-roadmap/ROADMAP_NOYAU.md` (`lyxal_storage` créé) ; ligne 1 du plan racine passée à
« Réalisé ». Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 11. Tests (banc SurrealQL)

* réglages : valeurs effectives, bornes ;
* buckets : création, nom invalide, doublon, modification, suppression refusée s'il n'est pas
  vide ;
* fichiers : parcours `begin` → `commit` → `get` → `delete` ; adresse occupée ; taille, type et
  quota refusés ; transitions interdites ; fichier `pending` absent des listes par défaut ;
  expiration et purge ;
* droits : chaque fonction sous une identité sans permission ; fichiers d'une organisation
  invisibles d'une autre ; écriture filtrée par les permissions (`STORAGE_WRITE_FORBIDDEN`) ;
* événements publiés ; rejeu des seeds ; chaque fonction appelée.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 12. Checklist (§13)

* Architecture : module du noyau, sans dépendance vers un module métier ; aucun cycle.
* Core : entrées par le moteur ; une extension demandée (F1).
* Crypto : aucune opération dans ce lot (l'empreinte est calculée au lot 2 par `lyxal_crypto`).
* Zéro dette : `0.1.0`, aucune migration, aucun alias.
