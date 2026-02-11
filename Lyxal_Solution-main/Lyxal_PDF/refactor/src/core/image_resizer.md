# Refactorisation: Image Resizer

## Objectif
Portage 1:1 de `renderer/src/core/image_resizer.js` vers `rendererts/src/core/image_resizer.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`
- [x] `src/core/core_utils.ts`
- [ ] `src/shared/image_utils.ts` (Utilisé via import, hors scope direct core)

## Plan d'Implémentation `ImageResizer`

- [x] `ImageResizer` (Classe utilitaire)
  - [x] `createImage` (Redimensionnement asynchrone)
  - [x] `_encodeBMP` (Encodage BMP pour passage rapide à `createImageBitmap`)
  - [x] `canUseImageDecoder` (Détection de support BMP via ImageDecoder)
  - [x] `needsToBeResized` (Logique de décision pour le redimensionnement)
  - [x] `_guessMax` (Estimation des limites du canvas)

## Notes Techniques
- Utilise `createImageBitmap` ou `ImageDecoder` (plus rapide) pour décoder/redimensionner les images.
- Gère les limites de taille de Canvas des navigateurs (Chrome vs Firefox).
- Utilise le format BMP en interne pour des raisons de performance (pas de compression, décodage rapide).

