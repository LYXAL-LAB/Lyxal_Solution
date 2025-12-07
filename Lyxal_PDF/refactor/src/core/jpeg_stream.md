# Refactorisation: JPEG Stream

## Objectif
Portage 1:1 de `renderer/src/core/jpeg_stream.js` vers `rendererts/src/core/jpeg_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK - FeatureTest, shadow, warn)
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/primitives.ts` (OK)
- [x] `src/core/jpg.ts` (OK - JpegImage)

## Plan d'Implémentation

### `JpegStream`
- [x] Hérite de `DecodeStream`.
- [x] Propriétés statiques: `canUseImageDecoder` (basé sur `FeatureTest` et `ImageDecoder`).
- [x] `constructor(stream: BaseStream, maybeLength: number, params: Dict)`
- [x] `get bytes()` : Lazy loading via `shadow`.
- [x] `readBlock()` / `decodeImage()` : Délégation à `JpegImage`.
- [x] `get jpegOptions()` : Extraction et transformation des paramètres (`Decode`, `ColorTransform`).
- [x] `getTransferableImage()` : Support expérimental `ImageDecoder` (WebCodecs).
- [x] Gestion du "junk" data avant le marqueur SOI (`#skipUselessBytes`).

## Notes Techniques
- Dépend de `JpegImage` pour le décodage proprement dit.
- Intègre la logique conditionnelle pour `ImageDecoder` (API Web moderne), avec fallback si non supporté.
- Typage strict des tableaux (`Int32Array` pour `decodeTransform`).

