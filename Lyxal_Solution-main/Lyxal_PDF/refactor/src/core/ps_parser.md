# Refactorisation: PostScript Parser

## Objectif
Portage 1:1 de `renderer/src/core/ps_parser.js` vers `rendererts/src/core/ps_parser.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`
- [x] `src/core/primitives.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/base_stream.ts`

## Plan d'Implémentation `PostScriptParser`

- [x] `PostScriptToken` (Représentation des tokens PS)
- [x] `PostScriptLexer` (Analyse lexicale des flux PS)
  - [x] `getToken`, `getNumber`
- [x] `PostScriptParser` (Analyse syntaxique)
  - [x] `parse`, `parseBlock`, `parseCondition`
  - [x] Gestion des `if` et `ifelse`

## Notes Techniques
- Implémente un sous-ensemble du langage PostScript utilisé dans les fonctions PDF de Type 4 (Calculator Functions).
- Génère une liste d'opérateurs pour l'évaluateur PS (`PostScriptEvaluator` dans `function.ts`).

