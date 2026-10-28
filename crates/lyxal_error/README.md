# 🛡️ Module `lyxal_error` — Moteur Universel d'Erreurs & Contrats Lyxal OS

[![Status](https://img.shields.io/badge/Status-Production--Ready-success.svg)](#)
[![Charte](https://img.shields.io/badge/Conformit%C3%A9-AGENTS.md%20100%25-blue.svg)](#)
[![Tests](https://img.shields.io/badge/Tests-20%20passed%20%7C%200%20failed-brightgreen.svg)](#)
[![SurrealDB](https://img.shields.io/badge/SurrealDB-2.x%20Compatible-orange.svg)](#)

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

Le module gère 3 tables déclaratives sous SurrealDB 2.x :

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
| `CORE_ERROR_DEFINITION_NOT_FOUND` | `internal` | `error` | 500 | Définition d'erreur introuvable dans le référentiel |
| `ERROR_PARAM_REQUIRED` | `validation` | `error` | 400 | Paramètre obligatoire manquant ou vide |
| `ERROR_DEFINITION_NOT_FOUND` | `business` | `warning` | 404 | Définition d'erreur demandée inexistante |
| `ERROR_DEFINITION_ALREADY_EXISTS` | `business` | `warning` | 409 | Définition d'erreur déjà enregistrée sous ce code |
| `ERROR_MAPPING_NOT_FOUND` | `business` | `warning` | 404 | Règle de correspondance d'erreur externe introuvable |
| `ERROR_OCCURRENCE_NOT_FOUND` | `business` | `warning` | 404 | Occurrence d'erreur demandée introuvable |

---

## 🦀 5. Contrats Rust Publics (`src/`)

Le crate expose les contrats fondamentaux de transport et de conversion de Lyxal OS :

```rust
use lyxal_error::{LyxalResult, LyxalError, LyxalCallError};

// Consommation typée d'une fonction SurrealQL
pub async fn resolve_call<T: serde::de::DeserializeOwned>(
    result: LyxalResult<T>
) -> Result<T, LyxalCallError> {
    result.into_result("operation_name")
}
```

### Structures de Transport
* `LyxalResult<T>` : Enveloppe générique `{ ok: bool, data: Option<T>, error: Option<LyxalError> }`.
  - `.into_result(op)` : Convertit l'enveloppe en `Result<T, LyxalCallError>`. Valide l'intégrité (rejette `ok: true` avec `error` ou `ok: false` sans `error`).
* `LyxalError` : Structure complète de l'erreur métier standardisée (code, labels multilingues, statut HTTP, détails structurés).
* `LyxalCallError` : Enum unifié de résultat côté consommateur Rust :
  - `LyxalCallError::Business(LyxalError)` : Erreur fonctionnelle retournée par SurrealQL.
  - `LyxalCallError::Transport(String)` : Échec réseau, parsing ou transport RPC.
  - `LyxalCallError::Contract(String)` : Violation du contrat de données.

---

## 🚀 6. Déploiement & Intégration Runtime

Le module s'intègre nativement avec `lyxal_runtime` via son fichier `manifest.toml` :

```toml
manifest_version = 1
id = "lyxal_error"
name = "Lyxal Error Management"
version = "0.1.0"
runtime_version = ">=0.1.0"
description = "Moteur universel d'erreurs, contrats de résultat et observabilité pour Lyxal OS"

[resources]
schemas = [
    "schema/error_definition.surql",
    "schema/error_external_mapping.surql",
    "schema/error_occurrence.surql",
]
migrations = [
    "migrations/0001_initial_schema.surql",
]
functions = [ ... ]
seeds = [
    "error/error_definitions.surql",
    "seeds/error_mappings.surql",
]
```

### Idempotence des Migrations
Toute migration s'enregistre de manière atomique dans la table `schema_migration` :
```surql
LET $record = type::thing("schema_migration", ["lyxal_error", "0001_initial_schema"]);
CREATE ONLY $record CONTENT {
    module: "lyxal_error",
    name: "0001_initial_schema",
    status: "APPLIED"
};
```

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
