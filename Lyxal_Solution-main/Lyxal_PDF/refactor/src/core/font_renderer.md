# Refactorisation: Font Renderer

## Objectif
Portage 1:1 de `renderer/src/core/font_renderer.js` vers `rendererts/src/core/font_renderer.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/cff_parser.ts`
- [x] `src/core/glyphlist.ts`
- [x] `src/core/encodings.ts`
- [x] `src/core/stream.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `FontRenderer`

- [x] `parseCmap`, `parseCff`, `parseGlyfTable` (Parsing des tables SFNT)
- [x] `lookupCmap` (Mappage Unicode -> GlyphID)
- [x] `compileGlyf` (Compilation des glyphes TrueType)
- [x] `compileCharString` (Compilation des glyphes Type 2/CFF)
- [x] `Commands` (Accumulateur de commandes de dessin)
- [x] `CompiledFont` (Classe de base abstraite)
- [x] `TrueTypeCompiled`, `Type2Compiled` (Implémentations concrètes)
- [x] `FontRendererFactory` (Fabrique principale)

## Notes Techniques
- Cœur du moteur de rendu de texte pour les polices embarquées (hors Type 3).
- Transforme les descriptions vectorielles (courbes de Bézier, lignes) en commandes `DrawOPS`.
- Gère la complexité des formats TrueType (`glyf`, `loca`) et CFF (`CharString`).

