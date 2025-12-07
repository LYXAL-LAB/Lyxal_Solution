# Refactorisation: XFA Setup

## Objectif
Portage 1:1 de `renderer/src/core/xfa/setup.js` vers `rendererts/src/core/xfa/setup.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/namespaces.ts`
- `core/xfa/config.ts`
- `core/xfa/connection_set.ts`
- `core/xfa/datasets.ts`
- `core/xfa/locale_set.ts`
- `core/xfa/signature.ts`
- `core/xfa/stylesheet.ts`
- `core/xfa/template.ts`
- `core/xfa/xdp.ts`
- `core/xfa/xhtml.ts`

## Plan d'Implémentation `Setup`

- [x] Configuration des namespaces XFA
- [x] Mapping des IDs de namespace aux classes d'implémentation

## Notes Techniques
- Point d'entrée pour l'initialisation des namespaces supportés.
- Utilise `@ts-ignore` pour les namespaces non encore migrés.
