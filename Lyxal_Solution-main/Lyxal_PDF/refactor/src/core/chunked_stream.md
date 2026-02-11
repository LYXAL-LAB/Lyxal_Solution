# Refactorisation: Chunked Stream

## Objectif
Portage 1:1 de `renderer/src/core/chunked_stream.js` vers `rendererts/src/core/chunked_stream.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- `core_utils.ts` (MissingDataException)

## Plan d'Implémentation `ChunkedStream`

- [x] `ChunkedStream` (classe)
- [x] Gestion des chunks de données
- [x] Support des requêtes de plage (range requests)

## Notes Techniques
- Typage strict des propriétés de la classe.
- Gestion des `Uint8Array` pour les données binaires.
