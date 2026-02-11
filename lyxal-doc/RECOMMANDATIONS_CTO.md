# Recommandations du CTO - Lyxal Doc Engine (Rust)

## Vision Globale
Lyxal Doc Engine doit être un moteur documentaire isolé et autonome, développé en **Rust**.

- **PAS de SurrealDB** pour l'instant.
- **PAS de SQL-first**.
- **PAS de persistance finale**.
- **Modèle pur** et **logique pure**.
- **Testable** et **intégrable plus tard** sans refonte.
- **Agnostique du runtime** (Lyxal OS et Lyxal Sync).

## Structure du Projet
`lyxal-doc/`
- `model/` : AST sémantique (LE CŒUR)
- `ops/` : Opérations (insert, delete, style…)
- `history/` : Version logique (sans CRDT pour l'instant)
- `validate/` : Règles de cohérence
- `render/` : PDF / DOCX / HTML (plus tard)
- `import/` : DOCX / MD (plus tard)
- `tests/` : Tests unitaires lourds

## Feuilles de Route

### 🧩 BRIQUE 1 — Modèle de document (AST sémantique)
**Objectif** : Définir la vérité métier absolue du document.
**À construire** : `Document`, `Block`, `Inline`, `Section`, `TextRun`, `StyleRef`, `Metadata`.
**Contraintes** : Typé, extensible, sérialisable, stable dans le temps, indépendant du rendu (aucune notion de page, pixel, UI).

### 🧩 BRIQUE 2 — Opérations pures (sans CRDT)
**Objectif** : Appliquer une opération sur un document pour obtenir un nouvel état valide.
**Exemples** : `InsertText`, `DeleteRange`, `ApplyStyle`, `SplitParagraph`, `MergeBlocks`.
**Contraintes** : Déterministes, aucune notion d'utilisateur, de réseau ou de temps réel.

### 🧩 BRIQUE 3 — Validation & invariants
**Objectif** : Empêcher les états impossibles (ex: pas de texte directement dans Document, pas de Bold sans texte).

### 🧩 BRIQUE 4 — Historique logique minimal
**Objectif** : Préparer le terrain pour Sync / CRDT (snapshot, version N -> N+1, diff logique pour undo/redo).

### 🧩 BRIQUE 5 — Sérialisation canonique
**Objectif** : Même document -> même JSON (ordre stable, hashable, signable).

## Ce qu'on NE fait PAS encore
- ❌ collaboration
- ❌ CRDT
- ❌ SurrealDB / SQL
- ❌ UI / Rendu visuel

## Ordre de travail recommandé
1. AST minimal mais solide
2. Opérations pures
3. Validation stricte
4. Tests unitaires lourds
5. Sérialisation stable
6. Sync / DB / Render (plus tard)

> "Un moteur documentaire est d’abord un moteur de cohérence. Le reste (sync, UI, DB) vient après."

