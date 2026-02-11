# Refactorisation: CCITT Fax Decoder

## Objectif
Portage 1:1 de `renderer/src/core/ccitt.js` vers `rendererts/src/core/ccitt.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK)

## Plan d'Implémentation

### `CCITTFaxDecoder`
- [x] Création des interfaces `CCITTFaxDecoderOptions` et `CCITTFaxDecoderSource`.
- [x] Conversion du constructeur pour utiliser l'interface d'options stricte.
- [x] Typage complet des propriétés de classe (tables, buffers).
- [x] Préservation des tables de constantes (Huffman codes).

## Notes Techniques
- Logique complexe de décodage de fax (Group 3/4).
- L'utilisation de `any` dans le constructeur original a été remplacée par une interface stricte pour la robustesse.
- Les tables internes (`twoDimTable`, etc.) sont typées implicitement comme `number[][]` ou `Uint32Array`.
