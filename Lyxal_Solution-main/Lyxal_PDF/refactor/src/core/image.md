# Refactorisation: PDF Image

## Objectif
Portage 1:1 de `renderer/src/core/image.js` vers `rendererts/src/core/image.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`
- [x] `src/shared/image_utils.ts` (Utilisé via import)
- [x] `src/core/base_stream.ts`
- [x] `src/core/colorspace.ts`
- [x] `src/core/colorspace_utils.ts`
- [x] `src/core/decode_stream.ts`
- [x] `src/core/image_resizer.ts`
- [x] `src/core/jpeg_stream.ts`
- [x] `src/core/jpx.ts`
- [x] `src/core/primitives.ts`

## Plan d'Implémentation `PDFImage`

- [x] `PDFImage` (Classe principale)
  - [x] `constructor` (Parsing des propriétés de l'image, filtres, espaces de couleurs)
  - [x] `buildImage` (Méthode statique de construction)
  - [x] `createMask` (Gestion des masques d'images)
  - [x] `createImageData` (Conversion en données utilisables par le canvas)
  - [x] `fillOpacity` (Gestion de la transparence/masque)
  - [x] `fillGrayBuffer` (Extraction en niveaux de gris)
  - [x] `getImageBytes` (Récupération des données brutes)

## Notes Techniques
- Gère la complexité des images PDF (formats, filtres, masques, decode arrays, espaces de couleurs).
- Utilise `ImageResizer` pour gérer les grandes images.
- Optimise les conversions de format (ex: 1BPP vers RGBA).
- Intègre la logique spécifique pour JPEG2000 (`JpxImage`) et JPEG (`JpegStream`).

