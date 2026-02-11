# Refactorisation: CFF Font

## Objectif
Portage 1:1 de `renderer/src/core/cff_font.js` vers `rendererts/src/core/cff_font.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/cff_parser.ts`
- [x] `src/core/fonts_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `CFFFont`

- [x] `CFFFont` (Classe principale)
  - [x] `constructor` (Parsing et compilation)
  - [x] `getGlyphMapping` (Logique de mapping CID/GID complexe)
  - [x] `_createBuiltInEncoding`

## Notes Techniques
- Encapsule `CFFParser` et `CFFCompiler`.
- Gère le mapping des glyphes pour les polices CID et non-CID.

