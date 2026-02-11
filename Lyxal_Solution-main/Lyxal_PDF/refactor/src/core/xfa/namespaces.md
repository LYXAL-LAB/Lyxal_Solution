# Refactorisation: XFA Namespaces

## Objectif
Portage 1:1 de `renderer/src/core/xfa/namespaces.js` vers `rendererts/src/core/xfa/namespaces.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/symbol_utils.ts`
- `core/xfa/config.ts`
- `core/xfa/connection_set.ts`
- `core/xfa/datasets.ts`
- `core/xfa/locale_set.ts`
- `core/xfa/stylesheet.ts`
- `core/xfa/template.ts`
- `core/xfa/xdp.ts`
- `core/xfa/xhtml.ts`
- `core/xfa/signature.ts`
- `core/xfa/unknown.ts`

## Plan d'Implémentation `Namespaces`

- [x] Définition des IDs de namespaces XFA
- [x] Mapping des namespaces vers leurs classes correspondantes

## Notes Techniques
- Registre central des namespaces XFA supportés et de leurs implémentations.
