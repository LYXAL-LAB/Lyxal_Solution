# Refactorisation: XFA FormCalc Parser

## Objectif
Portage 1:1 de `renderer/src/core/xfa/formcalc_parser.js` vers `rendererts/src/core/xfa/formcalc_parser.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/formcalc_lexer.ts`

## Plan d'Implémentation `FormCalc Parser`

- [x] Parser pour le langage FormCalc
- [x] Construction de l'arbre syntaxique abstrait (AST)

## Notes Techniques
- Analyseur syntaxique pour le langage FormCalc, basé sur le lexer.
- Utilise `any` pour les nœuds AST et les tokens pour permettre la flexibilité du langage FormCalc.
