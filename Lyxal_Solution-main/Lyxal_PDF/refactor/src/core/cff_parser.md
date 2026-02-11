# Refactorisation: CFF Parser

## Objectif
Portage 1:1 de `renderer/src/core/cff_parser.js` vers `rendererts/src/core/cff_parser.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (`bytesToString`, `FormatError`, `info`, `shadow`, `stringToBytes`, `Util`, `warn`)
- [x] `src/core/charsets.ts` (`ExpertCharset`, `ExpertSubsetCharset`, `ISOAdobeCharset`)
- [x] `src/core/encodings.ts` (`ExpertEncoding`, `StandardEncoding`)
- [x] `src/core/core_utils.ts` (`readInt16`)

## Plan d'Implémentation `CFFParser`

- [x] `CFFStandardStrings` (Tableau de chaînes standard)
- [x] `CharstringValidationData` (Données de validation des commandes Type 2)
- [x] `CFFParser` (Classe principale de parsing)
  - [x] `parse` (Méthode principale)
  - [x] `parseHeader`, `parseDict`, `parseIndex`, etc.
  - [x] `parseCharString` (Parsing des charstrings Type 2)
- [x] `CFF` (Structure de données représentant la police CFF)
- [x] `CFFHeader`, `CFFStrings`, `CFFIndex` (Classes auxiliaires)
- [x] `CFFDict`, `CFFTopDict`, `CFFPrivateDict` (Gestion des dictionnaires CFF)
- [x] `CFFCharset`, `CFFEncoding`, `CFFFDSelect` (Gestion des tables annexes)
- [x] `CFFCompiler` (Recompilation du CFF pour l'intégration dans le navigateur/OS)
  - [x] `compile` (Méthode principale de compilation)
  - [x] `compileDict`, `compileIndex`, etc.

## Notes Techniques
- Logique complexe de parsing et de validation des charstrings Type 2.
- Gestion des dictionnaires avec des clés numériques et des valeurs de types variés (`num`, `sid`, `offset`, `array`, `delta`).
- Utilisation de `any` pour simplifier le typage des dictionnaires très dynamiques, tout en typant strictement les structures principales.

