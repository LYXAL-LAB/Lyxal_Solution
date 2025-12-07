# Refactorisation: ASCII Hex Stream

## Objectif
Portage 1:1 de `renderer/src/core/ascii_hex_stream.js` vers `rendererts/src/core/ascii_hex_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)

## Plan d'Implémentation `AsciiHexStream`

### Classe `AsciiHexStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number)`
- [x] `readBlock()` : Implémentation de la logique de décodage Hexadécimal.
    - [x] Lecture par blocs (`UPSTREAM_BLOCK_SIZE`).
    - [x] Gestion des caractères blancs (ignorés).
    - [x] Conversion Hex -> Int.
    - [x] Gestion de la fin de flux (`>`).
    - [x] Gestion de la persistence de l'état `firstDigit` entre les blocs.

## Notes Techniques
- Logique purement algorithmique.
