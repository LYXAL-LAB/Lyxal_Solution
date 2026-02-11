# Refactorisation: Primitives

## Objectif
Portage 1:1 de `renderer/src/core/primitives.js` vers `rendererts/src/core/primitives.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK, migré)

## Plan d'Implémentation `Primitives`

### Caches (Global)
- [x] `CmdCache`, `NameCache`, `RefCache`
- [x] `clearPrimitiveCaches` (Reset global function)

### Classes de Base
- [x] `Name` (PDF Name objects `/Name`)
    - [x] `constructor` (Validation string)
    - [x] `static get` (Factory avec cache)
- [x] `Cmd` (PDF Command objects `cmd`)
    - [x] `constructor` (Validation string)
    - [x] `static get` (Factory avec cache)
- [x] `Ref` (PDF Reference objects `10 0 R`)
    - [x] `constructor` (num, gen)
    - [x] `toString` (Optimisé)
    - [x] `static fromString` (Parser)
    - [x] `static get` (Factory avec cache)

### Structures Complexes
- [x] `Dict` (PDF Dictionary `<< /Key Value >>`)
    - [x] `constructor` (Map wrapper)
    - [x] `xref` property (Gestion dépendance circulaire via interface `XRefLike`)
    - [x] `assignXref`
    - [x] `get`, `getAsync`, `getArray` (Dereferencing logic)
    - [x] `getRaw`, `getKeys`, `getRawValues`
    - [x] `set`, `has`, `delete`
    - [x] `setIf*` helpers (Validation types)
    - [x] `merge` (Static helper)
    - [x] `clone`
- [x] `RefSet` (Set of References)
    - [x] Wrapper autour de `Set<string>`
- [x] `RefSetCache` (Map of References)
    - [x] Wrapper autour de `Map<string, any>`

### Type Guards / Validators
- [x] `isName`
- [x] `isCmd`
- [x] `isDict` (Vérification récursive optionnelle sur `/Type`)
- [x] `isRefsEqual`

## Notes Techniques
- `Dict` dépend conceptuellement de `XRef` pour le déréférencement (`fetch`).
- Pour éviter une dépendance cyclique bloquante, une interface minimale `XRefLike` a été définie localement dans ce fichier.
- Les caches globaux sont maintenus comme dans l'original pour la performance.
