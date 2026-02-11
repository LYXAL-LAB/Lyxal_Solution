# Refactorisation: Worker

## Objectif
Portage 1:1 de `renderer/src/core/worker.js` vers `rendererts/src/core/worker.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `pdf_manager.ts`
- `worker_stream.ts`
- `document.ts`

## Plan d'Implémentation `Worker`

- [x] `WorkerMessageHandler` (classe)
- [x] Gestion des messages du worker
- [x] Initialisation du `LocalPdfManager` ou `NetworkPdfManager`

## Notes Techniques
- Point d'entrée du worker thread PDF.js.
- Utilisation de `@ts-ignore` pour `Promise.withResolvers()` qui peut ne pas être défini dans les types par défaut de l'environnement, et pour l'initialisation du port.
- Classes correctement typées et exportées.
