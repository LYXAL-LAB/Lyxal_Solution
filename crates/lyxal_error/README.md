# 🛡️ Module `lyxal_error` — Moteur Universel d'Erreurs & Contrats Lyxal OS

[![Status](https://img.shields.io/badge/Status-Production--Ready-success.svg)](#)
[![Charte](https://img.shields.io/badge/Conformit%C3%A9-AGENTS.md%20100%25-blue.svg)](#)
[![Tests](https://img.shields.io/badge/Tests-21%20passed%20%7C%200%20failed-brightgreen.svg)](#)
[![SurrealDB](https://img.shields.io/badge/SurrealDB-3.3.4%20Compatible-blue.svg)](#)

Le module **`lyxal_error`** constitue le référentiel centralisé, le moteur de résolution linguistique et le socle du contrat de résultat universel pour l'ensemble des modules de la suite **Lyxal OS** (`lyxal_surreal`, `lyxal_booking`, `lyxal_auth`, `lyxal_notification`, `lyxal_scheduler`, etc.).

Il est strictement découplé de tout domaine métier spécifique et ne contient que les définitions d'erreurs techniques fondamentales et propres à sa propre gestion.

---

## 🏛️ 1. Architecture & Contrat Universel

Toutes les opérations publiques de la plateforme Lyxal OS retournent le contrat immuable à **3 clés racines** `{ ok, data, error }` :

### Succès (`fn::result_ok($data)`)
```json
{
  "ok": true,
  "data": {
    "code": "CORE_SUCCESS",
    "details": "Action completed"
  },
  "error": null
}
```

### Échec (`fn::error_result($code, $language, $details)`)
```json
{
  "ok": false,
  "data": null,
  "error": {
    "code": "ERROR_PARAM_REQUIRED",
    "message": "A required parameter is missing or empty",
    "label": "Paramètre obligatoire manquant",
    "description": "Un paramètre obligatoire n'a pas été fourni ou est vide.",
    "resolution": "Vérifiez que tous les champs obligatoires sont renseignés.",
    "category": "validation",
    "severity": "error",
    "http_status": 400,
    "retryable": false,
    "details": { "field": "provider" }
  }
}
```

> [!IMPORTANT]
> **Règle absolue d'architecture** : La fonction d'échec universelle officielle est exclusivement `fn::error_result($code, $language, $details)`. La directive `fn::result_error` est **strictement interdite** sur l'ensemble de la plateforme Lyxal OS (aucun alias, aucun doublon).

---

## 📊 2. Schémas de Données (`schema/`)

Le module gère 3 tables déclaratives sous SurrealDB 3.3.4 :

| Table | Rôle | Stratégie d'évolution |
| :--- | :--- | :--- |
| **`error_definition`** | Catalogue canonique des codes d'erreur, métadonnées et dictionnaires multilingues | Désactivation logique (`enabled = false`) |
| **`error_external_mapping`** | Règles de correspondance des erreurs externes (fournisseurs HTTP/SaaS) vers codes Lyxal | Ordonnancement par priorité (`priority ASC`) |
| **`error_occurrence`** | Journal d'audit et observabilité des erreurs d'exécution | Ingestion immuable (*append-only*) & Purge par date d'antériorité |

---

## ⚙️ 3. Les 20 Fonctions SurrealQL (`functions/`)

Toutes les fonctions sont déclarées avec la syntaxe canonique `DEFINE FUNCTION OVERWRITE`. Les fonctions CRUD acceptent systématiquement un paramètre unique `$params: object`.

### 3.1. Services Transversaux (`functions/service/`)
- `fn::result_ok($data)` : Enveloppe de succès universelle `{ ok: true, data: $data, error: NONE }`.
- `fn::error_result($code, $language, $details)` : Enveloppe d'échec universelle `{ ok: false, data: NONE, error: ... }`.
- `fn::error_resolve($code, $language, $details)` : Moteur de résolution linguistique avec recherche et repli (FR/EN).
- `fn::error_get($params)` : Extraction unitaire de définition d'erreur (accepte code direct ou objet).
- `fn::error_log($params: object)` : Journalisation structurée sans masquage silencieux d'erreur.
- `fn::error_map_external($params: object)` : Résolution d'erreur externe avec correspondances exactes, préfixes ou codes HTTP.

### 3.2. Administration `error_definition` (`functions/definition/`)
- `fn::error_definition_create($params: object)` : Enregistrement d'une nouvelle définition d'erreur.
- `fn::error_definition_get($params: object)` : Récupération unitaire par code ou ID.
- `fn::error_definition_list($params: object)` : Recherche paginée avec filtres (module, catégorie, sévérité, statut).
- `fn::error_definition_update($params: object)` : Mise à jour incrémentale d'une définition existante.
- `fn::error_definition_disable($params: object)` : Désactivation logique (`enabled = false`).

### 3.3. Administration `error_external_mapping` (`functions/mapping/`)
- `fn::error_mapping_create($params: object)` : Enregistrement d'une correspondance fournisseur.
- `fn::error_mapping_get($params: object)` : Consultation unitaire d'un mapping.
- `fn::error_mapping_list($params: object)` : Liste filtrée des mappings par fournisseur.
- `fn::error_mapping_update($params: object)` : Mise à jour d'un mapping.
- `fn::error_mapping_disable($params: object)` : Désactivation logique d'un mapping.

### 3.4. Gestion `error_occurrence` (`functions/occurrence/`)
- `fn::error_occurrence_create($params: object)` : Enregistrement technique d'une occurrence.
- `fn::error_occurrence_get($params: object)` : Récupération détaillée d'une occurrence par identifiant.
- `fn::error_occurrence_list($params: object)` : Liste filtrée (code, module source, corrélation).
- `fn::error_occurrence_purge_before($params: object)` : Purge physique sécurisée des occurrences antérieures à une date.

---

## 🏷️ 4. Référentiel des Codes d'Erreur du Module (`error/`)

Le module fournit exclusivement son propre dictionnaire d'erreurs :

| Code d'Erreur | Catégorie | Sévérité | HTTP | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ERROR_PARAM_REQUIRED` | `validation` | `error` | 400 | Paramètre obligatoire manquant ou vide |
| `ERROR_DEFINITION_NOT_FOUND` | `business` | `warning` | 404 | Définition d'erreur demandée inexistante |
| `ERROR_DEFINITION_ALREADY_EXISTS` | `business` | `warning` | 409 | Définition d'erreur déjà enregistrée sous ce code |
| `ERROR_MAPPING_NOT_FOUND` | `business` | `warning` | 404 | Règle de correspondance d'erreur externe introuvable |
| `ERROR_OCCURRENCE_NOT_FOUND` | `business` | `warning` | 404 | Occurrence d'erreur demandée introuvable |

---

## 🦀 5. Contrats Rust Publics (`src/`)

Le crate expose les contrats fondamentaux de transport et de conversion de Lyxal OS :

```rust
use lyxal_error::{LyxalCallError, LyxalResult};
use surrealdb_types::SurrealValue;

// Consommation typée d'une fonction SurrealQL (en pratique via `lyxal_surreal::LyxalSurrealCall::call_fn`)
pub fn resolve_call<T: SurrealValue>(result: LyxalResult<T>) -> Result<T, LyxalCallError> {
    result.into_result("operation_name")
}
```

### Structures de Transport
* `LyxalResult<T: SurrealValue>` : Enveloppe générique `{ ok: bool, data: Option<T>, error: Option<LyxalError> }`, lue depuis SurrealDB (`SurrealValue`) et renvoyée en JSON par l'API (`serde`).
  - `.into_result(op)` : Convertit l'enveloppe en `Result<T, LyxalCallError>`. Rejette tout état incohérent (`ok: true` avec `error`, `ok: false` sans `error` ou avec `data`). Un succès sans donnée n'est accepté que si `T` accepte `NONE` (`()` ou `Option<_>`).
* `LyxalError` : Structure complète de l'erreur métier standardisée (code, libellés, catégorie, sévérité, statut HTTP, détails structurés).
* `LyxalCallError` : Enum de résultat côté consommateur Rust :
  - `LyxalCallError::Business(LyxalError)` : Erreur fonctionnelle retournée par SurrealQL (`fn::error_result`).
  - `LyxalCallError::BusinessCode { code, details }` : Erreur métier construite côté Rust à partir d'un code canonique.
  - `LyxalCallError::InvalidContract { function }` : Réponse ne respectant pas le contrat `LyxalResult`.
* Les `XxxParams` des fonctions `fn::error_*` dérivent `SurrealValue`.

---

## 🚀 6. Déploiement & Intégration Runtime

Le module s'intègre à `lyxal_runtime` par son fichier `manifest.toml`. Il déclare :

* ses 3 schémas (`schema/*.surql`), appliqués de manière idempotente par la phase schéma du runtime ;
* ses fonctions (`functions/**/*.surql`) ;
* ses définitions d'erreurs (`error/error_definitions.surql` et `error/core/core_definitions.surql`, codes `CORE_*` de `lyxal_core`), rejouables sans doublon (`IF !record::exists(...)`).

Régime pré-production (`.agents/AGENTS.md` §0) : le module n'a ni migration ni seed de démonstration. Aucun mapping externe n'est installé par défaut ; chaque module déclare les siens avec `fn::error_mapping_create`.

---

## 🧪 7. Validation & Qualification

Pour exécuter l'ensemble des validations qualité :

```bash
# Vérification des types
cargo check -p lyxal_error

# Analyse statique et linter
cargo clippy -p lyxal_error --all-targets

# Exécution intégrale de la suite de tests (Unitaires, Contrats, Manifeste, SurrealDB)
cargo test -p lyxal_error -- --nocapture
```
