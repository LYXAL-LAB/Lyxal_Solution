# Refactorisation: Decrypt Stream

## Objectif
Portage 1:1 de `renderer/src/core/decrypt_stream.js` vers `rendererts/src/core/decrypt_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/base_stream.ts` (OK)

## Plan d'Implémentation `DecryptStream`

### Classe `DecryptStream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number, decrypt: Function)`
- [x] `readBlock()` : Lecture par chunks et déchiffrement à la volée.
    - [x] Gestion du buffer de lecture (`chunkSize = 512`).
    - [x] Appel de la fonction de callback `decrypt(chunk, finalize)`.
- [x] `getOriginalStream()` : Retourne `this` (utilisé pour éviter le déchiffrement récursif si nécessaire ?).

## Notes Techniques
- Utilise une fonction de callback `decrypt` injectée pour effectuer le déchiffrement réel, permettant de supporter différents algorithmes (RC4, AES) sans coupler le stream à l'implémentation crypto.

