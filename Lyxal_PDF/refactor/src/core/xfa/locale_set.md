# Refactorisation: XFA Locale Set

## Objectif
Portage 1:1 de `renderer/src/core/xfa/locale_set.js` vers `rendererts/src/core/xfa/locale_set.ts`.

## État
- **Date**: 2025-12-06
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xfa/xfa_object.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `LocaleSet`

- [x] Namespace `LocaleSet`
- [x] Gestion des paramètres régionaux (locale)

## Notes Techniques
- Gère les définitions de localisation (dates, nombres, monnaies) pour XFA.
- Utilise `any` pour les attributs et `[key: string]: any` pour l'accès dynamique.
