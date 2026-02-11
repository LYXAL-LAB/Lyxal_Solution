# Refactorisation: LZW Stream

## Objectif
Portage 1:1 de `renderer/src/core/lzw_stream.js` vers `rendererts/src/core/lzw_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/base_stream.ts` (OK)

## Plan d'Implémentation

### `LZWStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number, earlyChange: number)`
- [x] `readBits(n)` : Lecture bit à bit optimisée.
- [x] `readBlock()` : Algorithme de décompression LZW (Lempel-Ziv-Welch).
    - [x] Gestion du dictionnaire dynamique (`lzwState`).
    - [x] Gestion des codes spéciaux (ClearTable 256, EOF 257).
    - [x] Gestion de `earlyChange` (paramètre PDF spécifique).

## Notes Techniques
- Implémente la logique LZW spécifique au format PDF (codes 9-12 bits).
- `lzwState` encapsulate l'état du dictionnaire pour la reprise entre les blocs.
