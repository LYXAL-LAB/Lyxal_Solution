# Refactorisation: XFA Layout

## Objectif
Portage 1:1 de `renderer/src/core/xfa/layout.js` vers `rendererts/src/core/xfa/layout.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/html_utils.ts`

## Plan d'Implémentation `Layout`

- [x] Gestion de l'espace disponible
- [x] Ajout de contenu HTML
- [x] Gestion des sauts de page/conteneur

## Notes Techniques
- Gère le placement des éléments sur la page en fonction des contraintes de mise en page XFA.
- Utilise `@ts-ignore` pour les fonctions mathématiques étendues (`Math.sumPrecise`, `MathClamp`) et d'autres utilitaires.
- Utilise `any` pour les nœuds et les structures de données complexes.
