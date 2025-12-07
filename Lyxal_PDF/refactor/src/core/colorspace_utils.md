# Refactorisation: ColorSpace Utils

## Objectif
Portage 1:1 de `renderer/src/core/colorspace_utils.js` vers `rendererts/src/core/colorspace_utils.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/colorspace.ts`
- [x] `src/core/icc_colorspace.ts`
- [x] `src/core/primitives.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `ColorSpaceUtils`

- [x] `ColorSpaceUtils` (Fabrique statique)
  - [x] `parse` (Point d'entrée principal pour créer un ColorSpace à partir d'un objet PDF)
  - [x] Gestion du cache global et local (`globalColorSpaceCache`, `localColorSpaceCache`)
  - [x] Support asynchrone optionnel (`asyncIfNotCached`)
  - [x] Singletons pour les espaces standards (`gray`, `rgb`, `cmyk`, `rgba`)

## Notes Techniques
- Centralise la logique de parsing des espaces colorimétriques PDF (Array ou Name).
- Gère la récursion pour les espaces imbriqués (`Indexed`, `Pattern`, `Alternate`, `ICCBased`).
- Gère les fallbacks en cas d'erreur ou d'espace inconnu.

