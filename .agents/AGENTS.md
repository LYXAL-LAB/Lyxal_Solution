# 🏛️ Charte d'Architecture & Règles du Workspace — Lyxal OS

> Ce document applique la **Constitution d'Architecture Lyxal OS** consignée dans `LYXAL_ARCHITECTURE.md`.

Ce document régit l'ensemble des processus de développement, des principes d'architecture et des bonnes pratiques applicables à tous les modules de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_error`, `lyxal_surreal`, `lyxal_notification`, `lyxal_scheduler`, etc.).

---

## 🌟 1. Principe Fondamental & Contrat de Stabilité

Lyxal OS est une plateforme applicative modulaire. Chaque module doit être :

* **Autonome**
* **Versionnable**
* **Installable & Testable indépendamment**
* **Réutilisable**

Aucun module ne connaît l'implémentation interne d'un autre module.

Les interactions se font uniquement via :

1. Les fonctions SurrealQL publiques (`fn::<module>_<nom>`).
2. Les contrats Rust publics (`LyxalResult<T>`, `LyxalSurrealCall`).
3. Le bus d'événements `lyxal_event` (`event_outbox`).

### Règle de Stabilité

```text
Stable ──► Documenté ──► Réutilisable
```

> Toute fonction publique doit être documentée via `COMMENT "..."` en SurrealQL et `///` en Rust avant d'être considérée comme stable et réutilisable.

---

## 📢 2. Notion d'API Publique vs Implémentation Interne

Chaque module distingue clairement ce qu'il expose publiquement de ce qui reste strictement interne :

* **SurrealQL** : `fn::<module>_<action>`
  Exemple : `fn::booking_create`.

* **Rust** : `call_fn(...)`, `XxxParams`, `XxxResult`, traits publics.

* **Événements** : `<module>.<entite>.<action>`
  Exemple : `booking.created`.

**Tout le reste est considéré comme strictement interne au module.**

---

# 📋 3. Processus Obligatoire de Planification & Validation CTO

> [!IMPORTANT]
>
> **RÈGLE N°1 : TOUTE INTERVENTION SUR LE CODE REQUIERT UN PLAN PRÉALABLE.**

Aucune modification de code ou création de fichier applicatif ne doit être effectuée sans avoir au préalable rédigé un plan d'implémentation `implementation_plan.md` structuré et obtenu la **validation explicite du CTO**.

## Étapes du Processus

### 1. Analyser `lyxal_core`

Avant toute création d'une nouvelle fonction technique, vérifier si la responsabilité existe déjà dans :

```text
lyxal_core/
├── validation/
├── sanitize/
├── security/
└── utils/
```

Le plan doit explicitement identifier :

```text
Fonctions Core réutilisées
Fonctions métier nouvelles
Fonctions Core éventuellement manquantes
```

Une fonction existante dans `lyxal_core` doit être réutilisée.

Une primitive générique semblant manquer doit être signalée au CTO.

Elle ne doit jamais être ajoutée automatiquement au Core sans validation explicite.

### 2. Rédiger le Plan (`implementation_plan.md`)

Le plan doit notamment :

* identifier les fonctions `lyxal_core` utilisées ;
* définir le type Rust `XxxParams` et `XxxResult` ;
* définir la signature SurrealQL `DEFINE FUNCTION OVERWRITE fn::<module>_<func>($params: object)` ;
* lister les codes d'erreurs master data à créer dans `<module>/error/<thème>/`.

### 3. Soumettre au CTO

Attendre la validation formelle avant toute action d'édition.

### 4. Exécuter

Implémenter :

* les fonctions SurrealQL ;
* les master data ;
* les tests ;
* le wrapper Rust 1-ligne `store.call_fn(...)`.

---

# 📁 4. Structure Canonique d'un Module Lyxal OS

```text
module_name/

├── schema/                  <-- Tables, index, assertions SurrealDB
├── functions/               <-- Fonctions métier SurrealQL ($params: object)
├── events/                  <-- Déclencheurs DEFINE EVENT & handlers
├── error/                   <-- Définitions d'erreurs master data par thèmes
│   ├── auth/
│   ├── bookings/
│   └── ...
├── seeds/                   <-- Données de démonstration ou initiales
├── src/                     <-- Code source Rust (Types, Wrappers, Protocoles)
├── README.md                <-- Documentation du module
├── CHANGELOG.md             <-- Historique des versions
└── implementation_plan.md   <-- Plan courant d'implémentation
```

---

# 🎯 5. Les Piliers d'Architecture Lyxal OS — Gold Standards

## 5.1. Une Responsabilité = Un Endroit

Une logique métier ne doit exister qu'à **un seul endroit**.

Il est interdit de recopier une validation entre Rust et SurrealQL ou entre deux modules métiers.

Il est également interdit de recopier une primitive générique déjà disponible dans `lyxal_core`.

---

## 5.2. Découpage Strict des Crates Rust

```text
lyxal_error
     ▲
     │
lyxal_surreal
     ▲
     │
Modules Métiers
(lyxal_booking, lyxal_notification, lyxal_scheduler...)
```

Les responsabilités restent strictement séparées.

---

## 5.3. Standard des Fonctions SurrealQL

### Signature obligatoire

Toujours :

```surql
DEFINE FUNCTION OVERWRITE fn::<module>_<nom>($params: object)
```

### Paramètre unique `$params`

Toutes les fonctions publiques acceptent un objet `$params` unique.

Exemple :

```surql
LET $email = $params.email;
LET $language = $params.language DEFAULT "fr";
```

### Contrat universel de retour

Toujours retourner :

```surql
fn::result_ok($data)
```

ou :

```surql
fn::result_error($code, $language, $details)
```

### Taille maximale

Une fonction SurrealQL ne dépasse pas environ **300 lignes**.

Elle doit être découpée et appeler des sous-fonctions lorsqu'elle devient trop importante.

---

## 5.4. Wrappers Rust 1-Ligne (`store.call_fn`)

Aucun code métier Rust ne doit dupliquer :

```text
.query(...)
.bind(...)
.take(0)
```

ou l'analyse des erreurs.

Les stores métiers implémentent :

```rust
lyxal_surreal::LyxalSurrealCall
```

Chaque opération Rust est un simple appel typé :

```rust
pub async fn nom_fonction(
    store: &Store,
    params: XxxParams
) -> Result<XxxResult, LyxalSurrealError> {
    store.call_fn("module_nom_fonction", params).await
}
```

---

## 5.5. Master Data d'Erreurs (`<module>/error/<thème>/`)

Les définitions d'erreurs sont classées par sous-domaines :

```text
<module>/error/<thème>/
```

Les directives sont **déterministes et idempotentes** :

```surql
UPSERT ONLY error_definition:<id> CONTENT {
    ...
};
```

Tous les codes d'erreurs sont strictement préfixés par leur module propriétaire.

Exemples :

```text
BOOKING_*
NOTIFICATION_*
SCHEDULER_*
AUTH_*
```

---

## 5.6. Règle sur les Événements (`DEFINE EVENT`)

Un `DEFINE EVENT` SurrealDB **produit uniquement des données** dans `event_outbox`.

Il ne :

* modifie jamais directement un autre module ;
* n'appelle pas directement un service externe ;
* n'exécute aucun effet de bord direct.

---

# 🧱 5.7. Utilisation Obligatoire de `lyxal_core`

`lyxal_core` constitue la **bibliothèque standard transversale de Lyxal OS**.

Il contient exclusivement des fonctions techniques génériques, indépendantes de toute logique métier et réutilisables par l'ensemble des modules.

## Structure

```text
lyxal_core/
├── validation/
├── sanitize/
├── security/
└── utils/
```

## Principe fondamental

Avant de créer une fonction technique générique dans un module Lyxal, il est **obligatoire de vérifier si cette responsabilité existe déjà dans `lyxal_core`**.

```text
Besoin d'une fonction
        │
        ▼
Existe dans lyxal_core ?
        │
   ┌────┴────┐
   │         │
  OUI       NON
   │         │
   ▼         ▼
Réutiliser   Responsabilité
le Core      générique ?
                  │
             ┌────┴────┐
             │         │
            OUI       NON
             │         │
             ▼         ▼
       Candidat Core   Fonction du
                      module métier
```

Si une fonction équivalente existe dans le Core, elle doit être réutilisée.

Il est interdit de dupliquer localement son implémentation.

---

## 5.7.1. `validation/`

Contient les fonctions permettant de **vérifier la conformité d'une donnée sans la modifier**.

Toute validation générique doit utiliser en priorité :

```text
lyxal_core/validation
```

Un module métier peut définir une validation propre à son domaine uniquement lorsque celle-ci dépend réellement de règles métier.

Exemple :

```text
Validation générique UUID
→ lyxal_core/validation

Vérifier qu'un créneau Booking est disponible
→ lyxal_booking
```

---

## 5.7.2. `sanitize/`

Contient les fonctions permettant de :

* nettoyer ;
* normaliser ;
* transformer ;
* canonicaliser

une donnée avant son utilisation.

Toute normalisation générique doit utiliser en priorité :

```text
lyxal_core/sanitize
```

---

## 5.7.3. `security/`

Contient les primitives et helpers génériques liés à la sécurité.

Les modules ne doivent jamais réimplémenter localement une primitive déjà disponible dans :

```text
lyxal_core/security
```

Les opérations cryptographiques nécessitant une implémentation native restent déléguées aux composants Rust prévus par l'architecture Lyxal.

---

## 5.7.4. `utils/`

Contient les fonctions techniques génériques réutilisables.

Notamment :

* tableaux ;
* objets ;
* chaînes ;
* nombres ;
* dates ;
* collections ;
* comparaisons ;
* conversions ;
* cache ;
* runtime ;
* pipelines ;
* helpers.

`utils` ne doit jamais devenir un emplacement générique permettant d'y déposer de la logique métier.

---

## 5.7.5. Frontière Core / Module

Une fonction appartient à `lyxal_core` uniquement si elle est :

* générique ;
* indépendante d'un domaine métier ;
* réutilisable par plusieurs modules ;
* sans dépendance envers un module métier Lyxal.

Une fonction appartient au module métier si son comportement dépend :

* d'une table métier ;
* d'un état métier ;
* d'une règle fonctionnelle ;
* d'un workflow métier ;
* d'un contrat spécifique au module.

Exemples :

```text
Validation générique d'un UUID
→ lyxal_core/validation

Normalisation générique d'une chaîne
→ lyxal_core/sanitize

Comparaison générique de deux dates
→ lyxal_core/utils

Primitive générique de sécurité
→ lyxal_core/security

Vérifier qu'un créneau Booking est disponible
→ lyxal_booking

Déterminer si une erreur Lyxal est retryable
→ lyxal_error

Calculer la prochaine exécution d'un Job
→ lyxal_scheduler
```

---

## 5.7.6. Interdiction de Duplication

Il est interdit :

* de recopier une fonction de `lyxal_core` dans un module ;
* de créer une variante locale uniquement pour éviter d'appeler le Core ;
* de réimplémenter en Rust une fonction générique déjà prise en charge par le Core lorsque son exécution appartient à SurrealQL ;
* d'ajouter une logique métier spécifique dans `lyxal_core`.

---

## 5.7.7. Extension du Core

`lyxal_core` est considéré comme une fondation stable.

Une nouvelle fonction ne doit être ajoutée au Core que si :

1. aucun équivalent n'existe ;
2. son besoin est réellement transversal ;
3. elle ne contient aucune logique métier ;
4. son emplacement (`validation`, `sanitize`, `security` ou `utils`) est clairement identifié ;
5. son ajout a été explicitement validé par le CTO.

> **Règle d'or : `lyxal_core` fournit les briques ; les modules fournissent le métier.**

---

# 🏗️ 6. Hiérarchie des Dépendances Inter-Modules

La hiérarchie générale devient :

```text
Fondation Transversale
lyxal_core
(validation / sanitize / security / utils)
        │
        ▼
Noyau Technique
lyxal_error
lyxal_surreal
lyxal_event
lyxal_auth
lyxal_notification
        │
        ▼
Modules Métiers
lyxal_booking
lyxal_crm
lyxal_documents
lyxal_btp
...
        │
        ▼
UI / Interfaces
Console Web
CLI
Axum Handlers
Mobile
```

> ❌ **Aucune dépendance circulaire n'est tolérée.**

Un composant de niveau inférieur ne doit jamais dépendre d'un composant situé au-dessus de lui.

`lyxal_core` ne dépend donc d'aucun module métier.

---

# 🔤 7. Conventions de Nommage Strictes

| Élément                 | Format                             | Exemple                               |
| ----------------------- | ---------------------------------- | ------------------------------------- |
| **Tables**              | `snake_case` préfixé par le module | `booking_account`, `booking_schedule` |
| **Fonctions SurrealQL** | `fn::<module>_<action>`            | `fn::booking_create`                  |
| **Événements**          | `<module>.<entite>.<action>`       | `booking.created`                     |
| **Codes d'Erreurs**     | `<MODULE>_<DOMAINE>_<CAUSE>`       | `BOOKING_SLOT_ALREADY_TAKEN`          |

Les fonctions appartenant à `lyxal_core` suivent leurs conventions propres définies par le Core et ne doivent pas être renommées localement par les modules consommateurs.

---

# 🔄 8. Évolution, Migrations & Non-Rupture d'API

Cycle de vie :

```text
V1 Architecture
      │
      ▼
V2 Sans breaking change
      │
      ▼
V3 Migration
      │
      ▼
V4 Dépréciation
```

On ne casse jamais une API existante.

Toute évolution de schéma passe par :

```text
schema/
   ↓
migration/
   ↓
runtime
```

Une fonction publique stable de `lyxal_core` suit la même règle de non-rupture.

---

# 🗺️ 9. Méthodologie Standard Lyxal OS en 3 Phases

```text
┌───────────────────────────┐
│     V1 — FONCTIONNEL      │
│ Tables + CRUD + Moteur    │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│   V2 — OBSERVABILITÉ      │
│ Stats + Dashboard + UI    │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│ V3 — ÉVÉNEMENTIEL & IA    │
│ Bus lyxal_event + IA      │
└───────────────────────────┘
```

### V1 — Fonctionnel

* Tables
* CRUD
* Fonctions SurrealQL
* Crate Rust
* `LyxalResult<T>`
* réutilisation de `lyxal_core`

### V2 — Observabilité & Console UI

* `error_statistics`
* dashboards UI
* métriques d'erreur par heure/module

### V3 — Événementiel & IA

```text
DEFINE EVENT
      ↓
event_outbox
      ↓
lyxal_event
      ↓
alertes / traitements / diagnostic IA
```

---

# 🧘 10. Philosophie Finale Lyxal OS & Frontières

* 🗄️ **Les données** vivent dans **SurrealDB**.

* ⚙️ **Les règles métier et la logique des données** vivent dans **SurrealQL**. Priorité à SurrealQL pour toute logique métier liée aux données.

* 🧱 **Les primitives techniques génériques** sont réutilisées depuis **`lyxal_core`**.

* 🌐 **Les protocoles externes, moteurs temps réel, communications réseau, chiffrement, parsing et traitements système** restent implémentés en **Rust**.

* ⚡ **Les événements** orchestrent les modules entre eux.

* 🎨 **L'interface UI / CLI** ne contient **aucune logique métier**.

La répartition fondamentale est donc :

```text
LYXAL CORE
    │
    │ primitives génériques
    ▼
SURREALQL
    │
    │ règles métier / données
    ▼
RUST
    │
    │ protocoles / système / réseau
    ▼
EVENTS
    │
    │ orchestration
    ▼
UI
```

---

# 🔒 11. Standards Inviolables de Transport (`lyxal_surreal`) & Cryptographie (`lyxal_crypto`)

Afin de garantir une cohérence parfaite et d'empêcher toute régression future sur l'ensemble de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_notification`, `lyxal_scheduler`, `lyxal_crm`, etc.), les règles suivantes s'imposent à tous les modules.

---

## 11.1. Transport Unifié `Surreal<Any>` & `LyxalSurrealCall`

### Store Unifié

Tout store de persistance d'un module métier doit être représenté par une structure enveloppant :

```rust
Surreal<Any>
```

avec :

```rust
surrealdb::engine::any::Any
```

Interdiction de créer des `enum (Ws/Mem)` locaux.

### Centralisation de `call_fn()`

La méthode d'exécution universelle :

```rust
call_fn()
```

existe à un seul endroit :

```text
lyxal_surreal
```

Aucun module métier ne doit surcharger ou dupliquer cette logique.

### Zéro `panic!`

Les appels au client transport ne doivent jamais générer de :

```rust
panic!
```

en mémoire.

---

## 11.2. Authentification des Moteurs Distants vs Embarqués

### Connexions Distantes

```text
ws://
wss://
```

requièrent obligatoirement une authentification `Root` (`signin`).

### Connexions Embarquées

```text
mem://
memory
```

ne doivent **JAMAIS** tenter d'authentification `Root`.

### Validation des Endpoints

Les schémas d'URL valides sont restreints à :

```text
ws://
wss://
mem://
memory
```

---

## 11.3. Cryptographie Centralisée avec `lyxal_crypto`

### Chiffrement des Secrets

Tous les secrets :

* mots de passe ;
* tokens ;
* clés API ;

sont gérés exclusivement via :

```text
lyxal_crypto
```

### Contextes AAD Déterministes

Chaque valeur chiffrée doit dériver son AAD d'un `SecretContext` strict :

```text
tenant
module
resource
record_id
field
```

### Format d'Enveloppe Moderne

Toute nouvelle écriture est scellée directement sous le format :

```text
enc:v1:
```

---

## 11.4. Interdiction Absolue des Erreurs Silencieuses

### Zéro Masquage d'Erreurs

Il est interdit de convertir silencieusement :

* un échec réseau ;
* une erreur SurrealQL ;
* une erreur de désérialisation

en :

```rust
None
```

ou :

```rust
Vec::new()
```

### Propagation par `Result`

Les extracteurs d'infrastructure doivent systématiquement retourner :

```rust
Result<Option<T>, LyxalSurrealError>
```

ou :

```rust
Result<Vec<T>, LyxalSurrealError>
```

---

## 11.5. Isolation du Domaine & Emplacement Restreint de `raw_query()`

### Visibilité de `raw_query()`

La méthode :

```rust
raw_query()
```

doit être restreinte :

```rust
pub(crate)
```

et réservée :

* au Module Runtime ;
* à l'installation de schémas/fonctions ;
* aux migrations ;
* aux tests.

### Domaines Découplés

La couche de transport :

```text
db.rs
```

ne contient aucune logique métier.

Les opérations de domaine consomment des types natifs SurrealDB :

```rust
RecordId
Datetime
```

et communiquent exclusivement via :

```rust
store.call_fn(...)
```

---

# 📦 12. Structure & Conventions des Modèles de Domaine (`models/`)

## 12.1. Arborescence Modulaire par Domaine

Tout module métier Lyxal OS organise ses structures Rust sous :

```text
models/
```

découpé par sous-domaines.

Exemple :

```text
models/
├── account.rs
├── calendar.rs
├── booking.rs
├── types.rs
└── mod.rs
```

`models/mod.rs` re-exporte publiquement les modèles de domaine et DTOs.

Cela garantit la stabilité des chemins d'import :

```rust
use crate::models::Booking;
```

---

## 12.2. Alias de Types Natifs SDK

Les identifiants et horodatages utilisent les alias natifs de la plateforme.

Exemples :

```rust
BookingRecordId
BookingDatetime
```

définis dans :

```text
models/types.rs
```

---

## 12.3. Ségrégation de Visibilité & Masquage des Secrets (`pub(crate)`)

### Modèles Publics

Ils ne contiennent :

* ni ciphertext ;
* ni `password_hash`.

Ils sont re-exportés avec :

```rust
pub use
```

### Structures de Persistance Internes

Elles sont définies :

```rust
pub(crate)
```

et re-exportées avec :

```rust
pub(crate) use
```

dans :

```text
models/mod.rs
```

Elles ne dérivent **JAMAIS `Serialize`**.

### Redaction `Debug`

Tous les secrets et hashs doivent être masqués dans les représentations `Debug`.

Exemple :

```text
[REDACTED]
```

---

## 12.4. Projections SurrealQL des Booléens de Statut (`*_configured`)

Les statuts d'existence de secrets :

```text
oidc_client_secret_configured
password_configured
oauth_configured
```

sont calculés dynamiquement dans la fonction SurrealQL projeteuse :

```text
fn::<module>_<action>
```

puis désérialisés dans le modèle Rust.

---

## 12.5. Remplacement des Tuples par des Structures Nommées

Les retours de fonctions SurrealQL doivent être désérialisés dans des structures nommées et typées :

```rust
#[derive(Debug, Deserialize)]
```

Les tuples anonymes tels que :

```rust
Vec<(String, String, ...)>
```

sont interdits pour les contrats publics de domaine.

---

# 🧭 13. Checklist Obligatoire Antigravity

Avant toute implémentation, Antigravity doit vérifier les points suivants.

## Architecture

* [ ] La responsabilité appartient-elle réellement au module ?
* [ ] Existe-t-elle déjà dans `lyxal_core` ?
* [ ] Existe-t-elle déjà dans un autre module ?
* [ ] La modification introduit-elle une dépendance circulaire ?
* [ ] La frontière SurrealQL / Rust est-elle respectée ?

## Core

* [ ] `validation` a été vérifié.
* [ ] `sanitize` a été vérifié.
* [ ] `security` a été vérifié.
* [ ] `utils` a été vérifié.
* [ ] Aucune primitive Core n'est dupliquée localement.

## SurrealQL

* [ ] Signature publique conforme.
* [ ] `$params: object` unique.
* [ ] Retour `result_ok` / `result_error`.
* [ ] `COMMENT` présent.
* [ ] Fonction inférieure à environ 300 lignes.
* [ ] Tests prévus.

## Rust

* [ ] `XxxParams` défini.
* [ ] `XxxResult` défini.
* [ ] Wrapper `store.call_fn(...)`.
* [ ] Aucune logique métier dupliquée.
* [ ] Aucun `panic!`.
* [ ] Aucun secret exposé.
* [ ] Aucun `raw_query()` métier.

## Error

* [ ] Codes d'erreurs identifiés.
* [ ] Préfixe du module respecté.
* [ ] Master data prévue.
* [ ] Aucune erreur silencieuse.

## Events

* [ ] Les événements ne produisent que des données.
* [ ] Passage par `event_outbox`.
* [ ] Aucun effet de bord inter-module direct.

## Validation CTO

* [ ] `implementation_plan.md` rédigé.
* [ ] Fonctions Core réutilisées documentées.
* [ ] Fonctions nouvelles documentées.
* [ ] Éventuels besoins Core signalés.
* [ ] Validation explicite du CTO obtenue.

> Tant que cette checklist n'est pas satisfaite et que le CTO n'a pas validé le plan, **aucune implémentation applicative ne doit commencer**.

---

# 🏁 14. Règle Finale

L'architecture Lyxal OS suit la hiérarchie suivante :

```text
┌───────────────────────────────────────────┐
│               LYXAL CORE                  │
│ validation · sanitize · security · utils  │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│             NOYAU TECHNIQUE               │
│ error · surreal · event · auth · etc.     │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│              MODULES MÉTIERS              │
│ booking · crm · documents · btp · etc.    │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│             UI / INTERFACES               │
│ Web · Mobile · CLI · API                  │
└───────────────────────────────────────────┘
```

Chaque responsabilité doit avoir **un propriétaire unique**.

Chaque module doit utiliser les contrats publics des couches inférieures sans connaître leur implémentation interne.

Chaque primitive générique existante doit être réutilisée depuis `lyxal_core`.

Chaque logique métier reste dans son module propriétaire.

Chaque interaction inter-module respecte les contrats publics ou le bus d'événements.

Chaque modification est planifiée et validée avant implémentation.

> **LYXAL CORE fournit les briques.
> SURREALQL porte le métier lié aux données.
> RUST porte les capacités système et protocolaires.
> LYXAL EVENT orchestre.
> LES MODULES composent.
> L'UI présente.**
