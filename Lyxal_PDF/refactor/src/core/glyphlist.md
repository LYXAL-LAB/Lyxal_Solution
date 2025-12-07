# Refactorisation: Glyphlist

## Objectif
Portage 1:1 de `renderer/src/core/glyphlist.js` vers `rendererts/src/core/glyphlist.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/core_utils.ts` (`getLookupTableFactory`)

## Plan d'Implémentation `Glyphlist`

- [x] `getGlyphsUnicode` (Mapping massif glyph name -> unicode)
- [x] `getDingbatsGlyphsUnicode` (Mapping Dingbats)

## Notes Techniques
- Fichier contenant principalement des données statiques (>4500 lignes).
- Copié directement depuis le JS et adapté pour TypeScript (ajout de `t: any`).

