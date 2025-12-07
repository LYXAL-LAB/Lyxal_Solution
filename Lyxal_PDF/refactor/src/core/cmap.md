# Refactorisation: CMap

## Objectif
Portage 1:1 de `renderer/src/core/cmap.js` vers `rendererts/src/core/cmap.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/binary_cmap.ts` (Nouveau)
- [x] `src/core/primitives.ts`
- [x] `src/core/parser.ts`

## Plan d'Implémentation `CMap`

- [x] `CMap` (Classe principale)
- [x] `IdentityCMap` (Sous-classe optimisée)
- [x] `parseCMap` (Parser texte)
- [x] `createBuiltInCMap` (Factory pour CMaps intégrés)
- [x] `CMapFactory` (Point d'entrée public)

## Notes Techniques
- `CMap` gère les conversions CID <-> Code.
- Supporte les formats texte (via `parseCMap`) et binaire (via `BinaryCMapReader`).
- `fetchBuiltInCMap` est injecté pour le chargement paresseux des données.

