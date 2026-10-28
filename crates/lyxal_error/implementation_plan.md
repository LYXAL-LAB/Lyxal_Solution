# 📋 Plan d'Implémentation & Remise en Conformité — `lyxal_error`

> **Module** : `crates/lyxal_error`  
> **Référence normative** : `.agents/AGENTS.md`  
> **Priorité** : P0 — Module fondamental de Lyxal OS  
> **Statut visé** : PRODUCTION-READY

---

## 1. Analyse Préalable & Alignement `lyxal_core`

Conformément à la règle 3.1 d'AGENTS.md :
* `lyxal_core` fournit les primitives transversales de validation et sanitization.
* `lyxal_error` est la fondation d'erreur et de contrat de résultat de LYXAL OS.
* Les primitives universelles `fn::result_ok($data)` et `fn::error_result($code, $language, $details)` constituent le socle immuable consommé par tous les modules.
* Dépendances Cargo : `lyxal_error` ne dépend d'aucun module supérieur (`lyxal_surreal`, `lyxal_runtime`, etc.).

---

## 2. Structure Canonique Cible du Module (`AGENTS.md` §4)

```text
crates/lyxal_error/
├── manifest.toml              <-- Contrat Runtime officiel lyxal_runtime (version, deps, schemas, functions, seeds)
├── schema/                    <-- Schémas déclaratifs SurrealDB (DEFINE TABLE/FIELD/INDEX OVERWRITE)
│   ├── error_definition.surql
│   ├── error_external_mapping.surql
│   └── error_occurrence.surql
├── migrations/                <-- Migrations versionnées
│   └── 0001_initial_schema.surql
├── functions/                 <-- Fonctions métier SurrealQL ($params: object ou signatures universelles)
│   ├── service/
│   │   ├── result_ok.surql
│   │   ├── error_result.surql
│   │   ├── error_resolve.surql
│   │   ├── error_get.surql
│   │   ├── error_log.surql
│   │   └── error_map_external.surql
│   ├── definition/
│   │   ├── error_definition_create.surql
│   │   ├── error_definition_get.surql
│   │   ├── error_definition_list.surql
│   │   ├── error_definition_update.surql
│   │   └── error_definition_disable.surql
│   ├── mapping/
│   │   ├── error_mapping_create.surql
│   │   ├── error_mapping_get.surql
│   │   ├── error_mapping_list.surql
│   │   ├── error_mapping_update.surql
│   │   └── error_mapping_disable.surql
│   └── occurrence/
│       ├── error_occurrence_create.surql
│       ├── error_occurrence_get.surql
│       ├── error_occurrence_list.surql
│       └── error_occurrence_purge_before.surql
├── error/                     <-- Master data d'erreurs propres au module lyxal_error
│   └── error_definitions.surql
├── seeds/                     <-- Données initiales et référentiel canonique
│   └── error_mappings.surql
├── src/                       <-- Code source Rust (LyxalResult, LyxalError, LyxalCallError, Types Params)
│   ├── lib.rs
│   ├── error.rs
│   ├── result.rs
│   └── types.rs
├── tests/                     <-- Tests d'intégration Rust et SurrealQL
│   ├── contracts_tests.rs
│   ├── manifest_tests.rs
│   └── surreal_integration_tests.rs
├── README.md                  <-- Documentation complète du module
├── CHANGELOG.md               <-- Historique des versions
└── implementation_plan.md     <-- Le présent plan
```

---

## 3. Normalisation SurrealQL & Signatures des Fonctions

### 3.1. Primitives Universelles (Signatures Conservées)
* `fn::result_ok($data)` -> Retourne `{ ok: true, data: $data, error: NONE }`
* `fn::error_result($code, $language, $details)` -> Construit le `{ ok: false, data: NONE, error: ... }` via `fn::error_resolve`
* `fn::error_resolve($code, $language, $details)` -> Résolution avec repli linguistique FR/EN

### 3.2. Fonctions de Service & Polymorphisme
* `fn::error_get($params)` -> Accepte soit un code `string` direct, soit un objet `$params: { code: string }`. Retourne `NONE` si non trouvé.
* `fn::error_log($params: object)` -> Journalisation structurée. Rejette les paramètres manquants avec `ERROR_PARAM_REQUIRED` sans retour `NONE` silencieux.
* `fn::error_map_external($params: object)` -> Résolution de mapping externe. Valide `$provider` et `$external_code`. Retourne `fn::result_ok(NONE)` si aucun mapping n'est configuré (absence normale).

### 3.3. Fonctions CRUD ($params: object & OVERWRITE)
Toutes les fonctions publiques CRUD adoptent la directive canonique `DEFINE FUNCTION OVERWRITE` et le paramètre unique `$params: object` :
1. `fn::error_definition_create($params: object)`
2. `fn::error_definition_get($params: object)`
3. `fn::error_definition_list($params: object)`
4. `fn::error_definition_update($params: object)`
5. `fn::error_definition_disable($params: object)`
6. `fn::error_mapping_create($params: object)`
7. `fn::error_mapping_get($params: object)`
8. `fn::error_mapping_list($params: object)`
9. `fn::error_mapping_update($params: object)`
10. `fn::error_mapping_disable($params: object)`
11. `fn::error_occurrence_create($params: object)`
12. `fn::error_occurrence_get($params: object)`
13. `fn::error_occurrence_list($params: object)`
14. `fn::error_occurrence_purge_before($params: object)`

---

## 4. Isolation Métier & Définitions d'Erreurs Propres

### 4.1. Suppression des Définitions Métier Externes
* Suppression définitive de tous les codes `BOOKING_*` de `seeds/error_definitions.surql` (aucun couplage avec les domaines applicatifs).

### 4.2. Codes Canoniques du Module `lyxal_error`
Les codes suivants sont formellement enregistrés avec métadonnées complètes, statuts HTTP et traductions FR/EN :
* `ERROR_PARAM_REQUIRED` (HTTP 400, validation) : Paramètre obligatoire absent ou vide.
* `ERROR_DEFINITION_NOT_FOUND` (HTTP 404, not_found) : Définition d'erreur introuvable dans le catalogue.
* `ERROR_DEFINITION_ALREADY_EXISTS` (HTTP 409, conflict) : Code d'erreur déjà défini.
* `ERROR_MAPPING_NOT_FOUND` (HTTP 404, not_found) : Règle de mapping externe inexistante.
* `ERROR_OCCURRENCE_NOT_FOUND` (HTTP 404, not_found) : Occurrence d'erreur introuvable.
* `CORE_ERROR_DEFINITION_NOT_FOUND` (HTTP 500, internal) : Code de repli système en cas d'erreur de résolution non référencée.

---

## 5. Intégration Runtime (`manifest.toml`)

Déclaration du contrat formel Runtime conforme à `lyxal_runtime` :
* Identifiant : `"lyxal_error"`
* Version : `"0.1.0"`
* Capabilités : `["database"]`
* Schémas : tables ordonnées
* Migrations : script idempotent initial `0001_initial_schema.surql`
* Fonctions : 20 fichiers de fonctions
* Seeds : master data d'erreurs canoniques

---

## 6. Plan de Test & Qualification

1. **Rust Tests** :
   * Contrats `LyxalResult<T>`, `LyxalError`, `LyxalCallError`.
   * Rejet des contrats invalides (`ok: true` avec `error`, `ok: false` avec `data`).
   * Sérialisation/Désérialisation JSON et intégration Axum (si feature activée).
   * Types de paramètres `XxxParams`.
2. **SurrealQL Tests (SurrealDB In-Memory)** :
   * Déploiement schémas + migrations + fonctions + seeds.
   * Création, consultation, mise à jour, désactivation d'une définition d'erreur.
   * Création et résolution de mapping externe (exact, prefix, contains, http_status).
   * Journalisation d'occurrence (`fn::error_log`) et purge (`fn::error_occurrence_purge_before`).
   * Résolution d'erreur avec repli linguistique (`fr`, `en`, fallback inconnu).
   * Vérification des rejets stricts de paramètres (`ERROR_PARAM_REQUIRED`).
3. **Idempotence des Migrations** :
   * Exécution multiple consécutive sans duplication ni erreur.
