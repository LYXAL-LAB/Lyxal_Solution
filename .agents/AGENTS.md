# 🏛️ Charte d'Architecture & Règles du Workspace — Lyxal OS

> Ce document applique la **Constitution d'Architecture Lyxal OS** consignée dans [LYXAL_ARCHITECTURE.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/LYXAL_ARCHITECTURE.md).

Ce document régit l'ensemble des processus de développement, des principes d'architecture et des bonnes pratiques applicables à tous les modules de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_error`, `lyxal_surreal`, `lyxal_notification`, `lyxal_scheduler`, etc.).

---

## 🌟 1. Principe Fondamental & Contrat de Stabilité

Lyxal OS est une plateforme applicative modulaire. Chaque module doit être :
- **Autonome**, **Versionnable**, **Installable & Testable indépendamment**, et **Réutilisable**.
- Aucun module ne connaît l'implémentation interne d'un autre module.
- Les interactions se font uniquement via :
  1. Les fonctions SurrealQL publiques (`fn::<module>_<nom>`).
  2. Les contrats Rust publics (`LyxalResult<T>`, `LyxalSurrealCall`).
  3. Le bus d'événements `lyxal_event` (`event_outbox`).

### Règle de Stabilité :
`Stable ──► Documenté ──► Réutilisable`
> Toute fonction publique doit être documentée (via `COMMENT "..."` en SurrealQL et `///` en Rust) avant d'être considérée comme stable et réutilisable.

---

## 📢 2. Notion d'API Publique vs Implémentation Interne

Chaque module distingue clairement ce qu'il expose publiquement de ce qui reste strictement interne :
- **SurrealQL** : `fn::<module>_<action>` (ex: `fn::booking_create`).
- **Rust** : `call_fn(...)`, `XxxParams`, `XxxResult`, traits publics.
- **Événements** : `<module>.<entite>.<action>` (ex: `booking.created`).
- *Tout le reste est considéré comme strictement interne au module.*

---

## 3. 📋 Processus Obligatoire de Planification & Validation CTO

> [!IMPORTANT]
> **RÈGLE N°1 : TOUTE INTERVENTION SUR LE CODE REQUIERT UN PLAN PRÉALABLE.**
> Aucune modification de code ou création de fichier applicatif ne doit être effectuée sans avoir au préalable rédigé un plan d'implémentation (`implementation_plan.md`) structuré et **obtenu la validation explicite du CTO**.

### Étapes du Processus :
1. **Rédiger le Plan (`implementation_plan.md`)** :
   - Définir le type Rust `XxxParams` et `XxxResult`.
   - Définir la signature SurrealQL `DEFINE FUNCTION OVERWRITE fn::<module>_<func>($params: object)`.
   - Lister les codes d'erreurs master data à créer dans `<module>/error/<thème>/`.
2. **Soumettre au CTO** : Attendre la validation formelle avant toute action d'édition.
3. **Exécuter** : Implémenter la fonction SurrealQL, les master data et le wrapper Rust 1-ligne `store.call_fn(...)`.

---

## 📁 4. Structure Canonique d'un Module Lyxal OS

```text
module_name/
├── schema/                 <-- Tables, index, assertions SurrealDB
├── functions/              <-- Fonctions métier SurrealQL ($params: object)
├── events/                 <-- Déclencheurs DEFINE EVENT & handlers
├── error/                  <-- Définitions d'erreurs master data par thèmes
│   ├── auth/
│   ├── bookings/
│   └── ...
├── seeds/                  <-- Données de démonstration ou initiales
├── src/                    <-- Code source Rust (Types, Wrappers, Protocoles)
├── README.md               <-- Documentation du module
├── CHANGELOG.md            <-- Historique des versions
└── implementation_plan.md  <-- Plan courant d'implémentation
```

---

## 🎯 5. Les Piliers d'Architecture Lyxal OS (Gold Standards)

### 5.1. Une Responsabilité = Un Endroit
Une logique métier ne doit exister qu'à **un seul endroit**. Interdit de recopier une validation entre Rust et SurrealQL ou entre deux modules métiers.

### 5.2. Découpage Stricte des Crates Rust
```text
lyxal_error      (Modèles purs & contrat d'erreur, zéro dépendance DB/Axum)
     ▲
     │
lyxal_surreal    (Transport WS V1, LyxalSurrealError, trait LyxalSurrealCall)
     ▲
     │
Modules Métiers  (lyxal_booking, lyxal_notification, lyxal_scheduler...)
```

### 5.3. Standard des Fonctions SurrealQL
- **Signature Obligatoire** : Toujours `DEFINE FUNCTION OVERWRITE fn::<module>_<nom>($params: object)`.
- **Paramètre Unique `$params`** : Toutes les fonctions acceptent un objet `$params` unique (`LET $email = $params.email; LET $language = $params.language DEFAULT "fr";`).
- **Contrat Universel de Retour** : Toujours retourner `fn::result_ok($data)` ou `fn::result_error($code, $language, $details)`.
- **Taille Maximale** : Une fonction SurrealQL ne dépasse pas **~300 lignes**. Elle découpe et appelle des sous-fonctions si elle devient trop grosse.

### 5.4. Wrappers Rust 1-Ligne (`store.call_fn`)
- Aucun code métier Rust ne doit dupliquer `.query(...)`, `.bind(...)`, `.take(0)` ou l'analyse des erreurs.
- Les stores métiers implémentent `lyxal_surreal::LyxalSurrealCall`.
- Chaque opération Rust est un simple appel typé :
  ```rust
  pub async fn nom_fonction(store: &Store, params: XxxParams) -> Result<XxxResult, LyxalSurrealError> {
      store.call_fn("module_nom_fonction", params).await
  }
  ```

### 5.5. Master Data d'Erreurs (`<module>/error/<thème>/`)
- Les définitions d'erreurs sont classées par sous-domaines dans `<module>/error/<thème>/`.
- Les directives sont **déterministes et idempotentes** : `UPSERT ONLY error_definition:<id> CONTENT { ... };`.
- Tous les codes d'erreurs sont strictement préfixés par leur module propriétaire (ex: `BOOKING_*`, `NOTIFICATION_*`).

### 5.6. Règle sur les Événements (`DEFINE EVENT`)
- Un `DEFINE EVENT` SurrealDB **produit uniquement des données** (`event_outbox`). Il ne modifie jamais directement un autre module et n'exécute aucun effet de bord direct.

---

## 🏗️ 6. Hiérarchie des Dépendances Inter-Modules

```text
Noyau Technique (lyxal_error, lyxal_surreal, lyxal_event, lyxal_auth, lyxal_notification)
  │
  ▼
Modules Métiers (lyxal_booking, lyxal_crm, lyxal_documents, lyxal_btp)
  │
  ▼
UI / Interfaces (Console Web, CLI, Axum Handlers, Mobile)
```
> ❌ **Aucune dépendance circulaire n'est tolérée.**

---

## 🔤 7. Conventions de Nommage Stricte

| Élément | Format | Exemple |
| :--- | :--- | :--- |
| **Tables** | `snake_case` préfixé par le module | `booking_account`, `booking_schedule` |
| **Fonctions SurrealQL** | `fn::<module>_<action>` | `fn::booking_create`, `fn::booking_generate_username` |
| **Événements** | `<module>.<entite>.<action>` | `booking.created`, `booking.updated` |
| **Codes d'Erreurs** | `<MODULE>_<DOMAINE>_<CAUSE>` | `BOOKING_SLOT_ALREADY_TAKEN` |

---

## 🔄 8. Évolution, Migrations & Non-Rupture d'API

- **Cycle de Vie** : `V1 (Architecture) ──► V2 (Sans breaking change) ──► V3 (Migration) ──► V4 (Dépréciation)`.
- On ne casse jamais une API existante.
- Toute évolution de schéma passe par `schema/` ➔ `migration/` ➔ `runtime`.

---

## 🗺️ 9. Méthodologie Standard Lyxal OS en 3 Phases

```text
┌───────────────────────────┐      ┌───────────────────────────┐      ┌───────────────────────────┐
│     V1 — FONCTIONNEL      │ ───► │     V2 — OBSERVABILITÉ    │ ───► │    V3 — ÉVÉNEMENTIEL &    │
│  Tables + CRUD + Moteur   │      │  Stats + Dashboard + UI   │      │  Bus lyxal_event + IA     │
└───────────────────────────┘      └───────────────────────────┘      └───────────────────────────┘
```

1. **V1 Fonctionnel** : Tables, CRUD, Fonctions SurrealQL, Crate Rust, `LyxalResult<T>`.
2. **V2 Observabilité & Console UI** : Table `error_statistics`, dashboards UI, métriques d'erreur par heure/module.
3. **V3 Événementiel & IA** : Pub/Sub `DEFINE EVENT` -> `event_outbox` -> `lyxal_event`, alertes automatiques et diagnostic IA.

---

## 🧘 10. Philosophie Finale Lyxal OS & Frontières

- 🗄️ **Les données** vivent dans **SurrealDB**.
- ⚙️ **Les règles métier et la logique des données** vivent dans **SurrealQL** (Priorité à SurrealQL pour toute logique métier liée aux données).
- 🌐 **Les protocoles externes, moteurs temps réel, communications réseau, chiffrement, parsing et traitements système** restent implémentés en **Rust**.
- ⚡ **Les événements** orchestrent les modules entre eux.
- 🎨 **L'interface UI / CLI** ne contient **aucune logique métier**.

---

## 🔒 11. Standards Inviolables de Transport (`lyxal_surreal`) & Cryptographie (`lyxal_crypto`)

Afin de garantir une cohérence parfaite et d'empêcher toute régression future sur l'ensemble de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_notification`, `lyxal_scheduler`, `lyxal_crm`, etc.), les règles suivantes s'imposent à tous les modules :

### 11.1. Transport Unifié `Surreal<Any>` & `LyxalSurrealCall`
- **Store Unifié** : Tout store de persistance d'un module métier doit être représenté par une structure enveloppant `Surreal<Any>` (`surrealdb::engine::any::Any`). Interdiction de créer des `enum (Ws/Mem)` locaux.
- **Centralisation de `call_fn()`** : La méthode d'exécution universelle `call_fn()` existe à un seul endroit : dans la crate `lyxal_surreal`. Aucun module métier ne doit surcharger ou dupliquer cette logique.
- **Zéro `panic!`** : Les appels au client transport ne doivent jamais générer de `panic!` en mémoire.

### 11.2. Authentification des Moteurs Distants vs Embarqués
- **Connexions Distantes (`ws://`, `wss://`)** : Requirent obligatoirement une authentification `Root` (`signin`).
- **Connexions Embarquées (`mem://`, `"memory"`)** : Ne doivent JAMAIS tenter d'authentification `Root`.
- **Validation des Endpoints** : Les schémas d'URL valides sont restreints à `ws://`, `wss://`, `mem://` et `"memory"`.

### 11.3. Cryptographie Centralisée avec `lyxal_crypto`
- **Chiffrement des Secrets** : Tous les secrets (mots de passe, tokens, clés API) sont gérés exclusivement via `lyxal_crypto`.
- **Contextes AAD Déterministes** : Chaque valeur chiffrée doit dériver son AAD d'un `SecretContext` strict (`tenant`, `module`, `resource`, `record_id`, `field`).
- **Format d'Enveloppe Moderne** : Toute nouvelle écriture est scellée directement sous le format `enc:v1:`.

### 11.4. Interdiction Absolue des Erreurs Silencieuses
- **Zéro Masquage d'Erreurs** : Interdiction de convertir silencieusement un échec réseau, SurrealQL ou de désérialisation en `None` ou `Vec::new()`.
- **Propagation par `Result`** : Les extracteurs d'infrastructure doivent systématiquement retourner `Result<Option<T>, LyxalSurrealError>` et `Result<Vec<T>, LyxalSurrealError>`.

### 11.5. Isolation du Domaine & Emplacement Restreint de `raw_query()`
- **Visibilité de `raw_query()`** : La méthode `raw_query()` doit être restreinte (`pub(crate)`) et réservée au Module Runtime (installation de schémas/fonctions), aux migrations et aux tests.
- **Domaines Découplés** : La couche de transport (`db.rs`) ne contient aucune logique métier. Les opérations de domaine (ex: `availability.rs`) consomment des types natifs SurrealDB (`RecordId`, `Datetime`) et communiquent exclusivement via `store.call_fn(...)`.

---

## 📦 12. Structure & Conventions des Modèles de Domaine (`models/`)

### 12.1. Arborescence Modulaire par Domaine
- Tout module métier Lyxal OS organise ses structures Rust sous un dossier `models/` découpé par sous-domaines (ex: `models/account.rs`, `models/calendar.rs`, `models/booking.rs`).
- L'index `models/mod.rs` re-exporte publiquement les modèles de domaine et DTOs, assurant la stabilité des chemins d'import (`use crate::models::Booking;`).

### 12.2. Alias de Types Natifs SDK
- Les identifiants et horodatages utilisent les alias natifs de la plateforme (`BookingRecordId`, `BookingDatetime`) définis dans `models/types.rs`.

### 12.3. Ségrégation de Visibilité & Masquage des Secrets (`pub(crate)`)
- **Modèles Publics** : Ne contiennent ni ciphertext ni `password_hash`. Re-exportés avec `pub use`.
- **Structures de Persistance Internes** : Définies en `pub(crate)`. Re-exportées avec `pub(crate) use` dans `models/mod.rs`. Ne dérivent JAMAIS `Serialize`.
- **Redaction `Debug`** : Implémentation manuelle du trait `std::fmt::Debug` affichant `[REDACTED]` pour tous les secrets et hashs.

### 12.4. Projections SurrealQL des Booléens de Statut (`*_configured`)
- Les statuts d'existence de secrets (`oidc_client_secret_configured`, `password_configured`, `oauth_configured`) sont calculés dynamiquement dans la fonction SurrealQL projeteuse (`fn::<module>_<action>`) et désérialisés dans le modèle Rust.

### 12.5. Remplacement des Tuples par des Structures Nommées
- Les retours de fonctions SurrealQL doivent être désérialisés dans des structures nommées typées (`#[derive(Debug, Deserialize)]`) et non dans des tuples anonymes (`Vec<(String, String, ...)>`).


