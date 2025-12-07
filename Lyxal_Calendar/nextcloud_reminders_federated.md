## 8. **calendar_reminders** (Rappels/Notifications)

**Système de rappels pour événements** (Ajouté en 2019)

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `calendar_id` | BIGINT (FK) | Référence à calendars |
| `object_id` | BIGINT (FK) | Référence à calendarobjects |
| `is_recurring` | SMALLINT | Event récurrent (0/1) |
| `uid` | STRING(255) | UID de l'événement |
| `recurrence_id` | BIGINT | ID de récurrence |
| `is_recurrence_exception` | SMALLINT | Exception à récurrence (0/1) |
| `event_hash` | STRING(255) | Hash de l'événement |
| `alarm_hash` | STRING(255) | Hash de l'alarme |
| `type` | STRING(255) | Type de rappel (EMAIL, DISPLAY, AUDIO) |
| `is_relative` | SMALLINT | Relatif ou absolu (0/1) |
| `notification_date` | BIGINT | Timestamp de notification |
| `is_repeat_based` | SMALLINT | Basé sur répétition (0/1) |

### Index
- PRIMARY KEY: `id`
- INDEX: `[object_id]`
- INDEX: `[uid, recurrence_id]`

**Usage** : Gère les alarmes VALARM du format iCal

---

## 9. **calendars_federated** (Calendriers Fédérés)

**Calendriers partagés entre instances Nextcloud** (Ajouté en 2025 !)

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `display_name` | STRING(255) | Nom du calendrier |
| `color` | STRING(7) | Couleur hexa (#FF0000) |
| `uri` | STRING(255) | URI unique |
| `principaluri` | STRING(255) | URI de l'utilisateur local |
| `remote_Url` | STRING(255) | URL de l'instance distante |
| `token` | STRING(255) | Token d'authentification |
| `sync_token` | INTEGER | Token de synchronisation |
| `last_sync` | BIGINT | Timestamp dernière sync |
| `shared_by` | STRING(255) | Utilisateur distant partageant |
| `shared_by_display_name` | STRING(255) | Nom affiché du partageur |
| `components` | STRING(255) | Types d'objets supportés |
| `permissions` | INTEGER | Permissions (READ/WRITE) |

### Index
- PRIMARY KEY: `id`
- INDEX: `[principaluri, uri]`
- INDEX: `[last_sync]`

**Feature** : Federation CalDAV (partage inter-instances Nextcloud)

---
