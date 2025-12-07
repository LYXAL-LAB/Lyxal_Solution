# Refactorisation: Predictor Stream

## Objectif
Portage 1:1 de `renderer/src/core/predictor_stream.js` vers `rendererts/src/core/predictor_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/primitives.ts` (OK - Dict)
- [x] `src/shared/util.ts` (OK - FormatError)

## Plan d'Implémentation `PredictorStream`

### Classe `PredictorStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number, params: Dict)`
    - [x] Parsing des paramètres (`Predictor`, `Colors`, `BitsPerComponent`, `Columns`).
    - [x] Calcul de `pixBytes` et `rowBytes`.
- [x] `readBlock()` (Dispatcher)
    - [x] Redirige vers `readBlockTiff` ou `readBlockPng` selon le prédicteur.
- [x] `readBlockTiff()` (Predictor 2)
    - [x] Implémentation algorithmique TIFF (XOR, etc.).
- [x] `readBlockPng()` (Predictor >= 10)
    - [x] Implémentation filtres PNG (None, Sub, Up, Average, Paeth).

## Notes Techniques
- Remplacement de l'assignation dynamique de `this.readBlock` par une méthode qui switche sur `this.predictor` pour un meilleur typage TS.
- Logique de calcul de pixels intensive.
