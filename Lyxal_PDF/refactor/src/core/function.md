# Refactorisation: Function

## Objectif
Portage 1:1 de `renderer/src/core/function.js` vers `rendererts/src/core/function.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/primitives.ts`
- [x] `src/shared/util.ts`
- [x] `src/core/ps_parser.ts`
- [x] `src/core/base_stream.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/image_utils.ts`

## Plan d'Implémentation `Function`

- [x] `PDFFunctionFactory` (Fabrique de fonctions PDF)
  - [x] `create` (Point d'entrée, gestion du cache `LocalFunctionCache`)
- [x] `PDFFunction` (Méthodes statiques de parsing et construction)
  - [x] `parse`, `parseArray`
  - [x] `constructSampled` (Type 0)
  - [x] `constructInterpolated` (Type 2)
  - [x] `constructStiched` (Type 3)
  - [x] `constructPostScript` (Type 4)
- [x] `PostScriptEvaluator` (Interpréteur pour les fonctions PS Type 4)
  - [x] Implémentation des opérateurs arithmétiques, pile, et conditions.
- [x] `PostScriptCompiler` (Compilateur JIT pour optimisation JS des fonctions PS)
  - [x] Optimisation AST (`AstNode`, `AstLiteral`, `AstBinaryOperation`, etc.)
  - [x] Génération de code JS (`ExpressionBuilderVisitor`)

## Notes Techniques
- Cœur mathématique pour les dégradés (Patterns) et les transformations de couleurs.
- Supporte l'évaluation dynamique (lente) et la compilation JIT (rapide) des fonctions PostScript.
- Les fonctions générées sont des closures optimisées pour être appelées répétitivement (pixel par pixel).

