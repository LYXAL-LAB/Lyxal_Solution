# Refactorisation: Decode Stream

## Objectif
Portage 1:1 de `renderer/src/core/decode_stream.js` vers `rendererts/src/core/decode_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/base_stream.ts` (OK)
- [x] `src/core/stream.ts` (OK)

## Plan d'Implémentation

### `DecodeStream` (Abstract)
- [x] Hérite de `BaseStream`.
- [x] Propriétés : `buffer`, `bufferLength`, `eof`, `minBufferLength`, `_rawMinBufferLength`.
- [x] Gestion du buffer dynamique (`ensureBuffer`).
- [x] Implémentation de `getByte` et `getBytes` via `readBlock()`.
- [x] Méthode `readBlock(decoderOptions?: any): void` définie (avec throw par défaut).
- [x] `makeSubStream` retourne un `Stream`.
- [x] `getImageData` gère le décodage asynchrone d'images.

### `StreamsSequenceStream`
- [x] Hérite de `DecodeStream`.
- [x] Concatène plusieurs `BaseStream`.
- [x] Implémente `readBlock` pour lire séquentiellement les streams.
- [x] Gestion d'erreurs via callback `onError`.

## Notes Techniques
- `readBlock` est implémenté avec un `unreachable` par défaut dans `DecodeStream` pour satisfaire le typage tout en forçant l'implémentation dans les classes filles.
- `StreamsSequenceStream` gère proprement le filtrage des streams dans le constructeur avant l'appel à super via une variable locale.
