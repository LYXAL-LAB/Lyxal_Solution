# Refactorisation: XFA Config

## Objectif
Portage 1:1 de `renderer/src/core/xfa/config.js` vers `rendererts/src/core/xfa/config.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/symbol_utils.ts`
- `core/xfa/namespaces.ts`
- `core/xfa/xfa_object.ts`

## Plan d'Implémentation `Config`

- [x] Namespace `Config`
- [x] Classes de configuration (ex: `Acrobat`, `Present`, etc.)

## Notes Techniques
- Gère la configuration du processeur XFA (comportement, versions, etc.).
- Utilise `@ts-ignore` pour les imports partagés (`shadow`, `warn`).
- Utilise `any` pour les attributs et les types complexes non encore définis.
