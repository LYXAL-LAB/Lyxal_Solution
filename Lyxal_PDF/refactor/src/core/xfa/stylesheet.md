# Refactorisation: XFA Stylesheet

## Objectif
Portage 1:1 de `renderer/src/core/xfa/stylesheet.js` vers `rendererts/src/core/xfa/stylesheet.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `Stylesheet`

- [x] Namespace `Stylesheet`
- [x] Support basique pour XSLT (souvent ignoré ou minimal dans les implémentations XFA PDF)

## Notes Techniques
- Gère les éléments liés aux feuilles de style XSLT dans le contexte XFA.
- Utilise `any` pour les attributs et `[key: string]: any` pour l'accès dynamique.
