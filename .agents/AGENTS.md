# 🏛️ Charte d'Architecture & Règles du Workspace — Lyxal OS

> Ce document applique la **Constitution d'Architecture Lyxal OS** consignée dans `LYXAL_ARCHITECTURE.md`.
> **Suite & Checklist obligatoire** : Les sections 10 à 15 (`lyxal_surreal`, `lyxal_crypto`, `models/`, Checklist Antigravity & Charte UI `surrealist`) sont chargées en permanence depuis `.agents/rules/lyxal_standards_and_checklist.md`.

Ce document régit l'ensemble des processus de développement, des principes d'architecture et des bonnes pratiques applicables à tous les modules de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_error`, `lyxal_surreal`, `lyxal_notification`, `lyxal_scheduler`, etc.).

---

# 🚧 0. Régime Pré-Production — Zéro Dette (EN VIGUEUR)

> [!IMPORTANT]
>
> **Lyxal OS n'a jamais été mis en production ni utilisé.** Il n'existe aucune donnée, aucune installation et aucun consommateur externe à préserver.
> Tant que le CTO n'a pas déclaré explicitement la **première mise en production**, ce régime **prime** sur toute règle de compatibilité, de migration ou d'historique (§8, `LYXAL_ARCHITECTURE.md` §8, skills `lyxal-surrealdb` §3 et `lyxal-module-integration` §4–5).

## 0.1. Objectif

Chaque module repris doit sortir **propre, à l'état cible**, comme s'il était écrit aujourd'hui pour la première fois. On ne garde rien « pour compatibilité ». L'historique vit uniquement dans Git.

## 0.2. Ce qui est interdit en pré-production

* Conserver un ancien contrat « par sécurité » : alias, fonction ou champ déprécié, double nommage, `#[deprecated]`, branche `legacy` / `v1` / `fallback` lisant un ancien format, valeur par défaut ajoutée uniquement pour ne pas casser un appelant interne.
* Empiler des migrations correctives (`0002_fix_...`, `0003_rename_...`).
* Conserver du code mort, commenté ou non appelé.
* Conserver des documents historiques dans les modules : rapports de clôture, d'audit ou de recette passés, changelogs de versions jamais livrées, plans d'implémentation déjà exécutés.

## 0.3. Ce qui s'applique à la place

1. **Rupture libre et coordonnée** : un contrat public (SurrealQL, Rust, événement) peut être renommé, modifié ou supprimé. Obligation unique : mettre à jour **dans le même changement** tous les appelants du dépôt, pour que le workspace compile et que les tests passent. Le changement de contrat reste mentionné dans l'`implementation_plan.md` soumis au CTO.
2. **Une seule migration par module** : `migrations/0001_initial.surql` décrit le schéma cible complet et **est réécrite en place** à chaque évolution. Une base de développement existante est **supprimée et recréée** ; la vérification du `MigrationChecksum` n'impose donc rien en pré-production.
3. **Versions `0.x`** : tant qu'aucun module n'est livré, les versions (`manifest.toml`, `Cargo.toml`) restent en `0.y.z` et les contraintes de dépendance en `>=0.1.0`. Un statut annoncé (« gelé », « V1.1 », « clôturé staging ») décrit un état d'avancement, **pas** une obligation de compatibilité. Les décisions d'architecture associées (ex. pas de `TYPE RELATION` sur les tables existantes) restent valables.
4. **Documentation de l'état actuel uniquement** : le `README.md` du module décrit ce qui existe aujourd'hui. Pas de `CHANGELOG.md` avant la première version livrée. Un `implementation_plan.md` est supprimé une fois exécuté et fusionné. La **feuille de route** `ROADMAP.md` décrit les évolutions à venir : elle n'est pas un document historique, elle est **conservée** et remise à jour à chaque reprise (étapes réalisées retirées car décrites par le `README.md`, références corrigées), jamais supprimée.
5. **Nettoyage à la reprise** : lors de la reprise d'un module, tout élément relevant du §0.2 est supprimé dans le même chantier et listé dans le plan.

## 0.4. Ce qui reste inchangé

Toutes les autres règles s'appliquent normalement : validation CTO du plan (§3), structure canonique (§4), standards SurrealQL / Rust (§5), `lyxal_core`, `lyxal_crypto`, erreurs, événements, idempotence des seeds (nécessaire pour rejouer une installation), zéro erreur silencieuse.

## 0.5. Fin du régime

À la première mise en production déclarée par le CTO, cette section est retirée et le §8 (non-rupture, migrations incrémentales immuables, dépréciation) s'applique pleinement. La migration `0001_initial.surql` de chaque module devient alors figée.

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
crates/lyxal_core/functions/
├── validations/   (fn::validation_*)
├── sanitize/      (fn::sanitize_*)
├── security/      (fn::security_*)
└── utils/         (fn::utils_*)
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

├── manifest.toml            <-- Contrat Runtime (id, version, dépendances, [resources] installées par lyxal_runtime)
├── schema/                  <-- Schémas déclaratifs SurrealDB (tables, index, assertions)
├── migrations/              <-- Scripts de migration ordonnés (ex: 0001_initial.surql)
├── functions/               <-- Fonctions métier SurrealQL ($params: object)
├── events/                  <-- Déclencheurs DEFINE EVENT & handlers
├── error/                   <-- Définitions d'erreurs master data par thèmes
│   ├── auth/
│   ├── bookings/
│   └── ...
├── seeds/                   <-- Données initiales de référence (rejouables) ; démonstration : tests/fixtures/
├── tests/                   <-- Tests SurrealQL `*.test.surql`, exécutés en CI par scripts/ci/test_lyxal_modules.py
├── src/                     <-- Code source Rust (Types, Wrappers, LyxalModule, Workers)
├── README.md                <-- Documentation du module
├── ROADMAP.md               <-- Évolutions à venir (conservée et mise à jour à chaque reprise, cf. §0)
├── CHANGELOG.md             <-- Historique des versions (créé à la première version livrée, cf. §0)
└── implementation_plan.md   <-- Plan courant d'implémentation (supprimé une fois exécuté, cf. §0)
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
lyxal_core (SurrealQL — Couche 0 : validation / sanitize / security / utils)

lyxal_error
     ▲
     │
lyxal_surreal       lyxal_crypto
     ▲                    ▲
     │                    │
     └────────┬───────────┘
              │
lyxal_event · lyxal_runtime
(+ services du Noyau : lyxal_parsing, lyxal_auth, lyxal_i18n, lyxal_storage, lyxal_secrets,
   lyxal_scheduler, lyxal_notification)
              ▲
              │
      Modules Métiers
(lyxal_booking, lyxal_catalogue, lyxal_crm...)
```

> La hiérarchie complète et faisant foi est celle de la **section 6**. Les services du Noyau (`lyxal_parsing`, `lyxal_auth`, `lyxal_i18n`, `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler`, `lyxal_notification`) appartiennent au **Noyau Technique**, pas aux modules métiers.

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
LET $language = $params.language ?? "fr";
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

Les directives de seeds et master data utilisent la méthode canonique `CREATE`, **protégée par un contrôle d'existence** afin d'être rejouables sans erreur ni écrasement (idempotence non destructive) :

```surql
IF !record::exists(error_definition:<MODULE>_<DOMAINE>_<CAUSE>) THEN (
    CREATE error_definition:<MODULE>_<DOMAINE>_<CAUSE> CONTENT {
        code: "<MODULE>_<DOMAINE>_<CAUSE>",
        ...
    }
) END;
```

Cette forme `IF !record::exists(...) THEN ( CREATE ... ) END;` est le standard officiel pour tous les seeds de la suite Lyxal OS (`seeds/*.surql`, `error/**/*.surql`). Un `CREATE` nu (non protégé) est interdit : il échoue au rejeu. `UPSERT` / `UPDATE` sont également interdits dans les seeds car ils écraseraient des données personnalisées.

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
* **Émission SurrealQL (`DEFINE EVENT`)** : Tout événement déclenché par une mutation en base appelle exclusivement `fn::event_publish` et **vérifie son résultat** : en cas d'échec, `THROW` annule la mutation d'origine plutôt que de perdre l'événement :

```surql
DEFINE EVENT OVERWRITE booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "booking.created",
        producer: "lyxal_booking",
        source: $after.id,
        payload: {
            booking_id: <string> $after.id,
            customer_email: $after.customer_email
        },
        metadata: {}
    });
    IF !$published.ok {
        THROW $published.error.code;
    };
};
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
use lyxal_event::HandlerRegistry;
use lyxal_runtime::{EventConsumerModule, RuntimeError};

impl EventConsumerModule for NotificationModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        // `register` retourne un `LyxalEventError` : il doit être converti explicitement.
        registry
            .register::<BookingCreated, _>(BookingCreatedHandler)
            .map_err(|e| RuntimeError::EventEngineError { message: e.to_string() })?;
        Ok(())
    }
}
```

* Les abonnements persistants sont déclarés en SurrealDB via `EventSubscription` (`event_subscription`).

### 5.6.3. Idempotence & Garantie At-Least-Once

* Le transport d'événements garantit une livraison **At-Least-Once**.
* Tout handler de domaine **DOIT être idempotent** (déduplication par `event_id`, `correlation_id` ou clé métier).
* En cas d'échec transitoire (ex: API externe indisponible), le handler retourne `Err(LyxalEventError::HandlerFailed { .., terminal: false })` pour déclencher le retry exponentiel + Full Jitter automatique ; `terminal: true` envoie directement la livraison en dead letter. **Il est strictement interdit de masquer silencieusement une erreur.**

### 5.6.4. Séquencement Streaming In-Process & Invariant de Contiguïté

* Le streaming d'événements est pris en charge par le moteur unifié **LYXAL Event Engine** (`ReliableDispatcher`, `OutboxFeeder`, `HandlerConsumerBridge`).
* **Fencing Transactionnel Étanche** : Le leader détient un bail distribué (`event_stream_lease:outbox_leader`) à génération monotone. Toute écriture durable (`assign_seq`, `flush_batch`, `dead_letter_transfer`) applique une garde conditionnelle atomique sur le bail et échoue avec `EVENT_STALE_LEADER_FENCED` en cas de split-brain ou de perte de leadership.
* **Invariant de Contiguïté sans Trou** : Chaque abonnement possède un flux ordonné (`event_subscription_progress`). Le curseur persistant (`last_persisted_cursor`) ne progresse via `fn::event_flush_batch` que si toutes les séquences antérieures sont résolues (`delivered`, `dead_letter`, `dropped`).
* **Barrière DLQ Atomique** : Tout message empoisonné est persisté dans `event_dead_letter` via `fn::event_dead_letter_transfer` avant toute confirmation du curseur.
* **Reprise Post-Crash Déterministe** : Lors d'un crash ou redémarrage du serveur, `fetch_and_enqueue_pending` reprend les livraisons en cours dès expiration de leur verrou (`locked_until`). La fonction `fn::event_delivery_assign_seq` reverrouille atomiquement la livraison sans modifier son numéro de séquence `delivery_seq` d'origine.

---

# 🧱 5.7. Utilisation Obligatoire de `lyxal_core`

`lyxal_core` constitue la **bibliothèque standard transversale de Lyxal OS**.

Il contient exclusivement des fonctions techniques génériques, indépendantes de toute logique métier et réutilisables par l'ensemble des modules.

## Structure

```text
crates/lyxal_core/functions/
├── validations/   (fn::validation_*)
├── sanitize/      (fn::sanitize_*)
├── security/      (fn::security_*)
└── utils/         (fn::utils_*)
```

> Dans la suite de ce document, les raccourcis `lyxal_core/validation`, `lyxal_core/sanitize`, `lyxal_core/security` et `lyxal_core/utils` désignent ces quatre dossiers.

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

---

## 5.7.8. Entrées des modules : validation, nettoyage et contrôle par `lyxal_core` (obligatoire)

Toute fonction d'un module qui valide, nettoie ou contrôle (sécurité) les données reçues le fait **exclusivement** avec `lyxal_core` :

* **une valeur isolée** : la primitive correspondante (`fn::validation_*`, `fn::sanitize_*`, `fn::security_*`) ;
* **plusieurs champs d'un objet** ou une suite d'étapes : le **moteur unique**, c'est-à-dire `fn::validation_object_execute`, `fn::sanitize_object_execute` ou `fn::security_object_execute` (et leurs variantes `*_pipeline_execute` pour une valeur), avec les règles des catalogues `fn::<domaine>_step_catalog()`.

Il est interdit dans un module :

* de réécrire une vérification ou une normalisation déjà couverte par le Core (format d'e-mail, longueur, bornes, UUID, trim, casse…), par une expression régulière ou une condition locale ;
* d'écrire son propre exécuteur de pipeline, de schéma d'objet, de rapport d'erreurs par champ, d'optimiseur, de traces ou de mesures : ces mécaniques existent une seule fois, dans `fn::utils_engine_*` ;
* de lever un `THROW` pour une donnée invalide : le module lit le rapport du Core (`valid`, `by_field`) et renvoie **son** erreur via `fn::error_result("<MODULE>_...", ...)`.

Une règle qui dépend d'une table, d'un état ou d'un workflow (ex. créneau Booking disponible) reste dans le module (§5.7.5) ; elle s'exécute **après** la validation par le Core. Une règle générique absente des catalogues est un besoin d'extension du Core (§5.7.7), signalé au CTO, jamais contourné localement.

```surql
DEFINE FUNCTION OVERWRITE fn::booking_create($params: object) {
    LET $language = $params.language ?? "fr";
    LET $report = fn::validation_object_execute($params, {
        fields: {
            customer_email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            starts_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }], required: true }
        },
        unknown_keys: "strip"
    }, 20);
    IF !$report.valid { RETURN fn::error_result("BOOKING_INVALID_INPUT", $language, { fields: $report.by_field }); };
    LET $input = fn::sanitize_object_execute($report.value, { fields: { customer_email: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    -- règles métier (disponibilité du créneau…) puis écriture
    ...
};
```

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
version = "0.1.0"
description = "Moteur de réservation et gestion de calendriers Lyxal"
capabilities = ["booking"]

[runtime]
min_version = ">=0.1.0"

[[dependencies]]
id = "lyxal_auth"
version = ">=0.1.0"

[resources]
schemas = ["schema/tables.surql", "schema/fields.surql", "schema/indexes.surql"]
functions = ["functions/booking.surql"]
error_definitions = ["error/booking.surql"]
events = ["events/booking.surql"]
seeds = []
migrations = ["migrations/0001_initial.surql"]
```

* `lyxal_runtime` installe **exactement** les fichiers déclarés dans `[resources]`, par phase (`schemas`, `functions`, `error_definitions`, `events`, `seeds`, puis `migrations`) et dans l'ordre déclaré. Une clé inconnue du manifeste est refusée (`RUNTIME_MANIFEST_PARSE_ERROR`).
* Les migrations s'exécutent sous un bail distribué renouvelé tant qu'elles durent ; leur résultat n'est enregistré que si le nœud détient encore le bail (sinon `RUNTIME_LEASE_FENCED`). Une migration appliquée dont le contenu a changé arrête l'installation (`RUNTIME_MIGRATION_CHECKSUM_MISMATCH`).

> `lyxal_booking` ne déclare **pas** de dépendance vers `lyxal_notification` : conformément au §5.6.1, un producteur d'événements ne connaît jamais ses consommateurs. C'est `lyxal_notification` qui s'abonne à `booking.created` via `lyxal_event`.

### 5.8.2. Contrat Rust du Cycle de Vie (`LyxalModule`)

Chaque module expose une structure principale implémentant le trait officiel `lyxal_runtime::LyxalModule` :

```rust
use async_trait::async_trait;
use lyxal_runtime::{LyxalModule, ModuleContext, ModuleDescriptor, RuntimeError};

pub struct BookingModule {
    descriptor: ModuleDescriptor,
}

#[async_trait]
impl LyxalModule for BookingModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    /// Hook d'installation, exécuté par le Runtime sous bail d'installation
    /// (`InstallationLeaseManager`) ; une release déjà installée n'est pas réinstallée.
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
        Ok(HealthCheckResult::healthy(
            self.module_id.clone(),
            0, // latence mesurée en ms
            Some("Booking engine operational".to_string()),
        ))
    }
}
```

### 5.8.5. Règle de Séparation : Modules vs `lyxal_server` (Hôte)

* Les modules métiers (`lyxal_booking`, `lyxal_crm`, etc.) dépendent **uniquement des traits et contrats** de `lyxal_runtime`.
* Les modules métiers **n'instancient jamais le Runtime** eux-mêmes.
* C'est le binaire hôte (`apps/lyxal-server` ou CLI) qui instancie le `LyxalRuntime` et démarre le serveur réseau. Au démarrage, `lyxal-server` :
  1. installe `lyxal_core`, `lyxal_error`, ses définitions `SERVER_*` et le schéma du runtime (rejouable) ;
  2. installe tous les modules hébergés par `install_packages` (releases, migrations sous bail) ;
  3. enregistre leurs workers et sondes de santé, puis démarre l'ensemble par `start_all` (moteur d'événements compris).
* Les modules hébergés sont **embarqués dans le binaire** : `build.rs` du serveur lit le `manifest.toml` de chaque module et inclut exactement les fichiers de `[resources]` (compilation en échec si un fichier manque). Héberger un module = l'inscrire dans `build.rs` et, s'il a du code Rust, déclarer son `LyxalModule` et ses services dans `apps/lyxal-server/src/modules/` ; un module sans code Rust est porté par un `ManifestModule` construit depuis son manifeste.
* Les erreurs de l'hôte sont préfixées `SERVER_` et répondent au contrat `LyxalResult` (`{ ok, data, error }`), sans détail interne pour le client.

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
lyxal_parsing (lecture CSV, XML, JSON en flux avec rejets explicites, sans base ni logique métier)
lyxal_event
lyxal_runtime (Manifeste, Installation, Migrations, Cycle de vie, Workers, Santé, Baux, Réconciliation)
lyxal_auth (identités, organisations, rôles, permissions, invitations, contrôle des droits, connexion, sessions, jetons et double facteur)
lyxal_i18n (langues : référentiel CLDR et choix de la langue ; clés et traductions avec surcharges par organisation ; rendu des messages, nombres, dates et montants par ICU4X ; import et export JSON et XLIFF)
lyxal_base (référentiels transversaux : unités de mesure et types d'unités, libellés traduits par les clés de lyxal_i18n, SurrealQL seul)
lyxal_storage (fichiers et documents stockés : buckets, fiches de fichiers, états, droits et quotas ; octets écrits et lus en flux sur disque ou sur un service S3 avec empreinte, type réel contrôlé et antivirus optionnel, nettoyage par worker, envoi et téléchargement par les routes de l'hôte)
lyxal_secrets (secrets applicatifs stockés chiffrés par lyxal_crypto — à créer)
lyxal_scheduler (tâches planifiées — à créer)
lyxal_notification (notifications sortantes : e-mail — parcours, gabarits dont les phrases sont des clés lyxal_i18n, file d'envoi, suppression ; autres canaux : feuille de route du module)
(ordre de création des crates « à créer » : docs/14-roadmap/ROADMAP_NOYAU.md)
        │
        ▼
Modules Métiers
lyxal_booking
lyxal_catalogue (référentiel des articles, SurrealQL seul)
lyxal_pipeline_ingestion (ingestion, normalisation, qualification et publication des catalogues fabricants — Clôturé Staging)
lyxal_crm
lyxal_documents
lyxal_btp
...
        │
        ▼
UI / Process Host
lyxal-server (hôte : LyxalRuntime, modules embarqués, API HTTP système)
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

> [!NOTE]
> **Suspendu pendant le régime pré-production (§0).** Cette section décrit les règles applicables **après** la première mise en production.

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
