# Refactorisation: Fonts

## Objectif
Portage 1:1 de `renderer/src/core/fonts.js` vers `rendererts/src/core/fonts.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/cff_parser.ts`
- [x] `src/core/type1_font.ts`
- [x] `src/core/cff_font.ts`
- [x] `src/core/font_renderer.ts`
- [x] `src/core/opentype_file_builder.ts`
- [x] `src/core/glyf.ts`
- [x] `src/core/metrics.ts`
- [x] `src/core/glyphlist.ts`
- [x] `src/core/unicode.ts`
- [x] `src/core/encodings.ts`
- [x] `src/core/standard_fonts.ts`
- [x] `src/core/to_unicode_map.ts`
- [x] `src/core/fonts_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `Fonts`

- [x] `Font` (Classe principale, très volumineuse)
  - [x] `checkAndRepair` (Vérification et correction des polices corrompues)
  - [x] `exportData` (Exportation pour le worker ou le thread principal)
  - [x] `translate` (Traduction des codes de caractères)
- [x] `ErrorFont` (Police de repli)
- [x] `FontInspector` (Outil de débogage pour les polices)
- [x] Logique de conversion CFF/Type1/TrueType vers OpenType pour le navigateur.

## Notes Techniques
- C'est un des fichiers les plus complexes et les plus gros du projet.
- Il orchestre le chargement, le parsing, la conversion et l'utilisation des polices PDF.
- Il gère une multitude de cas particuliers et de contournements pour les polices mal formées ou les navigateurs spécifiques.
- Le refactoring a été fait par copie directe et corrections ciblées des imports et types, validé par linter.

