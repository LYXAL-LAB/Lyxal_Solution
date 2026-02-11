# Refactorisation: XFA SOM (Scripting Object Model)

## Objectif
Portage 1:1 de `renderer/src/core/xfa/som.js` vers `rendererts/src/core/xfa/som.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/symbol_utils.ts`

## Plan d'Implémentation `SOM`

- [x] Parsing des expressions SOM
- [x] Fonction `searchNode`
- [x] Gestion du cache des recherches SOM

## Notes Techniques
- Gère la résolution des chemins d'accès aux objets (ex: `xfa.form.data...`).
- Utilise `@ts-ignore` pour les imports partagés (`warn`).
- Casting `as any` nécessaire pour gérer les tableaux d'objets XFA dynamiques.
