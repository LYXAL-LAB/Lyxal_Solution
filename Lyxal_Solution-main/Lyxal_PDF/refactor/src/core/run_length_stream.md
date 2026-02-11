# Refactorisation: RunLength Stream

## Objectif
Portage 1:1 de `renderer/src/core/run_length_stream.js` vers `rendererts/src/core/run_length_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)

## Plan d'Implémentation `RunLengthStream`

### Classe `RunLengthStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number)`
- [x] `readBlock()` : Implémentation RLE (Run-Length Encoding).
    - [x] Lecture entête (2 octets).
    - [x] Cas n < 128 : Copie littérale.
    - [x] Cas n > 128 : Répétition.
    - [x] Cas n = 128 : Fin de flux.

## Notes Techniques
- Logique purement algorithmique.
