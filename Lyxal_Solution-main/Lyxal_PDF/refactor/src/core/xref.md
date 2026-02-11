# Refactorisation: XRef

## Objectif
Portage 1:1 de `renderer/src/core/xref.js` vers `rendererts/src/core/xref.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (OK)
- [x] `src/core/primitives.ts` (OK - Ref, Dict, Cmd, RefSet)
- [x] `src/core/parser.ts` (OK)
- [x] `src/core/core_utils.ts` (OK - Exceptions)
- [x] `src/core/base_stream.ts` (OK)
- [ ] `src/core/crypto.ts` (En cours de migration - Import temporairement ignoré par `@ts-ignore`)

## Plan d'Implémentation `XRef`

### Gestion du Cache & Références
- [x] `_cacheMap` (Map des objets chargés)
- [x] `_pendingRefs` (RefSet pour détecter les cycles)
- [x] `_xrefStms` (Set pour éviter la récursion infinie des XRefStm)
- [x] Gestion des références temporaires et persistantes (`getNewPersistentRef`, `getNewTemporaryRef`, `resetNewTemporaryRef`).

### Parsing & Récupération
- [x] `parse(recoveryMode)` : Point d'entrée principal.
- [x] `processXRefTable` & `readXRefTable` : Lecture des tables xref classiques (PDF 1.4-).
- [x] `processXRefStream` & `readXRefStream` : Lecture des flux xref (PDF 1.5+).
- [x] `indexObjects()` : Méthode de fallback pour scanner tout le fichier en cas de corruption.

### Fetching
- [x] `fetch(ref)` : Récupération avec gestion de cache et détection de cycles.
- [x] `fetchUncompressed` : Lecture directe depuis le fichier.
- [x] `fetchCompressed` : Lecture depuis un Object Stream (ObjStm). Peuple le cache avec tous les objets du flux.
- [x] `fetchAsync` : Wrapper pour la récupération asynchrone.

### Crypto
- [x] Intégration avec `CipherTransformFactory` (Appel présent, dépendance à migrer).

## Notes Techniques
- La classe a été entièrement réécrite pour correspondre à la logique originale JS, abandonnant la version simplifiée précédente.
- `indexObjects` est présent pour la robustesse.
- Le typage est strict sur les entrées XRef (`XRefEntry`).
