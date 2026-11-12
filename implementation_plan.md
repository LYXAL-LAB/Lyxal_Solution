# Plan d'implémentation — programme `lyxal_storage` V1

Création du crate du Noyau Technique `lyxal_storage` (rang 3 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](docs/14-roadmap/ROADMAP_NOYAU.md)) : fichiers et documents
stockés, avec le contrôle de qui y accède. Sources, et étude de la gestion de fichiers de
SurrealDB : [`crates/lyxal_storage/RECHERCHE_SOURCES.md`](crates/lyxal_storage/RECHERCHE_SOURCES.md).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (architecture,
modèle, lots, décisions). Chaque lot a ensuite son propre plan détaillé, soumis au CTO avant
toute ligne de code : contrats Rust `XxxParams` / `XxxResult`, signatures SurrealQL, codes
d'erreurs, tests.

## 1. Architecture

### 1.1. Répartition SurrealQL / Rust

La gestion de fichiers de SurrealDB 3.3.4 est expérimentale, sans flux ni transaction
(`RECHERCHE_SOURCES.md` §6). Le travail est donc partagé :

| SurrealQL (données et règles) | Rust (crate `lyxal_storage`, `object_store`) |
| :--- | :--- |
| Buckets : nom, organisation, taille maximale, types autorisés, lecture seule | Supports : disque local, mémoire (tests), S3 et compatibles |
| Fiche de chaque fichier : bucket, clé, propriétaire, taille, type, empreinte, état | Écriture et lecture **en flux**, sans charger un fichier en mémoire |
| Droits : qui lit, écrit, supprime (`lyxal_auth`) | Empreinte BLAKE3 calculée pendant l'écriture (`lyxal_crypto`) |
| États et transitions d'un fichier, quotas | Type réel du fichier, antivirus |
| Événements `storage.*` | Nettoyage des octets orphelins et purge (workers supervisés) |

### 1.2. Adresse d'un fichier

Un fichier est repéré par un **bucket** et une **clé** (`plans/2026/a.pdf`), comme la valeur
`file` de SurrealDB : la bascule future vers ses buckets ne changera pas les adresses. La fiche
`storage_object` a un identifiant propre ; les modules consommateurs la référencent par un champ
`record<storage_object>` déclaré `REFERENCE`.

### 1.3. Écriture en deux temps

Aucune transaction ne couvre la base et le support. Une écriture suit donc trois étapes :

1. `fn::storage_object_begin` : droits, quota et règles du bucket vérifiés ; fiche créée à
   l'état `pending` avec une date limite ;
2. Rust écrit les octets en flux, calcule l'empreinte et la taille, contrôle le type ;
3. `fn::storage_object_commit` : taille, type et empreinte enregistrés ; état `available`.

Un fichier `pending` n'est jamais servi. Un worker supprime les octets et la fiche d'une écriture
abandonnée. Une suppression marque la fiche `deleted`, puis le worker retire les octets : la
fiche ne disparaît qu'après eux.

### 1.4. Modèle (SurrealDB, préfixe `storage_`)

| Table | Contenu |
| :--- | :--- |
| `storage_settings` | réglages de l'installation, surchargés par organisation : taille maximale par défaut, quota, délai d'une écriture en attente, conservation après suppression |
| `storage_bucket` | nom (règle `lyxal_bucket_name` de `lyxal_core`), `tenant` (`NONE` : installation), support, taille maximale, types autorisés, lecture seule |
| `storage_object` | bucket, clé (règle `lyxal_storage_path`), `tenant`, propriétaire, nom d'origine, taille, type déclaré et type réel, empreinte BLAKE3, état (`pending`, `available`, `quarantined`, `deleted`), dates |
| `storage_upload` | envoi reprenable en cours : fichier visé, position atteinte, expiration |
| `storage_reclaim` | préfixe d'octets à retirer après la suppression d'un bucket |

* Les données d'une organisation sont supprimées avec elle (`REFERENCE ON DELETE CASCADE` sur
  `tenant`) ; leurs octets le sont par le worker de purge.
* **Permissions** par `fn::auth_has_permission` : `storage.bucket.manage`, `storage.object.read`,
  `storage.object.write` (organisation), `storage.installation.manage` et `storage.worker`
  (installation, compte de service).
* Les identifiants des supports (clés S3) ne sont pas en base : ils viennent de l'environnement de
  l'hôte, en `SecretString`, puis de `lyxal_secrets` quand il existera.

## 2. Dépendances

`lyxal_storage` dépend de `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` et, en Rust,
de `lyxal_surreal`, `lyxal_runtime` et `lyxal_crypto`. Bibliothèques : `object_store` 0.13 (déjà
dans `Cargo.lock` par le SDK `surrealdb`), `infer` (type réel), `clamav-client` (antivirus,
optionnel). Aucun module existant ne dépend de `lyxal_storage` avant la bascule de l'ingestion.

## 3. Fonctions publiques (`fn::storage_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages | `storage_settings_get`, `storage_settings_set` |
| Buckets | `storage_bucket_create`, `storage_bucket_update`, `storage_bucket_get`, `storage_bucket_list`, `storage_bucket_delete` (vide seulement) |
| Fichiers | `storage_object_begin`, `storage_object_commit`, `storage_object_get`, `storage_object_list`, `storage_object_delete`, `storage_object_usage` (volume d'une organisation) |
| Envoi reprenable | `storage_upload_create`, `storage_upload_advance`, `storage_upload_get`, `storage_upload_cancel` |
| Workers | `storage_object_expire` (écritures abandonnées), `storage_object_purge` (fichiers supprimés), `storage_object_quarantine` |

Entrées par le moteur `fn::validation_object_execute` de `lyxal_core` (règles existantes
`lyxal_bucket_name`, `lyxal_storage_path`, `filename`, `mime_type`, `checksum`) ; erreurs
`STORAGE_*` en master data ; écriture principale vérifiée (`STORAGE_WRITE_FORBIDDEN`).

## 4. Événements (`fn::event_publish`)

`storage.object.created`, `storage.object.deleted`, `storage.object.quarantined` : identifiants,
bucket, clé, taille et type ; jamais de contenu.

## 5. Lots

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1** | **Réalisé.** Socle SurrealQL : réglages, buckets, fiches de fichiers, états, droits, quotas, événements, erreurs, banc ; règle `checksum` de `lyxal_core` étendue à `blake3` ; module embarqué dans l'hôte. État : `crates/lyxal_storage/README.md` | `lyxal_storage`, `lyxal_core`, `apps/lyxal-server` |
| **2** | **Réalisé.** Crate Rust : supports disque et mémoire, écriture et lecture en flux, empreinte, écriture en deux temps, worker de nettoyage (octets des buckets et des organisations supprimés compris), module et sonde de santé ; support `default` de l'hôte par `LYXAL__STORAGE__DISK__ROOT`. État : `crates/lyxal_storage/README.md` | `lyxal_storage`, `apps/lyxal-server` |
| **3** | **Réalisé.** Hôte : routes `/api/v1/storage` d'envoi, de téléchargement (plage d'octets), de fiche, de liste et de suppression, en flux, sous la session de l'appelant ; taille bornée par le bucket. État : `apps/lyxal-server/README.md` | `apps/lyxal-server`, `lyxal_storage` |
| **4** | **Réalisé.** Support S3 et compatibles par `object_store` (Bunny Storage en référence), déclaré par nom dans l'environnement de l'hôte ; disque et S3 coexistent ; tests sur un serveur S3 de test. État : `crates/lyxal_storage/README.md` | `lyxal_storage`, `apps/lyxal-server` |
| **5** | Contrôle du contenu : type réel du fichier, antivirus, quarantaine ; affichage direct des images et des PDF dans le navigateur (décision H2 du lot 3) | `lyxal_storage`, `apps/lyxal-server` |
| **6** | Envoi reprenable (protocole tus 1.0) pour les gros fichiers | `lyxal_storage`, `apps/lyxal-server` |
| **7** | Bascule de l'ingestion : le fichier source d'un lot est conservé par `lyxal_storage` (constat A06 de l'audit externe) | `lyxal_pipeline_ingestion` |
| **8** | Clôture : audit `lyxal-audit`, `README.md`, `ROADMAP.md`, `AGENTS.md` §6, `ROADMAP_NOYAU.md`, `RECHERCHE_SOURCES.md` réduit en `MODELE_SOURCES.md` | docs |

## 6. Tests et critères de production

* **Banc SurrealQL** : chaque fonction ; droits par organisation (lecture, écriture, suppression
  refusées hors permission, fichiers d'une organisation invisibles d'une autre) ; quota ; taille
  et type refusés par le bucket ; fichier `pending` non servi ; transitions d'état.
* **Rust** : fichier écrit puis relu à l'identique, empreinte vérifiée ; écriture interrompue
  nettoyée ; fichier plus gros que la mémoire allouée au test ; mêmes tests sur disque, mémoire
  et S3 (serveur S3 de test).
* **Hôte** : envoi et téléchargement de bout en bout, lecture partielle, limite de taille,
  session requise.
* Contrôle complet : `scripts/ci/ci_local.sh` à chaque lot.

## 7. Checklist (§13)

* Core : règles existantes réutilisées ; aucune extension demandée à ce stade.
* Crypto : empreinte par `lyxal_crypto` (`Blake3Hasher`) ; aucune primitive ajoutée. Le
  chiffrement des fichiers au repos n'est pas dans cette V1 : il est inscrit à la feuille de
  route et sera soumis au CTO (§11.3).
* Rust : aucun `panic!`, aucune erreur silencieuse ; identifiants des supports en `SecretString`.
* Zéro dette : versions `0.y.z`, une seule migration par module.
* Licences : `object_store` (Apache-2.0), `infer` (MIT), `clamav-client` (MIT) ; ClamAV (GPL)
  reste un service séparé ; Supabase Storage et fileloft en conception seule.

## 8. Décisions du CTO (11 novembre 2026)

S1 à S6 validées selon les recommandations, avec Bunny Storage comme service S3 de référence.

| # | Question | Décision |
| :- | :--- | :--- |
| S1 | Où stocker le contenu des fichiers | **Par le code Rust (`object_store`)**, pas par les buckets de SurrealDB, encore expérimentaux et sans flux ; adresses compatibles pour basculer plus tard |
| S2 | Supports | **Disque local** d'abord (lot 2), **S3** dans le même programme (lot 4). Service S3 de référence : **Bunny Storage** par son API compatible S3 (aperçu public depuis juillet 2026 ; à choisir à la création de la zone de stockage). Le lot 4 comprend un essai réel sur une zone Bunny, identifiants fournis par le CTO, jamais dans le dépôt |
| S3 | Identité d'un fichier | **Identifiant propre** ; l'empreinte est une information de la fiche ; déduplication remise à plus tard |
| S4 | Antivirus | **Optionnel par configuration** (service ClamAV à part) ; le type réel du fichier est toujours contrôlé |
| S5 | Envoi reprenable | **Dans la V1** (lot 6) |
| S6 | Ingestion | **Branchée dans ce programme** (lot 7, constat A06) |

Décisions des lots : téléchargement toujours par l'hôte dans cette V1, les liens signés servis
par le support S3 sont à la feuille de route du module (J1, lot 4) ; un fichier téléchargé est
proposé à l'enregistrement, son affichage direct vient avec le contrôle du contenu (H2, lot 3).
