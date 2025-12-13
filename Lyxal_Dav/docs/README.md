# Lyxal_Dav — CalDAV (Rust only)

## Position CTO (non négociable)
- Aucune logique iCal en TypeScript. La vérité iCalendar est Rust.
- Crate dédié à créer : `crates/lyxal_ical_core` (parse/stringify/récurrences/timezones/validation).
- Fonctions natives Surreal `ical::*` (feature flag) consommeront ce core.
- Lyxal_Dav est un consommateur du core iCal, jamais l’inverse.

## État actuel (prototype Rust)
- Serveur Axum (`modules/server`) avec backend SQLite persistant (ETag déterministe, If-Match/If-None-Match, sync-token via calendarchanges).
- Méthodes supportées : PROPFIND, REPORT (calendar-query, multiget), GET, PUT, DELETE, MKCALENDAR, OPTIONS.
- Backend mémoire supprimé ; SQLite unique backend de référence en attendant Surreal.
- Module iCal actuel dans `modules/core/src/ical.rs` est provisoire et doit être remplacé par `lyxal_ical_core`.

## Roadmap (extrait CTO)
1) Crate `lyxal_ical_core` (Rust only) : parsing RFC5545 strict, stringify canonique, récurrences complètes (RRULE/RDATE/EXDATE), VTIMEZONE, validation stricte.
2) Fonctions natives Surreal (`ical::parse`, `ical::stringify`, `ical::occurrences`) sous feature `ical` (error FeatureNotEnabled si off).
3) Lyxal_Dav branché sur `lyxal_ical_core` (suppression de `modules/core/src/ical.rs`).
4) CalDAV complet : REPORT sync-collection, principals/chemins canoniques, scheduling iTIP/iMIP, freebusy, PROPPATCH si requis.
5) Validation clients réels (Apple/Thunderbird).

## Démarrage (prototype)
```bash
cargo run -p lyxal-dav-server
```
Backend par défaut : SQLite (`sqlite://dav.db`).

## Références internes
- Code serveur : `modules/server/src/main.rs`, `modules/server/src/sqlite_backend.rs`
- Core DAV (handlers) : `modules/core/src/*`
- Validation manuelle : `docs/VALIDATION.md`
- Le dossier `reference/` (PHP SabreDAV) reste uniquement comme base de comparaison.***
