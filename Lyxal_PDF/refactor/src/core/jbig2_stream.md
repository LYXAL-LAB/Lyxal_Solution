# Refactorisation: JBIG2 Stream

## Objectif
Portage 1:1 de `renderer/src/core/jbig2_stream.js` vers `rendererts/src/core/jbig2_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/base_stream.ts` (OK)
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/primitives.ts` (OK)
- [x] `src/core/jbig2.ts` (OK - Migré précédemment)
- [x] `src/shared/util.ts` (OK)

## Plan d'Implémentation

### `Jbig2Stream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(stream: BaseStream, maybeLength: number, params: Dict)`
- [x] `get bytes()` : Lazy loading du flux sous-jacent.
- [x] `readBlock()` / `decodeImage()` : Intégration avec `Jbig2Image`.
- [x] Gestion des segments globaux (`JBIG2Globals`).
- [x] Inversion des couleurs (Black=1 -> Black=0) pour conformité PDF.

## Notes Techniques
- Utilise la nouvelle classe `Jbig2Image` entièrement typée.
- Gestion stricte des types `Uint8Array`.

