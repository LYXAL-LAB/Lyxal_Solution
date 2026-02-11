# Refactorisation: XFA Bind

## Objectif
Portage 1:1 de `renderer/src/core/xfa/bind.js` vers `rendererts/src/core/xfa/bind.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/template.ts`
- `core/xfa/som.ts`

## Plan d'Implémentation `Bind`

- [x] Classe `Binder`
- [x] Liaison des données aux éléments du formulaire

## Notes Techniques
- Gère la liaison entre les données XML et le modèle de formulaire.
- Utilise `@ts-ignore` pour les imports de `template.js` et `warn` de `util.js`.
