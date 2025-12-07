# Refactorisation: JPX (JPEG 2000)

## Objectif
Portage 1:1 de `renderer/src/core/jpx.js` vers `rendererts/src/core/jpx.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK - BaseException, warn)
- [x] `src/core/core_utils.ts` (OK - fetchBinaryData)
- [x] `src/core/stream.ts` (OK - Stream)

## Plan d'Implémentation

### `JpxImage`
- [x] Gestion statique du module OpenJPEG (WASM/JS).
- [x] `setOptions` : Configuration du handler et des flags WASM.
- [x] `#instantiateWasm` : Chargement et instanciation du binaire WASM.
- [x] `#getJsModule` : Fallback asm.js/js si WASM échoue.
- [x] `decode(bytes, options)` : Méthode principale asynchrone.
    - [x] Initialisation lazy du module.
    - [x] Allocation mémoire (`_malloc`).
    - [x] Appel `_jp2_decode`.
    - [x] Gestion des erreurs et nettoyage (`_free`).
- [x] `parseImageProperties(stream)` : Lecture rapide des dimensions (SIZ marker) sans décodage complet.

## Notes Techniques
- Dépendance externe forte : `OpenJPEG`.
- Nécessite des déclarations TypeScript pour le module `OpenJPEG` (méthodes `_malloc`, `_free`, `_jp2_decode`, `writeArrayToMemory`).
- Utilise `Promise.withResolvers` (ou équivalent) pour la synchronisation du chargement du module.

