# Refactorisation: Base Stream

## Objectif
Portage 1:1 de `renderer/src/core/base_stream.js` vers `rendererts/src/core/base_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK, migré)

## Plan d'Implémentation `BaseStream`

### Classe Abstraite
- [x] `BaseStream` (Class)
    - [x] `constructor` (Vérification classe abstraite)
    - [x] `length` / `isEmpty` (Abstract getters)
    - [x] `isDataLoaded` (Default true)
    - [x] `getByte` / `getBytes` (Abstract methods)
    - [x] `getImageData` (Async wrapper)
    - [x] `peekByte` / `peekBytes` (Navigation relative)
    - [x] `getUint16` / `getInt32` (Lecture binaire)
    - [x] `getString` (Utilise `bytesToString` de `util.ts`)
    - [x] `skip` / `reset` / `moveStart` (Navigation)
    - [x] `makeSubStream` (Factory pattern pour sous-flux)

## Notes Techniques
- Classe abstraite de base.
- `getString` a été adapté pour accepter `length` optionnel afin de matcher l'usage dans `core_utils`.
