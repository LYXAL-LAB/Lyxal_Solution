# Refactorisation: Calculate SHA-384 / SHA-512

## Objectif
Portage 1:1 de `renderer/src/core/calculate_sha_other.js` vers `rendererts/src/core/calculate_sha_other.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK - shadow)

## Plan d'Implémentation
- [x] Classe `Word64` : Gestion des entiers 64 bits (high/low 32 bits).
    - [x] `constructor`, `and`, `xor`, `not`, `add`
    - [x] `shiftRight`, `rotateRight`
    - [x] `copyTo`, `assign`
- [x] Constantes `PARAMS` (Table k pour SHA-512).
- [x] Fonctions bitwise helpers (`ch`, `maj`, `sigma`, `sigmaPrime`, etc.) utilisant `Word64`.
- [x] `calculateSHA512(data, offset, length, mode384)` : Implémentation générique.
    - [x] Initialisation différente selon le mode (SHA-384 vs SHA-512).
    - [x] Padding.
    - [x] Boucle principale (blocs de 1024 bits).
- [x] `calculateSHA384` : Wrapper appelant `calculateSHA512` avec `mode384 = true`.

## Notes Techniques
- JS ne supporte pas nativement les entiers 64 bits dans les opérations bitwise (limité à 32 bits). L'implémentation `Word64` est donc critique et doit être migrée scrupuleusement.

