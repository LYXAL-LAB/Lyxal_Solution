# Refactorisation: Core Utils

## Objectif
Portage 1:1 de `renderer/src/core/core_utils.js` vers `rendererts/src/core/core_utils.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **PENDING**

## Dépendances à consolider AVANT
- `primitives.ts` (Dict, Ref)
- `base_stream.ts`

## Plan d'Implémentation `CoreUtils`

- [ ] `MissingDataException` (classe)
- [ ] `ParserEOFException` (classe)
- [ ] `XRefEntryException` (classe)
- [ ] `XRefParseException` (classe)
- [ ] Fonctions utilitaires (readInt, isWhiteSpace, log2, etc.)

## Notes Techniques
- Ensemble de classes d'erreurs et de fonctions helpers bas niveau utilisées partout dans le core.
