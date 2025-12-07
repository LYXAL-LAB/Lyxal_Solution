# Refactorisation: Flate Stream

## Objectif
Portage 1:1 de `renderer/src/core/flate_stream.js` vers `rendererts/src/core/flate_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/stream.ts` (OK)
- [x] `src/shared/util.ts` (OK)

## Plan d'Implémentation `FlateStream`

### Constantes Globales
- [x] `codeLenCodeMap` (Int32Array)
- [x] `lengthDecode` (Int32Array)
- [x] `distDecode` (Int32Array)
- [x] `fixedLitCodeTab` (Table Huffman statique)
- [x] `fixedDistCodeTab` (Table Huffman statique)

### Classe `FlateStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number)`
    - [x] Validation header zlib (CMF, FLG).
- [x] `asyncGetBytes()` & `getImageData()`
    - [x] Tentative d'utilisation de `DecompressionStream` (API native).
    - [x] Fallback sur le décodeur JS si échec.
- [x] `readBlock()` (Implémentation JS pure de DEFLATE)
    - [x] Block type 0 (Non compressé).
    - [x] Block type 1 (Codes fixes).
    - [x] Block type 2 (Codes dynamiques - Huffman).
    - [x] Block type 3 (Erreur).
- [x] `getBits(n)` / `getCode(table)` (Bit reader).
- [x] `generateHuffmanTable(lengths)` (Constructeur d'arbre).

## Notes Techniques
- Déclaration `DecompressionStream` ajoutée localement pour éviter les erreurs TS si la lib DOM n'est pas à jour.
- Logique bitwise intensive préservée.
