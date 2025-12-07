# Refactorisation: XFA Fonts

## Objectif
Portage 1:1 de `renderer/src/core/xfa/fonts.js` vers `rendererts/src/core/xfa/fonts.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/fonts.js` (pour les polices PDF)
- `shared/util.js`

## Plan d'Implémentation `Fonts`

- [x] Gestion des polices XFA
- [x] Mapping des polices XFA vers les polices PDF

## Notes Techniques
- Gère la sélection et le chargement des polices pour le rendu XFA.
- Utilise `any` pour les objets de police et `Map<string, any>` pour le cache.
