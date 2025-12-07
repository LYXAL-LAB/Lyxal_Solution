# Refactorisation: Encodings

## Objectif
Portage 1:1 de `renderer/src/core/encodings.js` vers `rendererts/src/core/encodings.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- Aucune (fichier autonome contenant des constantes de tableaux de chaînes).

## Plan d'Implémentation `Encodings`

- [x] `ExpertEncoding`
- [x] `MacExpertEncoding`
- [x] `MacRomanEncoding`
- [x] `StandardEncoding`
- [x] `WinAnsiEncoding`
- [x] `SymbolSetEncoding`
- [x] `ZapfDingbatsEncoding`
- [x] `getEncoding(encodingName)` (fonction helper)

## Notes Techniques
- Typage simple : `string[]` pour les encodings, `(name: string) => string[] | null` pour la fonction helper.

