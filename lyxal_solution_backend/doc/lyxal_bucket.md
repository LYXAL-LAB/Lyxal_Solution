# lyxal_bucket

## Rôle
Crate interne responsable de la gestion des **Buckets** (stockage d'objets ou fichiers binaires lourds type Amazon S3) attachés aux enregistrements de la base de données Lyxal Solution.

## Ce qu'il contient
- **Manager (`manager.rs`)** — Gestionnaire de haut niveau pour l'orchestration des buckets.
- **Controller (`controller.rs`)** — Contrôleurs d'accès et de permissions pour les opérations sur les objets.
- **Store (`store/`)** — Implémentations concrètes des backends de stockage (système de fichiers local, mémoire en RAM pour le développement, etc.).

## Destiné à
Consommé par le cœur de la base et l'API d'exposition :
- `lyxal_db` — Le parseur SQL l'utilise pour évaluer les requêtes liées aux objets volumineux.
- `lyxal_server` — Pour router et streamer les uploads/downloads HTTP directement vers/depuis l'adaptateur de stockage.

## Architecture & Modularité
Provenant historiquement du module `lyxal-core/src/buc`, ce composant a été propulsé au rang de crate indépendant (`lyxal_bucket`).
Ce choix d'architecture "Google Grade" permet à la fonctionnalité de stockage d'objets d'évoluer (ajout d'adaptateurs Azure Blob, AWS S3, etc.) sans impacter ni nécessiter la recompilation du moteur SQL principal (`lyxal_db`) ou du système transactionnel KV (`lyxal_core_kvs`).

## Dépendances clés
- Dépendra des crates de gestion de flux asynchrones (ex: `tokio`, `futures`).
- `lyxal-types` — (À venir) Pour la liaison entre les RecordIds et les métadonnées des objets.
