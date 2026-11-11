# `lyxal_storage` — recherche de sources open source

Document de travail préalable au plan d'implémentation de `lyxal_storage` (crate du Noyau
Technique, rang 3 de [`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)).
Le crate n'existe pas encore : ce dossier ne contient que ce document. Aucun code ne sera écrit
avant un `implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3). Ce document est
retiré, ou réduit aux sources retenues, quand le crate est créé.

Recherche du 8 novembre 2026, revue le 11 novembre 2026 : états de maintenance revérifiés, et
gestion de fichiers de SurrealDB étudiée dans son code et essayée sur le serveur 3.3.4 (§6). Cette
étude change le choix de la brique d'accès aux supports : `object_store` au lieu d'OpenDAL (§5).

## 1. Besoin

`lyxal_storage` range et retrouve les fichiers de Lyxal OS, avec le contrôle de qui y accède :

* **Ingestion** : conserver le fichier source d'un lot pour la reprise automatique après
  redémarrage (constat A06 de l'audit externe du 7 novembre 2026).
* **Modules métiers à venir** : `lyxal_documents` (devis, factures, plans), `lyxal_btp` (photos,
  pièces jointes).
* **Preuves** : justificatifs fournisseurs (certificats, fiches techniques).

Fonctions attendues :

| Besoin | Détail |
| :--- | :--- |
| Écriture et lecture en flux | sans charger un fichier entier en mémoire |
| Plusieurs supports | disque local au démarrage ; stockage objet compatible S3, Google Cloud, Azure ensuite |
| Intégrité | empreinte BLAKE3 de chaque fichier, vérifiable |
| Métadonnées en base | propriétaire, taille, type, empreinte, dates, dans SurrealDB |
| Droits d'accès | selon l'identité de `lyxal_auth` |
| Gros fichiers | envoi reprenable après coupure |
| Sécurité du contenu | type réel du fichier, antivirus |
| Plus tard | déduplication, conservation et purge |

## 2. Principe d'assemblage

Plusieurs projets, chacun pour une brique, plutôt qu'un seul. Deux façons de les utiliser :

* **Dépendance** : la bibliothèque Rust est prise telle quelle, à version fixée par `Cargo.lock`
  (même règle que `lyxal_parsing`).
* **Modèle** : l'architecture d'un projet, Rust ou non, est étudiée et transcrite en Rust.

Règle de licence :

* on ne copie ou transcrit du code que depuis des licences permissives (Apache-2.0, MIT, BSD) ;
* un projet GPL ou AGPL ne sert que comme service séparé, non modifié, jamais copié.

## 3. Sources retenues

| Brique | Projet | Langage, licence | Usage |
| :--- | :--- | :--- | :--- |
| Accès aux supports (disque, S3, GCS, Azure) | [`object_store`](https://docs.rs/object_store) (Apache Arrow) | Rust, Apache-2.0 ; 0.13.2, **déjà dans `Cargo.lock`** par le SDK `surrealdb` | **Dépendance**, cœur technique (voir §5) |
| Architecture du service | [Supabase Storage](https://github.com/supabase/storage/wiki) | TypeScript, Apache-2.0 | **Modèle** : buckets, métadonnées et droits en base, octets à part ; transcrit avec SurrealDB pour les métadonnées et `object_store` pour les octets |
| Intégrité | BLAKE3, déjà dans `lyxal_crypto` ; conception d'[iroh-blobs](https://docs.rs/crate/iroh-blobs/0.99.0/source/DESIGN.md) | Rust | **Modèle** : fichier repéré par son empreinte, vérification morceau par morceau (arbre BLAKE3) |
| Envoi reprenable (protocole tus 1.0) | [fileloft](https://sound-systems.github.io/fileloft/) ; [tus-protocol](https://docs.rs/tus-protocol) | Rust, MIT ; jeune (0.3) | **Modèle** : logique du protocole transcrite sur `object_store` (envoi en plusieurs parties) |
| Type réel du fichier | [infer](https://lib.rs/crates/infer) | Rust, MIT | **Dépendance** |
| Antivirus | [clamav-client](https://docs.rs/clamav-client), client du service ClamAV | Rust ; ClamAV sous GPL | **Dépendance** du client ; ClamAV reste un service séparé |
| Déduplication (plus tard) | [fastcdc](https://docs.rs/fastcdc) | Rust, MIT | Option ultérieure |

Alternative écartée : [Apache OpenDAL](https://release-catalog.apache.org/opendal/index.html)
(Rust, Apache-2.0, 0.59.2 en septembre 2026). Couverture plus large et mécanisme de couches, mais
dépendance nouvelle, alors que `object_store` est déjà compilé avec SurrealDB (§5).

## 4. Stockage objet auto-hébergé (si nécessaire)

| Projet | Langage, licence | Avis |
| :--- | :--- | :--- |
| [RustFS](https://sealos.io/blog/what-is-rustfs/) | Rust, Apache-2.0 ; 1.0 le 16 septembre 2026 ([source](https://linuxiac.com/rustfs-1-0-s3-compatible-object-storage-reaches-ga/)) | Candidat ; état du mode multi-serveurs non confirmé par une source officielle |
| [SeaweedFS](https://www.opensourcealternatives.to/item/seaweedfs) | Go, cœur Apache-2.0 | Plus éprouvé |
| [MinIO](https://github.com/minio/minio) | Go, AGPL | **Écarté** : dépôt archivé le 25 avril 2026, plus maintenu, failles non corrigées |
| [Garage](https://awesome.ecosyste.ms/projects/github.com%2Fdeuxfleurs-org%2Fgarage) | Rust, AGPL | Service séparé non modifié seulement ; code non réutilisable |

`object_store` parle à tous ces services (protocole S3) : le choix du serveur ne change pas le
code de `lyxal_storage`.

## 5. Accès aux supports : `object_store`

`object_store` est la bibliothèque qu'utilise SurrealDB 3.3 pour ses propres buckets
(`surrealdb-core` 3.3.5, `src/buc/store/cloud.rs` : S3, GCS, Azure). Raisons du choix :

* **aucune dépendance nouvelle** : la version 0.13.2 est déjà dans `Cargo.lock` ;
* **même socle que SurrealDB** : la bascule future vers ses buckets (§6) ne change pas de
  support ;
* **flux** : lecture en flux, écriture en plusieurs parties, sans charger un fichier en mémoire ;
* **supports** : disque local, mémoire (tests), S3 et compatibles, GCS, Azure, activés par options
  de compilation ; seuls le disque et S3 sont activés au départ.

Ce que `lyxal_storage` ajoute autour, sans copie ni fork :

* **intégrité** : empreinte BLAKE3 calculée pendant l'écriture, en un seul passage, par
  `lyxal_crypto` (`Blake3Hasher`) ;
* **erreurs** : chaque échec converti en code `STORAGE_*` du contrat `LyxalResult` ;
* **secrets** : identifiants des supports tenus en `SecretString`, lus dans l'environnement de
  l'hôte, puis par `lyxal_secrets` quand il existera ;
* **cohérence** : écriture en deux temps (fiche « en attente », octets, fiche « disponible ») et
  nettoyage des octets orphelins, puisqu'aucune transaction ne couvre la base et le support.

La vitesse d'un transfert vient du disque et du réseau, pas de la bibliothèque : une réécriture ne
gagnerait rien de mesurable.

## 6. Fichiers dans SurrealDB : étude du 11 novembre 2026

SurrealDB stocke des fichiers depuis la version 3.0 ([`DEFINE BUCKET`](https://surrealdb.com/docs/surrealql/statements/define/bucket),
[annonce](https://surrealdb.com/blog/file-support-in-surrealdb-3-0)). Sources étudiées :

* `lyxal_solution_backend/` : copie de SurrealDB 3.0.0-beta.2 (avril 2026) ; supports mémoire et
  disque seulement (`lyxal/core/src/bucket/`) ;
* `surrealdb-core` 3.3.5 (SDK du workspace) : `src/buc/`, supports mémoire, disque, S3, GCS, Azure ;
* serveur `surreal` 3.3.4, démarré avec `--allow-experimental files`, interrogé par `/sql`.

Constats vérifiés par essai sur le serveur 3.3.4 :

| Point | Constat |
| :--- | :--- |
| Écriture, lecture, métadonnées | `f"bucket:/chemin".put()`, `.get()`, `.head()`, `file::list` : fonctionnent en mémoire et sur disque |
| Fichier dans une fiche | un champ peut porter une valeur `file` ; son contenu se lit dans la même requête |
| Droits | `PERMISSIONS WHERE …` par bucket, avec `$action`, `$file`, `$target` ; liste interdite aux sessions invité et enregistrement |
| Disque | dossiers autorisés par `SURREAL_BUCKET_FOLDER_ALLOWLIST` ; un chemin qui sort de la racine est refusé |
| Lecture seule | `DEFINE BUCKET … READONLY` refuse toute écriture |
| S3 | présent dans le binaire 3.3.4 (tentative de connexion constatée) |
| Statut | **expérimental** : refusé sans `--allow-experimental files` ; le client `surreal sql` refuse même la syntaxe |
| Flux | **aucun** : `put` et `get` portent le fichier entier en mémoire, dans une requête |
| Taille | corps d'une requête `/sql` refusé dès 1 Mo par défaut (`413`) |
| Transaction | **aucune** : après `BEGIN … CANCEL`, la fiche n'est pas créée mais le fichier reste écrit |
| Téléchargement HTTP | route `/bucket` absente en 3.3.4 (`404`) ; documentée pour la 4.0 |
| Absent | empreinte, type réel, antivirus, envoi reprenable, quotas |

Conclusion : la fonction ne convient pas aujourd'hui à des plans ou des photos de plusieurs
dizaines de mégaoctets. `lyxal_storage` est conçu pour pouvoir y basculer plus tard :

* un fichier est repéré par un bucket et une clé, comme la valeur `file` de SurrealDB ;
* les octets passent par `object_store`, que SurrealDB utilise aussi ;
* à réévaluer quand la fonction ne sera plus expérimentale et que les flux existeront.

## 7. Questions

Les questions à trancher sont posées dans le plan du programme (`implementation_plan.md` à la
racine).
