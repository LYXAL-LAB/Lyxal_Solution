# Refactorisation: XFA Datasets

## Objectif
Portage 1:1 de `renderer/src/core/xfa/datasets.js` vers `rendererts/src/core/xfa/datasets.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `Datasets`

- [x] `Datasets` (classe)
- [x] Gestion des données utilisateur (XML Data)

## Notes Techniques
- Contient l'espace de noms `datasets` de XFA.
- Utilisation de `@ts-ignore` pour les ID de namespace et l'accès dynamique aux propriétés.
