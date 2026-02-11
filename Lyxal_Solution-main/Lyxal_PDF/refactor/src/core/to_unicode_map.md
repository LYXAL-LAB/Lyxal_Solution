# Refactorisation: ToUnicodeMap

## Objectif
Portage 1:1 de `renderer/src/core/to_unicode_map.js` vers `rendererts/src/core/to_unicode_map.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (`unreachable`)

## Plan d'Implémentation `ToUnicodeMap`

- [x] `ToUnicodeMap` (Classe de base pour le mapping)
- [x] `IdentityToUnicodeMap` (Classe optimisée pour mapping identité)

## Notes Techniques
- `_map` typé comme `any[]` pour flexibilité (integer ou string).
- Conversion explicite `parseInt(charCode)` dans les boucles `for-in` car les clés sont des strings.

