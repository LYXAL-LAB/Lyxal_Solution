# Refactorisation: ASCII85 Stream

## Objectif
Portage 1:1 de `renderer/src/core/ascii_85_stream.js` vers `rendererts/src/core/ascii_85_stream.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/decode_stream.ts` (OK)
- [x] `src/core/core_utils.ts` (OK - pour `isWhiteSpace`)

## Plan d'Implémentation `Ascii85Stream`

### Classe `Ascii85Stream`
- [x] Hérite de `DecodeStream`.
- [x] `constructor(str: BaseStream, maybeLength: number)`
- [x] `readBlock()` : Implémentation de la logique de décodage ASCII85.
    - [x] Gestion des caractères blancs (`isWhiteSpace`).
    - [x] Gestion du caractère spécial 'z' (4 octets nuls).
    - [x] Gestion de la fin de flux (`~>`).
    - [x] Décodage par blocs de 5 caractères -> 4 octets.

## Notes Techniques
- Logique purement algorithmique, pas de dépendances externes.
