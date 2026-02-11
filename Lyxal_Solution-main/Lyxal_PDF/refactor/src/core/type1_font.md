# Refactorisation: Type1 Font

## Objectif
Portage 1:1 de `renderer/src/core/type1_font.js` vers `rendererts/src/core/type1_font.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/cff_parser.ts`
- [x] `src/core/type1_parser.ts`
- [x] `src/core/fonts_utils.ts`
- [x] `src/core/stream.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `Type1Font`

- [x] `getHeaderBlock`, `getEexecBlock` (Extraction des blocs binaires)
- [x] `findBlock` (Recherche de signatures)
- [x] `Type1Font` (Classe principale)
  - [x] `constructor` (Orchestration du parsing et de la conversion)
  - [x] `wrap` (Conversion interne vers CFF pour normalisation)
  - [x] `getType2Charstrings`, `getType2Subrs`
  - [x] `getGlyphMapping`

## Notes Techniques
- Convertit les polices Type 1 en format CFF (Type 2 charstrings) pour uniformiser le traitement dans le moteur de rendu.
- Gère le décryptage et le parsing des structures spécifiques Type 1 (PFB, eexec).
- Utilise `CFFCompiler` pour générer le CFF final.

