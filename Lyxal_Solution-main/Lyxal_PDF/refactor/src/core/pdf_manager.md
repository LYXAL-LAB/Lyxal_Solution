# Refactorisation: PDFManager

## Objectif
Portage 1:1 de `renderer/src/core/pdf_manager.js` vers `rendererts/src/core/pdf_manager.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `document.ts` (PDFDocument)
- `stream.ts`

## Plan d'Implémentation `PDFManager`

- [x] `PDFManager` (classe)
- [x] `LocalPdfManager` (classe)
- [x] `NetworkPdfManager` (classe)
- [x] Gestion des messages et des requêtes asynchrones

## Notes Techniques
- Gère le cycle de vie du document PDF et l'interface avec le worker/main thread.
- Utilisation de `@ts-ignore` pour les parties interagissant avec le gestionnaire de messages principal si nécessaire.
- Classes `BasePdfManager`, `LocalPdfManager`, `NetworkPdfManager` correctement typées et exportées.
