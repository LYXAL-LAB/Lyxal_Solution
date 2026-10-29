---
name: lyxal-new-module
description: >-
  Use this skill when the user asks to design, plan, or create a new Lyxal OS module, add a sub-domain to an existing module, or prepare a CTO implementation plan (implementation_plan.md) before scaffolding canonical Rust and SurrealQL structures.
---

# Lyxal OS — Création & Planification Canonique de Module (`lyxal-new-module`)

> **Source normative** : Ce Skill exécute la procédure opérationnelle de création de module. Les règles d'architecture, de sécurité et de nommage demeurent régies par [`.agents/AGENTS.md`](../../AGENTS.md) et [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md). En cas d'écart, les règles permanentes prévalent toujours.

---

## Quand déclencher ce Skill

Activer ce Skill dès que l'utilisateur demande :
- La conception ou la création d'un nouveau module dans `crates/<module_name>` ;
- La rédaction d'un `implementation_plan.md` pour un nouveau module ou sous-domaine ;
- La mise en place du squelette canonique (`manifest.toml`, `schema/`, `functions/`, `error/`, `seeds/`, `src/`).

---

## Procédure Opérationnelle en 3 Étapes

### Étape 1 — Inspection Préalable & Analyse des Dépendances (Lecture Seule)

Avant toute proposition d'architecture, inspecter obligatoirement l'existant dans le dépôt :

1. **Workspace Cargo & Crates existants** :
   - Lire [`Cargo.toml`](../../../Cargo.toml) à la racine pour identifier les membres actifs (`crates/lyxal_error`, `crates/lyxal_surreal`, `crates/lyxal_runtime`, `crates/lyxal_event`, `crates/lyxal_crypto`, `crates/lyxal_pipeline_ingestion`, `apps/lyxal-server`) et les versions partagées dans `[workspace.dependencies]`.
2. **Modules de référence validés** :
   - **Module Hybride Rust + SurrealQL** : [`crates/lyxal_pipeline_ingestion`](../../../crates/lyxal_pipeline_ingestion/manifest.toml) (`manifest.toml`, `src/module.rs`, `src/storage/store.rs`, `schema/`, `functions/`, `events/`, `error/`, `seeds/`).
   - **Module Déclaratif SurrealQL** : [`crates/lyxal_catalogue`](../../../crates/lyxal_catalogue/manifest.toml) (`manifest.toml`, `schema/`, `functions/`, `seeds/`, `ROADMAP.md`).
   - **Moteur d'Erreurs** : [`crates/lyxal_error`](../../../crates/lyxal_error/manifest.toml).
3. **Vérification de non-duplication & Graphe DAG** :
   - Vérifier si la responsabilité existe déjà dans `lyxal_core` (`validation/`, `sanitize/`, `security/`, `utils/`), `lyxal_base` (`base_unite`, `base_unite_type`), `lyxal_crypto` ou `lyxal_error`.
   - S'assurer que les dépendances déclarées respectent l'ordre topologique strict sans cycle (`DependencyResolver` de `crates/lyxal_runtime`).
   - Si une primitive générique `lyxal_core` ou `lyxal_crypto` manque, la noter comme **Point d'escalade CTO** et ne jamais l'implémenter ni la contourner localement.

---

### Étape 2 — Rédaction du Plan & Verrou de Validation CTO (`implementation_plan.md`)

> [!IMPORTANT]
> **VERROU ABSOLU CTO** : Ne créer ni modifier aucun fichier applicatif (`Cargo.toml`, `manifest.toml`, `.surql`, `.rs`) tant que le plan `implementation_plan.md` n'a pas été présenté et explicitement validé par le CTO.

Le plan soumis doit impérativement documenter :

1. **Périmètre & Classification** :
   - Identifiant canonique `lyxal_<domaine>`, chemin cible `crates/lyxal_<domaine>`, nature (Déclaratif SurrealQL seul ou Hybride SurrealQL + Crate Rust).
2. **Bilan de Réutilisation** :
   - Primitives `lyxal_core` / `lyxal_crypto` / `lyxal_base` / `lyxal_error` réutilisées ;
   - Nouvelles fonctions métier propres au module ;
   - Besoins transversaux éventuels soumis à arbitrage CTO.
3. **Contrat `manifest.toml`** (conforme à [`crates/lyxal_runtime/src/manifest/model.rs`](../../../crates/lyxal_runtime/src/manifest/model.rs)) :
   - `manifest_version = 1`, `id`, `name`, `version`, `description`, `capabilities` (`"database"`, `"workers"`, `"events"`) ;
   - `[runtime]` avec `min_version = ">=0.1.0"` ;
   - `[[dependencies]]` (tableau de tables TOML avec `id` et `version`) ;
   - `[resources]` (`schemas`, `migrations`, `functions`, `events`, `seeds`, `error_definitions`).
4. **Contrats SurrealQL** :
   - Liste des tables (`DEFINE TABLE OVERWRITE <module>_<entite> TYPE NORMAL SCHEMAFULL PERMISSIONS ... COMMENT "..."`) ;
   - Signatures exactes des fonctions (`DEFINE FUNCTION OVERWRITE fn::<module>_<action>($params: object) { ... } COMMENT "..."`) ;
   - Événements éventuels (`DEFINE EVENT ... THEN ( fn::event_publish({ ... }) )`).
5. **Master Data d'Erreurs** :
   - Liste exhaustive des codes `<MODULE>_<DOMAINE>_<CAUSE>`, catégories, statuts HTTP, caractère `retryable` et traductions (`fr` / `en`).
6. **Contrats Rust (si crate Rust)** :
   - Implémentation de [`lyxal_runtime::LyxalModule`](../../../crates/lyxal_runtime/src/module.rs) via `ModuleDescriptorBuilder` ;
   - Store de persistance implémentant [`lyxal_surreal::LyxalSurrealCall`](../../../crates/lyxal_surreal/src/call.rs) avec structures `*Params` et `*Result` nommées ;
   - Organisation de `src/models/` (ségrégation `pub` vs `pub(crate)`, masquage `Debug` des secrets) ;
   - Workers éventuels implémentant [`lyxal_runtime::worker::LyxalWorker`](../../../crates/lyxal_runtime/src/worker/mod.rs) avec `CancellationToken` ;
   - Sondes de santé éventuelles (`ModuleHealthCheck`).
7. **Risques & Stratégie de Tests** :
   - Tests unitaires Rust (`cargo test -p lyxal_<domaine>`) ;
   - Scénarios de tests SurrealQL sur SurrealDB 3.2.0 (cas nominaux, erreurs attendues, permissions RLS, idempotence des seeds).

**Fin de l'Étape 2** : Présenter le plan et attendre l'instruction explicite de validation avant de passer à l'Étape 3.

---

### Étape 3 — Génération de la Structure Canonique (Après Validation CTO)

Une fois la validation CTO obtenue, créer les fichiers dans l'ordre suivant :

1. **Manifeste Runtime (`crates/lyxal_<domaine>/manifest.toml`)** :
   - Utiliser la syntaxe `[[dependencies]]` et `[runtime]` validée par `ManifestParser` dans `crates/lyxal_runtime` (prendre modèle sur [`crates/lyxal_pipeline_ingestion/manifest.toml`](../../../crates/lyxal_pipeline_ingestion/manifest.toml)).
2. **Schémas Déclaratifs (`schema/XX_<table_name>.surql`)** :
   - Numéroter dans l'ordre topologique des références (`00_`, `01_`, ...).
   - Toujours utiliser `TYPE NORMAL SCHEMAFULL` par défaut (toute table `TYPE RELATION` exige un arbitrage CTO explicite conformément à [`AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).
3. **Définitions d'Erreurs (`error/<domaine>/error_definitions.surql`) & Seeds (`seeds/*.surql`)** :
   - Protéger chaque insertion par `IF !record::exists(error_definition:<CODE>) THEN ( CREATE error_definition:<CODE> CONTENT { ... } ) END;` pour garantir l'idempotence non destructrice.
4. **Fonctions Métier (`functions/<sous_domaine>/<module>_<action>.surql`)** :
   - Paramètre unique `$params: object`, retour exclusif `fn::result_ok($data)` ou `fn::error_result($code, $language, $details)`, `COMMENT "..."` obligatoire, taille < 300 lignes.
5. **Code Rust (`Cargo.toml` + `src/`)** :
   - Déclarer les dépendances via `{ workspace = true }` dans `crates/lyxal_<domaine>/Cargo.toml` et enregistrer le crate dans [`Cargo.toml`](../../../Cargo.toml) racine si requis.
   - Implémenter `src/module.rs` (`LyxalModule::descriptor(&self) -> &ModuleDescriptor`), `src/models/`, `src/storage/store.rs` (`LyxalSurrealCall`), `src/error.rs`, `src/lib.rs`.
6. **Vérification Finale** :
   - Vérifier la cohérence entre les chemins listés dans `manifest.toml` (`[resources]`) et les fichiers réellement créés sur disque.
   - Exécuter le Skill `lyxal-audit` sur le nouveau module avant de présenter le livrable final.

