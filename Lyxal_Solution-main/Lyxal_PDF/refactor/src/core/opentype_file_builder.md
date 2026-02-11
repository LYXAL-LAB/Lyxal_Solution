# Refactorisation: OpenType File Builder

## Objectif
Portage 1:1 de `renderer/src/core/opentype_file_builder.js` vers `rendererts/src/core/opentype_file_builder.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/core_utils.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `OpenTypeFileBuilder`

- [x] `writeInt16`, `writeInt32`, `writeData` (Helpers d'écriture binaire)
- [x] `OpenTypeFileBuilder` (Classe principale)
  - [x] `constructor`
  - [x] `addTable` (Ajout de tables OpenType)
  - [x] `toArray` (Sérialisation finale du fichier de police)
  - [x] `getSearchParams` (Calcul des paramètres de recherche pour l'en-tête)

## Notes Techniques
- Utilitaire pour construire des fichiers de police OpenType (OTF/TTF) valides à partir de tables brutes.
- Calcule automatiquement les checksums et les offsets.

