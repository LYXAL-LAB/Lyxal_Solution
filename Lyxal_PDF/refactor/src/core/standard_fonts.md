# Refactorisation: Standard Fonts

## Objectif
Portage 1:1 de `renderer/src/core/standard_fonts.js` vers `rendererts/src/core/standard_fonts.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/fonts_utils.ts` (`normalizeFontName`)

## Plan d'Implémentation `Standard Fonts`

- [x] `getStdFontMap` (Mapping des 14 polices standard)
- [x] `getFontNameToFileMap`
- [x] `getNonStdFontMap`
- [x] `getSerifFonts`
- [x] `getSymbolsFonts`
- [x] `getGlyphMapForStandardFonts`
- [x] `getSupplementalGlyphMapForArialBlack`
- [x] `getSupplementalGlyphMapForCalibri`
- [x] `getStandardFontName`
- [x] `isKnownFontName`

## Notes Techniques
- Utilisation intensive de `getLookupTableFactory` pour générer des objets de mapping.
- Typage `any` dans les factories pour simplifier l'assignation dynamique des propriétés (clés numériques ou string).

