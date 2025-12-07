# Refactorisation: JPG (JpegImage)

## Objectif
Portage 1:1 de `renderer/src/core/jpg.js` vers `rendererts/src/core/jpg.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK)
- [x] `src/core/colorspace.ts` (OK - DeviceCmykCS)
- [x] `src/core/core_utils.ts` (OK - readUint16)

## Plan d'Implémentation

### `JpegImage`
- [x] `constructor` avec options de transformation (`decodeTransform`, `colorTransform`).
- [x] `parse(data)` : Analyseur complet de segments JPEG (SOF, DHT, SOS, etc.).
- [x] `getData(width, height, ...)` : Décodage et conversion de couleurs.
- [x] `canUseImageDecoder` : Méthode statique pour la détection de support natif (implémentation partielle).

### Fonctions Internes
- [x] `buildHuffmanTable` : Construction des arbres Huffman.
- [x] `decodeScan` : Décodage des données compressées (Huffman + RLE).
- [x] `quantizeAndInverse` : IDCT (Inverse Discrete Cosine Transform).
- [x] `convertYccToRgb`, `convertCmykToRgb`, etc. : Conversions d'espace colorimétrique.

## Notes Techniques
- Fichier volumineux contenant toute la logique de décodage JPEG en pur JS.
- Gestion des marqueurs JPEG standards et extensions Adobe/JFIF.
- IDCT optimisée (algorithme de Loeffler).

