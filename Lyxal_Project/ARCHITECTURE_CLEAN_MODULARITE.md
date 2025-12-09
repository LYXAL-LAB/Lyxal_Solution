# Architecture Modulaire (Clean Architecture)
## Pourquoi séparer le Moteur et la Base de Données ?

Pour garantir la portabilité (WASM, Desktop, CLI) et la maintenabilité, nous appliquons une séparation stricte des responsabilités.

### Le Schéma de Dépendance
`[SurrealDB Core]` --> depend de --> `[Lyxal Surreal (Glu)]` --> depend de --> `[Lyxal PDF (Engine)]`

### 1. Lyxal PDF (`crates/lyxal-pdf`)
*   **Nature :** Moteur Pur (Pure Rust).
*   **Dépendances :** Aucune dépendance à SurrealDB. Uniquement `pdf-writer`, `serde`, `image`.
*   **Rôle :**
    *   Prend des données brutes (Structs Rust).
    *   Génère des octets PDF.
    *   Compile en WASM pour le navigateur.
*   **Règle d'Or :** Doit pouvoir compiler et tourner sans internet, sans base de données, juste avec un CPU.

### 2. Lyxal Surreal (`crates/lyxal-surreal`)
*   **Nature :** Couche d'Adaptation (The Glue).
*   **Dépendances :** `surrealdb-core` et `lyxal-pdf`.
*   **Rôle :**
    *   **Traduction :** Convertit `surrealdb::val::Value` (JSON BDD) en `lyxal::Document` (Struct Moteur).
    *   **Sécurité :** Isole l'exécution du moteur (catch_unwind) pour qu'un bug PDF ne crash pas la BDD.
    *   **Concurrence :** Gère le `tokio::task::spawn_blocking` pour ne pas bloquer les requêtes des autres utilisateurs.

### 3. SurrealDB Core (`crates/core`)
*   **Nature :** Le Cœur de la Base.
*   **Rôle :** Appelle la couche Glu via des fonctions enregistrées (`fnc::lyxal::generate()`).

---
*Ce document sert de référence pour ne jamais coupler le moteur PDF à la logique de la base de données.*

