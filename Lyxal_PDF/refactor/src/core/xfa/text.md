# Refactorisation: XFA Text

## Objectif
Portage 1:1 de `renderer/src/core/xfa/text.js` vers `rendererts/src/core/xfa/text.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/fonts.ts`
- `core/xfa/html_utils.ts`

## Plan d'Implémentation `Text`

- [x] Classe `TextMeasure`
- [x] Calculs de mise en page du texte (mesure, rendu HTML)

## Notes Techniques
- Gère la mesure et le rendu du texte enrichi dans les formulaires XFA.
- Utilise `@ts-ignore` pour l'import de `fonts.js` (car `selectFont` vient de `fonts.ts` qui est migré mais pas encore pleinement intégré partout sans ignore dans ce contexte JS->TS progressif).
- Utilise `any` pour les objets de police et les glyphes.
