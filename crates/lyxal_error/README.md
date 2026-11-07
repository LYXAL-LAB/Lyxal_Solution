# Module `lyxal_error` — Erreurs canoniques et contrat de résultat Lyxal OS

`lyxal_error` porte le contrat de retour universel `{ ok, data, error }`, le référentiel des
erreurs canoniques (avec traductions), la conversion des erreurs de fournisseurs externes et le
journal des occurrences. Il ne contient aucune logique métier d'un autre module.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3. Dépend de `lyxal_core` (validation des entrées).


Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Contrat de résultat

Toute fonction publique d'un module Lyxal renvoie `{ ok, data, error }` :

* succès : `fn::result_ok($data)` → `{ ok: true, data: $data, error: NONE }` ;
* échec : `fn::error_result($code, $language, $details)` → `{ ok: false, data: NONE, error: {…} }`.

```json
{
  "ok": false,
  "data": null,
  "error": {
    "code": "ERROR_INVALID_INPUT",
    "message": "One or more input parameters are missing or invalid",
    "label": "Paramètres invalides",
    "category": "validation",
    "severity": "error",
    "http_status": 400,
    "retryable": false,
    "details": { "fields": { "code": ["…"] } }
  }
}
```

`fn::error_result` est la seule fonction d'échec ; `fn::result_error` est interdite.

---

## 2. Tables (`schema/`)

| Table | Rôle |
| :--- | :--- |
| `error_definition` | Erreurs canoniques : code (`<MODULE>_…`, identifiant `error_definition:<CODE>`), module, catégorie, sévérité, statut HTTP, traductions. Désactivation logique (`enabled = false`). |
| `error_external_mapping` | Correspondances d'erreurs de fournisseurs externes vers une définition. `matcher` : `exact`, `prefix`, `contains` ou `http_status` ; parcours par `priority` croissante. |
| `error_occurrence` | Journal des erreurs survenues, purgeable par date. |

---

## 3. Fonctions SurrealQL (`functions/`)

Fonctions positionnelles (appelées au cœur des expressions de toute la suite) :

* `fn::result_ok($data)`
* `fn::error_result($code, $language, $details)`
* `fn::error_resolve($code, $language, $details)` : résout le libellé traduit d'un code (repli sur la langue par défaut, puis sur une erreur interne générique pour un code inconnu).

Toutes les autres prennent un objet unique `$params: object`. Les entrées sont validées par
`fn::validation_object_execute` de `lyxal_core` ; tout champ inconnu, absent ou invalide renvoie
`ERROR_INVALID_INPUT` avec le rapport par champ dans `details.fields`. `language` (défaut `fr`)
est accepté partout.

| Fonction | Paramètres (requis en gras) | Donnée renvoyée |
| :--- | :--- | :--- |
| `fn::error_definition_create` | **code**, **module**, **message**, domain, category, severity, http_status, translations, default_language, retryable, log_occurrence, documentation, metadata, enabled | définition |
| `fn::error_definition_get` | **code** | définition |
| `fn::error_definition_list` | module, domain, category, severity, enabled_only (défaut `true`), limit (1 à 500, défaut 50), start | liste |
| `fn::error_definition_update` | **code**, puis les champs à modifier (seuls les champs fournis changent) | définition |
| `fn::error_definition_disable` | **code** | `{ id, disabled }` |
| `fn::error_mapping_create` | **provider**, **external_code**, **definition_code**, service, matcher (défaut `exact`), priority, external_http_status, description, retryable_override, metadata | correspondance |
| `fn::error_mapping_get` | **mapping_id** (`record<error_external_mapping>`) | correspondance |
| `fn::error_mapping_list` | provider, service, enabled_only, limit, start | liste |
| `fn::error_mapping_update` | **mapping_id**, puis les champs à modifier | correspondance |
| `fn::error_mapping_disable` | **mapping_id** | `{ id, disabled }` |
| `fn::error_map_external` | **provider**, **external_code**, service, http_status | `{ mapping, definition, definition_code, retryable_override }` ou `NONE` |
| `fn::error_log` | **code**, **source_module**, operation, source, actor (`record`), technical_message, context, request_id, trace_id, correlation_id, fingerprint, environment (défaut `production`), severity | `{ logged: true, occurrence }`, ou `{ logged: false, occurrence: NONE }` si la définition a `log_occurrence = false` |
| `fn::error_occurrence_get` | **occurrence_id** (`record<error_occurrence>`) | occurrence |
| `fn::error_occurrence_list` | code, source_module, limit, start | liste |
| `fn::error_occurrence_purge_before` | **before_date** (`datetime`) | `{ before, count }` |

Règles propres au module : le code d'une définition commence par `UPPER(module)_` ; une
correspondance référence une définition existante ; deux correspondances ne peuvent pas avoir le
même fournisseur, service, code externe et matcher.

Écritures vérifiées : une création, modification ou désactivation filtrée par les permissions
des tables (écriture réservée aux sessions d'administration) renvoie `ERROR_WRITE_FORBIDDEN`
(`details.table`) au lieu d'un succès. `fn::error_occurrence_purge_before` est refusée sous toute
identité (jeton ou utilisateur), pour qui le journal est invisible et non modifiable.

---

## 4. Codes d'erreur du module (`error/`)

| Code | Catégorie | HTTP | Cause |
| :--- | :--- | :--- | :--- |
| `ERROR_INVALID_INPUT` | `validation` | 400 | Paramètre absent, inconnu ou invalide (`details.fields`) |
| `ERROR_DEFINITION_CODE_PREFIX_MISMATCH` | `validation` | 400 | Le code ne commence pas par `UPPER(module)_` |
| `ERROR_DEFINITION_NOT_FOUND` | `not_found` | 404 | Définition inconnue |
| `ERROR_MAPPING_NOT_FOUND` | `not_found` | 404 | Correspondance inconnue |
| `ERROR_OCCURRENCE_NOT_FOUND` | `not_found` | 404 | Occurrence inconnue |
| `ERROR_DEFINITION_ALREADY_EXISTS` | `conflict` | 409 | Code déjà enregistré |
| `ERROR_MAPPING_ALREADY_EXISTS` | `conflict` | 409 | Correspondance identique déjà enregistrée |
| `ERROR_WRITE_FORBIDDEN` | `authorization` | 403 | Écriture refusée par les permissions de la table (`details.table`) |
| `ERROR_INVALID_FUNCTION_RESPONSE` | `internal` | 500 | Réponse d'une fonction hors contrat `{ ok, data, error }`, détectée côté Rust |

Chaque module porte ses propres définitions : les codes `CORE_*` sont dans `lyxal_core`.

---

## 5. Contrats Rust (`src/`)

* `LyxalResult<T>` : enveloppe `{ ok, data, error }`, lue via `SurrealValue` et renvoyée en JSON
  par l'API (`serde`). `.into_result(fonction)` donne `Result<T, LyxalCallError>` et rejette tout
  état incohérent.
* `LyxalError` : erreur métier résolue (code, libellés, catégorie, sévérité, statut HTTP, détails).
* `LyxalCallError` : `Business(LyxalError)` (erreur renvoyée par `fn::error_result`) ou
  `InvalidContract { function }` (réponse hors contrat ; avec la fonctionnalité `axum`, réponse
  HTTP 500 de code `ERROR_INVALID_FUNCTION_RESPONSE`). `is_business_code(code)` teste le code
  d'une erreur `Business`.
* Un `*Params` par fonction `fn::error_*` (`src/types.rs`), champ pour champ identique au
  SurrealQL ; les identifiants sont des `RecordId`, les dates des `Datetime`. Un champ `None` vaut
  « non fourni ».
* Types de résultat : `ErrorDefinition`, `ErrorMapping`, `ErrorOccurrence`, `ErrorExternalMatch`,
  `DisableResult`, `PurgeResult`.

Ce crate ne dépend ni de `lyxal_surreal` ni de `lyxal_runtime` : les modules appellent ces
fonctions par `lyxal_surreal::LyxalSurrealCall::call_fn("error_…", params)`.

---

## 6. Installation (`manifest.toml`)

Le manifeste déclare les 3 schémas, les fonctions et les définitions d'erreurs (rejouables sans
doublon grâce à `IF !record::exists(...)`). Pas de migration ni de seed de démonstration ; aucune
correspondance externe n'est installée par défaut, chaque module déclare les siennes.

---

## 7. Vérification

```bash
cargo test -p lyxal_error
```

Les tests d'intégration démarrent un serveur SurrealDB 3.3.4 (`LYXAL_SURREAL_BIN`, à défaut
`surreal` dans le `PATH`), installent `lyxal_core` puis `lyxal_error` depuis leurs manifestes et
appellent chaque fonction avec les types Rust du crate. Le banc SurrealQL
(`tests/*.test.surql`, `scripts/ci/test_lyxal_modules.py`) appelle chaque fonction publique et
vérifie les refus d'écriture sous identité simulée. `scripts/ci/ci_local.sh` rejoue la CI
complète.
