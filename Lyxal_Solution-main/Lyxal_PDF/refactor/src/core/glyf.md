# Refactorisation: Glyf Table

## Objectif
Portage 1:1 de `renderer/src/core/glyf.js` vers `rendererts/src/core/glyf.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
Aucune dépendance externe.

## Plan d'Implémentation `GlyfTable`

- [x] `GlyfTable` (Classe principale)
  - [x] `constructor` (Parsing initial)
  - [x] `getSize`
  - [x] `write`
  - [x] `scale`
- [x] `Glyph` (Représente un glyphe simple ou composite)
  - [x] `parse`
  - [x] `getSize`
  - [x] `write`
  - [x] `scale`
- [x] `GlyphHeader` (En-tête du glyphe)
- [x] `SimpleGlyph` (Glyphe simple avec contours)
- [x] `CompositeGlyph` (Glyphe composite avec références à d'autres glyphes)
- [x] `Contour`

## Notes Techniques
- Logique bas niveau de manipulation binaire (`DataView`, `Uint8Array`).
- Gestion des drapeaux de glyphes TrueType (`ON_CURVE_POINT`, etc.).
- Remplacement de `Math.sumPrecise` (non standard) par `Array.prototype.reduce`.
- Typage strict des structures binaires.

