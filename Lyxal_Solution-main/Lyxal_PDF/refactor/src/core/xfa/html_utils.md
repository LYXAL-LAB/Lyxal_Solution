# Refactorisation: XFA HTML Utils

## Objectif
Portage 1:1 de `renderer/src/core/xfa/html_utils.js` vers `rendererts/src/core/xfa/html_utils.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/utils.ts`

## Plan d'Implémentation `HTMLUtils`

- [x] Fonctions de conversion vers HTML/CSS
- [x] Gestion des dimensions, polices, couleurs
- [x] Utilitaires de mise en page

## Notes Techniques
- Utilisé pour générer la représentation HTML des éléments XFA.
- Utilise `@ts-ignore` pour les imports partagés (`warn`, `createValidAbsoluteUrl`, etc.).
- Utilise `any` et `@ts-ignore` pour les objets complexes avec propriétés dynamiques.
