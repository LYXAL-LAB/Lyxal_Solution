# Plan d'implémentation — lot 7 du programme `lyxal_storage` : bascule de l'ingestion

Septième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décision S6).
Il traite le constat A06 de l'audit externe du 7 novembre 2026 : aujourd'hui le fichier d'un
catalogue fabricant et la file des lots à traiter ne vivent que dans la mémoire du serveur. Un
redémarrage les perd, et un gros fichier est chargé en entier. Après ce lot, le fichier est
conservé par `lyxal_storage`, la liste des lots à traiter est dans la base, et le fichier est lu
au fil de l'eau. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **M1** | Où le fichier d'origine d'un lot est-il conservé ? | **Dans `lyxal_storage`**, dans un bucket de l'installation réservé à l'ingestion. Le lot pointe vers la fiche du fichier ; tant que le lot existe, le fichier ne peut pas être supprimé |
| **M2** | Où est la liste des lots à traiter ? | **Dans la base, plus dans la mémoire.** Le worker y prend les lots reçus ou interrompus. Après un redémarrage, il reprend seul, au dernier point de reprise. La file en mémoire est supprimée |
| **M3** | Comment le fichier est-il lu ? | **Au fil de l'eau, bloc par bloc**, sans jamais le charger en entier : la mémoire utilisée ne dépend plus de la taille du fichier. C'est la partie la plus lourde du lot (les quatre lecteurs de formats sont repris). L'alternative, plus rapide à faire, garderait le fichier entier en mémoire avec une taille maximale ; elle ne répond qu'à moitié au constat A06 |
| **M4** | Que devient la preuve commerciale jointe à un lot ? | **Elle est enregistrée sur le lot à sa création.** Aujourd'hui elle n'est transmise qu'en mémoire et serait perdue au redémarrage |
| **M5** | Qui crée le bucket de l'ingestion ? | **Le serveur, automatiquement, au démarrage** (bucket `ingestion-sources`, portée installation, 100 Mo par fichier, réglable ensuite comme tout bucket). Rien à faire à la main |

## 2. Fonctionnement après le lot

1. Le fichier du catalogue est envoyé dans le bucket `ingestion-sources` par les routes de
   fichiers (envoi simple ou reprenable).
2. Le lot est créé par `fn::ingestion_batch_create` avec la fiche du fichier. Le nom, la taille
   et l'empreinte du fichier sont lus sur cette fiche : ils ne sont plus recopiés par l'appelant.
3. Le worker demande à la base les lots à traiter, en réserve un (réservation existante), ouvre
   le fichier dans `lyxal_storage` et le lit bloc par bloc. Chaque bloc traité enregistre le
   point de reprise, comme aujourd'hui.
4. Arrêt ou panne : le lot reste dans la base avec son point de reprise ; il est repris au
   démarrage suivant, sans intervention.
5. À la fin de la lecture, l'empreinte des octets lus est comparée à celle de la fiche ; un
   fichier altéré fait échouer le lot.

## 3. Changements de contrat (rupture coordonnée, `.agents/AGENTS.md` §0.3)

| Élément | Avant | Après |
| :--- | :--- | :--- |
| `fn::ingestion_batch_create` | `nom_fichier`, `file_hash_blake3`, `taille_octets` fournis par l'appelant | `source_object` (fiche `storage_object`) obligatoire ; ces trois valeurs sont lues sur la fiche ; `commercial_proof` facultatif |
| `IngestionWorker::enqueue_batch` | file en mémoire avec les octets | supprimée |
| `IngestionWorker::process_batch` | reçoit les octets, le format et la preuve | reçoit l'identifiant du lot ; lit le reste dans la base et le stockage |
| `SourceAdapter::read` | rend tous les éléments du fichier | rend un lecteur qui produit les éléments un par un |

Tous les appelants du dépôt (tests du module, hôte) sont mis à jour dans le même changement.

## 4. SurrealQL (`lyxal_pipeline_ingestion`)

| Élément | Changement |
| :--- | :--- |
| `ingestion_batch.source_object` | `record<storage_object>`, déclaré `REFERENCE` : le fichier d'un lot ne se supprime pas (`STORAGE_OBJECT_IN_USE`) |
| `ingestion_batch.commercial_proof` | objet facultatif : type, référence, autorité, vérificateur, date (M4) |
| `fn::ingestion_batch_create` | lit la fiche par `fn::storage_object_get` (fonction publique de `lyxal_storage`, sous les droits de l'appelant) ; refuse un fichier absent ou non disponible |
| `fn::ingestion_batch_pending_list` | nouvelle : lots `RECEIVED`, `PARSING` ou `VALIDATING` sans réservation en cours, du plus ancien au plus récent ; droit du worker |
| `manifest.toml` | dépendance `lyxal_storage` |

Fonctions Core réutilisées : `fn::validation_object_execute` (règles `record`, `is_object`,
`integer`, `enum`, `required_string`). Aucune fonction Core manquante. Aucune table de
`lyxal_storage` n'est lue directement.

Erreurs ajoutées (thème des lots) : `INGESTION_SOURCE_NOT_AVAILABLE` (fichier absent ou non
disponible à la création du lot), `INGESTION_SOURCE_ALTERED` (empreinte relue différente).

## 5. Rust

| Fichier | Contenu |
| :--- | :--- |
| `adapters/` | les quatre adaptateurs (CSV, JSON, XML, FAB-DIS) rendent un itérateur sur un lecteur d'octets ; `lyxal_parsing` lit déjà en flux |
| `worker/ingestion_worker.rs` | plus de file en mémoire ; boucle : lots à traiter lus dans la base, réservation, lecture du fichier par `StorageService::open`, traitement par blocs. La lecture (synchrone) tourne dans une tâche bloquante attendue par le worker, reliée par un canal borné à deux blocs ; elle s'arrête avec le worker. Reprise : les éléments déjà traités sont relus et passés |
| `storage/store.rs`, `models.rs` | `NewBatch` avec `source_object` et `commercial_proof` ; appel de `fn::ingestion_batch_pending_list` |
| `Cargo.toml` | dépendance `lyxal_storage` (noyau technique, niveau inférieur : pas de cycle) |
| `apps/lyxal-server/src/modules/ingestion.rs` | crée le bucket `ingestion-sources` s'il manque (M5) ; passe les supports de stockage au worker. Sans support configuré, le worker ne traite aucun lot et la sonde du module le signale |

## 6. Tests

* Banc SurrealQL : création d'un lot sur une fiche (valeurs lues sur la fiche, fichier absent ou
  non disponible refusé), suppression du fichier refusée tant que le lot existe, liste des lots à
  traiter (réservation en cours exclue, droits).
* Module : les tests existants passent par le stockage ; lot repris après un arrêt simulé sans
  rien remettre en file ; fichier altéré détecté ; gros fichier lu sans dépasser une mémoire
  bornée ; les quatre formats.
* Hôte : au démarrage, le bucket existe ; un lot créé avant un redémarrage est traité après.

## 7. Documents

`crates/lyxal_pipeline_ingestion/README.md` et `ROADMAP.md` ; `apps/lyxal-server/README.md` ;
ligne 7 du plan racine passée à « Réalisé » ; `docs/14-roadmap/ROADMAP_NOYAU.md`. Ce plan est
supprimé dans la demande de fusion de l'implémentation.
