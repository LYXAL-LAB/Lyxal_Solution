# Audit Complet : Module `buc` (Buckets) - SurrealDB core

Ce document présente l'audit technique du module de stockage d'objets (buckets) de SurrealDB.

## 1. Architecture Globale

Le module `buc` est structuré de manière hiérarchique et modulaire :
- **Manager (`manager.rs`)** : Orchestre les connexions et gère le cache. Il implémente la logique des "Global Buckets" qui permet de partager un backend physique entre plusieurs bases de données de manière isolée.
- **Controller (`controller.rs`)** : Interface de haut niveau liée au contexte d'exécution. Il est responsable de l'application des politiques de sécurité (IAM/Permissions) et de la validation des opérations.
- **Abstraction (`store/mod.rs`)** : Définit le trait `ObjectStore`, permettant une indépendance totale vis-à-vis du backend physique.
- **Backends (`store/file.rs`, `store/memory.rs`)** : Implémentations concrètes pour le système de fichiers local et la mémoire vive.

---

## 2. Points Forts (Strengths)

*   **Abstraction Propre** : L'utilisation du trait `ObjectStore` permet d'ajouter facilement de nouveaux backends (S3, Azure, GCS) sans modifier la logique métier.
*   **Sécurité Native** : 
    *   Intégration profonde avec le moteur de permissions de SurrealDB (variables `$file`, `$action`, `$target` injectées dans le contexte).
    *   Système de "Allowlist" (`BUCKET_FOLDER_ALLOWLIST`) pour limiter l'accès au disque.
    *   Protection contre les traversées de répertoire (`path_clean` et canonicalisation).
*   **Support Multi-Tenancy** : Le `PrefixedStore` permet une isolation transparente entre namespaces/bases de données sur un même backend global.
*   **Gestion Platform-Aware** : Code spécifique pour Windows (gestion des lettres de lecteurs, préfixes UNC) et support WASM.

---

## 3. Avantages (Pros)

*   **Performance Async** : Utilisation intensive de `tokio` et `DashMap` pour une concurrence maximale sans blocage.
*   **Extensibilité** : Le design des "Composers" (`CommunityComposer`, `LyxalComposer`) permet d'étendre les capacités du module selon les éditions (ex: Enterprise).
*   **Facilité de Test** : Le `MemoryStore` permet des tests unitaires rapides et isolés sans dépendance externe.

---

## 4. Inconvénients & Points Faibles (Weaknesses)

*   **Gestion des Gros Répertoires** : L'implémentation de `list` dans `FileStore` charge toutes les entrées en mémoire pour les trier et les paginer. C'est un risque majeur de performance et de consommation mémoire (O(N)) sur des buckets contenant des millions de fichiers.
*   **Absence de Streaming** : L'API actuelle manipule des `Bytes` (tout en mémoire). Elle ne supporte pas le streaming pour les gros fichiers (uploads/downloads par morceaux), ce qui limite l'usage pour des fichiers de plusieurs Go.
*   **Hardcoding de Permission** : La restriction interdisant aux utilisateurs `Guest` et `Record` de lister les fichiers est codée en dur dans le contrôleur au lieu d'être une règle par défaut dans le système de permission.
*   **Simplicité du MemoryStore** : Aucune limite de taille n'est imposée, ce qui pourrait mener à une saturation de la RAM (OOM) si un utilisateur malveillant sature un bucket mémoire.

---

## 5. Axes d'Amélioration (Improvement Areas)

### Priorité Haute (Critique pour la production)
*   **Pagination Efficace** : Remplacer le chargement complet dans `list` par un itérateur ou une pagination native au niveau du système de fichiers (ou backend cloud).
*   **Support Multipart/Streaming** : Étendre le trait `ObjectStore` para supporter les `AsyncRead` / `AsyncWrite` afin de gérer de gros volumes de données sans saturer la RAM.

### Priorité Moyenne (Fonctionnalités)
*   **Backends Cloud Natifs** : Intégrer S3 et GCS directement via des crates comme `object_store` (Apache).
*   **Metadata Étendues** : Permettre le stockage de métadonnées personnalisées (Headers HTTP, Tags) avec les objets.
*   **Compression/Chiffrement** : Ajouter une couche de middleware optionnelle para chiffrer les données au repos (At-Rest Encryption) directement via le store.

### Priorité Basse (Optimisation)
*   **Lifecycle Rules** : Implémenter des règles de nettoyage automatique (TTL - Time to Live) pour supprimer les fichiers temporaires.
*   **Signatures d'URL** : Permettre la génération d'URLs pré-signées pour déléguer l'accès temporaire à des clients externes sans passer par le core de SurrealDB.

---

## 6. Conclusion de l'Audit

Le module `buc` est **solide et bien conçu** pour les cas d'usage standards. Son intégration avec le système de permissions est son plus grand atout. Cependant, son architecture actuelle est optimisée pour des fichiers de taille modeste et des répertoires peu profonds. Pour une utilisation "Enterprise" à grande échelle, le passage au streaming et l'optimisation du listing sont indispensables.
