# Refactorisation: CCITT Fax Stream

## Objectif
Portage 1:1 de `renderer/src/core/ccitt_stream.js` vers `rendererts/src/core/ccitt_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/ccitt.ts` (OK)
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/primitives.ts` (OK)
- [x] `src/core/base_stream.ts` (OK)

## Plan d'Implémentation

### `CCITTFaxStream`
- [x] Hérite de `DecodeStream`.
- [x] Intègre `CCITTFaxDecoder`.
- [x] Implémente `readBlock` pour le décodage par blocs.
- [x] Gestion des paramètres via `Dict`.

## Notes Techniques
- Dépendance forte sur `ccitt.ts`.
- Utilise `Dict.empty` si les paramètres sont absents, comportement fidèle au JS.
