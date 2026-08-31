# 🏛️ Constitution d'Architecture Lyxal OS — `LYXAL_ARCHITECTURE.md`

Ce document constitue la **Constitution d'Architecture officielle et permanente** qui régit l'ensemble de la plateforme **Lyxal OS** (`lyxal_booking`, `lyxal_error`, `lyxal_surreal`, `lyxal_notification`, `lyxal_scheduler`, etc.).

---

## 🌟 1. Principes Fondamentaux & Contrat de Stabilité

Lyxal OS est une plateforme applicative modulaire d'entreprise. Chaque module de la plateforme doit être :
- **Autonome** : Fonctionne sans couplage fort.
- **Versionnable** : Suit le versionnement sémantique (`MAJOR.MINOR.PATCH`).
- **Installable & Testable indépendamment** : Possède ses propres tests et schémas.
- **Réutilisable par d'autres modules** : Expose des contrats publics stables.

> [!IMPORTANT]
> **Isolation Inter-Modules** : Aucun module ne doit connaître l'implémentation interne d'un autre module.
> Les interactions s'effectuent uniquement via :
> 1. Les fonctions SurrealQL publiques (`fn::<module>_<nom>`).
> 2. Les contrats Rust publics (`LyxalResult<T>`, `LyxalSurrealCall`).
> 3. Le bus d'événements `lyxal_event` (`event_outbox`).

### Règle de Stabilité :
```text
Stable  ──►  Documenté  ──►  Réutilisable
```
> Toute fonction ou struct publique doit être explicitement **documentée** (via `COMMENT "..."` en SurrealQL et `///` en Rust) avant d'être considérée comme **stable** et réutilisable par un autre module.

---

## 📢 2. Notion d'API Publique vs Implémentation Interne

Chaque module distingue clairement ce qu'il expose publiquement de ce qui reste strictement interne :

| Vecteur | Élément Exposé (API Publique) | Éléments Internes (Privés) |
| :--- | :--- | :--- |
| **SurrealQL** | `fn::<module>_<action>` (ex: `fn::booking_create`) | Sous-fonctions privées de calcul, tables internes |
| **Rust** | `call_fn(...)`, `XxxParams`, `XxxResult`, traits publics | Fonctions helper privées (`pub(crate)` / `private`) |
| **Événements** | `<module>.<entite>.<action>` (ex: `booking.created`) | Événements techniques éphémères internes |

---

## 📋 3. Processus Obligatoire de Planification & Validation CTO

> [!CAUTION]
> **RÈGLE N°1 : TOUTE INTERVENTION SUR LE CODE REQUIERT UN PLAN PRÉALABLE.**
> Aucune modification de code ou création de fichier applicatif ne doit être effectuée sans avoir au préalable rédigé un plan d'implémentation (`implementation_plan.md`) structuré et **obtenu la validation explicite du CTO**.

### Étapes du Processus :
1. **Rédiger le Plan (`implementation_plan.md`)** :
   - Définir le type Rust `XxxParams` et `XxxResult`.
   - Définir la signature SurrealQL `DEFINE FUNCTION OVERWRITE fn::<module>_<func>($params: object)`.
   - Lister les codes d'erreurs master data dans `<module>/error/<thème>/`.
2. **Soumettre au CTO** : Attendre la validation formelle avant toute action d'édition.
3. **Exécuter** : Implémenter la fonction SurrealQL, les master data et le wrapper Rust 1-ligne `store.call_fn(...)`.

---

## 📁 4. Structure Canonique d'un Module Lyxal OS

Tous les modules de la suite Lyxal OS adoptent la même arborescence standardisée :

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

## 🎯 5. Les Règles d'Or Lyxal OS

### 5.1. Une Responsabilité = Un Endroit
Une logique métier ne doit exister qu'à **un seul endroit**.
- ❌ **Interdit** de recopier une validation Rust dans SurrealQL ou inversement.
- ❌ **Interdit** de recopier une logique de réservation (Booking) dans la Notification.
- ✅ Une logique métier possède toujours une **source unique de vérité**.

### 5.2. Règles sur les Fonctions SurrealQL
- **Signature Obligatoire** : Toujours `DEFINE FUNCTION OVERWRITE fn::<module>_<nom>($params: object)`.
- **Paramètre Unique `$params`** : Toutes les fonctions acceptent un objet `$params` unique (`LET $email = $params.email; LET $language = $params.language DEFAULT "fr";`).
- **Contrat Universel de Retour** : Toujours retourner `fn::result_ok($data)` ou `fn::result_error($code, $language, $details)`.
- **Taille Maximale** : Une fonction SurrealQL ne fait qu'une seule responsabilité métier et **ne dépasse pas ~300 lignes**. Elle découpe et appelle des sous-fonctions si la logique grandit.

### 5.3. Découpage Stricte des Crates Rust
```text
lyxal_error      (Modèles purs & contrat d'erreur, zéro dépendance DB/Axum)
     ▲
     │
lyxal_surreal    (Transport WS V1, LyxalSurrealError, trait LyxalSurrealCall)
     ▲
     │
Modules Métiers  (lyxal_booking, lyxal_notification, lyxal_scheduler...)
```

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
- Les directives doivent être **déterministes et idempotentes** : `UPSERT ONLY error_definition:<id> CONTENT { ... };`.
- Tous les codes d'erreurs sont strictly préfixés par leur module propriétaire (ex: `BOOKING_*`, `NOTIFICATION_*`).

### 5.6. Règle sur les Événements (`DEFINE EVENT`)
- Un `DEFINE EVENT` SurrealDB **produit uniquement des données** (`event_outbox`).
- Il ne modifie jamais directement un autre module et n'exécute aucun effet de bord direct.
- Le moteur consommateur (`lyxal_event` / `lyxal_notification`) décide des actions à mener.

---

## 🏗️ 6. Hiérarchie des Dépendances & Structure Cible

Les dépendances sont strictement unidirectionnelles :

```text
Noyau Technique (lyxal_core: error, surreal, event, auth, storage, notification)
  │
  ▼
Modules Métiers (lyxal_booking, lyxal_crm, lyxal_documents, lyxal_btp)
  │
  ▼
Interfaces Applicatives (Console Web, CLI, Axum API Handlers, Desktop, Mobile)
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

- **Cycle de Vie des APIs** : `V1 (Architecture) ──► V2 (Sans breaking change) ──► V3 (Migration) ──► V4 (Dépréciation)`.
- **Règle de Non-Rupture** : On ne casse jamais une API existante. On ajoute de nouveaux champs/fonctions, on déprécie l'ancienne version, puis on la supprime dans une version majeure ultérieure.
- **Migrations Déterministes** : Aucun fichier existant ne doit être modifié manuellement en production (`schema/` ➔ `migration/` ➔ `runtime`).

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

## 🧘 10. Philosophie Finale Lyxal OS

Lorsqu'un doute existe sur l'emplacement d'une logique :

- 🗄️ **Les données** vivent dans **SurrealDB**.
- ⚙️ **Les règles métier et la logique des données** vivent dans **SurrealQL** (Priorité à SurrealQL pour toute logique métier liée aux données).
- 🌐 **Les protocoles externes, moteurs temps réel, communications réseau, chiffrement, parsing et traitements système** restent implémentés en **Rust**.
- ⚡ **Les événements** orchestrent les modules entre eux.
- 🎨 **L'interface UI / CLI** ne contient **aucune logique métier**.
