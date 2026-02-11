# Refactorisation: XFA Builder

## Objectif
Portage 1:1 de `renderer/src/core/xfa/builder.js` vers `rendererts/src/core/xfa/builder.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/symbol_utils.ts`
- `core/xfa/namespaces.ts`
- `core/xfa/xfa_object.ts`

## Plan d'Implémentation `Builder`

- [x] Classe `Builder`
- [x] Construction de l'arbre d'objets XFA à partir du parser XML
- [x] Gestion des namespaces et des types d'objets

## Notes Techniques
- C'est le "pont" entre le parser XML et le modèle objet XFA.
- Utilise `@ts-ignore` pour les imports circulaires ou manquants (`setup.ts`, `template.ts`, `unknown.ts`).
