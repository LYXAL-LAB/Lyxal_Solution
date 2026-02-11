# Refactorisation: Calculate SHA-256

## Objectif
Portage 1:1 de `renderer/src/core/calculate_sha256.js` vers `rendererts/src/core/calculate_sha256.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK - shadow)

## Plan d'Implémentation
- [x] Constantes `PARAMS` (Table k pour SHA-256).
- [x] Fonctions bitwise helpers (`rotr`, `ch`, `maj`, `sigma`, `sigmaPrime`, etc.).
- [x] `calculateSHA256(data, offset, length)` : Implémentation de l'algorithme de hachage SHA-256.
    - [x] Initialisation des variables d'état (h0-h7).
    - [x] Padding des données.
    - [x] Boucle principale de traitement par blocs de 512 bits.
    - [x] Opérations bitwise in-place.

## Notes Techniques
- Implémentation JS pure.

