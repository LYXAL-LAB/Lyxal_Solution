# Refactorisation: Operator List

## Objectif
Portage 1:1 de `renderer/src/core/operator_list.js` vers `rendererts/src/core/operator_list.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts`

## Plan d'Implémentation `OperatorList`

- [x] `OperatorList` (Classe principale)
  - [x] `addOp` (Ajout d'opération simple)
  - [x] `addImageOps` (Ajout d'image avec gestion masque/OC)
  - [x] `flush` (Envoi vers le stream sink)
  - [x] `QueueOptimizer` (Optimiseur de file d'attente)
    - [x] `iterateInlineImageGroup`, `foundInlineImageGroup`
    - [x] `iterateImageMaskGroup`, `foundImageMaskGroup`
    - [x] `iterateImageGroup`
    - [x] `iterateShowTextGroup`
    - [x] `constructPath` optimization

## Notes Techniques
- Gère la liste des opérations graphiques (Display List) envoyées au thread principal (worker -> main).
- L'optimiseur fusionne les opérations répétitives (ex: affichage de caractères individuels transformé en chaîne, tuiles d'images fusionnées) pour réduire la taille des messages et le nombre d'appels Canvas.

