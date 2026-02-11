# Refactorisation: Metadata Parser

## Objectif
Portage 1:1 de `renderer/src/core/metadata_parser.js` vers `rendererts/src/core/metadata_parser.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- `core_utils.ts` (XML parser helpers)

## Plan d'Implémentation `MetadataParser`

- [x] `MetadataParser` (classe)
- [x] Parsing XMP (Extensible Metadata Platform)

## Notes Techniques
- Extraction et nettoyage des métadonnées XML du PDF.
