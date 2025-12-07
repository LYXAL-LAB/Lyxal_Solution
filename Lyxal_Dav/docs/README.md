# Lyxal_Dav - CalDAV Server Documentation

## Overview

Lyxal_Dav is a CalDAV server built with Bun/TypeScript that uses SurrealDB as its backend. It provides calendar synchronization compatible with iOS, macOS, Thunderbird, and other CalDAV clients.

---

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌────────────────────┐
│  CalDAV Client  │────▶│  Lyxal_Dav   │────▶│  SurrealDB         │
│  (iOS, macOS)   │◀────│  (Bun/TS)    │◀────│  (with ical::)     │
└─────────────────┘     └──────────────┘     └────────────────────┘
```

---

## Features Implemented

### Core CalDAV (RFC 4791)
| Feature | Status | Description |
|---------|--------|-------------|
| **GET** | ✅ | Retrieve calendar objects |
| **PUT** | ✅ | Create/update events |
| **DELETE** | ✅ | Remove events |
| **PROPFIND** | ✅ | List calendars and properties |
| **REPORT** | ✅ | Calendar-query support |
| **MKCALENDAR** | ✅ | Create new calendars |

### CalDAV Scheduling (RFC 6638)
| Feature | Status | Description |
|---------|--------|-------------|
| **Free/Busy** | ✅ | VFREEBUSY queries |
| **Inbox** | ✅ | Receive iTIP messages |
| **Outbox** | ✅ | Send iTIP messages |

### iTIP Scheduling (RFC 5546)
| Method | Status | Description |
|--------|--------|-------------|
| **REQUEST** | ✅ | Send meeting invitations |
| **REPLY** | ✅ | Accept/decline meetings |
| **CANCEL** | ✅ | Cancel meetings |

---

## Key Files

| File | Purpose |
|------|---------|
| `src/server.ts` | HTTP request handling, routing |
| `src/backend.ts` | Business logic, SurrealDB queries |
| `src/principal.ts` | User/principal management |
| `src/auth.ts` | Authentication (Basic Auth) |
| `src/xml.ts` | XML response generation |

---

## Endpoints

```
/well-known/caldav          → CalDAV discovery
/principals/users/{user}    → User properties (PROPFIND)
/calendars/{user}/          → Calendar home (PROPFIND, MKCALENDAR)
/calendars/{user}/{cal}/    → Calendar collection
/calendars/{user}/{cal}/{event}.ics → Individual event
/calendars/{user}/inbox/    → Scheduling Inbox
```

---

## Usage Examples

### Start Server
```bash
bun run src/index.ts
```

### Send Free/Busy Request
```bash
curl -X POST http://localhost:3000/calendars/alice \
  -u alice:password \
  -H "Content-Type: text/calendar" \
  -d 'BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VFREEBUSY
DTSTART:20250101T000000Z
DTEND:20250102T000000Z
END:VFREEBUSY
END:VCALENDAR'
```

### Send Meeting Invitation
```bash
curl -X POST http://localhost:3000/calendars/alice \
  -u alice:password \
  -H "Content-Type: text/calendar" \
  -d 'BEGIN:VCALENDAR
VERSION:2.0
METHOD:REQUEST
BEGIN:VEVENT
UID:meeting-1
SUMMARY:Team Meeting
ORGANIZER:mailto:alice@lyxal.local
ATTENDEE:mailto:bob@lyxal.local
END:VEVENT
END:VCALENDAR'
```

---

# SurrealDB iCal Extensions

## Custom Native Functions

We've extended SurrealDB 3.0-alpha with native iCalendar parsing functions.

### Installation

The custom SurrealDB binary is located at:
```
surrealdb-3.0.0-alpha.16/target/release/surreal.exe
```

### Available Functions

| Function | Description | Example |
|----------|-------------|---------|
| `ical::parse(text)` | Parse first VEVENT to object | `{ summary, uid, dtstart }` |
| `ical::events(text)` | Parse all VEVENTs to array | `[{...}, {...}]` |
| `ical::get(text, prop)` | Extract specific property | `"Meeting Title"` |
| `ical::has(text, comp)` | Check component exists | `true/false` |
| `ical::method(text)` | Get iTIP METHOD | `"REQUEST"` |
| `ical::attendees(text)` | Extract attendee emails | `["bob@...", "charlie@..."]` |
| `ical::organizer(text)` | Extract organizer email | `"alice@..."` |

### Usage in SurrealQL

```surql
-- Parse an iCalendar event
LET $ical = "BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:test-123
SUMMARY:My Meeting
DTSTART:20250106T140000Z
ATTENDEE;CN=Bob:mailto:bob@example.com
END:VEVENT
END:VCALENDAR";

-- Use the functions
RETURN ical::parse($ical);
-- → { uid: "test-123", summary: "My Meeting", dtstart: "20250106T140000Z" }

RETURN ical::attendees($ical);
-- → ["bob@example.com"]
```

### Use with DEFINE API (Future)

```surql
DEFINE API "/calendars/:user/:calendar/:object"
FOR put
MIDDLEWARE api::req::raw_body(true)
THEN {
    LET $parsed = ical::parse(<string>$request.body);
    
    CREATE calendarobjects SET
        uri = $request.params.object,
        summary = $parsed.summary,
        dtstart = $parsed.dtstart,
        attendees = ical::attendees(<string>$request.body);
    
    RETURN { status: 201 };
};
```

---

## Modified SurrealDB Files

| File | Changes |
|------|---------|
| `crates/core/src/fnc/ical.rs` | New module with 7 functions |
| `crates/core/src/fnc/mod.rs` | Module registration + dispatcher |
| `crates/core/src/syn/parser/builtin.rs` | Parser registration |

---

## Future Extensions

### Priority 1: Production Ready
- [ ] Fix `@lyxal/surreal` module errors
- [ ] Add OAuth2 authentication
- [ ] Automated test suite

### Priority 2: CalDAV Enhancements
- [ ] VTODO support
- [ ] VJOURNAL support
- [ ] Advanced recurrence handling
- [ ] Alarms/reminders

### Priority 3: SurrealDB Functions
- [ ] `ical::stringify()` - Rebuild iCal from object
- [ ] `xml::parse()` - Parse XML requests
- [ ] `xml::build()` - Generate XML responses

### Priority 4: Full SurrealDB CalDAV
- [ ] Fix DEFINE API raw_body for non-JSON
- [ ] Move PROPFIND/REPORT to SurrealQL
- [ ] 100% CalDAV in database layer

---

## Building SurrealDB with Extensions

### Prerequisites
- Rust (rustup)
- Visual Studio Build Tools 2022
- LLVM/Clang

### Compile
```powershell
cd surrealdb-3.0.0-alpha.16/surrealdb-3.0.0-alpha.16
cargo build --release
```

### Run
```powershell
.\target\release\surreal.exe start --user root --pass root memory
```

---

## Links

- [CalDAV RFC 4791](https://datatracker.ietf.org/doc/html/rfc4791)
- [CalDAV Scheduling RFC 6638](https://datatracker.ietf.org/doc/html/rfc6638)
- [iTIP RFC 5546](https://datatracker.ietf.org/doc/html/rfc5546)
- [SurrealDB](https://surrealdb.com)
