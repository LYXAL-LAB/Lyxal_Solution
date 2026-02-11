# Refactorisation: Crypto

## Objectif
Portage 1:1 de `renderer/src/core/crypto.js` vers `rendererts/src/core/crypto.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK - bytesToString, stringToBytes, etc.)
- [x] `src/core/primitives.ts` (OK - Dict, Name)
- [x] `src/core/decrypt_stream.ts` (OK)
- [x] `src/core/calculate_md5.ts` (OK)
- [x] `src/core/calculate_sha256.ts` (OK)
- [x] `src/core/calculate_sha_other.ts` (OK - SHA384/512)

## Plan d'Implémentation `Crypto`

### Algorithmes de Chiffrement (Classes de Base)
- [x] `ARCFourCipher` (RC4)
- [x] `NullCipher` (Pas de chiffrement)
- [x] `AESBaseCipher` (Classe abstraite AES)
    - [x] `_encrypt`, `_decrypt` (Rijndael)
    - [x] `decryptBlock` (Mode CBC)
    - [x] `encrypt` (Mode CBC)
- [x] `AES128Cipher` (Hérite AESBaseCipher)
- [x] `AES256Cipher` (Hérite AESBaseCipher)

### Algorithmes de Sécurité PDF (Handlers)
- [x] `PDFBase` (Classe abstraite)
- [x] `PDF17` (Standard Security Handler rev 2-4)
- [x] `PDF20` (Standard Security Handler rev 5-6, ISO 32000-2)
    - [x] Implémentation complexe de `_hash` (Algorithme 2.B)

### Factory & Transforms
- [x] `CipherTransform`
    - [x] `createStream` (Utilise `DecryptStream`)
    - [x] `decryptString` / `encryptString`
- [x] `CipherTransformFactory`
    - [x] `constructor` (Analyse du dictionnaire Encrypt)
    - [x] `createCipherTransform` (Génération des clés par objet)
    - [x] `#prepareKeyData` (Calcul clé v2/v4)
    - [x] `#createEncryptionKey20` (Calcul clé v5 AES-256)

## Notes Techniques
- Migration complète en JS/TS pur, supprimant la dépendance erronée à Node `crypto`.
- Intègre les helpers de hachage migrés séparément.
