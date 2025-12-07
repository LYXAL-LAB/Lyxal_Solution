# Refactorisation: Object Loader

## Objectif
Portage 1:1 de `renderer/src/core/object_loader.js` vers `rendererts/src/core/object_loader.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- `primitives.ts` (Dict, Ref)

## Plan d'Implémentation `ObjectLoader`

- [x] `ObjectLoader` (classe)
- [x] Chargement récursif d'objets (Deep Loading)
- [x] Gestion des références circulaires

## Notes Techniques
- Utilitaire pour s'assurer que toutes les données (clés de dictionnaire, enfants) sont chargées en mémoire.
