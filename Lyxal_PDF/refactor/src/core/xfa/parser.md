# Refactorisation: XFA Parser

## Objectif
Portage 1:1 de `renderer/src/core/xfa/parser.js` vers `rendererts/src/core/xfa/parser.ts`.

## État
- **Date**: 2025-12-05
- **Status**: **TERMINÉ**

## Dépendances à consolider AVANT
- `core/xml_parser.ts`
- `core/xfa/xfa_object.ts`
- `core/xfa/unknown.ts`
- `core/xfa/namespaces.ts`

## Plan d'Implémentation `XFAParser`

- [x] `XFAParser` (classe)
- [x] Hérite de `SimpleXMLParser`
- [x] Parsing XML spécifique à XFA et mapping vers les objets XFA

## Notes Techniques
- Parse le XML XFA et construit l'arbre d'objets XFA correspondant.
- Utilisation de `@ts-ignore` pour les symboles importés et `Builder` non typé.
