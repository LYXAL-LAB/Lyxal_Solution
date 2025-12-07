# Refactorisation: XMLParser

## Objectif
Portage 1:1 de `renderer/src/core/xml_parser.js` vers `rendererts/src/core/xml_parser.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- Aucune (utilitaire autonome)

## Plan d'Implémentation `XMLParser`

- [x] `XMLParserBase` (classe de base)
- [x] `SimpleXMLParser` (implémentation)
- [x] Parsing XML simple sans DOM

## Notes Techniques
- Utilisé pour parser les métadonnées XMP et autres structures XML dans le PDF sans dépendre du DOM du navigateur.
- Types `any` utilisés pour la structure DOM interne simplifiée afin de faciliter la migration sans reconstruire un typage DOM complet.
