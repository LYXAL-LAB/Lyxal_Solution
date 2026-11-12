# `lyxal_storage` — modèle et sources

Sources open source dont `lyxal_storage` reprend une bibliothèque ou un modèle, sources écartées,
et décisions du CTO qui fixent la conception du module. L'état du module est décrit par son
[`README.md`](README.md), ses évolutions par sa [`ROADMAP.md`](ROADMAP.md).

Recherche du 8 novembre 2026, revue le 11 novembre 2026 ; la version utilisée de chaque crate est
fixée par `Cargo.lock`.

## 1. Principe d'assemblage

* **Dépendance** : bibliothèque Rust prise telle quelle, version fixée par `Cargo.lock`, licence
  permissive (Apache-2.0, MIT, BSD) ;
* **Modèle** : architecture d'un projet étudiée et transcrite (SurrealQL pour les données et les
  règles, Rust pour les octets) ; un projet GPL ou AGPL ne sert que comme service séparé, non
  modifié, jamais copié.

## 2. Sources retenues

| Brique | Source | Licence | Usage |
| :--- | :--- | :--- | :--- |
| Accès aux supports (disque, mémoire, S3) | [`object_store`](https://docs.rs/object_store) 0.13 (Apache Arrow) | Apache-2.0 | **Dépendance** ; déjà compilée avec le SDK `surrealdb`, qui l'utilise pour ses propres buckets |
| Architecture du service | [Supabase Storage](https://github.com/supabase/storage/wiki) | Apache-2.0 | **Modèle** : buckets, fiches et droits en base, octets à part |
| Empreinte | BLAKE3, par `lyxal_crypto` (`Blake3Hasher`) | — | calculée pendant l'écriture, en un passage |
| Type réel d'un fichier | [`infer`](https://lib.rs/crates/infer) 0.22 | MIT | **Dépendance** |
| Antivirus | [`clamav-client`](https://docs.rs/clamav-client) 2.3 | MIT | **Dépendance** du client ; ClamAV (GPL) reste un service séparé |
| Envoi reprenable | [protocole tus 1.0](https://tus.io/protocols/resumable-upload) ; [`tusd`](https://github.com/tus/tusd) (MIT) et [fileloft](https://sound-systems.github.io/fileloft/) (MIT) | norme ouverte | **Modèle** : protocole écrit d'après sa spécification ; aucune bibliothèque serveur reprise (jeunes, et liées à leur propre stockage) |
| Serveur S3 des tests | `s3s`, `s3s-fs` 0.17 | Apache-2.0 | dépendances de test seulement |

Écartés : Apache OpenDAL (couverture plus large, mais dépendance nouvelle alors
qu'`object_store` est déjà compilé) ; MinIO (dépôt archivé le 25 avril 2026) ; Garage (AGPL :
service séparé seulement). `object_store` parle à tout service S3 : le choix du serveur ne change
pas le code.

## 3. Fichiers dans SurrealDB (étude du 11 novembre 2026)

SurrealDB stocke des fichiers depuis la version 3.0 (`DEFINE BUCKET`). Essayée sur le serveur
3.3.4, la fonction ne convient pas aujourd'hui : expérimentale (`--allow-experimental files`),
sans flux (le fichier entier passe en mémoire dans une requête, 1 Mo par défaut), sans transaction
avec la fiche, sans empreinte, type réel, antivirus, envoi reprenable ni quota.

`lyxal_storage` est conçu pour pouvoir y basculer : un fichier est repéré par un bucket et une
clé, comme la valeur `file` de SurrealDB, et ses octets passent par `object_store`, que SurrealDB
utilise aussi. À réévaluer quand la fonction ne sera plus expérimentale et que les flux
existeront.

## 4. Bunny Storage par son API S3 (documentation du 12 novembre 2026)

Service S3 de référence. Essai réel réussi le 12 novembre 2026 (`tests/it/real_s3.rs`).

* L'API S3 s'active à la création de la zone de stockage, pas après ; elle est en aperçu et
  n'existe que dans certaines régions (Francfort, New York, Singapour). Une région sans S3
  répond `501`.
* Une zone = un bucket S3. Clé d'accès : nom de la zone ; clé secrète : mot de passe de la
  zone. Point d'accès `https://<région>-s3.storage.bunnycdn.com`, adresses `/<zone>/<clé>`
  seulement (`path_style`).
* Pris en charge : écriture, lecture par plage, suppression, `HEAD`, liste, copie, envoi en
  plusieurs parties (10 000 parties au plus, session abandonnée effacée après 10 jours), liens
  signés (7 jours au plus). Non pris en charge : chiffrement côté serveur, versions.
* Limites : 500 requêtes par seconde par zone, 100 connexions par adresse ; au-delà,
  `503 SlowDown` à réessayer.
* Sources : <https://docs.bunny.net/storage/s3>, <https://bunny.net/docs/storage/limits>.

## 5. Décisions du CTO (novembre 2026)

| # | Question | Décision |
| :- | :--- | :--- |
| S1 | Où stocker le contenu des fichiers | par le code Rust (`object_store`), pas par les buckets de SurrealDB ; adresses compatibles pour basculer plus tard |
| S2 | Supports | disque local et S3 ; service S3 de référence : Bunny Storage |
| S3 | Identité d'un fichier | identifiant propre ; l'empreinte est une information de la fiche ; déduplication à la feuille de route |
| S4 | Antivirus | optionnel par configuration (ClamAV à part) ; le type réel est toujours contrôlé |
| S5 | Envoi reprenable | dans la V1 (protocole tus 1.0 : création, abandon, expiration) |
| S6 | Ingestion | fichiers sources des lots conservés par `lyxal_storage` |
| G5 | Octets d'un bucket supprimé | préfixe inscrit dans `storage_reclaim` par un événement, dans la transaction, retiré par le worker |
| J1 | Téléchargement | toujours par l'hôte ; liens signés servis par le support S3 à la feuille de route |
| K1 à K5 | Contrôle du contenu | type réel enregistré à la place du type annoncé ; exécutables refusés par défaut ; fichier infecté refusé sans rien conserver ; antivirus injoignable : envoi refusé ; affichage direct réservé aux images matricielles et aux PDF |
| L2 à L4 | Envoi reprenable | parties sur le support du fichier, position tenue par la base ; contrôles une fois, à l'assemblage ; envoi inachevé gardé 24 h par défaut |
| N1 | Montée en charge | volume recompté à chaque écriture quand un quota est réglé : compteurs à la feuille de route |
