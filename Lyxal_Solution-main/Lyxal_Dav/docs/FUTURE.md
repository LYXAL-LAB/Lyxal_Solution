# Lyxal_Dav - Future Extensions Roadmap

This document outlines potential features and enhancements for the Lyxal_Dav CalDAV server. These are organized by priority and complexity.

---

## Priority 1: Production Readiness

### 1.1 Database Connection (`@lyxal/surreal`)
- **Issue**: The workspace package `@lyxal/surreal` is not resolving correctly.
- **Fix**: 
  - Ensure `package.json` at workspace root has `"workspaces": ["Lyxal_Dav", "Lyxal_Surreal"]`.
  - Run `bun install` from workspace root.
  - Or use `bun link` to create a local symlink.

### 1.2 Authentication Enhancement
- **Current**: Basic Auth with hardcoded credentials.
- **Target**: 
  - OAuth2/OIDC integration (Keycloak, Auth0).
  - API Token support.
  - Session management.

### 1.3 Automated Tests
- **Framework**: Bun's built-in test runner.
- **Coverage**:
  - Unit tests for Backend methods.
  - Integration tests for HTTP endpoints.
  - CalDAV compliance tests (DAVtest suite).

---

## Priority 2: CalDAV Enhancements

### 2.1 VTODO Support
- **Description**: Full task/todo management.
- **Implementation**:
  - Add `VTODO` to supported components.
  - Implement `task-home-set` discovery.
  - Handle completion status updates.

### 2.2 VJOURNAL Support
- **Description**: Journal/note entries.
- **Implementation**: Similar to VTODO, minimal additional logic.

### 2.3 Advanced Recurrence
- **Current**: Simple first/last occurrence denormalization.
- **Target**:
  - Full RRULE expansion using `@lyxal/ical`.
  - Exception handling (EXDATE, RDATE).
  - Recurrence-ID for instance modifications.

### 2.4 Alarms & Reminders
- **Description**: VALARM component support.
- **Implementation**:
  - Parse VALARM from events.
  - Expose via push notifications or email.
  - Snooze/dismiss tracking.

---

## Priority 3: Enterprise Features

### 3.1 Resource Booking
- **Description**: Meeting rooms, equipment.
- **Implementation**:
  - Resource principal type (`principals/resources/room-a`).
  - Auto-accept/decline based on availability.
  - Conflict detection.

### 3.2 Delegation
- **Description**: Secretary manages boss's calendar.
- **Implementation**:
  - `calendar-proxy-read`/`calendar-proxy-write` properties.
  - Impersonation in scheduling requests.

### 3.3 WebSocket Push
- **Description**: Real-time sync without polling.
- **Implementation**:
  - WebSocket endpoint for changes.
  - Notify on `synctoken` updates.
  - RFC 8030 (Web Push) for mobile.

### 3.4 External iTIP Delivery (Email)
- **Description**: Send invitations to users outside the system.
- **Implementation**:
  - SMTP integration.
  - iMIP (RFC 6047) formatting.
  - Incoming email parsing for replies.

---

## Priority 3.5: External Calendar Interoperability

> **Note**: Currently, only users on the same Lyxal_Dav server can share calendars. This section covers cross-platform sharing.

### 3.5.1 iCal Subscription (Read-Only Import)
- **Description**: Subscribe to external `.ics` URLs (Google, Apple, etc.).
- **Complexity**: 🟢 Easy
- **Implementation**:
  ```typescript
  // backend.ts
  async subscribeToExternalCalendar(principalUri: string, icalUrl: string) {
      // Periodic fetch of icalUrl
      // Parse with @lyxal/ical
      // Store as read-only calendar with sync
  }
  ```
- **Workflow**:
  ```
  Google Calendar ──[.ics URL]──▶ Lyxal_Dav (read-only copy)
  ```

### 3.5.2 iCal Export (Public URL)
- **Description**: Generate a public `.ics` URL for a Lyxal calendar.
- **Complexity**: 🟢 Easy
- **Implementation**:
  - Add `GET /calendars/{user}/{calendar}.ics` endpoint.
  - Return full calendar as iCalendar text.
  - Optional: Token-based access for private calendars.
- **Workflow**:
  ```
  Lyxal_Dav ──[.ics URL]──▶ Google Calendar (subscription)
  ```

### 3.5.3 iMIP Email Integration (Bi-Directional)
- **Description**: Send/receive invitations via email for external users.
- **Complexity**: 🔴 Complex
- **Components**:
  1. **Outbound**: SMTP to send `.ics` attachments.
  2. **Inbound**: IMAP/webhook to parse email replies.
- **Workflow**:
  ```
  Alice@lyxal ──[EMAIL+ICS]──▶ Carol@gmail.com
  Carol@gmail ──[REPLY EMAIL]──▶ Alice@lyxal (parsed & delivered to Inbox)
  ```
- **Dependencies**:
  - Nodemailer or similar for SMTP.
  - Email parsing library.

### 3.5.4 CalDAV Proxy (Federation)
- **Description**: Act as a proxy to fetch from other CalDAV servers.
- **Complexity**: 🔴 Complex
- **Use Case**: User adds their Google CalDAV credentials, Lyxal fetches their calendar.
- **Security Considerations**: OAuth2 token storage, credential encryption.

---

## Priority 4: Interoperability

### 4.1 CalDAV-Sync Extensions
- **Description**: Apple/Google specific extensions.
- **Examples**:
  - `calendar-color` (Apple).
  - `calendar-order` (Apple).
  - Push notifications (Apple).

### 4.2 CardDAV (Contacts)
- **Description**: Separate module `Lyxal_CardDav`.
- **Components**:
  - Address Book discovery.
  - vCard parsing/serialization.
  - Sync tokens.

### 4.3 WebDAV (Files)
- **Description**: Separate module `Lyxal_Files`.
- **Features**:
  - File/folder collections.
  - Locking (LOCK/UNLOCK).
  - Versioning.

---

## Implementation Notes

### File Structure
```
Lyxal_Dav/
├── src/
│   ├── server.ts       # HTTP handler
│   ├── backend.ts      # CalDAV backend logic
│   ├── database.ts     # SurrealDB connection
│   ├── auth.ts         # Authentication
│   ├── principal.ts    # User/Resource principals
│   ├── xml.ts          # XML response helpers
│   └── types.ts        # Type definitions
├── docs/
│   └── FUTURE.md       # This file
└── test/               # Future: Test files
```

### Adding a New Feature
1. Add types to `types.ts`.
2. Implement backend logic in `backend.ts`.
3. Add HTTP handling in `server.ts`.
4. Update principal properties if needed.
5. Add tests.
6. Update this document.

---

## References

- [RFC 4791 - CalDAV](https://tools.ietf.org/html/rfc4791)
- [RFC 6638 - Scheduling Extensions](https://tools.ietf.org/html/rfc6638)
- [RFC 7953 - Calendar Availability](https://tools.ietf.org/html/rfc7953)
- [CalConnect Calendar Resources](https://www.calconnect.org/)
