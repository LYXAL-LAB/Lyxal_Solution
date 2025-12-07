# Refactorisation: Font Substitutions

## Objectif
Portage 1:1 de `renderer/src/core/font_substitutions.js` vers `rendererts/src/core/font_substitutions.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/fonts_utils.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `FontSubstitutions`

- [x] `substitutionMap` (Table statique de mapping des polices)
- [x] `getFontSubstitution` (Fonction principale de recherche)
- [x] `generateFont` (Génération des paramètres CSS/FontFace)
- [x] `getFamilyName`, `getStyleToAppend`

## Notes Techniques
- Contient une table importante de substitutions de polices pour assurer un rendu correct même si la police exacte n'est pas présente sur le système utilisateur.
- Génère des chaînes CSS (`@font-face`) ou des objets pour l'API FontFace.
- Typage des structures de substitution (`SubstitutionInfo`, `FontStyle`).

