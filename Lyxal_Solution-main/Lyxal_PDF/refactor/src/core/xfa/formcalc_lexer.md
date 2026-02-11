# Refactorisation: XFA FormCalc Lexer

## Objectif
Portage 1:1 de `renderer/src/core/xfa/formcalc_lexer.js` vers `rendererts/src/core/xfa/formcalc_lexer.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- Aucune directe

## Plan d'Implémentation `FormCalc Lexer`

- [x] Tokenizer pour le langage FormCalc
- [x] Gestion des différents types de tokens (identifiants, nombres, chaînes, opérateurs)

## Notes Techniques
- Analyseur lexical pour le langage de script FormCalc utilisé dans les formulaires XFA.
- Utilise `any` pour `value` de `Token` car elle peut être de différents types (string, number, null).
