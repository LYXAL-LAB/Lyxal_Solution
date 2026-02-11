# Refactorisation: Metrics

## Objectif
Portage 1:1 de `renderer/src/core/metrics.js` vers `rendererts/src/core/metrics.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/core_utils.ts` (`getLookupTableFactory`)

## Plan d'Implémentation `Metrics`

- [x] `getMetrics` (Tables de largeurs de glyphes pour polices standard)
- [x] `getFontBasicMetrics` (Métriques de base : ascent, descent, etc.)

## Notes Techniques
- Fichier de données volumineux (>3000 lignes).
- Copié directement depuis le JS et typé minimalement (`any` pour les tables de lookup dynamiques).

