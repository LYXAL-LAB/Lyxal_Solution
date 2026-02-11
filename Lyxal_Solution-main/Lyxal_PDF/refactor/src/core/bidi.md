# Refactorisation: Bidi

## Objectif
Portage 1:1 de `renderer/src/core/bidi.js` vers `rendererts/src/core/bidi.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (`warn`)

## Plan d'Implémentation `Bidi`

- [x] `bidi` (Algorithme bidirectionnel unicode simplifié)

## Notes Techniques
- Implémente une version partielle de l'algorithme Unicode Bidirectional (UAX #9) suffisante pour le rendu PDF.
- Utilise des tableaux statiques réutilisés (`chars`, `types`) pour éviter les allocations mémoire répétées.

