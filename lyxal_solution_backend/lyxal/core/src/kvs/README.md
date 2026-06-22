# lyxal_core_kvs

Ce crate est le **Key-Value Store (KVS)** et le gestionnaire de transactions de l'architecture **Lyxal Solution**.

## Rôle
`lyxal_core_kvs` sert de couche d'abstraction ("storage engine adapter") permettant au moteur d'évaluation SQL de dialoguer de la même façon avec le stockage en mémoire, sur disque (RocksDB), ou via le réseau (TiKV, etc.).

## Architecture
- **`src/ds.rs`** : Le système de DataStore (qui instancie et abstrait la base).
- **`src/tx.rs`** : Le système de Transactions (Commit, Rollback).
- **`src/key.rs`** : Définition de l'encodage et décodage binaire des clés.
- **`src/mem/`, `src/rocksdb/`, etc.** : Les implémentations spécifiques (drivers).

## Séparation Compute / Storage
En séparant ce module du reste du moteur de base de données (`lyxal_db`), Lyxal peut instancier des processus ou des fonctions custom (Sōzu plugins via `lyxal_function`) qui accèdent rapidement et directement au disque (transactions très bas niveau) **sans avoir à embarquer l'énorme parseur et évaluateur SQL**. Ce crate représente le "Storage".
