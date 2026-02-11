# Refactorisation: Fonts Utils

## Objectif
Portage 1:1 de `renderer/src/core/fonts_utils.js` vers `rendererts/src/core/fonts_utils.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/encodings.ts`
- [x] `src/core/glyphlist.ts`
- [x] `src/core/unicode.ts`

## Plan d'Implémentation `Fonts Utils`

- [x] `FontFlags`
- [x] `MacStandardGlyphOrdering`
- [x] `recoverGlyphName`
- [x] `type1FontGlyphMapping`
- [x] `normalizeFontName`
- [x] `compileType3Glyph` (Utilise `DOMMatrix`)

## Notes Techniques
- Utilisation de `DOMMatrix` pour `compileType3Glyph`. Assurez-vous que l'environnement cible supporte `DOMMatrix` (Web API).

