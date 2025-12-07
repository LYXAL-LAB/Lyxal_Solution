# Refactorisation: Type1 Parser

## Objectif
Portage 1:1 de `renderer/src/core/type1_parser.js` vers `rendererts/src/core/type1_parser.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/encodings.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/stream.ts`
- [x] `src/shared/util.ts`

## Plan d'Implémentation `Type1Parser`

- [x] `Type1CharString` (Interpréteur de CharStrings Type 1)
  - [x] `convert` (Conversion vers commandes Type 2)
  - [x] `executeCommand`
- [x] `decrypt`, `decryptAscii` (Décryptage eexec et charstrings)
- [x] `Type1Parser` (Classe principale)
  - [x] `constructor` (Décryptage initial)
  - [x] `extractFontProgram` (Extraction des Subrs et CharStrings)
  - [x] `extractFontHeader` (Extraction des métadonnées)
  - [x] `getToken`, `readNumber`, etc.

## Notes Techniques
- Logique complexe de parsing "lexical" du PostScript simplifié.
- Gestion du cryptage eexec (ASCII et binaire).
- Conversion des commandes Type 1 obsolètes ou différentes vers des équivalents Type 2 pour le moteur CFF.

