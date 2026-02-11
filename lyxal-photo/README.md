# Lyxal Photo Engine

> **Version:** 1.0 (Architecture "Brain & Muscle" Industrielle)
> **Statut:** Production-Ready (M0-M9 Complétés)

Lyxal Photo est un moteur de gestion de photos et vidéos **souverain**, **hyper-convergé** et **cloud-agnostique**. Conçu pour surpasser les standards actuels (Google Photos, PhotoPrism), il sépare strictement la logique métier (SurrealDB) de la puissance de calcul (Rust), garantissant performance, évolutivité et auditabilité.

---

## 🏗️ Architecture "Brain vs Muscle"

L'architecture repose sur un principe fondateur unique :

1.  **Le Cerveau (SurrealDB - `schema.surql`) :**
    *   Détient la **Vérité** (Données, Métadonnées, Graphe Social, Géographie).
    *   Orchestre les processus via des **Événements** (`DEFINE EVENT`).
    *   Ne fait **jamais** de traitement lourd (pas de resizing, pas d'inférence IA).
    *   Expose une API de haut niveau (`fn::photo::*`) pour les clients.

2.  **Les Muscles (Rust - `src/`) :**
    *   Exécutent les tâches lourdes (Transcodage, IA, Hashage).
    *   Sont **Apatrides** (Stateless) et **Idempotents**.
    *   Ne font **jamais** de SQL (lecture/écriture directe interdite).
    *   Communiquent uniquement par **Rapport** via la table `scheduler::history`.

### Flux de Données

```mermaid
graph TD
    User[Client / API] -->|Upload| Brain[SurrealDB (Brain)]
    Brain -->|Event: on_file_created| Scheduler[Scheduler Queue]
    Scheduler -->|Task Payload| Worker[Rust Worker (Muscle)]
    Worker -->|Download/Upload| Storage[Storage Engine (Bunny/S3/FS)]
    Worker -->|Report Result| Brain
    Brain -->|Event: on_task_finished| DB[Mise à jour Tables]
```

---

## 📦 Modules & Composants

### 1. Le Cerveau (`schema.surql`)
Le fichier unique de définition du système.
*   **Tables Clés :** `asset` (binaire unique), `file` (référence), `photo` (entité logique), `place` (lieu canonique), `face` (biométrie).
*   **Orchestration :**
    *   `on_file_created` -> Déclenche `render` (thumbs) et `transcode` (vidéo).
    *   `on_photo_created` -> Déclenche `ai.analyze` et `geo.resolve`.
    *   `on_ai_completed` -> Déclenche `clustering`.
*   **Observabilité :** Tables `telemetry_task_run` et `telemetry_daily` auto-alimentées.

### 2. Les Muscles (`src/pipeline/`)
Workers spécialisés respectant le contrat strict M8.1.
*   **`render` :** Génération pyramide d'images (WebP/AVIF) avec `fast_image_resize`.
*   **`video_render` :** Transcodage FFmpeg (H.264/H.265, Storyboards, Animated Thumbs).
*   **`ai` :** Inférence photo (Visages, Embeddings 512d, Labels) via ONNX Runtime.
*   **`video_ai` :** Analyse temporelle vidéo (Sampling de frames, détection visages).
*   **`geo` :** Géocodage inverse agnostique (Nominatim) avec cache LRU.
*   **`cluster` :** Regroupement biométrique des visages.

### 3. Infrastructure (`src/`)
*   **`storage` :** Abstraction totale du stockage (`StorageEngine`). Supporte `fs://` (local) et `bunny://` (Bunny.net).
*   **`ai` :** Gestionnaire de modèles ONNX (`ModelManager`) et pré-traitement vision.
*   **`api` :** Contrats DTO (`contract.rs`) pour une API stable et découplée de la DB.

---

## 🚀 Guide de Démarrage

### Pré-requis
*   **Rust** (latest stable)
*   **SurrealDB** (v2/v3 beta)
*   **FFmpeg** (installé sur le système pour le module vidéo)
*   **Modèles ONNX** (à placer dans un dossier `models/`) :
    *   `retinaface.onnx`
    *   `arcface_512.onnx`
    *   `mobilenet_v2.onnx`

### Configuration
Les workers se configurent via des variables d'environnement ou le `StorageManager` :
```rust
let storage = StorageManager::new(
    "./data".to_string(), // Root local
    bunny_config          // Config Bunny optionnelle
);
```

### Lancement des Tests
```bash
# Tester la compilation et les tests unitaires
cargo test

# Vérifier le formatage
cargo fmt --check
```

---

## 🔮 Roadmap "Future-Proof" & SurrealML

L'architecture actuelle est conçue pour durer 10 ans. Voici comment elle évoluera, notamment avec l'intégration de **SurrealML**.

### 1. Intégration SurrealML (Le Cerveau devient Intelligent)
Aujourd'hui, l'IA "Lourde" (Extraction de features) est dans les workers Rust. Demain, l'IA "Décisionnelle" (Scoring, Reco) ira dans SurrealDB.

*   **Recherche Sémantique (CLIP) :**
    *   *Actuel :* Recherche hybride (Mots-clés + Filtres).
    *   *Futur :* Charger un modèle CLIP texte dans SurrealML.
    *   *Implémentation :* Modifier `fn::photo::search` pour vectoriser la requête utilisateur à la volée et comparer avec les embeddings stockés.
*   **Recommandation & "For You" :**
    *   Utiliser SurrealML pour analyser les logs `telemetry` et prédire les photos les plus pertinentes pour un utilisateur donné.
*   **Classification Tabulaire :**
    *   Prédire la qualité esthétique ou la pertinence d'une photo basée sur ses métadonnées (EXIF, Heure, Lieu) directement en SQL.

**Règle d'Or :** Ne jamais déplacer l'extraction de pixels (décodage vidéo, resizing) dans SurrealDB. Cela reste le rôle des Workers Rust (Muscles).

### 2. Échelle & Multi-Tenant
*   **Storage :** Le `StorageEngine` est déjà prêt pour le sharding (par tenant ou par date).
*   **Scheduler :** Le système de queues de SurrealDB permet d'ajouter des instances de workers Rust à l'infini pour absorber la charge (Horizontal Scaling).

### 3. Maintenance & Audit (M7+)
*   **Health Check :** Utiliser `fn::photo::health_summary()` pour monitorer la santé du cluster.
*   **Retention :** Implémenter des politiques de suppression douce (Soft Delete déjà supporté par le schéma) et de purge des fichiers temporaires.

---

## 🛡️ Sécurité & Données

*   **Souveraineté :** Aucune donnée ne quitte le serveur (sauf vers le Storage chiffré).
*   **Idempotence :** Tout plantage est récupérable. Aucune corruption de données possible grâce aux transactions ACID de SurrealDB et à la logique `DELETE-then-CREATE` des workers.
*   **Zéro Fuite :** L'API publique (`src/api`) n'expose jamais les IDs internes ou la structure brute de la base.

---

**Lyxal Photo Engine** - *Build once, scale forever.*
