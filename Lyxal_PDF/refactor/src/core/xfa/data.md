# Refactorisation: XFA Data

## Objectif
Portage 1:1 de `renderer/src/core/xfa/data.js` vers `rendererts/src/core/xfa/data.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`
- `core/xfa/utils.ts`
- `core/xfa/symbol_utils.ts`

## Plan d'Implémentation `DataHandler`

- [x] `DataHandler` (classe)
- [x] Gestion de la sérialisation des données XFA
- [x] Mapping entre XML et objets XFA

## Notes Techniques
- Gère les données du formulaire (valeurs des champs, etc.).
- Utilisation de symboles pour l'accès aux propriétés internes (`symbol_utils`).
