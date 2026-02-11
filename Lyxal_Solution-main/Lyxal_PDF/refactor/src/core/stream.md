# Refactorisation: Stream

## Objectif
Portage 1:1 de `renderer/src/core/stream.js` vers `rendererts/src/core/stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/base_stream.ts` (OK, migré)
- [x] `src/shared/util.ts` (OK, migré)
- [x] `src/core/primitives.ts` (OK, migré - requis pour le type `Dict`)

## Plan d'Implémentation `Stream`

### Classes
- [x] `Stream` (Extends `BaseStream`)
    - [x] `constructor` (Gestion Uint8Array/ArrayBuffer, start, length, dict)
    - [x] `bytes` (Stockage données)
    - [x] `dict` (Métadonnées PDF)
    - [x] Implémentation méthodes abstraites : `getByte`, `getBytes`, `length`, `isEmpty`, `reset`, `moveStart`, `makeSubStream`
    - [x] `clone` (Deep copy avec clonage du dict)
- [x] `StringStream` (Extends `Stream`)
    - [x] Wrapper autour de `stringToBytes`
- [x] `NullStream` (Extends `Stream`)
    - [x] Stream vide constant

## Notes Techniques
- Importation explicite de `Dict` depuis `primitives.ts` ajoutée pour le typage strict du constructeur.
- Gestion robuste des bornes (`start`, `end`, `pos`) pour éviter les dépassements de buffer.
