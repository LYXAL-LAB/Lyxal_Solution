# lyxal_core_kvs

## Rôle
Crate interne agissant comme **Key-Value Store (KVS)** et **Gestionnaire de Transactions** pour le moteur SQL de Lyxal Solution.
Il sert de couche d'abstraction (Storage Engine Adapter) entre le parseur/évaluateur SQL et le stockage physique des données, permettant au moteur de dialoguer de manière agnostique avec différents backends (mémoire, disque, réseau).

## Ce qu'il contient
- **DataStore (`ds.rs`)** — Le système central qui abstrait et instancie la base de données sous-jacente.
- **Transactions (`tx.rs`, `tr.rs`)** — Logique de Commit, Rollback, et isolation MVCC.
- **Clés Binaires (`key.rs`)** — Définition de l'encodage et du décodage très optimisé des clés d'enregistrement pour garantir des requêtes rapides.
- **Moteurs de Stockage (`rocksdb/`, `mem/`, `lyxalkv/`, `tikv/`)** — Les implémentations spécifiques (drivers) activables via feature flags.

## Destiné à
Consommé par les crates de calcul et d'interface de Lyxal :
- `lyxal_db` — Le moteur SQL utilise `lyxal_core_kvs` pour lire et écrire les résultats de ses calculs.
- `lyxal_server` / `cli` — Pour initialiser la connexion au stockage via les variables d'environnement.
- `lyxal_function` (futur) — Sōzu pourra hypothétiquement utiliser ce crate pour lire ultra-rapidement des données directes en KV sans charger l'évaluateur SQL.

## Architecture & Découplage (Compute vs Storage)
Initialement partie intégrante du moteur SQL (`lyxal-core/src/kvs`), ce module a été extrait dans son propre crate pour concrétiser la séparation **Compute (Calcul) / Storage (Stockage)** de l'architecture Lyxal.
Ce découplage permet des temps de compilation drastiquement réduits et offre la possibilité de lancer des nœuds "Storage-only".

## Dépendances clés
- `lyxal-types` — Fournit les définitions des primitives de données.
- `lyxal-protocol` — (Optionnel) Pour la sérialisation KV.
- `rocksdb`, `tikv-client` — (Optionnels, via features) Les wrappers vers les moteurs externes.
