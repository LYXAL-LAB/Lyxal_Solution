# Refactorisation: ICC ColorSpace

## Objectif
Portage 1:1 de `renderer/src/core/icc_colorspace.js` vers `rendererts/src/core/icc_colorspace.ts`.

## État
- **Date**: 2025-12-04
- **Status**: **COMPLET**

## Dépendances à consolider AVANT
- [x] `src/core/colorspace.ts`
- [x] `src/shared/util.ts`
- [ ] `external/qcms/qcms.js` (Hors scope core, importé tel quel)

## Plan d'Implémentation `IccColorSpace`

- [x] `IccColorSpace` (Classe wrapper pour QCMS)
  - [x] `constructor` (Initialisation Wasm/QCMS)
  - [x] `getRgb...` (Méthodes de conversion via QCMS)
- [x] `CmykICCBasedCS` (Implémentation spécifique pour CMYK avec profil par défaut)
- [x] Gestion du chargement synchrone Wasm/ICC (`fetchSync`).

## Notes Techniques
- Utilise la bibliothèque externe `qcms` (portage Rust/Wasm de LittleCMS/QCMS) pour la gestion des profils ICC.
- Nécessite le chargement d'un module Wasm (`qcms_bg.wasm`) et d'un profil ICC par défaut pour CMYK.
- L'API est asynchrone dans le navigateur mais ici contrainte au synchrone pour le parsing PDF existant.

