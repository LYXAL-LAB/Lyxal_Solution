# Audit du module Change Feed (`cf`) - SurrealDB 3.0.0-beta.2

Le module `cf` est responsable de la persistence et de la gestion de l'historique des modifications (Change Feeds) au sein de SurrealDB. Ce rapport détaille les points forts, les faiblesses et les axes d'amélioration identifiés lors de l'audit technique.

## 🛠️ Architecture Technique

Le module est décomposé en quatre piliers :
- **`mutations.rs`** : Définition des structures de données (`ChangeSet`, `TableMutation`).
- **`writer.rs`** : Capture des changements durant les transactions.
- **`reader.rs`** : Interface de récupération des données (pull-based).
- **`gc.rs`** : Gestion du cycle de vie et nettoyage (Garbage Collection).

---

## ✅ Points Forts

### 1. Précision et Déterminisme
- **Versionstamping** : L'utilisation des `Versionstamp` et `Timestamp` de la couche KV garantit un ordre total et monotone des modifications, indispensable pour la réplication et le clustering.
- **Support des Différences (JSON Patches)** : L'option `store_diff` (via `TableMutation::SetWithDiff`) permet de n'enregistrer que les deltas. C'est un avantage majeur pour la performance réseau et le stockage sur des documents volumineux.

### 2. Flexibilité de Configuration
- **Granularité** : Le flux peut être activé au niveau de la base de données ou affiné par table.
- **Politiques de rétention** : Chaque table/DB peut avoir sa propre durée d'expiration (`expiry`), gérée automatiquement.

### 3. Robustesse du Modèle de Données
- **Revisioning** : L'utilisation de la crate `revision` permet de faire évoluer les structures de données (`TableMutation`) tout en conservant la compatibilité ascendante lors de la lecture d'anciennes versions du flux.

---

## ⚠️ Faiblesses et Risques

### 1. Performance de la Garbage Collection (GC)
- **Scannage du Catalogue** : Le processus de GC (`gc_all_at`) itère de manière séquentielle sur tous les namespaces, bases de données et tables. Sur une instance avec des milliers de tables, cela peut engendrer une latence et une consommation CPU inutile.
- **Approche Séquentielle** : Le nettoyage se fait via `tx.delr(beg..end)`, ce qui est efficace, mais la *découverte* des plages à supprimer dépend d'un parcours complet du catalogue.

### 2. Pression Mémoire (Writer)
- **Buffering en Transaction** : Toutes les modifications d'une transaction sont stockées en mémoire dans une `DashMap`. Une transaction massive (ex: import de millions de records) pourrait saturer la mémoire vive de l'instance avant le commit.

### 3. Modèle "Pull" exclusif
- **Polling obligatoire** : Actuellement, le module `cf` est conçu pour être lu. Il n'y a pas de mécanisme de "Push" natif intégré ici pour notifier les consommateurs dès qu'un changement est écrit (bien que `LIVE SELECT` puisse consommer ces flux, le module `cf` lui-même reste passif).

---

## 🚀 Axes d'Amélioration

### 1. Optimisation du GC
- **Index d'Expiration** : Introduire un système de "watermark" global ou par base de données pour éviter de scanner toutes les tables à chaque cycle de GC.
- **Parallélisation** : Permettre au GC de traiter les namespaces ou les bases de données en parallèle si le backend KV le supporte.

### 2. Streaming natif
- **Intégration Pub/Sub** : Ajouter des hooks dans `writer.rs` pour diffuser les modifications vers un bus interne (ou un système externe comme NATS/Kafka) en temps réel, réduisant le besoin de polling.

### 3. Filtrage Côté Serveur
- **Prédicats de lecture** : Améliorer `reader.rs` pour permettre de filtrer les modifications (ex: uniquement sur certains champs ou via une condition `WHERE`) directement lors du scan des clés KV pour économiser de la bande passante.

### 4. Gestion des Transactions Massives
- **Spilling au disque** : Pour les transactions dépassant un certain seuil de taille, envisager un mécanisme de déchargement du buffer du `Writer` vers un stockage temporaire pour éviter les erreurs `OOM` (Out Of Memory).

---

## 📊 Conclusion

Le module `cf` est extrêmement solide et bien architecturé pour les cas d'usage standards. Sa gestion des deltas via JSON Patch est un point différenciateur fort. Les axes d'optimisation se situent principalement sur le passage à l'échelle (scale) logicielle (milliers de tables) et l'interopérabilité en temps réel (Push vs Pull).
