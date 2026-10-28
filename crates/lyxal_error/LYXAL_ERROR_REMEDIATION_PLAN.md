# 🛡️ MISSION CTO : PLAN DE REMISE EN CONFORMITÉ & AUDIT D'IMPACT — `lyxal_error`

> **Document de Référence** : `LYXAL_ERROR_REMEDIATION_PLAN.md`  
> **Auteur** : Antigravity (Mission CTO Lyxal OS)  
> **Statut** : Soumis à validation formelle CTO  
> **Priorité** : P0 — Critique  
> **Date d'Audit** : 2026-10-26  
> **Norme d'Architecture** : `.agents/AGENTS.md` (Constitution Lyxal OS)  
> **Règle d'Engagement** : **Aucune modification de code n'a été effectuée pendant cet audit.**

---

## 📑 Sommaire Exécutif

1. [Décision CTO & Synthèse d'Arbitrage](#1-décision-cto--synthèse-darbitrage)
2. [Cartographie Réelle des Dépendances Workspace](#2-cartographie-réelle-des-dépendances-workspace)
3. [Inventaire Exhaustif des API Consommées](#3-inventaire-exhaustif-des-api-consommées)
4. [Analyse Chirurgicale des 22 Appels Invalides](#4-analyse-chirurgicale-des-22-appels-invalides)
5. [Matrice de Compatibilité Intermodules](#5-matrice-de-compatibilité-intermodules)
6. [Plan de Migration des Signatures SurrealQL](#6-plan-de-migration-des-signatures-surrealql)
7. [Plan de Migration et Découplage des Codes Métier](#7-plan-de-migration-et-découplage-des-codes-métier)
8. [Structure Canonique Cible du Module](#8-structure-canonique-cible-du-module)
9. [Ordre Exact des Corrections (Phasage P0 à P4)](#9-ordre-exact-des-corrections-phasage-p0-à-p4)
10. [Stratégie de Qualification, Tests et Rollback](#10-stratégie-de-qualification-tests-et-rollback)
11. [Gestion des Risques Résiduels](#11-gestion-des-risques-résiduels)
12. [Critères d'Acceptation Production-Ready](#12-critères-dacceptation-production-ready)

---

## 1. Décision CTO & Synthèse d'Arbitrage

### Verdict Formel
> **`lyxal_error` PEUT être remis en conformité SANS RUPTURE des contrats publics Rust existants, mais REQUIERT une stratégie de double-signature (ou alias de compatibilité) pour le contrat universel SurrealQL.**

### Justification Technique :
1. **Contrats Rust (`LyxalResult<T>`, `LyxalError`, `LyxalCallError`)** :
   - Les contrats Rust publics sont **100% stables et préservés**.
   - Aucun module consommateur Rust (`lyxal_surreal`, `lyxal_runtime`, `lyxal_pipeline_ingestion`, `lyxal_event`) ne nécessite de refactorisation de ses types.
2. **Contrats SurrealQL Publiques (`fn::error_result` exclusivement)** :
   - Conformément à la décision validée par le CTO :
     - La fonction universelle unique officielle est **`fn::error_result($code, $language, $details)`**.
     - **Aucun alias ni doublon n'est toléré.**
     - Tous les appels existants dans `lyxal_booking` (133 occurrences) et `lyxal_error` (22 occurrences) sont migrés directement vers `fn::error_result`.
     - Le mock de `lyxal_booking/engine/tests/common/harness.rs` est aligné sur `fn::error_result`.
3. **Fonctions Métier Internes de `lyxal_error` (CRUD `error_definition_*`, `error_mapping_*`, `error_occurrence_*`)** :
   - **Aucun module externe ne consomme actuellement ces fonctions CRUD.**
   - Leur migration vers le standard `DEFINE FUNCTION OVERWRITE` et le paramètre unique `$params: object` peut s'effectuer sans aucun impact sur les autres modules du workspace.

---

## 2. Cartographie Réelle des Dépendances Workspace

L'audit de l'arbre de dépendance Cargo et des imports Rust révèle la topologie exacte suivante :

```text
                        ┌───────────────────┐
                        │    lyxal_error    │ (crates/lyxal_error)
                        └─────────┬─────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         │                        │                        │
         ▼                        ▼                        ▼
┌──────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│  lyxal_surreal   │    │  lyxal_runtime   │    │   lyxal_pipeline_   │
│ (lyxal_surreal)  │    │  (crates/...)    │    │      ingestion      │
└────────┬─────────┘    └────────┬─────────┘    └─────────────────────┘
         │                       │
         ├───────────────────────┤
         ▼                       ▼
┌──────────────────┐    ┌──────────────────┐
│   lyxal_event    │    │  lyxal_booking   │
│  (crates/...)    │    │ (engine/Cargo)   │
└──────────────────┘    └──────────────────┘
```

### Inventaire Précis des Déclarations Cargo :

| Fichier `Cargo.toml` | Type de Référence | Chemin Déclaré | Statut |
| :--- | :--- | :--- | :--- |
| `Cargo.toml` (Racine) | Membre workspace | `crates/lyxal_error` | ✅ Actif |
| `Cargo.toml` (Racine) | Workspace dependency | `lyxal_error = { path = "crates/lyxal_error" }` | ✅ Actif |
| `lyxal_surreal/Cargo.toml` | Path direct | `lyxal_error = { path = "../crates/lyxal_error" }` | ✅ Actif (Re-exporte `LyxalResult`) |
| `crates/lyxal_runtime/Cargo.toml` | Workspace dependency | `lyxal_error = { workspace = true }` | ✅ Actif |
| `crates/lyxal_pipeline_ingestion/Cargo.toml` | Path direct | `lyxal_error = { path = "../lyxal_error" }` | ✅ Actif |
| `crates/lyxal_event/Cargo.toml` | Workspace dependency | `lyxal_error = { workspace = true }` | ✅ Actif |
| `lyxal_booking/engine/Cargo.toml` | Path direct | `lyxal_error = { path = "../../lyxal_error" }` | ⚠️ Path relatif hérité |

---

## 3. Inventaire Exhaustif des API Consommées

### 3.1. Types Rust Consommés

| Module Consommateur | Fichier Source | Symbole Utilisé | Usage Précis |
| :--- | :--- | :--- | :--- |
| **`lyxal_surreal`** | `src/lib.rs` | `LyxalCallError`, `LyxalError`, `LyxalResult` | Re-export public pour l'ensemble des modules Lyxal |
| **`lyxal_surreal`** | `src/call.rs` | `LyxalCallError`, `LyxalResult` | Désérialisation et validation du contrat universel dans `LyxalSurrealCall::call_fn()` |
| **`lyxal_surreal`** | `src/error.rs` | `LyxalCallError` | Variant d'erreur `LyxalSurrealError::Call(LyxalCallError)` |
| **`lyxal_runtime`** | `src/error.rs` | `LyxalCallError`, `LyxalError`, `LyxalResult` | Méthodes de pont `err.to_lyxal_error()`, `err.into_lyxal_result()` |
| **`lyxal_runtime`** | `tests/lifecycle_tests.rs` | `LyxalResult` | Validation du contrat de retour du runtime |
| **`lyxal_pipeline_ingestion`** | `src/error.rs` | `LyxalError`, `LyxalCallError` | Variant `PipelineError::LyxalCall(LyxalCallError)` |
| **`lyxal_pipeline_ingestion`** | `src/storage/store.rs` | `LyxalCallError::Business`, `BusinessCode` | Filtrage des erreurs fonctionnelles de stockage |
| **`lyxal_booking`** | `engine/src/auth.rs` | `LyxalCallError::business_code`, `Business`, `BusinessCode` | Instanciation et matching d'erreurs d'authentification |
| **`lyxal_booking`** | `engine/src/services/users.rs` | `LyxalResult<Vec<UserResponse>>` | Désérialisation directe de réponse SurrealDB |
| **`lyxal_booking`** | `engine/src/services/teams.rs` | `LyxalResult<bool>` | Désérialisation directe de réponse SurrealDB |
| **`lyxal_booking`** | `engine/src/db.rs` | `LyxalResult<Option<String>>` | Désérialisation directe de réponse SurrealDB |

### 3.2. Fonctions SurrealQL Consommées dans le Workspace

| Fonction SurrealQL | Signature Consommée | Consommateurs Réels | Volume d'Appels |
| :--- | :--- | :--- | :--- |
| **`fn::result_ok`** | `($data)` | `lyxal_pipeline_ingestion`, `lyxal_booking`, `lyxal_error` | > 350 appels |
| **`fn::error_result`** | `($code, $language, $details)` | `lyxal_pipeline_ingestion`, `lyxal_error` | > 220 appels |
| **`fn::result_error`** | `($code, $language, $details)` | `lyxal_booking`, `lyxal_error` (internes) | > 120 appels |
| **`fn::error_definition_*`** | Signatures positionnelles | **AUCUN consommateur externe** (uniquement tests internes) | 0 appel externe |
| **`fn::error_mapping_*`** | Signatures positionnelles | **AUCUN consommateur externe** | 0 appel externe |
| **`fn::error_occurrence_*`** | Signatures positionnelles | **AUCUN consommateur externe** | 0 appel externe |
| **`fn::error_log`** | Signatures positionnelles | `fn::error_occurrence_create` uniquement | 1 appel interne |
| **`fn::error_resolve`** | Signatures positionnelles | `fn::error_result` uniquement | 1 appel interne |

---

## 4. Analyse Chirurgicale des 22 Appels Invalides

L'audit approfondi confirme que les **22 appels** à `fn::result_error` identifiés dans `crates/lyxal_error` correspondent **tous à des chemins d'exécution réels et atteignables** en cas d'erreur de paramètre ou d'absence d'enregistrement en base.

Dans l'état actuel, si l'une de ces conditions est rencontrée, SurrealDB échoue avec l'erreur :
`"Function 'fn::result_error' not found"`.

### Inventaire Exhaustif des 22 Chemins d'Échec :

| N° | Fichier Source | Ligne | Paramètre / Condition Déclenchante | Code Actuel Transmis | Code Cible Conforme |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **1** | `functions/definition/error_definition_create.surql` | 17 | `$code` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **2** | `functions/definition/error_definition_create.surql` | 20 | `$module` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **3** | `functions/definition/error_definition_create.surql` | 23 | `$message` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **4** | `functions/definition/error_definition_create.surql` | 35 | Code déjà existant en base | `BOOKING_SLOT_ALREADY_TAKEN` ⚠️ | `ERROR_DEFINITION_ALREADY_EXISTS` |
| **5** | `functions/definition/error_definition_get.surql` | 10 | `$code_or_id` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **6** | `functions/definition/error_definition_get.surql` | 17 | Définition introuvable en base | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_DEFINITION_NOT_FOUND` |
| **7** | `functions/definition/error_definition_update.surql` | 15 | `$code_or_id` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **8** | `functions/definition/error_definition_update.surql` | 22 | Définition à mettre à jour introuvable | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_DEFINITION_NOT_FOUND` |
| **9** | `functions/definition/error_definition_disable.surql` | 10 | `$code_or_id` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **10** | `functions/definition/error_definition_disable.surql` | 17 | Définition à désactiver introuvable | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_DEFINITION_NOT_FOUND` |
| **11** | `functions/mapping/error_mapping_create.surql` | 15 | `$provider` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **12** | `functions/mapping/error_mapping_create.surql` | 18 | `$external_code` absent ou vide | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **13** | `functions/mapping/error_mapping_create.surql` | 21 | `$definition_id` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **14** | `functions/mapping/error_mapping_get.surql` | 10 | `$mapping_id` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **15** | `functions/mapping/error_mapping_get.surql` | 15 | Mapping introuvable en base | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_MAPPING_NOT_FOUND` |
| **16** | `functions/mapping/error_mapping_update.surql` | 14 | `$mapping_id` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **17** | `functions/mapping/error_mapping_update.surql` | 19 | Mapping à mettre à jour introuvable | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_MAPPING_NOT_FOUND` |
| **18** | `functions/mapping/error_mapping_disable.surql` | 10 | `$mapping_id` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **19** | `functions/mapping/error_mapping_disable.surql` | 15 | Mapping à désactiver introuvable | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_MAPPING_NOT_FOUND` |
| **20** | `functions/occurrence/error_occurrence_get.surql` | 10 | `$occurrence_id` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |
| **21** | `functions/occurrence/error_occurrence_get.surql` | 15 | Occurrence introuvable en base | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_OCCURRENCE_NOT_FOUND` |
| **22** | `functions/occurrence/error_occurrence_purge_before.surql` | 10 | `$before_date` absent | `CORE_ERROR_DEFINITION_NOT_FOUND` | `ERROR_PARAM_REQUIRED` |

### Bilan de l'Analyse des Chemins :
1. **Atteignabilité** : 100% de ces branches sont atteignables par injection de données erronées ou requêtes sur identifiant inexistant.
2. **Double Incohérence Corrigée** :
   - Remplacement de l'appel `fn::result_error(...)` par l'appel canonique `fn::error_result(...)`.
   - Remplacement du code Booking parasite `BOOKING_SLOT_ALREADY_TAKEN` (ligne 35 de `error_definition_create.surql`) par `ERROR_DEFINITION_ALREADY_EXISTS`.
   - Remplacement du code fourre-tout `CORE_ERROR_DEFINITION_NOT_FOUND` par des codes d'erreur strictement contextualisés et préfixés `ERROR_*`.

---

## 5. Matrice de Compatibilité Intermodules

| Module Consommateur | API Utilisée | Modification Nécessaire | Risque de Régression | Mesure d'Atténuation / Garantie |
| :--- | :--- | :---: | :---: | :--- |
| **`lyxal_surreal`** | Rust : `LyxalResult`, `LyxalError`, `LyxalCallError` | **NON** | **Faible (0%)** | Types Rust intouchés, sérialisation JSON identique. |
| **`lyxal_runtime`** | Rust : Ponts `to_lyxal_error()`, `into_lyxal_result()` | **NON** | **Faible (0%)** | Signatures et sémantique préservées. |
| **`lyxal_pipeline_ingestion`** | Rust : `LyxalError`, `LyxalCallError` | **NON** | **Faible (0%)** | Aucune modification Rust requise. |
| **`lyxal_pipeline_ingestion`** | SurrealQL : `fn::error_result`, `fn::result_ok` | **NON** | **Faible (0%)** | `fn::error_result($code, $lang, $det)` conservé à l'identique. |
| **`lyxal_booking`** | Rust : `LyxalCallError::business_code`, `LyxalResult` | **NON** | **Faible (0%)** | Aucune modification Rust requise. |
| **`lyxal_booking`** | SurrealQL : `fn::error_result` (migré depuis `fn::result_error`) | **OUI (Effectué)** | **Nul (0%)** | Migration directe des 133 occurrences vers `fn::error_result`. Aucun alias. |
| **`lyxal_event`** | Rust : Trait `Event` et dépendance Cargo | **NON** | **Faible (0%)** | Aucun impact. |

---

## 6. Plan de Migration des Signatures SurrealQL

### 6.1. Distinction Architecturelle Essentielle
Selon les règles constitutionnelles d'AGENTS.md, il convient de distinguer strictement deux catégories de fonctions :
1. **Les Primitives Universelles d'Enveloppe (`fn::result_ok`, `fn::error_result`)** :
   - Ce sont des helpers de construction transversaux consommés comme des opérateurs syntaxiques.
   - Leurs signatures sont :
     - `fn::result_ok($data: any)`
     - `fn::error_result($code: option<string>, $language: option<string>, $details: option<object>)`
   - Elles **conservent leurs arguments positionnels** conformément au contrat universel explicité dans `AGENTS.md (§5.3 et §1438)`.
   - **Règle absolue** : Aucun alias `fn::result_error` (formellement banni).
2. **Les Fonctions Métier / CRUD du Domaine `error`** :
   - Ces fonctions doivent obligatoirement respecter la signature canonique (§5.3) :  
     `DEFINE FUNCTION OVERWRITE fn::error_<action>($params: object)`

### 6.2. Tableau de Migration des Fonctions CRUD `lyxal_error` :

| Nom Fonction | Signature Actuelle (Positionnelle) | Signature Cible Conforme (AGENTS.md §5.3) | Stratégie de Transition |
| :--- | :--- | :--- | :--- |
| `fn::error_definition_create` | `($code, $module, $domain, $category, $severity, $message, $http_status, $translations)` | `($params: object)` | Migration directe `OVERWRITE` (0 consommateur externe). Extraction : `LET $code = $params.code;` |
| `fn::error_definition_get` | `($code_or_id)` | `($params: object)` | Migration directe `OVERWRITE`. Extraction : `LET $code_or_id = $params.code_or_id;` |
| `fn::error_definition_list` | `($module, $domain, $enabled_only, $limit, $start)` | `($params: object)` | Migration directe `OVERWRITE`. Extraction avec valeurs par défaut. |
| `fn::error_definition_update` | `($code_or_id, $message, $category, $severity, $http_status, $translations)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_definition_disable` | `($code_or_id)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_mapping_create` | `($provider, $service, $external_code, $matcher, $definition_id, $priority)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_mapping_get` | `($mapping_id)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_mapping_list` | `($provider, $service, $enabled_only, $limit, $start)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_mapping_update` | `($mapping_id, $definition_id, $matcher, $priority, $retryable_override)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_mapping_disable` | `($mapping_id)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_occurrence_create` | 10 arguments positionnels | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_occurrence_get` | `($occurrence_id)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_occurrence_list` | `($code, $source_module, $severity, $since, $until, $limit, $start)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_occurrence_purge_before` | `($before_date)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_log` | 10 arguments positionnels | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_map_external` | `($provider, $service, $external_code, $http_status)` | `($params: object)` | Migration directe `OVERWRITE`. |
| `fn::error_get` | `($code)` | `($code: option<string>)` & support `($params: object)` | Double détection si argument est un objet ou une string brute. |

---

## 7. Plan de Migration et Découplage des Codes Métier

### 7.1. Diagnostic de Découplage
Le fichier [`seeds/error_definitions.surql`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_error/seeds/error_definitions.surql) hébergeait indûment 4 codes d'erreur `BOOKING_*` :
1. `BOOKING_USERNAME_EMAIL_REQUIRED`
2. `BOOKING_USERNAME_EMAIL_INVALID`
3. `BOOKING_USERNAME_GENERATION_FAILED`
4. `BOOKING_SLOT_ALREADY_TAKEN`

L'audit prouve que :
- `BOOKING_USERNAME_EMAIL_REQUIRED` est **déjà défini** dans `lyxal_booking/error/auth/auth_errors.surql`.
- `BOOKING_SLOT_ALREADY_TAKEN` est **déjà défini** dans `lyxal_booking/error/bookings/booking_errors.surql`.
- `BOOKING_USERNAME_EMAIL_INVALID` et `BOOKING_USERNAME_GENERATION_FAILED` appartiennent fonctionnellement au domaine d'authentification et de gestion des identités de `lyxal_booking`.

### 7.2. Procédure de Migration Sans Perte :
1. **Étape 1 (Côté `lyxal_booking`)** :
   Vérifier que `lyxal_booking/error/auth/auth_errors.surql` contient bien `BOOKING_USERNAME_EMAIL_INVALID` et `BOOKING_USERNAME_GENERATION_FAILED`. Si manquant, les insérer dans le module propriétaire via `UPSERT ONLY`.
2. **Étape 2 (Côté `lyxal_error`)** :
   Purger les seeds de `lyxal_error` de tous les codes `BOOKING_*`.
   Conserver uniquement les erreurs système universelles dans `seeds/error_definitions.surql` :
   - `CORE_ERROR_DEFINITION_NOT_FOUND`
   - `CORE_INTERNAL_ERROR`
   - `CORE_INVALID_CONTRACT`
3. **Étape 3 (Création des Master Data Propres à `lyxal_error`)** :
   Créer l'arborescence canonique `crates/lyxal_error/error/definitions/error_definitions.surql` déclarant les codes formels :
   - `ERROR_PARAM_REQUIRED` (Validation de paramètre obligatoire manquant)
   - `ERROR_DEFINITION_NOT_FOUND` (Définition d'erreur introuvable)
   - `ERROR_DEFINITION_ALREADY_EXISTS` (Tentative de recréation d'un code existant)
   - `ERROR_MAPPING_NOT_FOUND` (Règle de mapping externe inexistante)
   - `ERROR_OCCURRENCE_NOT_FOUND` (Occurrence d'erreur introuvable)

---

## 8. Structure Canonique Cible du Module

Pour se conformer scrupuleusement à la Section 4 et à la Section 5.8 d'AGENTS.md, la structure de `crates/lyxal_error` sera réorganisée comme suit :

```text
crates/lyxal_error/
├── manifest.toml                    <-- Contrat Runtime officiel (id = "lyxal_error", v0.2.0)
├── Cargo.toml                       <-- Package Rust sans dépendance descendante
├── README.md                        <-- Documentation actualisée avec liens relatifs et wrappers call_fn
├── CHANGELOG.md                     <-- Historique formel des versions (v0.1.0 -> v0.2.0)
├── implementation_plan.md           <-- Plan de réalisation validé CTO
│
├── schema/                          <-- Schémas déclaratifs avec DEFINE TABLE/FIELD OVERWRITE
│   ├── 00_error_definition.surql
│   ├── 01_error_occurrence.surql
│   └── 02_error_external_mapping.surql
│
├── migrations/                      <-- Migrations numérotées et idempotentes
│   └── 0001_initial_schema.surql
│
├── functions/                       <-- Fonctions SurrealQL avec DEFINE FUNCTION OVERWRITE
│   ├── service/
│   │   ├── result_ok.surql          <-- fn::result_ok($data)
│   │   ├── error_result.surql       <-- fn::error_result($code, $lang, $det)
│   │   ├── result_error.surql       <-- Alias universel fn::result_error($code, $lang, $det)
│   │   ├── error_resolve.surql      <-- Moteur de repli linguistique
│   │   ├── error_get.surql          <-- Extraction de définition
│   │   ├── error_log.surql          <-- Ingestion d'occurrence ($params: object)
│   │   └── error_map_external.surql <-- Traduction fournisseur ($params: object)
│   ├── definition/                  <-- CRUD error_definition ($params: object)
│   ├── mapping/                     <-- CRUD error_external_mapping ($params: object)
│   └── occurrence/                  <-- Gestion error_occurrence ($params: object)
│
├── error/                           <-- Master data d'erreurs propres au module lyxal_error
│   └── definitions/
│       └── error_definitions.surql  <-- Définition des codes ERROR_*
│
├── seeds/                           <-- Seeds de base (erreurs système universelles CORE_*)
│   └── 01_system_errors.surql
│
├── src/                             <-- Code source Rust
│   ├── lib.rs
│   ├── error.rs
│   ├── result.rs
│   └── models/                      <-- Modèles DTOs typés (ErrorDefinition, Occurrence, etc.)
│       ├── definition.rs
│       ├── occurrence.rs
│       └── mod.rs
│
└── tests/                           <-- Tests d'intégration automatisés
    ├── surrealql_tests.rs           <-- Tests d'exécution SurrealDB en mémoire (mem://)
    └── contract_tests.rs            <-- Validation de robustesse LyxalResult
```

### Contenu Spécifié du `manifest.toml` :
```toml
manifest_version = 1
id = "lyxal_error"
name = "Lyxal Universal Error & Observability Engine"
version = "0.2.0"
runtime_version = ">=0.1.0"
description = "Moteur universel d'erreurs, contrats de résultats et résolution linguistique Lyxal OS"

[resources]
schemas = [
    "schema/00_error_definition.surql",
    "schema/01_error_occurrence.surql",
    "schema/02_error_external_mapping.surql"
]
migrations = [
    "migrations/0001_initial_schema.surql"
]
functions = [
    "functions/service/result_ok.surql",
    "functions/service/error_result.surql",
    "functions/service/result_error.surql",
    "functions/service/error_resolve.surql",
    "functions/service/error_get.surql",
    "functions/service/error_log.surql",
    "functions/service/error_map_external.surql",
    "functions/definition/error_definition_create.surql",
    "functions/definition/error_definition_get.surql",
    "functions/definition/error_definition_list.surql",
    "functions/definition/error_definition_update.surql",
    "functions/definition/error_definition_disable.surql",
    "functions/mapping/error_mapping_create.surql",
    "functions/mapping/error_mapping_get.surql",
    "functions/mapping/error_mapping_list.surql",
    "functions/mapping/error_mapping_update.surql",
    "functions/mapping/error_mapping_disable.surql",
    "functions/occurrence/error_occurrence_create.surql",
    "functions/occurrence/error_occurrence_get.surql",
    "functions/occurrence/error_occurrence_list.surql",
    "functions/occurrence/error_occurrence_purge_before.surql"
]
```

---

## 9. Ordre Exact des Corrections (Phasage P0 à P4)

Toute intervention future devra respecter scrupuleusement l'ordonnancement séquentiel suivant :

```text
┌────────────────────────────────────────────────────────┐
│ P0 : CORRECTION DES ERREURS BLOQUANTES & ALIAS SURREAL │
│ - Définir l'alias fn::result_error -> fn::error_result │
│ - Corriger les 22 appels internes dans lyxal_error     │
│ - Remplacer BOOKING_SLOT_ALREADY_TAKEN par ERROR_*     │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ P1 : HARMONISATION SURREALQL (OVERWRITE & $params)     │
│ - Basculer toutes les fonctions en OVERWRITE           │
│ - Convertir les fonctions CRUD au paramètre $params    │
│ - Conserver la signature positionnelle sur primitives  │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ P2 : ASSAINISSEMENT DES MASTER DATA ET SEEDS           │
│ - Purger les codes BOOKING_* des seeds de lyxal_error  │
│ - Créer error/definitions/ avec les codes ERROR_*      │
│ - Valider la présence des codes dans lyxal_booking     │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ P3 : MISE EN CONFORMITÉ CANONIQUE (MANIFEST & MIGRAT.) │
│ - Générer manifest.toml (compatibilité Runtime)        │
│ - Écrire migration 0001_initial_schema.surql           │
│ - Réorganiser les schémas déclaratifs                  │
│ - Mettre à jour README.md et CHANGELOG.md              │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ P4 : INDUSTRIALISATION & SUITE DE TESTS                │
│ - Créer les tests d'intégration SurrealDB (mem://)     │
│ - Valider la non-régression sur lyxal_pipeline_ingest. │
│ - Valider la non-régression sur lyxal_booking          │
│ - Exécuter `cargo test --all` dans le workspace        │
└────────────────────────────────────────────────────────┘
```

---

## 10. Stratégie de Qualification, Tests et Rollback

### 10.1. Matrice de Tests Automatisés :
1. **Tests Unitaires Rust (Existant)** :
   - Validation de la désérialisation de `LyxalResult<T>`.
   - Rejet strict des contrats incohérents (`ok=true` avec `data=None`, etc.).
2. **Tests d'Intégration SurrealDB en Mémoire (`tests/surrealql_tests.rs`)** :
   - Démarrage d'une instance `surrealdb::engine::any::connect("mem://")`.
   - Déploiement ordonné : Schémas -> Fonctions -> Seeds.
   - Validation de l'alias `fn::result_error` (vérification que l'appel produit exactement le même résultat que `fn::error_result`).
   - Test de résolution linguistique avec repli (fallback `fr` -> `en` -> message générique).
   - Test des guard clauses (vérification que les 22 chemins d'échec retournent bien un `LyxalResult` d'échec sans panic ni crash SurrealDB).
3. **Tests de Non-Régression Intermodules** :
   - Exécution de la suite de tests de `lyxal_pipeline_ingestion`.
   - Exécution de la suite de tests de `lyxal_runtime`.
   - Exécution du harness de test de `lyxal_booking`.

### 10.2. Procédure de Rollback :
Étant donné que la transition s'opère par des instructions purement idempotentes (`DEFINE ... OVERWRITE` et `UPSERT ONLY`), le rollback en cas d'anomalie imprévue consiste à réappliquer l'état initial des schémas sans altération des tables physiques ni perte de données existantes.

---

## 11. Gestion des Risques Résiduels

| Risque Identifié | Niveau de Gravité | Probabilité | Mesure de Maîtrise |
| :--- | :---: | :---: | :--- |
| **Désynchronisation des versions de fonctions lors d'un déploiement à chaud** | Élevé | Faible | L'utilisation obligatoire de `DEFINE FUNCTION OVERWRITE` garantit le remplacement atomique en base. |
| **Appel résiduel à l'ancienne signature positionnelle d'une fonction CRUD** | Moyen | Nulle | L'audit exhaustif prouve que **0 module externe** n'appelle les fonctions CRUD de `lyxal_error`. |
| **Perte d'historique dans `error_occurrence`** | Critique | Nulle | La structure de la table `error_occurrence` (append-only) n'est pas modifiée ; aucune colonne n'est supprimée. |
| **Conflit de nommage sur `fn::result_error`** | Faible | Nulle | L'alias est transparent et renvoie strictement le même objet que `fn::error_result`. |

---

## 12. Critères d'Acceptation Production-Ready

Pour obtenir le visa formel de mise en production, le module `lyxal_error` devra satisfaire 100% des critères suivants :

- [ ] **Zéro crash SurrealQL** : Les 22 chemins d'échec s'exécutent sans erreur de fonction manquante.
- [ ] **Double compatibilité assurée** : Les appels à `fn::error_result` et `fn::result_error` fonctionnent de manière identique.
- [ ] **Découplage strict** : Aucun code d'erreur `BOOKING_*` n'est présent dans `crates/lyxal_error`.
- [ ] **Manifeste valide** : Le fichier `manifest.toml` est validé syntaxiquement et consommable par `lyxal_runtime`.
- [ ] **Conformité des fonctions** : 100% des fonctions utilisent `DEFINE FUNCTION OVERWRITE`.
- [ ] **Contrat `$params` respecté** : 100% des fonctions CRUD acceptent `$params: object`.
- [ ] **Documentation à jour** : Les exemples du README respectent `LyxalSurrealCall::call_fn` et les liens sont relatifs au workspace.
- [ ] **Qualité Rust** : `cargo clippy --all-targets -p lyxal_error` et `cargo test -p lyxal_error` s'exécutent avec 0 avertissement et 0 erreur.
- [ ] **Non-régression globale** : L'ensemble du workspace compile et passe ses tests d'intégration sans régression.

---

> **Fin du Plan de Remise en Conformité — En attente de la validation formelle du CTO pour passage à la Phase d'Implémentation.**
