# Plan d'implémentation — `lyxal_storage`, lot 2 : supports, flux et workers (Rust)

Deuxième lot du programme `lyxal_storage` (`implementation_plan.md` à la racine, décisions S1 à
S6). Il crée le crate Rust : les octets sont écrits et lus en flux sur un support (disque local,
mémoire pour les tests), avec leur empreinte, et des workers retirent les octets devenus
inutiles. Les routes HTTP d'envoi et de téléchargement sont au lot 3, S3 au lot 4. Aucune ligne
de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **G1** | Que fait le serveur si aucun dossier de stockage n'est configuré ? | **Il démarre, le stockage est signalé « dégradé »** et toute écriture est refusée avec une erreur claire, comme pour l'e-mail sans relais. Refuser de démarrer bloquerait une installation qui n'utilise pas encore les fichiers |
| **G2** | Quand vérifie-t-on qu'un fichier n'a pas été altéré sur le disque ? | **À la demande** dans ce lot (une fonction relit le fichier et compare son empreinte). Une vérification périodique de tous les fichiers est inscrite à la feuille de route |
| **G3** | Quand une organisation est supprimée, quand retire-t-on le contenu de ses fichiers ? | **Au prochain passage du worker** : la suppression d'une organisation est déjà un acte délibéré et différé de `lyxal_auth` ; garder ses fichiers plus longtemps n'a pas de raison |
| **G4** | Peut-on changer le support d'un bucket après sa création ? | **Non dans cette V1** : le support est choisi à la création. Déplacer des fichiers d'un support à un autre est inscrit à la feuille de route |

## 2. Emplacement des octets

Un fichier est écrit sous `<portée>/<bucket>/<identifiant de la fiche>` :

* `<portée>` : `installation` ou la clé de l'organisation ; les octets d'une organisation sont
  donc sous un seul préfixe ;
* l'identifiant de la fiche, pas la clé : un fichier supprimé et son remplaçant à la même adresse
  coexistent jusqu'à la purge ; le nom d'origine et la clé restent dans la fiche.

## 3. SurrealQL (compléments au socle)

| Élément | Changement |
| :--- | :--- |
| `storage_bucket.backend` | nouveau champ : nom du support (`default` par défaut), fixé à la création (G4) ; paramètre `backend` de `fn::storage_bucket_create` |
| `fn::storage_object_begin` | le résultat porte aussi `max_size` (limite effective) et `backend` : le Rust arrête une écriture qui dépasse, sans attendre la fin |
| `storage_reclaim` (nouvelle table) | préfixe d'octets à retirer : `backend`, `prefix`, `created_at`. Créée par un `DEFINE EVENT` à la suppression d'un bucket, y compris en cascade avec son organisation (G3) |
| `fn::storage_reclaim_list` | `limit` → `{ items: [{ id, backend, prefix }] }` ; droit : worker |
| `fn::storage_reclaim_done` | **reclaim** → `{ done }` : ligne supprimée après le retrait des octets ; droit : worker |

Fonctions Core réutilisées : `fn::validation_object_execute` (règles `record`, `integer`,
`snake_case_name` pour `backend`). Aucune fonction Core manquante.

Erreurs ajoutées (thème `supports`) : `STORAGE_BACKEND_UNKNOWN` (support non configuré),
`STORAGE_BACKEND_UNAVAILABLE` (support injoignable, à réessayer), `STORAGE_OBJECT_NOT_AVAILABLE`
(fichier qui n'est pas à l'état `available`), `STORAGE_CONTENT_MISMATCH` (taille reçue
différente de la taille annoncée, ou dépassement), `STORAGE_INTEGRITY_FAILED` (empreinte relue
différente de celle de la fiche).

## 4. Rust (crate `lyxal_storage`)

| Fichier | Contenu |
| :--- | :--- |
| `store.rs` | `StorageStore` (`LyxalSurrealCall`) : un wrapper `store.call_fn(...)` par fonction publique |
| `models/` | `types.rs` (`StorageRecordId`, `StorageDatetime`), `settings.rs`, `bucket.rs`, `object.rs`, `worker.rs` : un `XxxParams` et un `XxxResult` par fonction (`SettingsGetParams` / `SettingsView`, `BucketCreateParams` / `Bucket`, `ObjectBeginParams` / `BegunObject`, `ObjectCommitParams` / `StoredObject`, `PurgeListParams` / `PurgeList`, …), structures nommées, `SurrealValue` |
| `backend.rs` | `Backends` : supports nommés, construits par l'hôte. `BackendConfig::Disk { root }` (`object_store::local::LocalFileSystem`, racine imposée) et `BackendConfig::Memory` (tests). Aucun identifiant dans ce lot |
| `service.rs` | `StorageService` : `put` (ouverture, écriture en flux par parties, empreinte et taille calculées au passage, fin d'écriture), `open` (fiche et flux de lecture, plage d'octets possible), `delete`, `verify` (G2) |
| `worker.rs` | `StorageCleanupWorker` (`LyxalWorker`, annulation coopérative) : écritures abandonnées, fichiers supprimés hors délai, préfixes à retirer |
| `module.rs` | `StorageModule` (`LyxalModule`), `StorageHealthCheck` : chaque support écrit, relit et supprime un petit fichier témoin ; « dégradé » sans support (G1) |
| `error.rs` | `StorageError` : échec SurrealQL (`LyxalSurrealError`), échec du support, codes `STORAGE_*` du §3 ; `is_retryable()` |

Règles :

* **flux** : `put` reçoit un flux d'octets ; rien n'est accumulé au-delà d'une partie (8 Mo) ;
* **empreinte** : `lyxal_crypto::hash::Blake3Hasher`, en un seul passage ; aucune crate
  cryptographique importée ;
* **échec en cours d'écriture** (support, taille dépassée, flux interrompu) : l'écriture est
  abandonnée sur le support, les octets déjà écrits sont retirés, la fiche passe à `deleted` ;
  l'erreur est rendue, jamais masquée ;
* **lecture** : seul un fichier `available` est servi ;
* **type du fichier** : dans ce lot, le type annoncé (sinon `application/octet-stream`) ; le
  type réel est contrôlé au lot 5 ;
* **ordre des retraits** : les octets d'abord, la fiche ensuite ; un retrait d'octets déjà
  absents n'est pas une erreur (rejeu après arrêt) ;
* aucun `panic!`, `unwrap()` ni `tokio::spawn` hors tests.

Dépendances : `object_store` 0.13 (fonctionnalité `fs`), `bytes`, `futures`, `tokio`,
`async-trait`, `thiserror` ; `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto`.

## 5. Hôte

* Configuration : `LYXAL__STORAGE__DISK__ROOT` (dossier du support `default`). Absente : module
  hébergé, sonde « dégradée », écritures refusées par `STORAGE_BACKEND_UNKNOWN` (G1).
* `src/modules/storage.rs` : `StorageModule`, `StorageCleanupWorker`, `StorageHealthCheck`.
* Aucune route HTTP dans ce lot.

## 6. Documents

`README.md` et `ROADMAP.md` du module ; `apps/lyxal-server/README.md` (configuration) ; ligne 2
du plan racine passée à « Réalisé ». Ce plan est supprimé dans la demande de fusion de
l'implémentation.

## 7. Tests

* **Banc SurrealQL** : `backend` d'un bucket ; `max_size` rendu par `begin` ; ligne
  `storage_reclaim` créée à la suppression d'un bucket et à la purge d'une organisation ;
  fonctions de reprise réservées au worker.
* **Rust, sur les supports mémoire et disque** (dossier temporaire) :
  * fichier écrit puis relu à l'identique ; empreinte de la fiche égale à celle du contenu ;
  * fichier de 64 Mo écrit et relu sans dépasser une mémoire bornée ;
  * lecture d'une plage d'octets ;
  * taille dépassée, flux interrompu, support en échec : aucun octet ni fiche disponible ne
    reste ;
  * fichier non disponible non servi ; fichier altéré sur le disque détecté par `verify` ;
  * worker : écriture abandonnée, fichier supprimé hors délai et préfixe d'une organisation
    purgée retirés ; rejeu sans erreur ; arrêt sur annulation ;
  * chaque wrapper de `StorageStore` appelé.
* **Hôte** : démarrage avec et sans dossier configuré (sonde saine, sonde dégradée).
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 8. Checklist (§13)

* Architecture : le Rust porte le protocole du support et les flux ; les règles restent en
  SurrealQL ; aucune validation recopiée en Rust.
* Core : aucune extension demandée.
* Crypto : `lyxal_crypto` seul ; aucune primitive ajoutée.
* Runtime : `LyxalModule`, `LyxalWorker` avec `CancellationToken`, `ModuleHealthCheck`.
* Zéro dette : champ et fonctions ajoutés dans le schéma cible, sans migration.
