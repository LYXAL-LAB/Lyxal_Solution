# 📋 Plan d'Implémentation — RÉALIGNEMENT ARCHITECTURAL LYXAL PIPELINE INGESTION

> **Module :** `crates/lyxal_pipeline_ingestion`  
> **Décision CTO :** AUDIT ACCEPTÉ — RÉALIGNEMENT AUTORISÉ — PHASE 5 BLOQUÉE  
> **Référentiel Obligatoire :** `C:\Users\HP\Desktop\Lyxal_OS\.agents\AGENTS.md`  
> **Objectif :** Rétablir la stricte conformité architecturale Lyxal OS : frontière SurrealQL/Rust, wrappers `store.call_fn(...)`, externalisation des règles métier en tables/seeds configurables, réutilisation des référentiels existants (`base_unite`, `catalogue_relation_type`), structure canonique complète, et validation des 8 tests exigés.

---

## 1. Analyse de Réutilisation `lyxal_core` et Modules Existants

Conformément à la Charte d'Architecture Lyxal OS (§ 3 & § 5.7) :

### 1.1. Fonctions Core & Transversales Réutilisées
- **`lyxal_base`** :
  - Référentiel universel des unités de mesure (`base_unite`).
  - Utilisation de la table `base_unite` et validation des codes officiels (`M`, `ML`, `CM`, `M2`, `M3`, `KG`, `T`, `PCE`, `ROUL`, `BTE`, `SAC`, `ENS`, etc.).
  - Table de liaison dynamique `ingestion_unit_alias` pour résoudre les alias commerciaux et UN/CEFACT sans modifier Rust.
- **`lyxal_catalogue`** :
  - Référentiel des types de relations `catalogue_relation_type` (`SUBSTITUT`, `SIMILAIRE`, `COMMERCIAL_SPECIFICATION`).
  - Fonction publique officielle `fn::catalogue_relation_create` pour la publication contrôlée des relations globales.
  - **Limitation documentée CTO :** La table `catalogue_relation` du Catalogue V1.1 comporte un index unique sur `(source, cible, relation_type)` sans champ `contexte` de système constructif. Par conséquent, les substitutions contextualisées restent stockées avec toute leur traçabilité dans la table propre au pipeline `ingestion_substitution_rule`.
- **`lyxal_surreal`** :
  - Trait universel `LyxalSurrealCall` et méthode `call_fn<T, P>(&self, "function_name", params)`.
  - Contrats universels de retour `fn::result_ok($data)` et `fn::error_result($code, $language, $details)`.
- **`lyxal_crypto`** :
  - `lyxal_crypto::blake3_hex` pour les empreintes immuables BLAKE3 de fichiers, lignes et scellements.
- **`lyxal_error`** :
  - Codes d'erreurs normalisés `INGESTION_*` définis dans `error/ingestion/error_definitions.surql`.
- **`lyxal_event`** :
  - Outbox transactionnelle `fn::event_publish` déclenchée par SurrealDB (`events/01_events.surql`).
- **`lyxal_runtime`** :
  - Traits `LyxalModule`, `LyxalWorker`, `HealthCheck`.

---

## 2. DTOs Typés Rust (`XxxParams` & `XxxResult`)

Conformément à AGENTS.md § 5.3 & § 5.4, toutes les opérations du store Rust transitent par `store.call_fn(...)` avec des structures de paramètres et de résultats typées :

```rust
// Gestion des Lots
pub struct BatchCreateParams { ... }
pub struct BatchCheckpointParams { ... }
pub struct BatchTransitionParams { ... }

// Gestion du Staging & Quarantaine
pub struct StagedSaveParams { ... }
pub struct QuarantineLogParams { ... }

// Gestion des Manifestes de Publication
pub struct ManifestSaveParams { ... }
pub struct ManifestApproveParams { ... }
pub struct ManifestRecordExecParams { ... }

// Résolution Dynamique des Règles & Référentiels
pub struct ResolveUnitParams { pub raw_unit: String }
pub struct ResolveUnitResult { pub canonical_code: String, pub resolved: bool }

pub struct ResolveManufacturerParams { pub raw_name: String }
pub struct ResolveManufacturerResult { pub canonical_name: String, pub is_verified: bool }

// Configuration Dynamique (Sans Recompilation)
pub struct FamilyRuleAddParams { ... }
pub struct SpecAddParams { ... }
pub struct SubstitutionRuleAddParams { ... }
```

---

## 3. Fonctions Publiques SurrealQL (`fn::ingestion_*`)

Toutes les fonctions acceptent obligatoirement un objet unique `$params`, sont bornées à < 300 lignes, et retournent systématiquement `fn::result_ok($data)` ou `fn::error_result($code, $language, $details)`.

| Fonction | Fichier | Rôle Métier |
| :--- | :--- | :--- |
| `fn::ingestion_batch_create` | `functions/batch/ingestion_batch_create.surql` | Crée ou met à jour un lot avec contrôle d'idempotence et validation de schéma. |
| `fn::ingestion_batch_checkpoint` | `functions/batch/ingestion_batch_checkpoint.surql` | Met à jour le curseur, les compteurs de qualification et l'horodatage de checkpoint. |
| `fn::ingestion_batch_transition` | `functions/batch/ingestion_batch_transition.surql` | Valide et applique une transition d'état sur un lot avec audit trail immuable. |
| `fn::ingestion_staged_save` | `functions/staged/ingestion_staged_save.surql` | Enregistre un article en staging avec empreinte canonique. |
| `fn::ingestion_quarantine_log` | `functions/quarantine/ingestion_quarantine_log.surql` | Consigne une anomalie typée dans la quarantaine industrielle. |
| `fn::ingestion_manifest_save` | `functions/manifest/ingestion_manifest_save.surql` | Crée ou met à jour un manifeste de publication scellé. |
| `fn::ingestion_manifest_approve` | `functions/manifest/ingestion_manifest_approve.surql` | Contrôle les permissions `steward_admin`, vérifie le scellement et approuve le manifeste. |
| `fn::ingestion_manifest_record_exec`| `functions/manifest/ingestion_manifest_record_exec.surql` | Enregistre le compte-rendu d'exécution et les métriques de publication. |
| `fn::ingestion_resolve_unit` | `functions/rule/ingestion_resolve_unit.surql` | Résout un alias d'unité via `ingestion_unit_alias` raccordé à `base_unite`. |
| `fn::ingestion_resolve_manufacturer`| `functions/rule/ingestion_resolve_manufacturer.surql` | Résout un nom de fabricant via `ingestion_manufacturer_alias`. |
| `fn::ingestion_rule_family_add` | `functions/rule/ingestion_rule_family_add.surql` | Déclare ou met à jour une famille de produits sans recompilation. |
| `fn::ingestion_rule_spec_add` | `functions/rule/ingestion_rule_spec_add.surql` | Déclare une spécification technique patronne avec tolérances et critères. |
| `fn::ingestion_rule_substitution_add`| `functions/rule/ingestion_rule_substitution_add.surql` | Déclare une règle de substitution contextualisée et révocable. |

---

## 4. Tables de Règles Métier Externalisées (`schema/`)

Suppression de toutes les règles en dur dans Rust. Définition des tables déclaratives `SCHEMAFULL` :
1. `06_ingestion_family_rule.surql` : Définition des familles de produits, mots-clés de classification, unités par défaut.
2. `07_ingestion_specification.surql` : Spécifications techniques patronnes, cotes nominales, tolérances configurables (`length_tol_mm`, etc.), normes exigées, classements feu, attributs techniques requis.
3. `08_ingestion_manufacturer_alias.surql` : Correspondances des dénominations commerciales vers les fabricants canoniques et gestion des holdings.
4. `09_ingestion_unit_alias.surql` : Correspondance des unités fabricants et codes internationaux (UN/CEFACT) vers `base_unite`.
5. `10_ingestion_substitution_rule.surql` : Règles de substitution contextualisées (champ d'application système constructif, organisme certificateur, numéro d'agrément, date de validité, révocation).

---

## 5. Données de Configuration Initiales (`seeds/`)

1. `01_initial_families.surql` : Les 4 familles clés BTP (Plaques de plâtre, Rails/Montants, Appareillage électrique, Isolants thermiques).
2. `02_initial_specifications.surql` : Spécifications patronnes (BA13, R48, Prise 2P+T, GR32, Laine de roche).
3. `03_initial_aliases.surql` : Alias fabricants (Placo, Isover, Weber, Knauf, Siniat, Legrand, Schneider...) et alias unités (`base_unite`).
4. `04_carrelage_demo.surql` : Famille "Carrelage" pour validation de l'extensibilité sans recompilation Rust.

---

## 6. Structure Canonique & Manifeste (`manifest.toml`)

- Déclaration de toutes les ressources dans `manifest.toml` :
  - `schemas` (11 schémas ordonnés)
  - `migrations` (`migrations/0001_initial_schema.surql`)
  - `functions` (13 fonctions réparties par domaine)
  - `events` (`events/01_events.surql`)
  - `error` (`error/ingestion/error_definitions.surql`)
- Documentation canonique : `README.md` et `CHANGELOG.md`.

---

## 7. Plan des Tests de Validation du Réalignement

En plus des **46 tests existants maintenus à 100% au vert**, ajout d'une suite dédiée validant les 8 exigences CTO :
1. **Test 1 — Extensibilité Famille sans Recompilation :** Ajout de la famille "Carrelage Sol" dans SurrealDB, évaluation immédiate d'un article "Carrelage Grès Cérame 60x60" par le moteur Rust sans aucune recompilation.
2. **Test 2 — Ajout Fabricant / Alias Dynamique :** Enregistrement d'un nouvel alias fabricant dans SurrealDB et résolution immédiate sans modification Rust.
3. **Test 3 — Résolution Unité depuis `base_unite` :** Résolution dynamique d'alias vers `base_unite:M2` et `base_unite:PCE`.
4. **Test 4 — Utilisation Exclusive des Fonctions Publiques :** Vérification que toutes les opérations de `IngestionStore` transitent exclusivement par `call_fn` et les fonctions `fn::ingestion_*`.
5. **Test 5 — Persistance & Rechargement après Redémarrage :** Persistance des règles, spécifications et substitutions, réinstanciation du store et reprise nominale.
6. **Test 6 — Contrôles RLS & Permissions :** Validation des restrictions d'accès sur les tables et fonctions (rejet des rôles non autorisés).
7. **Test 7 — Publication Isolée & Contrats Catalogue :** Publication d'une relation `SUBSTITUT` via `fn::catalogue_relation_create`, documentation de la distinction entre relation globale et substitution contextualisée.
8. **Test 8 — Reprise sur Incident & Idempotence :** Simulation d'interruption avec reprise sur checkpoint sans duplication d'articles.

---

## 8. Respect des Restrictions Formelles
- **ZÉRO modification de `lyxal_catalogue` V1.1.**
- **ZÉRO refonte générale des modules existants.**
- **ZÉRO publication dans le Master de production.**
- **Préserver les 41 références BTP en quarantaine pour Phase 5.**
- **Aucun lancement de Phase 5 avant validation formelle CTO.**
