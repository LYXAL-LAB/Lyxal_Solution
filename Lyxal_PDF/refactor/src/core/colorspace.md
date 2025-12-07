# Refactorisation: ColorSpace

## Objectif
Portage 1:1 de `renderer/src/core/colorspace.js` vers `rendererts/src/core/colorspace.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`
- [x] `src/core/base_stream.ts`

## Plan d'Implémentation `ColorSpace`

- [x] `ColorSpace` (Classe de base abstraite)
- [x] `DeviceGrayCS`, `DeviceRgbCS`, `DeviceRgbaCS`, `DeviceCmykCS` (Implémentations de base)
- [x] `AlternateCS`, `PatternCS`, `IndexedCS` (Implémentations spéciales)
- [x] `CalGrayCS`, `CalRGBCS`, `LabCS` (Implémentations calibrées CIE)
- [x] `resizeRgbImage`, `resizeRgbaImage`, `copyRgbaImage` (Utilitaires de redimensionnement)

## Notes Techniques
- Gère la conversion de tous les espaces colorimétriques PDF vers RGB/RGBA pour l'affichage.
- Inclut des conversions mathématiques complexes (CIE Lab, CalRGB, etc.).
- Utilise des `TypedArray` pour la performance.
- Les méthodes `getRgbItem`, `getRgbBuffer`, `getOutputLength` sont polymorphes.

