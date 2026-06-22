# lyxal_bucket

Ce crate gère les fonctionnalités de **Buckets** (stockage d'objets, type S3) pour le backend **Lyxal Solution**.

## Rôle
Initialement intégré au cœur du moteur SQL (`lyxal-core/src/buc`), ce module a été extrait dans son propre crate (`lyxal_bucket`) pour améliorer la modularité de l'architecture Lyxal. 

Il fournit les abstractions et l'implémentation pour le stockage, la récupération, et la gestion des fichiers lourds ou des objets binaires liés aux enregistrements de la base de données.

## Architecture
- **`src/mod.rs`**: Bibliothèque racine
- **`src/manager.rs`**: Gestionnaire de haut niveau
- **`src/controller.rs`**: Contrôleurs d'accès
- **`src/store/`**: Implémentations concrètes des backends de stockage (local, mémoire, etc.)

## Usage interne
Ce crate est importé et utilisé par :
- `lyxal_db` (le moteur SQL principal)
- `lyxal_server` (l'API de transport)
