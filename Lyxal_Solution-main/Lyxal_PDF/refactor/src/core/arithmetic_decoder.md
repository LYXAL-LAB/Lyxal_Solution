# Refactorisation: Arithmetic Decoder

## Objectif
Portage 1:1 de `renderer/src/core/arithmetic_decoder.js` vers `rendererts/src/core/arithmetic_decoder.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- Aucune (Logique interne pure)

## Plan d'Implémentation

### `ArithmeticDecoder`
- [x] Implémentation de la procédure de décodage arithmétique (JPEG 2000 Part I Annex C.3).
- [x] Typage de la table `QeTable`.
- [x] Typage strict des entrées/sorties (`Uint8Array`, `Int8Array`).
- [x] Méthodes `byteIn` et `readBit` implémentées à l'identique.

## Notes Techniques
- Module critique utilisé par `jbig2.ts` et `jpx.ts`.
- La table `QeTable` est typée mais conservée en constante locale.
