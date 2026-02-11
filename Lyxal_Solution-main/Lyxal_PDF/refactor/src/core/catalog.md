# Refactorisation: Catalog

## Objectif
Portage 1:1 de `renderer/src/core/catalog.js` vers `rendererts/src/core/catalog.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `primitives.ts` (Dict, Ref, Name)
- `core_utils.ts` (MissingDataException)

## Plan d'Implémentation `Catalog`

- [x] `Catalog` (classe)
- [x] Parsing de la structure du catalogue PDF (Pages, Outlines, Metadata)
- [x] Gestion des destinations nommées et des permissions

## Notes Techniques
- Point d'entrée principal pour la navigation dans la structure du document PDF.
- Utilisation de `@ts-ignore` pour certaines interactions avec `StructTreeRoot` en attente de sa refactorisation complète.
- Casts explicites ajoutés pour gérer les types `Map` et `Promise.all` complexes.
