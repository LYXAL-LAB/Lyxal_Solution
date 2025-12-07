# Refactorisation: Pattern

## Objectif
Portage 1:1 de `renderer/src/core/pattern.js` vers `rendererts/src/core/pattern.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/base_stream.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/colorspace_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `Pattern`

- [x] `Pattern` (Classe principale, factory `parseShading`)
- [x] `BaseShading` (Classe abstraite)
- [x] `RadialAxialShading` (Gradients linéaires et radiaux)
- [x] `MeshShading` (Ombrages maillés complexes Types 4-7)
  - [x] `MeshStreamReader` (Lecteur de flux spécifique pour les maillages)
  - [x] `_decodeType4Shading`, `_decodeType5Shading`, `_decodeType6Shading`, `_decodeType7Shading`
  - [x] `_buildFigureFromPatch` (Interpolation bicubique pour les patchs)
- [x] `getTilingPatternIR` (Extraction des motifs de pavage)

## Notes Techniques
- Gère la complexité des ombrages PDF, notamment les Mesh Shadings qui sont convertis en triangles ou patchs interpolés.
- Utilise `ColorSpaceUtils` pour la gestion des couleurs dans les dégradés.
- Génère une Représentation Intermédiaire (IR) utilisée par le backend graphique.

