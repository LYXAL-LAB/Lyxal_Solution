# Refactorisation: XFA Factory

## Objectif
Portage 1:1 de `renderer/src/core/xfa/factory.js` vers `rendererts/src/core/xfa/factory.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/parser.ts`
- `core/xfa/datasets.ts`
- `core/xfa/template.ts`
- `core/xfa/config.ts`
- `core/xfa/connection_set.ts`
- `core/xfa/locale_set.ts`
- `core/xfa/stylesheet.ts`
- `core/xfa/xdp.ts`
- `core/xfa/xhtml.ts`

## Plan d'Implémentation `XFAFactory`

- [x] `XFAFactory` (classe)
- [x] Parsing des différentes sections XFA (template, datasets, config, etc.)
- [x] Initialisation de l'objet racine XFA

## Notes Techniques
- Point d'entrée pour le traitement des formulaires XFA.
- Utilisation de `@ts-ignore` pour les symboles exportés (`$globalData`) et les imports non encore migrés (`Binder`, `DataHandler`, `FontFinder`, `XFAParser`, `XhtmlNamespace`).
