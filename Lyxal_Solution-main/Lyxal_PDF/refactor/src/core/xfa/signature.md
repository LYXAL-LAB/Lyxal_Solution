# Refactorisation: XFA Signature

## Objectif
Portage 1:1 de `renderer/src/core/xfa/signature.js` vers `rendererts/src/core/xfa/signature.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `Signature`

- [x] Namespace `Signature`
- [x] Classes liées à la signature numérique (XML DSig)

## Notes Techniques
- Gère les éléments de signature numérique XML dans les formulaires XFA.
- Utilise `any` pour les attributs et `[key: string]: any` pour l'accès dynamique.
