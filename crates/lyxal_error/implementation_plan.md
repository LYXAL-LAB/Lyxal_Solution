# 📋 Plan d'Implémentation CTO — `lyxal_error` (Mise en conformité SurrealDB 3.2.0, DTOs & Idempotence)

> **Statut** : `TERMINÉ ET VALIDÉ (100 % CONFORME SURREALDB 3.2.0)`
> **Module** : `crates/lyxal_error` (Couche 1 — Fondation Transversale / Gestion Canonique des Erreurs & Contrats)
> **Référence d'entrée** : Rapport d'audit de conformité CTO `crates/lyxal_error` v0.1.0 (2 P1, 0 P0, 2 P2) & Mission CTO
> **Cible de référence** : **SurrealDB 3.2.0** (`c:\Users\HP\Desktop\Lyxal_OS\surreal.exe` — `3.2.0 for windows on x86_64`)

---

## 1. Objectifs & Périmètre Strict

1. **Périmètre exclusif** : `crates/lyxal_error/` (aucun autre module modifié).
2. **Compatibilité SurrealDB 3.2.0** : Résoudre les 10 échecs de validation syntaxique (`type::thing` et `type::is::*`) et valider l'intégralité des **26 fichiers `.surql`** (`schemas/`, `migrations/`, `functions/`, `error/`, `seeds/`).
3. **Réconciliation DTO Rust ↔ SurrealQL** :
   - Assurer la prise en charge bidirectionnelle sans perte de données :
     - `ErrorMappingCreateParams` / `ErrorMappingUpdateParams` : supporter à la fois `match_type`/`matcher` et `target_code`/`definition_id`, plus `service`, `external_http_status`, `description`.
     - `ErrorDefinitionCreateParams` / `ErrorDefinitionUpdateParams` : persister et mettre à jour `retryable`, `log_occurrence`, `documentation`, `metadata`, `active` (`enabled`).
     - `ErrorDefinitionListParams` : supporter le filtre `severity`.
4. **Idempotence des Seeds & Master Data** :
   - Rendre `error/error_definitions.surql` et `seeds/error_mappings.surql` strictement réexécutables (`IF !record::exists(...)`).
5. **Preuves d'Exécution sur Vraie Instance SurrealDB 3.2.0** :
   - Démarrer une instance locale réelle `surreal.exe 3.2.0` (port éphémère / mémoire isolée `mem://`).
   - Exécuter la suite complète de validation : bootstrap des 26 fichiers, rejouabilité des seeds, tests positifs nominaux, tests négatifs (paramètres requis, codes inconnus), vérification de la non-perte des champs DTOs.
6. **Vérifications Rust** :
   - `cargo check -p lyxal_error --tests`
   - `cargo clippy -p lyxal_error --all-targets`
   - `cargo test -p lyxal_error`

---

## 2. Décomposition des Lots d'Exécution

### Lot 1 — Correction Syntaxique & Compatibilité SurrealDB 3.2.0 (10 fichiers)
- Remplacer `type::thing(...)` par `type::record(...)` (ou `<record<...>>` selon le contexte) dans :
  1. `functions/definition/error_definition_disable.surql`
  2. `functions/definition/error_definition_get.surql`
  3. `functions/definition/error_definition_update.surql`
  4. `functions/mapping/error_mapping_create.surql`
  5. `functions/mapping/error_mapping_disable.surql`
  6. `functions/mapping/error_mapping_get.surql`
  7. `functions/mapping/error_mapping_update.surql`
  8. `functions/occurrence/error_occurrence_get.surql`
  9. `functions/service/error_get.surql`
- Remplacer `type::is::*` par `type::is_*` (ou `$val IS type`) dans :
  1. `functions/mapping/error_mapping_create.surql` (`type::is_string`, `type::is_record`)
  2. `functions/mapping/error_mapping_disable.surql` (`type::is_record`)
  3. `functions/mapping/error_mapping_get.surql` (`type::is_record`)
  4. `functions/mapping/error_mapping_update.surql` (`type::is_record`, `type::is_string`)
  5. `functions/occurrence/error_occurrence_get.surql` (`type::is_record`)
  6. `functions/occurrence/error_occurrence_purge_before.surql` (`type::is_datetime`, `type::is_string`)
  7. `functions/service/error_get.surql` (`type::is_string`, `type::is_object`)
- **Validation** : `surreal.exe validate` sur les 26 fichiers `.surql` $\rightarrow$ **`26 / 26 OK`**.

### Lot 2 — Réconciliation DTOs Rust ↔ SurrealQL
- **Côté SurrealQL** :
  - `fn::error_mapping_create` & `fn::error_mapping_update` :
    - Lire `$params.matcher ?? $params.match_type ?? "exact"`
    - Lire `$params.definition_id ?? $params.target_code ?? $params.definition`
    - Lire `$params.service`
    - Enregistrer `external_http_status: $params.external_http_status ?? $params.http_status`
  - `fn::error_definition_create` :
    - Persister `retryable`, `log_occurrence`, `documentation`, `metadata` dans le `CREATE ONLY error_definition CONTENT { ... }`.
  - `fn::error_definition_update` :
    - Supporter la mise à jour de `retryable`, `log_occurrence`, `documentation`, `metadata`, ainsi que `enabled: $params.active` si présent.
  - `fn::error_definition_list` :
    - Ajouter le filtre `severity: ($clean_sev = NONE OR severity = $clean_sev)`.
- **Côté Rust (`src/types.rs`)** :
  - Ajouter des alias Serde bienveillants :
    - `ErrorMappingCreateParams` : `#[serde(alias = "matcher")] pub match_type: String`, `#[serde(alias = "definition_id")] pub target_code: String`, ajout du champ optionnel `pub service: Option<String>`.
    - `ErrorMappingUpdateParams` : alias `matcher` et `definition_id`, ajout de `pub service: Option<String>` et `pub retryable_override: Option<bool>`.
    - `ErrorDefinitionCreateParams` / `ErrorDefinitionListParams` : ajout des champs complémentaires `module`, `domain`, `enabled_only`.
- **Validation** : mise à jour des tests dans `tests/contracts_tests.rs` et `tests/surreal_integration_tests.rs` pour prouver la persistance et relecture sans perte.

### Lot 3 — Idempotence des Seeds & Master Data
- `error/error_definitions.surql` :
  - Remplacer les `CREATE error_definition CONTENT { ... }` aveugles par :
    ```surql
    IF !record::exists(type::record("error_definition", "<CODE>")) THEN (
        CREATE type::record("error_definition", "<CODE>") CONTENT { ... }
    ) END;
    ```
- `seeds/error_mappings.surql` :
  - Vérifier l'existence préalable du mapping par `provider`, `service`, `external_code`, `matcher` avant d'insérer, ou assigner un ID déterministe `error_external_mapping:<provider>_<code_slug>` avec `IF !record::exists(...)`.
- **Validation** : test unitaire et dynamique confirmant le double jeu sans erreur et sans duplication.

### Lot 4 — Validation Complète sur Instance Réelle SurrealDB 3.2.0
- Créer un script de test dynamique d'intégration exécuté contre une instance réelle `surreal.exe 3.2.0` :
  - Démarrage de `surreal.exe start --bind 127.0.0.1:<port> --user root --pass root mem://`
  - Initialisation de la base (`schemas` $\rightarrow$ `migrations` $\rightarrow$ `functions` $\rightarrow$ `error_definitions` $\rightarrow$ `seeds`)
  - Exécution des 20 fonctions via requêtes réelles SurrealDB 3.2.0
  - Vérification de la rejouabilité des seeds
  - Arrêt propre du processus serveur
- Consignation des résultats et preuve de passage 100 %.

### Lot 5 — Contrôles Rust, Clippy & Clôture Documentaire
- `cargo check -p lyxal_error --tests`
- `cargo clippy -p lyxal_error --all-targets`
- `cargo test -p lyxal_error`
- Mise à jour de `crates/lyxal_error/CHANGELOG.md` et `crates/lyxal_error/README.md`.
- Rédaction du rapport final de clôture CTO.

---

## 3. Matrice des Risques & Précautions
- **Compatibilité des tests SDK existants (`surrealdb = "2.2"`)** :
  - Les syntaxes SurrealQL 3.2.0 (`type::record(...)`, `type::is_string(...)`) doivent rester interprétables par le moteur local `Mem` du SDK 2.2 utilisé dans `Cargo.toml`, OU les tests d'intégration doivent être adaptés de manière à ce que les deux environnements soient rigoureusement verts.
  - La sémantique de `type::record("table", "id")` et `$val IS string` sera validée sur les deux moteurs.
- **Préservation des signatures publiques** :
  - Toutes les signatures `fn::error_*($params: object)` conservent leur contrat existant tout en acceptant les nouveaux champs optionnels.

