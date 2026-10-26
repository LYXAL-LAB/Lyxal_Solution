# 🛡️ Module `lyxal_error` — Moteur Universel d'Erreurs & d'Observabilité Lyxal OS

Le module **`lyxal_error`** constitue le référentiel centralisé, le moteur de résolution linguistique et le système d'observabilité des erreurs pour l'ensemble des modules de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_auth`, `lyxal_notification`, `lyxal_scheduler`).

---

## 🏛️ Architecture & Contrat Universel

Toutes les fonctions SurrealQL de l'écosystème Lyxal retournent un contrat JSON universel à **3 clés racines immuables** :

```json
{
  "ok": true,
  "data": { ... },
  "error": null
}
```

En cas d'échec métier ou technique :

```json
{
  "ok": false,
  "data": null,
  "error": {
    "code": "BOOKING_USERNAME_EMAIL_INVALID",
    "message": "The provided email address is invalid",
    "label": "L'adresse e-mail est invalide",
    "description": "L'adresse saisie ne respecte pas le format attendu.",
    "resolution": "Vérifiez l'adresse e-mail saisie.",
    "category": "validation",
    "severity": "error",
    "http_status": 422,
    "retryable": false,
    "details": { "field": "email" }
  }
}
```

---

## 📊 Tables Cœur (`schema/`)

| Table | Rôle | Stratégie |
| :--- | :--- | :--- |
| **`error_definition`** | Catalogue canonique des codes d'erreur master data et traductions | Désactivation logique (`enabled = false`) |
| **`error_occurrence`** | Journal technique des occurrences réelles | Ingestion immuable (*append-only*) & Purge par date |
| **`error_external_mapping`** | Règles de correspondance d'erreurs externes (Google, CalDAV, SMTP, Stripe) | Priorisation par ordre (`priority ASC`) |

---

## ⚙️ Les 20 Fonctions SurrealQL (`functions/`)

Les fonctions sont réparties dans 4 répertoires fonctionnels :

### 1. Services Publiques Consommés par les Modules (`functions/service/`)
- `fn::result_ok($data)` : Enveloppe de succès conforme au contrat universel.
- `fn::error_result($code, $lang, $details)` : Enveloppe d'échec conforme au contrat universel.
- `fn::error_resolve($code, $lang, $details)` : Moteur de résolution & traduction avec repli linguistique.
- `fn::error_get($code)` : Extraction brute de définition d'erreur.
- `fn::error_log(...)` : Journalisation d'occurrences immuables.
- `fn::error_map_external($provider, $service, $ext_code, $http_status)` : Traduction de codes externes (Google, CalDAV, SMTP).

### 2. Administration `error_definition` (`functions/definition/`)
- `fn::error_definition_create`, `get`, `list`, `update`, `disable`

### 3. Administration `error_external_mapping` (`functions/mapping/`)
- `fn::error_mapping_create`, `get`, `list`, `update`, `disable`

### 4. Gestion `error_occurrence` (`functions/occurrence/`)
- `fn::error_occurrence_create`, `get`, `list`, `purge_before`

---

## 🦀 Intégration Rust (`src/`)

Le crate Rust `lyxal_error` fournit les structures génériques de désérialisation et de conversion HTTP Axum :

```rust
use lyxal_error::{LyxalResult, LyxalCallError};

pub async fn generate_username(
    store: &SurrealBookingStore,
    email: &str,
    language: &str,
) -> Result<GeneratedUsername, LyxalCallError> {
    let mut response = store.client()
        .query("RETURN fn::booking_generate_username($email, $language);")
        .bind(("email", email.to_owned()))
        .bind(("language", language.to_owned()))
        .await?;

    let result: LyxalResult<GeneratedUsername> = response.take(0)?;
    result.into_result("booking_generate_username")
}
```

---

## 📄 Liens utiles

- 📄 **[SCHEMA_DOCUMENTATION.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_error/SCHEMA_DOCUMENTATION.md)** : Documentation technique détaillée des champs et index.
- 📄 **[ROADMAP.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_error/ROADMAP.md)** : Feuille de route universelle en 3 phases (**V1 Fonctionnel**, **V2 Observabilité & Console UI**, **V3 Événementiel & IA**).
- 📄 **[features.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_error/features.md)** : Spécifications des événements (`DEFINE EVENT`) et arbitrages d'architecture.
