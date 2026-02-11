# Refactorisation: JBIG2

## Objectif
Portage 1:1 de `renderer/src/core/jbig2.js` vers `rendererts/src/core/jbig2.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK)
- [x] `src/core/core_utils.ts` (OK)
- [x] `src/core/arithmetic_decoder.ts` (OK)
- [x] `src/core/ccitt.ts` (OK)

## Plan d'Implémentation

### `Jbig2Image`
- [x] Implémentation de `parseChunks` et `parse`.
- [x] Gestion des segments JBIG2 (SymbolDictionary, TextRegion, etc.).
- [x] Utilisation stricte des types pour `chunks` et `data` (`Uint8Array`).

### `DecodingContext` & Utilitaires
- [x] Typage strict de `ContextCache` (`Int8Array`).
- [x] Typage de `DecodingContext` intégrant `ArithmeticDecoder`.
- [x] Implémentation complète des procédures de décodage (Huffman, Arithmétique).

## Notes Techniques
- Fichier complexe implémentant l'annexe A et B de la spec JBIG2.
- Utilise `ArithmeticDecoder` pour le codage arithmétique et `CCITTFaxDecoder` pour les segments MMR.
- Logique bit-à-bit préservée à l'identique.
