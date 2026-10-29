# 🏛️ Charte d'Architecture & Règles du Workspace — Lyxal OS

> Ce document applique la **Constitution d'Architecture Lyxal OS** consignée dans `LYXAL_ARCHITECTURE.md`.
> **Suite & Checklist obligatoire** : Les sections 10 à 15 (`lyxal_surreal`, `lyxal_crypto`, `models/`, Checklist Antigravity & Charte UI `surrealist`) sont chargées en permanence depuis `.agents/rules/lyxal_standards_and_checklist.md`.

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

├── manifest.toml            <-- Contrat Runtime (id, version, deps, schemas, migrations, workers)
├── schema/                  <-- Schémas déclaratifs SurrealDB (tables, index, assertions)
├── migrations/              <-- Scripts de migration ordonnés (ex: 0001_initial.surql)
├── functions/               <-- Fonctions métier SurrealQL ($params: object)
├── events/                  <-- Déclencheurs DEFINE EVENT & handlers
├── error/                   <-- Définitions d'erreurs master data par thèmes
│   ├── auth/
│   ├── bookings/
│   └── ...
├── seeds/                   <-- Données de démonstration ou initiales
├── src/                     <-- Code source Rust (Types, Wrappers, LyxalModule, Workers)
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
lyxal_surreal       lyxal_crypto
     ▲                    ▲
     │                    │
     └────────┬───────────┘
              │
      Modules Métiers
(lyxal_booking, lyxal_notification, lyxal_scheduler...)
```

`lyxal_crypto` est le crate cryptographique fondamental de Lyxal OS.

Il se situe au même niveau que `lyxal_surreal` dans la hiérarchie : c'est une **fondation technique** consommée par les modules métiers, pas un module métier lui-même.

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
fn::error_result($code, $language, $details)
```

> [!IMPORTANT]
> **Règle absolue** : La fonction d'échec universelle officielle unique est exclusivement `fn::error_result($code, $language, $details)`. L'utilisation ou la définition de `fn::result_error` est **strictement interdite** dans tous les modules de la suite Lyxal OS (aucun alias, aucun doublon toléré).


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

Les directives de seeds et master data utilisent la méthode canonique `CREATE` :

```surql
CREATE error_definition CONTENT {
    code: "<MODULE>_<DOMAINE>_<CAUSE>",
    ...
};
```

Cette méthode `CREATE` est le standard officiel à utiliser pour tous les seeds de la suite Lyxal OS (`seeds/*.surql`).

Tous les codes d'erreurs sont strictement préfixés par leur module propriétaire.

Exemples :

```text
BOOKING_*
NOTIFICATION_*
SCHEDULER_*
AUTH_*
```

---

## 5.6. Standard Universel d'Événements avec `lyxal_event`

`lyxal_event` est le moteur d'événements asynchrone officiel de Lyxal OS (Transactional Outbox).

### 5.6.1. Règle du Producteur (Découplage Absolu)

* Un module producteur (ex: `lyxal_booking`) **ne connaît JAMAIS ses consommateurs** (ex: `lyxal_notification`). Il lui est strictement interdit d'importer ou de référencer un autre module métier.
* **Émission SurrealQL (`DEFINE EVENT`)** : Tout événement déclenché par une mutation en base appelle exclusivement `fn::event_publish` :

```surql
DEFINE EVENT IF NOT EXISTS booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN (
    fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "booking.created",
        producer: "lyxal_booking",
        payload: {
            booking_id: <string> $after.id,
            customer_email: $after.customer_email
        },
        metadata: {}
    })
);
```

* **Émission Rust** : Les producteurs utilisent la façade `publisher.publish(&event).await`.
* Un `DEFINE EVENT` SurrealDB **produit uniquement des données** dans `event_outbox` via `fn::event_publish`. Il ne :
  * modifie jamais directement un autre module ;
  * n'appelle pas directement un service externe ;
  * n'exécute aucun effet de bord direct.

### 5.6.2. Règle du Consommateur (Handlers Typés & Extension Découplée)

* Chaque structure d'événement de domaine implémente le contrat officiel `lyxal_event::Event` :

```rust
impl Event for BookingCreated {
    const EVENT_TYPE: &'static str = "booking.created";
}
```

* Les gestionnaires implémentent `#[async_trait] impl Handler<E> for MyHandler`.
* Les modules consommateurs déclarent leurs handlers au Runtime via le trait neutre :

```rust
impl EventConsumerModule for NotificationModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry.register(BookingCreatedHandler)?;
        Ok(())
    }
}
```

* Les abonnements persistants sont déclarés en SurrealDB via `EventSubscription` (`event_subscription`).

### 5.6.3. Idempotence & Garantie At-Least-Once

* Le transport d'événements garantit une livraison **At-Least-Once**.
* Tout handler de domaine **DOIT être idempotent** (déduplication par `event_id`, `correlation_id` ou clé métier).
* En cas d'échec transitoire (ex: API externe indisponible), le handler retourne `Err(LyxalEventError::Handler(...))` pour déclencher le retry exponentiel + Full Jitter automatique. **Il est strictement interdit de masquer silencieusement une erreur.**

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

# ⚙️ 5.8. Contrat d'Intégration avec `lyxal_runtime`

`lyxal_runtime` est le moteur d'exécution officiel de Lyxal OS. Il est responsable de l'installation, de l'exécution, de la supervision et de la réconciliation continue de l'ensemble des modules.

Tout module développé pour la suite Lyxal OS doit respecter les 5 contrats suivants :

### 5.8.1. Contrat de Manifeste (`manifest.toml`)

Chaque module déclare formellement ses métadonnées, sa compatibilité SemVer, ses dépendances et ses ressources dans un fichier `manifest.toml` situé à la racine du module :

```toml
manifest_version = 1
id = "lyxal_booking"
name = "Lyxal Booking Engine"
version = "1.0.0"
description = "Moteur de réservation et gestion de calendriers Lyxal"
capabilities = ["booking"]

[runtime]
min_version = ">=0.1.0"

[[dependencies]]
id = "lyxal_auth"
version = ">=1.0.0"

[[dependencies]]
id = "lyxal_notification"
version = ">=1.0.0"

[resources]
schemas = ["schema/tables.surql", "schema/indexes.surql"]
migrations = ["migrations/0001_initial.surql"]
```

### 5.8.2. Contrat Rust du Cycle de Vie (`LyxalModule`)

Chaque module expose une structure principale implémentant le trait officiel `lyxal_runtime::LyxalModule` :

```rust
use async_trait::async_trait;
use lyxal_runtime::{
    LyxalModule, ModuleContext, ModuleDescriptor, ModuleDescriptorBuilder, RuntimeError, Version,
};

pub struct BookingModule {
    descriptor: ModuleDescriptor,
}

#[async_trait]
impl LyxalModule for BookingModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    /// Hook d'installation mutationnel garanti d'être exécuté exactement UNE fois
    /// par le Runtime sous bail distribué (`InstallationLeaseManager`).
    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}
```

### 5.8.3. Contrat des Processus de Fond (`LyxalWorker`)

Les modules ne doivent **JAMAIS** lancer de tâches `tokio::spawn` sauvages ou de boucles non supervisées. Tout processus continu d'arrière-plan doit implémenter `lyxal_runtime::worker::LyxalWorker` et coopérer obligatoirement avec le `CancellationToken` :

```rust
use async_trait::async_trait;
use lyxal_runtime::worker::{LyxalWorker, WorkerContext, WorkerDescriptor};
use lyxal_runtime::RuntimeError;
use std::time::Duration;

pub struct BookingReminderWorker {
    descriptor: WorkerDescriptor,
}

#[async_trait]
impl LyxalWorker for BookingReminderWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(Duration::from_secs(10)) => {
                    // Traitement périodique du worker
                }
            }
        }
        Ok(())
    }
}
```

### 5.8.4. Contrat des Sondes de Santé (`ModuleHealthCheck`)

Pour permettre au `HealthEngine` d'agréger la santé du système sans impacter les performances, les modules fournissent des sondes implémentant `ModuleHealthCheck` :

```rust
use async_trait::async_trait;
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::{ModuleContext, ModuleId, RuntimeError};

pub struct BookingHealthCheck {
    module_id: ModuleId,
}

#[async_trait]
impl ModuleHealthCheck for BookingHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        Ok(HealthCheckResult::healthy("Booking engine operational"))
    }
}
```

### 5.8.5. Règle de Séparation : Modules vs `lyxal_server` (Hôte)

* Les modules métiers (`lyxal_booking`, `lyxal_crm`, etc.) dépendent **uniquement des traits et contrats** de `lyxal_runtime`.
* Les modules métiers **n'instancient jamais le Runtime** eux-mêmes.
* C'est le binaire hôte (`lyxal_server` ou CLI) qui instancie le `LyxalRuntime`, enregistre les modules dans le `ModuleRegistry`, exécute les réconciliations et démarre le serveur réseau.

---

# 🏗️ 6. Hiérarchie des Dépendances Inter-Modules

La hiérarchie générale devient :

```text
Fondation Transversale
lyxal_core
(validation / sanitize / security / utils)
        │
        ▼
Noyau Technique & Moteur
lyxal_error
lyxal_surreal
lyxal_crypto (AES-256-GCM, SHA-256, BLAKE3, Argon2id, HMAC, HKDF)
lyxal_event
lyxal_runtime (Manifest, Lifecycle, Workers, Health, Locks)
lyxal_auth
lyxal_notification
lyxal_scheduler
        │
        ▼
Modules Métiers
lyxal_booking
lyxal_catalogue (Master Catalogue & Référentiel Commercial V1.1)
lyxal_pipeline_ingestion (Ingestion, Normalisation, Qualification Catalogues V1.0.0 — Clôturé Staging)
lyxal_crm
lyxal_documents
lyxal_btp
...
        │
        ▼
UI / Process Host
lyxal_server (Axum Handlers, HTTP API, Process Boot)
Console Web / Mobile
CLI
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
