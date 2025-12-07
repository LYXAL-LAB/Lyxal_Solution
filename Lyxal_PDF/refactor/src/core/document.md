# Refactorisation: PDFDocument

## Objectif
Portage 1:1 de `renderer/src/core/document.js` vers `rendererts/src/core/document.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `catalog.ts`
- `stream.ts`
- `pdf_manager.ts`

## Plan d'Implémentation `PDFDocument`

- [x] `PDFDocument` (classe principale)
- [x] Parsing du Header et du Trailer
- [x] Gestion des références croisées (XRef) via `XRef`
- [x] Initialisation du `Catalog`
- [x] `Page` (classe représentant une page PDF)

## Notes Techniques
- Cœur logique du document PDF, orchestre l'accès aux données.
- Utilisation de `@ts-ignore` pour les imports non encore migrés (`Linearization`, `XFAFactory`).
- Typage partiel avec `any` pour les parties interagissant avec des modules non migrés ou complexes (XFA).
