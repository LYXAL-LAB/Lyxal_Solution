# Validation CalDAV (Rust pur, backend SQLite)

## Démarrage
- Backend unique : SQLite local `sqlite://dav.db`.
- Démarrage : `cargo run -p lyxal-dav-server`.

## Test manuel minimal (curl)
1. Créer un calendrier (idempotent si déjà présent) :
   ```
   curl -i -X MKCALENDAR http://127.0.0.1:3000/calendar
   ```
2. Déposer un événement :
   ```
   curl -i -X PUT \
     -H "Content-Type: text/calendar" \
     --data-binary @event.ics \
     http://127.0.0.1:3000/calendar/event1.ics
   ```
3. Vérifier la ressource et l’ETag :
   ```
   curl -i http://127.0.0.1:3000/calendar/event1.ics
   ```
4. PROPFIND profondeur 1 :
   ```
   curl -i -X PROPFIND -H "Depth: 1" http://127.0.0.1:3000/calendar
   ```
5. REPORT calendar-query (fenêtre temps) :
   ```
   curl -i -X REPORT \
     -H "Content-Type: application/xml" \
     --data-binary @calendar-query.xml \
     http://127.0.0.1:3000/calendar
   ```
6. Concurrence ETag (If-Match / If-None-Match) :
   ```
   curl -i -X PUT \
     -H "If-Match: \"<etag_obtenu>\"" \
     --data-binary @event.ics \
     http://127.0.0.1:3000/calendar/event1.ics
   ```

## Fonctionnel
- Méthodes : PROPFIND, REPORT (calendar-query, calendar-multiget), GET, PUT, DELETE, MKCALENDAR, OPTIONS.
- ETag déterministe (blake3) + préconditions If-Match / If-None-Match → 412 ou 304.
- Sync-token stocké par calendrier (champ `D:sync-token`).
- Backend : SQLite (référence pour future intégration Surreal).

## Non couvert / limites actuelles
- Pas d’authentification, pas d’ACL/LOCK.
- Pas de CalDAV scheduling (iTIP), pas de gestion avancée des fuseaux (VTIMEZONE conservé mais non validé côté serveur).
- Pas de compression/gzip ni pagination des multistatus.
- Tests clients réels (Apple/Thunderbird) à exécuter manuellement avec les commandes ci-dessus comme base.

