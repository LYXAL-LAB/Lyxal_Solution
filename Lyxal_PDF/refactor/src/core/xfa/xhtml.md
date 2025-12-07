# Refactorisation: XFA XHTML

## Objectif
Portage 1:1 de `renderer/src/core/xfa/xhtml.js` vers `rendererts/src/core/xfa/xhtml.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`
- `core/xfa/html_utils.ts`

## Plan d'Implémentation `XHTML`

- [x] Namespace `Xhtml`
- [x] Support du sous-ensemble XHTML utilisé dans XFA pour le texte riche

## Notes Techniques
- Gère le contenu XHTML intégré dans les formulaires XFA (texte formaté, styles).
- Utilise `@ts-ignore` pour les imports de `html_utils.js` (car les fonctions viennent de `html_utils.ts` migré).
- Utilise `any` pour les attributs et `[key: string]: any` pour l'accès dynamique.
