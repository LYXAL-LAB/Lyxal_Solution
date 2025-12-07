# Refactorisation: XFA Object

## Objectif
Portage 1:1 de `renderer/src/core/xfa/xfa_object.js` vers `rendererts/src/core/xfa/xfa_object.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/symbol_utils.ts`
- `core/xfa/utils.ts`
- `core/xfa/som.ts` (pour `searchNode`)

## Plan d'Implémentation `XFAObject`

- [x] Classe de base `XFAObject`
- [x] Classe `XmlObject`
- [x] Classe `XFAAttribute` (si présente)
- [x] Gestion des relations parent/enfant et attributs

## Notes Techniques
- C'est la brique fondamentale du modèle objet XFA.
- Utilise intensivement les symboles définis dans `symbol_utils`.
- Utilise `@ts-ignore` pour les dépendances externes non encore migrées (`som.ts`, `shared/util.js`).
