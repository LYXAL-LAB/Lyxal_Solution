# Refactorisation: XFA Fonts

## Objectif
Portage 1:1 de `renderer/src/core/xfa_fonts.js` vers `rendererts/src/core/xfa_fonts.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/primitives.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/fonts_utils.ts`
- [x] Tables de données (facteurs et largeurs) :
  - `calibri_factors.ts`
  - `helvetica_factors.ts`
  - `liberationsans_widths.ts`
  - `myriadpro_factors.ts`
  - `segoeui_factors.ts`

## Plan d'Implémentation `XfaFonts`

- [x] `getXfaFontDict` (Génération du dictionnaire de police XFA)
- [x] `getXfaFontName` (Récupération des infos de mapping)
- [x] `getXfaFontWidths` (Calcul des largeurs redimensionnées)
- [x] Gestion des mappings de polices (Calibri, Helvetica, MyriadPro, SegoeUI vers LiberationSans)

## Notes Techniques
- Fournit un mécanisme de fallback pour les polices spécifiques aux formulaires XFA en les mappant vers des métriques compatibles (généralement basées sur Liberation Sans).
- Utilise des facteurs d'échelle pour ajuster les largeurs de caractères.

