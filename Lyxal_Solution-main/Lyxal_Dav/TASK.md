# Développement Lyxal_Dav

## État actuel ✅
- [x] Structure workspace créée (style surrealml)
- [x] Module `core` avec compilation réussie
- [x] Module `ical` migré (parse, stringify, occurrences, etc.)
- [x] Module `xml` (parse/generate DAV XML)
- [x] Module `methods` (PROPFIND, REPORT)
- [x] Trait `DavBackend`

## Phase 1 : Complétion des méthodes DAV
- [x] Implémenter PUT handler
- [x] Implémenter GET handler
- [x] Implémenter DELETE handler
- [x] Implémenter MKCALENDAR handler

## Phase 2 : Amélioration PROPFIND/REPORT
- [x] Support `Depth: 0` / `Depth: 1` / `Depth: infinity`
- [x] Filter par propriétés demandées
- [x] Génération CTag dynamique (via backend)
- [x] Support calendar-multiget avec filtrage

## Phase 3 : Récurrence et RRULE
- [x] Intégration `ical::occurrences` dans `query_collection`
- [x] Expansion des occurrences pour REPORT time-range
- [x] Gestion EXDATE (exclusions)

## Phase 4 : Serveur de test autonome
- [x] Créer `bin/test_server.rs` (via modules/server)
- [x] Mock backend en mémoire
- [x] Endpoint HTTP `/dav/...`
- [x] Tests avec curl/httpie

## Phase 5 : Tests et validation
- [ ] Tests unitaires complets
- [ ] Tests d'intégration avec clients CalDAV
- [ ] Documentation API
