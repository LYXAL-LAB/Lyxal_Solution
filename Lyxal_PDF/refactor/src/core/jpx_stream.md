# Refactorisation: JPX Stream

## Objectif
Portage 1:1 de `renderer/src/core/jpx_stream.js` vers `rendererts/src/core/jpx_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK)
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/jpx.ts` (OK - JpxImage)

## Plan d'Implémentation `JpxStream`

### Classe `JpxStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(stream, maybeLength, params)`
- [x] `get bytes()` : Lazy getter.
- [x] `ensureBuffer(requested)` : No-op car décodage complet.
- [x] `readBlock(decoderOptions)` : `unreachable` car stream asynchrone.
- [x] `get isAsyncDecoder()` : `true`.
- [x] `decodeImage(bytes, decoderOptions)` : Méthode asynchrone qui appelle `JpxImage.decode`.
- [x] `get canAsyncDecodeImageFromBuffer()`

## Notes Techniques
- C'est un stream particulier car il est asynchrone (`isAsyncDecoder` = true).
- Il utilise `JpxImage` qui charge potentiellement WASM.
