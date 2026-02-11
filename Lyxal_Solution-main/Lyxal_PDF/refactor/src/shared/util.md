# Refactorisation: Shared Util

## Objectif
Portage 1:1 de `renderer/src/shared/util.js` vers `rendererts/src/shared/util.ts`.

## Dépendances à consolider AVANT
Aucune. Ce fichier est une feuille dans l'arbre des dépendances (niveau 0).

## Plan d'Implémentation `Util`

### Constantes et Enums
- [ ] `RenderingIntentFlag`
- [ ] `AnnotationMode`
- [ ] `AnnotationEditorType`
- [ ] `AnnotationEditorParamsType`
- [ ] `PermissionFlag`
- [ ] `MeshFigureType`
- [ ] `TextRenderingMode`
- [ ] `ImageKind`
- [ ] `AnnotationType`
- [ ] `AnnotationReplyType`
- [ ] `AnnotationFlag`
- [ ] `AnnotationFieldFlag`
- [ ] `AnnotationBorderStyleType`
- [ ] `AnnotationActionEventType`
- [ ] `DocumentActionEventType`
- [ ] `PageActionEventType`
- [ ] `VerbosityLevel`
- [ ] `OPS` (Opérateurs PDF)
- [ ] `DrawOPS`

### Utilitaires Globaux
- [ ] `isNodeJS` (Détection environnement)
- [ ] `setVerbosityLevel` / `getVerbosityLevel`
- [ ] `info` / `warn` (Loggers)
- [ ] `unreachable` / `assert` (Assertions critiques)
- [ ] `shadow` (Helper pour properties non-énumérables)

### Exceptions (Héritage Error)
- [ ] `BaseException` (Classe de base abstraite)
- [ ] `PasswordException`
- [ ] `UnknownErrorException`
- [ ] `InvalidPDFException`
- [ ] `ResponseException`
- [ ] `FormatError`
- [ ] `AbortException`

### String & Bytes Utils
- [ ] `bytesToString` / `stringToBytes`
- [ ] `string32`
- [ ] `toHexUtil` / `toBase64Util` / `fromBase64Util` (Polyfills)
- [ ] `stringToPDFString` (Décodage PDFDocEncoding / UTF-16BE / UTF-8)
- [ ] `stringToUTF8String` / `utf8StringToString`

### Math & Geometry (Class `Util`)
- [ ] `makeHexColor`
- [ ] `transform` / `applyTransform` (Matrices 2D)
- [ ] `minMax` calculations (Bounding boxes)
- [ ] `normalizeRect`
- [ ] `intersect`
- [ ] `singularValueDecompose2dScale`

### Feature Tests
- [ ] `FeatureTest` (Support navigateur : LittleEndian, Eval, OffscreenCanvas, etc.)

## Notes Techniques
- Les polyfills (`Promise.try`, `Math.sumPrecise`, `AbortSignal.any`) doivent être traités avec soin en TypeScript.
- `PDFJSDev` est une variable globale injectée au build, à déclarer en `any` ou `declare const`.

