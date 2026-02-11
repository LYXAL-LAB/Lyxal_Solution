# Refactorisation: Unicode

## Objectif
Portage 1:1 de `renderer/src/core/unicode.js` vers `rendererts/src/core/unicode.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/core_utils.ts` (`getLookupTableFactory`)

## Plan d'Implémentation `Unicode`

- [x] `mapSpecialUnicodeValues`
- [x] `getUnicodeForGlyph`
- [x] `getUnicodeRangeFor`
- [x] `getCharUnicodeCategory`
- [x] `clearUnicodeCaches`

## Notes Techniques
- `getSpecialPUASymbols` généré par `getLookupTableFactory`.
- `UnicodeRanges` copié tel quel.
- `SpecialCharRegExp` utilise le flag `u` pour les propriétés Unicode.

