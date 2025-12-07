# Refactorisation: Binary CMap

## Objectif
Portage 1:1 de `renderer/src/core/binary_cmap.js` vers `rendererts/src/core/binary_cmap.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/shared/util.ts` (`FormatError`)

## Plan d'Implémentation `BinaryCMap`

- [x] `BinaryCMapStream`
- [x] `BinaryCMapReader`

## Notes Techniques
- Utilisation de `Uint8Array` pour les buffers.
- `cMap` est passé comme `any` car `CMap` est défini dans `cmap.ts` (dépendance cyclique potentielle si on importait, mais ici on ne fait que l'utiliser dynamiquement).
- `stack[--sp]` avec un shift nécessite un `@ts-ignore` ou un cast car TS n'aime pas les opérations bitwise sur des valeurs potentiellement undefined si sp sort des bornes (mais la logique interne garantit que non).

