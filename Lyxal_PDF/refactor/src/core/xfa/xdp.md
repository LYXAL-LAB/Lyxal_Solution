# Refactorisation: XFA XDP

## Objectif
Portage 1:1 de `renderer/src/core/xfa/xdp.js` vers `rendererts/src/core/xfa/xdp.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `XDP`

- [x] Namespace `Xdp`
- [x] Élément racine `xdp` et conteneurs de paquets

## Notes Techniques
- Gère l'élément racine XDP (XML Data Package) qui enveloppe les différentes parties d'un formulaire XFA.
- Utilise `any` pour les références aux autres parties du formulaire (config, template, datasets, etc.) et `[key: string]: any` pour l'accès dynamique.
