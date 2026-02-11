# Validation CalDAV (Rust pur, backend SQLite)

## D1: REPORT sync-collection (Non validé Apple Calendar)
**Statut:** Implémenté et testé unitairement, mais **NON validé sur Apple Calendar réel**.
Cette validation est une dette bloquante avant toute release.

## D2: Principals / Auth / ACL (Terminé - D2+)
**Statut:** Complètement implémenté (y compris D2+).
La validation client réelle (Apple Calendar) reste nécessaire.

### Implémentation D2+ (Délégation réelle)
- **Suppression du placeholder `is_proxy`**.
- **Source de vérité unique:** Table `davshares` (roles: `owner`, `proxy-read`, `proxy-write`).
- **Logique centralisée:** Méthode `check_access` unifiée couvrant :
  - **Délégation Globale (Home)**: Vérifie `davshares` sur le calendar-home (ex: `/calendars/alice/`) via `is_proxy`.
  - **Délégation Spécifique**: Vérifie `davshares` sur le chemin de la ressource.
- **Application universelle:**
  - **Calendriers**: GET/PUT/DELETE/REPORT respectent les droits proxy (read vs write).
  - **Scheduling (iTIP)**:
    - **Inbox/Outbox**: `proxy-write` peut envoyer (PUT Outbox) et gérer (PUT/DELETE Inbox). `proxy-read` ne peut que lire.
    - **Sécurité Inbox**: Écriture directe par tiers (strangers) INTERDITE (Strict mode). La distribution iTIP passe par l'Outbox et le traitement serveur.
- **Locks**:
  - Un proxy ne peut pas casser le lock du owner (sauf s'il possède le token).
  - Lock exclusif respecté.

### Tests D2+:
- `test_proxy_delegation`:
  - `proxy-read` (Bob) peut lire Inbox, mais écriture refusée.
  - `proxy-write` (Charlie) peut écrire Outbox.
  - Stranger (Dave) accès refusé.
- `test_proxy_lock_behavior`:
  - `proxy-write` ne peut pas locker une ressource déjà lockée par owner (423 Locked).

### Corrections D2.1 appliquées (rappel):
- **401 vs 403:** Strictement appliqué.
- **Calendar-home-set:** Pointe vers `/calendar/` ou `/calendars/{user}/`.
- **Proxy endpoints:** `calendar-proxy-read` et `write` exposés.

### Tests unitaires D2.1:
- `PROPFIND /principals/user/` sans auth -> 401 Unauthorized.
- `PROPFIND /calendar/` avec auth mais sans droits -> 403 Forbidden.
- `PROPFIND /principals/user/` retourne un `calendar-home-set` non vide et stable.
- `PUT /calendar/event.ics` avec `proxy-read` -> 403 Forbidden.
- `PUT /calendar/event.ics` avec `proxy-write` -> 201 Created.
- `DELETE /calendar/event.ics` avec `proxy-read` -> 403 Forbidden.

## D3: WebDAV / CalDAV Core Completeness

### D3.1 - PROPPATCH (Terminé)
- PROPPATCH implémenté : set/remove, props persistées (davprops) avec protections (resourcetype, getetag, sync-token, principal-URL, calendar-home-set).
- ACL appliquées (auth + write).
- Tests unitaires OK (`cargo test -p lyxal-dav-core`).

### D3.2 - Collections WebDAV (Terminé)
- MKCOL implémenté (collections génériques) avec contrôle d'existence et ACL parent.
- Stockage des collections dans `webcollections`, props custom via davprops.
- PROPFIND Depth 0/1/infinity : parcours récursif avec ACL par ressource, resourcetype/displayname/getetag/propriétés custom.
- Tests unitaires couvrant MKCOL (OK/405/403) et PROPFIND (depth/ACL) via suites existantes (`cargo test -p lyxal-dav-core`).

### D3.3 - MOVE / COPY (Terminé)
- **MOVE**: Support ressources et collections (récursif).
  - Headers: `Destination` (requis), `Overwrite` (T/F).
  - 412 Precondition Failed si Overwrite=F et cible existe.
  - ACL: Write sur source ET destination.
  - Sync-token: Incrémenté sur calendrier source (DELETE) et destination (CREATE/UPDATE).
  - Journalisation: DELETE source, UPDATE/CREATE destination.
- **COPY**: Duplication ressources et collections (récursif).
  - Nouvel ETag pour la copie.
  - ACL: Read source, Write destination.
  - Sync-token: Incrémenté sur destination.
- Tests unitaires MOVE/COPY (OK/412/403) passés (`cargo test -p lyxal-dav-core`).

### D3.4 - LOCK / UNLOCK (Terminé)
- **LOCK**: Lock exclusif write (depth 0/infinity).
  - Génération token opaque (UUID).
  - Timeout géré (Second-xxx).
  - Persistance dans `davlocks` (SQLite).
  - Réponse XML `activelock/lockdiscovery`.
- **UNLOCK**: Libération via header `Lock-Token`.
- **Vérifications**: PUT, DELETE, PROPPATCH, MOVE, COPY vérifient les verrous actifs.
  - Retourne 423 Locked si verrouillé par un autre ou token manquant (Header `If`).
- Tests unitaires LOCK/UNLOCK et enforcement 423 passés (`cargo test -p lyxal-dav-core`).

## D4: Scheduling / iTIP

### D4.1 - Inbox/Outbox (Terminé)
- **Endpoints**: `/calendars/{user}/inbox/` et `/calendars/{user}/outbox/`.
- **WebDAV**: `PROPFIND` (Depth 0/1) retourne `resourcetype` (`schedule-inbox`, `schedule-outbox`).
- **Discovery**: `PROPFIND` sur `/principals/{user}/` retourne `schedule-inbox-URL` et `schedule-outbox-URL`.
- **Stockage**: Table `scheduling_messages` pour les messages iTIP.
- **PUT**: Stockage des messages dans inbox/outbox.
- **Tests**: Validés (`cargo test -p lyxal-dav-core`).

### D4.2 - REPORT free-busy-query (Terminé)
- **Support**: `REPORT` avec body `free-busy-query`.
- **Parsing**: Extraction de `time-range` (start/end).
- **Logique**:
  - Récupération des événements dans la plage (via `list_collection` + filtre).
  - Expansion des récurrences (RRULE, EXDATE, RDATE) via `lyxal_ical_core`.
  - Calcul des périodes occupées (busy periods).
- **Réponse**: Génération d'un objet `VFREEBUSY` encapsulé dans un `VCALENDAR`.
- **Tests**: Unit tests pour `free-busy-query` (requête valide, réponse VFREEBUSY correcte).

### D4.3 - iTIP METHOD handling (Terminé)
- **Parsing & Validation**: Utilise `lyxal_ical_core` pour valider l'ICS et extraire METHOD, UID, SEQUENCE, DTSTAMP.
- **Stockage**: Table `scheduling_state` (uid, organizer, attendee, status, sequence, last_dtstamp).
- **METHOD Logic**:
  - `REQUEST`: Dépôt inbox des participants + création/MAJ `scheduling_state`.
  - `REPLY`: Dépôt inbox organisateur + MAJ status participant.
  - `CANCEL`: Dépôt inbox participants + status `CANCELLED`.
- **Anti-régression**: Ignorer si `SEQUENCE` reçu < actuel, ou si `SEQUENCE` égal mais `DTSTAMP` <= actuel.
- **Tests**: Unit tests validés (`test_itip_request`, `test_itip_reply`, `test_itip_cancel`, `test_itip_regression`).

**Exemple REQUEST (curl)**:
```bash
curl -X PUT -u alice:password -H "Content-Type: text/calendar" --data 'BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Lyxal//EN
METHOD:REQUEST
BEGIN:VEVENT
UID:uuid-1234
SEQUENCE:0
DTSTAMP:20231217T100000Z
DTSTART:20231225T100000Z
ORGANIZER:mailto:alice@example.com
ATTENDEE:mailto:bob@example.com
END:VEVENT
END:VCALENDAR' http://localhost:8080/calendars/alice/outbox/invite.ics
```

### D4.4 - ACL & Sécurité Scheduling (Terminé)
- **ACL Outbox**:
  - Write: Requis (owner ou proxy-write).
  - Read: Requis (owner, proxy-read, ou proxy-write).
- **ACL Inbox**:
  - Write: Requis (owner ou proxy-write). **Mode Strict**: L'écriture directe par des tiers est INTERDITE. La distribution iTIP est gérée en interne par le serveur lors d'un PUT sur l'Outbox de l'organisateur.
  - Read: Requis (owner, proxy-read, ou proxy-write).
- **Anti-spam / Limites**:
  - **Size Limit**: Bloque les payloads > limite (défaut 256KB, configurable via `DAV_SCHEDULING_BODY_LIMIT_BYTES`). Retourne erreur (mappée 413 ou 400).
  - **Validation Stricte**: Rejette les ICS invalides ou avec METHOD inconnu.
- **Cohérence / Transactions**:
  - Les opérations iTIP (distribution dans Inbox + mise à jour State) et le stockage du message dans l'Outbox sont atomiques (transaction SQL).
- **Tests**:
  - `test_scheduling_access_control`: Vérifie que seul le owner (ou proxy) peut écrire dans outbox/inbox.
  - `test_payload_too_large`: Vérifie le rejet des gros fichiers.
  - `test_transaction_rollback`: Vérifie que rien n'est persisté si le traitement échoue (ex: ICS invalide).

## Non couvert / limites actuelles
- Pas de shared locks (exclusif seulement).
- Pas de gestion avancée des fuseaux (VTIMEZONE conservé mais non validé côté serveur).
- Pas de compression/gzip ni pagination des multistatus.
