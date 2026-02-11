# Refactorisation: XFA Utils

## Objectif
Portage 1:1 de `renderer/src/core/xfa/utils.js` vers `rendererts/src/core/xfa/utils.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- Aucune

## Plan d'Implémentation `XFAUtils`

- [x] Fonctions utilitaires (stripQuotes, getInteger, getFloat, etc.)
- [x] Conversion d'unités

## Notes Techniques
- Fonctions d'aide générales pour le parsing et la manipulation des valeurs XFA.
- Utilisation de `@ts-ignore` pour les imports partagés non migrés.
