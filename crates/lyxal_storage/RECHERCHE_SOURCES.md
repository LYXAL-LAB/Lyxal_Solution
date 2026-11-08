# `lyxal_storage` — recherche de sources open source

Document de travail préalable au plan d'implémentation de `lyxal_storage` (crate du Noyau
Technique, rang 3 de [`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)).
Le crate n'existe pas encore : ce dossier ne contient que ce document. Aucun code ne sera écrit
avant un `implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3). Ce document est
retiré, ou réduit aux sources retenues, quand le crate est créé.

Recherche du 8 novembre 2026. Les versions et états de maintenance cités viennent de sources
secondaires quand c'est indiqué ; ils sont revérifiés sur les dépôts officiels au moment du plan.

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
| Accès aux supports (disque, S3, GCS, Azure…) | [Apache OpenDAL](https://release-catalog.apache.org/opendal/index.html) | Rust, Apache-2.0 ; versions régulières (0.58.2, août 2026) | **Dépendance**, cœur technique (voir §5) |
| Architecture du service | [Supabase Storage](https://github.com/supabase/storage/wiki) | TypeScript, Apache-2.0 | **Modèle** : buckets, métadonnées et droits en base, octets à part ; transcrit avec SurrealDB pour les métadonnées et OpenDAL pour les octets |
| Intégrité | BLAKE3, déjà dans `lyxal_crypto` ; conception d'[iroh-blobs](https://docs.rs/crate/iroh-blobs/0.99.0/source/DESIGN.md) | Rust | **Modèle** : fichier repéré par son empreinte, vérification morceau par morceau (arbre BLAKE3) |
| Envoi reprenable (protocole tus 1.0) | [fileloft](https://sound-systems.github.io/fileloft/) ; [tus-protocol](https://docs.rs/tus-protocol) | Rust, MIT ; jeune (0.3) | **Modèle** : logique du protocole transcrite sur OpenDAL |
| Type réel du fichier | [infer](https://lib.rs/crates/infer) | Rust, MIT | **Dépendance** |
| Antivirus | [clamav-client](https://docs.rs/clamav-client), client du service ClamAV | Rust ; ClamAV sous GPL | **Dépendance** du client ; ClamAV reste un service séparé |
| Déduplication (plus tard) | [fastcdc](https://docs.rs/fastcdc) | Rust, MIT | Option ultérieure |

Alternative à OpenDAL : [`object_store`](https://docs.rs/object_store) (Apache Arrow, Rust,
Apache-2.0), plus restreint (S3, GCS, Azure, disque). OpenDAL est préféré pour sa couverture et
son mécanisme de couches.

## 4. Stockage objet auto-hébergé (si nécessaire)

| Projet | Langage, licence | Avis |
| :--- | :--- | :--- |
| [RustFS](https://sealos.io/blog/what-is-rustfs/) | Rust, Apache-2.0 ; 1.0 en septembre 2026 ([source](https://aicybr.com/blog/rustfs-1-0-ga-s3-object-storage)) | Candidat ; mode multi-serveurs à vérifier |
| [SeaweedFS](https://www.opensourcealternatives.to/item/seaweedfs) | Go, cœur Apache-2.0 | Plus éprouvé |
| [MinIO](https://github.com/minio/minio) | Go, AGPL | **Écarté** : dépôt archivé en avril 2026, plus maintenu |
| [Garage](https://awesome.ecosyste.ms/projects/github.com%2Fdeuxfleurs-org%2Fgarage) | Rust, AGPL | Service séparé non modifié seulement ; code non réutilisable |

OpenDAL parle à tous ces services (protocole S3) : le choix du serveur ne change pas le code de
`lyxal_storage`.

## 5. OpenDAL : dépendance ou version « lyxalisée » ?

Question du CTO : OpenDAL serait-il plus performant s'il était réécrit ou forké à la manière de
Lyxal ?

**Réponse : non pour la vitesse brute ; oui pour l'intégration, sans fork.**

* **La vitesse vient des supports, pas d'OpenDAL.** Le temps d'un transfert est pris par le disque
  et le réseau. OpenDAL est déjà asynchrone, en flux, et transfère les gros fichiers en plusieurs
  morceaux simultanés ; ses abstractions ne coûtent presque rien. Un fork ne gagnerait rien de
  mesurable et nous ferait maintenir des dizaines de connecteurs.
* **Ce qu'on peut gagner, on le gagne sans fork, avec ses « couches ».** OpenDAL permet d'ajouter
  des couches autour de chaque opération (il en fournit déjà : nouvelles tentatives, délais,
  limite de concurrence, journalisation, métriques). La version lyxalisée est donc une pile de
  couches Lyxal posées sur OpenDAL :
  * **intégrité** : empreinte BLAKE3 calculée pendant l'écriture, en un seul passage, par
    `lyxal_crypto` (pas de relecture du fichier) ;
  * **erreurs** : chaque échec converti en code `STORAGE_*` du contrat `LyxalResult` ;
  * **secrets** : identifiants des supports (clés S3…) lus par `lyxal_secrets` et tenus en
    `SecretString`, jamais en clair dans la configuration ;
  * **traçabilité** : métriques et journaux au format Lyxal.
* **On ne garde que les supports utiles.** OpenDAL active ses connecteurs par options de
  compilation : on n'active que le disque et S3 au départ. Le binaire reste petit et la surface
  de sécurité réduite.
* **Les vrais gains de performance sont dans notre conception**, pas dans OpenDAL :
  * empreinte calculée pendant le transfert (un seul passage) ;
  * déduplication par empreinte (un fichier identique n'est stocké qu'une fois) ;
  * envoi reprenable pour les gros fichiers ;
  * métadonnées interrogées dans SurrealDB sans toucher au support.

Conclusion : OpenDAL en dépendance à version fixée, entouré de couches Lyxal. Une copie ou un fork
ne se justifierait que si un correctif nécessaire était refusé par le projet ; ce cas serait
soumis au CTO.

## 6. Piste à surveiller : fichiers dans SurrealDB

SurrealDB stocke des fichiers depuis la version 3.0 ([`DEFINE BUCKET`](https://surrealdb.com/docs/surrealql/statements/define/bucket),
[annonce](https://surrealdb.com/blog/file-support-in-surrealdb-3-0)) :

* fonction encore **expérimentale**, à activer explicitement au démarrage du serveur ;
* supports S3, GCS et Azure documentés pour SurrealDB **4.0** seulement ;
* accès HTTP aux fichiers prévu en 4.0.

Très cohérent avec l'architecture « données dans SurrealDB », mais trop tôt sur SurrealDB 3.3.4.
À réévaluer lors du passage à SurrealDB 4. La documentation n'a pas pu être lue directement
pendant cette recherche (site non autorisé par le réseau de la session) : les points ci-dessus
viennent des résumés de recherche.

## 7. Questions pour le plan

1. **Ordre** : après `lyxal_auth` (recommandé, droits d'accès réels), ou avant avec des droits
   provisoires.
2. **Premier support** : disque local seul au départ, S3 ensuite ; ou les deux dès le départ.
3. **Identité d'un fichier** : par son empreinte BLAKE3 (déduplication naturelle) ou par un
   identifiant UUID v7 avec l'empreinte en métadonnée.
4. **Envoi reprenable (tus)** : dans la première version ou plus tard.
5. **Antivirus** : obligatoire (service ClamAV à déployer) ou optionnel par configuration.
