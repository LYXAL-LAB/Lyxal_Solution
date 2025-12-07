# Refactorisation: Image Utils

## Objectif
Portage 1:1 de `renderer/src/core/image_utils.js` vers `rendererts/src/core/image_utils.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`
- [x] `src/core/primitives.ts`

## Plan d'Implémentation `ImageUtils`

- [x] `BaseLocalCache` (Classe de base pour les caches locaux)
- [x] `LocalImageCache`, `LocalColorSpaceCache`, `LocalFunctionCache`, `LocalGStateCache`, `LocalTilingPatternCache`, `RegionalImageCache`
- [x] `GlobalColorSpaceCache`, `GlobalImageCache` (Caches globaux inter-pages)

## Notes Techniques
- Implémente différentes stratégies de mise en cache pour optimiser le rendu et la consommation mémoire (limitations de taille, nettoyage, références croisées).

