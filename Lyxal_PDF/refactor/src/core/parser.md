# Refactorisation: Parser

## Objectif
Portage 1:1 de `renderer/src/core/parser.js` vers `rendererts/src/core/parser.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
Le Parser est le point central de lecture. Il nécessite tous les types de flux pour pouvoir les instancier.

### Core & Utils (✅ FAIT)
- [x] `src/shared/util.ts`
- [x] `src/core/primitives.ts`
- [x] `src/core/core_utils.ts`
- [x] `src/core/stream.ts` (Inclut `NullStream`, `Stream`)

### Streams de Décodage (✅ FAIT)
Il faut impérativement migrer ces fichiers avant de commencer `parser.ts`.
- [x] `src/core/ascii_85_stream.ts`
- [x] `src/core/ascii_hex_stream.ts`
- [x] `src/core/ccitt_stream.ts`
- [x] `src/core/flate_stream.ts`
- [x] `src/core/jbig2_stream.ts`
- [x] `src/core/jpeg_stream.ts`
- [x] `src/core/jpx_stream.ts`
- [x] `src/core/lzw_stream.ts`
- [x] `src/core/predictor_stream.ts`
- [x] `src/core/run_length_stream.ts`

### Autres
- [ ] `CipherTransform` (Dépendance optionnelle pour `getObj` / `makeStream`, gérée via `any` temporairement en attendant `crypto.ts`).

## Plan d'Implémentation `Parser`

### Classes
- [x] `Lexer`
    - [x] `constructor(stream, knownCommands)`
    - [x] `nextChar`, `peekChar`
    - [x] `getNumber`, `getString`, `getName`, `getHexString`
    - [x] `getObj` (Parseur de tokens bas niveau)
    - [x] `skipToNextLine`
- [x] `Parser`
    - [x] `constructor(lexer, xref, allowStreams, recoveryMode)`
    - [x] `refill`, `shift`, `tryShift`
    - [x] `getObj(cipherTransform)` (Parseur d'objets haut niveau : Array, Dict, Stream)
    - [x] `makeStream` (Logique robuste avec `findStreamLength`)
    - [x] `filter` / `makeFilter` (Factory de streams complète avec tous les cas)
    - [x] `makeInlineImage` (Support complet avec cache et heuristiques de fin de stream)
        - [x] `findDefaultInlineStreamEnd`
        - [x] `findDCTDecodeInlineStreamEnd`
        - [x] `findASCII85DecodeInlineStreamEnd`
        - [x] `findASCIIHexDecodeInlineStreamEnd`
- [x] `Linearization`
    - [x] `create(stream)` (Parsing du dictionnaire de linéarisation)

## Notes Techniques
- La classe `Lexer` implémente une tokenisation fidèle à la spécification PDF (gestion whitespace, commentaires, chaînes hexadécimales).
- `Parser` gère correctement les structures récursives (Array, Dict) et les streams imbriqués.
- `makeFilter` instancie tous les types de streams migrés.
- `makeInlineImage` inclut la logique complexe de détection de fin de stream pour les images inline (EI), y compris les cas particuliers pour les filtres DCT, ASCII85, ASCIIHex.
