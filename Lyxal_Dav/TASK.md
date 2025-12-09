# Développement Lyxal_Dav

## État actuel ✅
- [x] Structure workspace créée (style surrealml)
- [x] Module `core` avec compilation réussie
- [x] Module `ical` migré (parse, stringify, occurrences, etc.)
- [x] Module `xml` (parse/generate DAV XML)
- [x] Module `methods` (PROPFIND, REPORT)
- [x] Trait `DavBackend`

## Phase 1 : Complétion des méthodes DAV
- [ ] Implémenter PUT handler
- [ ] Implémenter GET handler
- [ ] Implémenter DELETE handler
- [ ] Implémenter MKCALENDAR handler

## Phase 2 : Amélioration PROPFIND/REPORT
- [ ] Support `Depth: 0` / `Depth: 1` / `Depth: infinity`
- [ ] Filter par propriétés demandées
- [ ] Génération CTag dynamique
- [ ] Support calendar-multiget avec filtrage

## Phase 3 : Récurrence et RRULE
- [ ] Intégration `ical::occurrences` dans `query_collection`
- [ ] Expansion des occurrences pour REPORT time-range
- [ ] Gestion EXDATE (exclusions)

## Phase 4 : Serveur de test autonome
- [ ] Créer `bin/test_server.rs`
- [ ] Mock backend en mémoire
- [ ] Endpoint HTTP `/dav/...`
- [ ] Tests avec curl/httpie

## Phase 5 : Tests et validation
- [ ] Tests unitaires complets
- [ ] Tests d'intégration avec clients CalDAV
- [ ] Documentation API
