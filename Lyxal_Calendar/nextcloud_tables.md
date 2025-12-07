# Nextcloud Calendar - Tables de Base de Données

## 📊 Tables Identifiées (6 tables)

Basé sur l'analyse des fichiers de migration dans `lib/Migration/`

---

## 1. **calendar_appt_configs** (Configurations de Rendez-vous)

**Migration**: Version2040Date20210908101001.php

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `token` | STRING(128) UNIQUE | Token public d'accès |
| `name` | STRING(128) | Nom du type de rendez-vous |
| `description` | TEXT | Description |
| `location` | TEXT | Lieu |
| `visibility` | STRING(10) | PUBLIC ou PRIVATE |
| `user_id` | STRING(64) | ID du propriétaire |
| `target_calendar_uri` | STRING(255) | URI du calendrier cible |
| `calendar_freebusy_uris` | TEXT | JSON - Calendriers pour détection de conflits |
| `availability` | TEXT | RRULE - Créneaux disponibles |
| `start` | INTEGER | Timestamp début période |
| `end` | INTEGER | Timestamp fin période |
| `length` | INTEGER | Durée du rendez-vous (minutes) |
| `increment` | INTEGER | Incrément entre slots (minutes) |
| `preparation_duration` | INTEGER | Temps de préparation (minutes) |
| `followup_duration` | INTEGER | Temps de suivi (minutes) |
| `time_before_next_slot` | INTEGER | Buffer avant prochain slot |
| `daily_max` | INTEGER | Max slots par jour (NULL = illimité) |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `token`

**Équivalent Cal.com** : Similaire à `EventType` (mais sans team/organization)

---

## 2. **calendar_appt_bookings** (Réservations)

**Migration**: Version3000Date20211109132439.php

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `appt_config_id` | BIGINT (FK) | Référence à calendar_appt_configs |
| `created_at` | INTEGER | Timestamp création |
| `token` | STRING(32) UNIQUE | Token de confirmation |
| `display_name` | STRING(128) | Nom de la personne réservant |
| `description` | TEXT | Notes supplémentaires |
| `email` | STRING(128) | Email du réservant |
| `start` | INTEGER | Timestamp début |
| `end` | INTEGER | Timestamp fin |
| `timezone` | STRING(32) | Fuseau horaire |
| `confirmed` | BOOLEAN | Confirmé ou non (default: false) |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `token`

**Équivalent Cal.com** : Similaire à `Booking` + `Attendee`

---

## 3. **calendar_proposal_dts** (Propositions de Dates - Details)

**Migration**: Version5050Date20250701000001.php

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uid` | STRING(255) | UID de la proposition |
| `uuid` | STRING(36) | UUID |
| `title` | TEXT | Titre de l'événement |
| `description` | TEXT | Description |
| `location` | TEXT | Lieu |
| `duration` | INTEGER | Durée (minutes) |

**Nouveau feature** : Proposition de dates multiples (comme Doodle)

---

## 4. **calendar_proposal_pts** (Propositions - Participants)

**Migration**: Version5050Date20250701000002.php

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uid` | STRING(255) | UID de la proposition |
| `pid` | BIGINT (FK) | ID de la proposition (proposal_dts) |
| `name` | STRING(255) | Nom du participant |
| `address` | STRING(320) | Email |
| `attendance` | STRING(8) | REQUIRED, OPTIONAL |
| `status` | STRING(8) | ACCEPTED, DECLINED, TENTATIVE |
| `realm` | STRING(8) | ? |
| `token` | STRING(255) | Token d'accès |

**Feature** : Gestion des participants avec RSVP

---

## 5. **calendar_proposal_dats** (Propositions - Dates disponibles)

**Migration**: Version5050Date20250701000003.php

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uid` | STRING(255) | UID |
| `pid` | BIGINT (FK) | ID de la proposition |
| `date` | INTEGER | Timestamp de la date proposée |

**Feature** : Liste des dates proposées pour vote

---

## 6. **calendar_proposal_vts** (Propositions - Votes)

**Migration**: Version5050Date20250701000004.php

### Structure  
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uid` | STRING(255) | UID |
| `pid` | BIGINT (FK) | ID de la proposition |
| `participant_id` | BIGINT (FK) | ID du participant |
| `date_id` | BIGINT (FK) | ID de la date |
| `vote` | STRING(8) | YES, NO, MAYBE |

**Feature** : Votes des participants sur les dates

---

## 🔗 Relations Entre Tables

```
calendar_appt_configs (1) ──┬──> (*) calendar_appt_bookings
                             
calendar_proposal_dts (1) ──┬──> (*) calendar_proposal_pts (Participants)
                             ├──> (*) calendar_proposal_dats (Dates)
                             └──> (*) calendar_proposal_vts (Votes)
```

---

## 📋 Résumé des Fonctionnalités

### Système de Rendez-vous (comme Cal.com)
- ✅ Configuration de types de rendez-vous (`calendar_appt_configs`)
- ✅ Réservations avec email (`calendar_appt_bookings`)
- ✅ Gestion de disponibilités (RRULE)
- ✅ Buffers avant/après
- ✅ Limite quotidienne de slots

### Système de Propositions (comme Doodle)
- ✅ Créer une proposition avec titre/description (`calendar_proposal_dts`)
- ✅ Inviter des participants (`calendar_proposal_pts`)
- ✅ Proposer plusieurs dates (`calendar_proposal_dats`)
- ✅ Participants votent sur les dates (`calendar_proposal_vts`)

---

## ⚠️ Tables ABSENTES

### Tables Nextcloud Core (non incluses dans Calendar app)
Les tables suivantes sont dans Nextcloud Core, pas dans l'app Calendar :

- ❌ **Users** : Gestion utilisateurs (Core Nextcloud)
- ❌ **Calendars** : Base CalDAV (Core Nextcloud)
- ❌ **Calendar Objects** : Événements iCal (Core Nextcloud)
- ❌ **Calendar Shares** : Partage calendriers (Core Nextcloud)

**Explication** : Nextcloud Calendar est une **app** qui s'appuie sur le système CalDAV de Nextcloud Core.

Les vraies tables de calendrier sont dans `dav_*` (tables du serveur DAV de Nextcloud Core).

---

## 💡 Conclusion

### Ce que l'app Nextcloud Calendar ajoute :
1. **Appointment Booking** : Système de réservation public (comme Cal.com)
2. **Date Polling** : Système de vote sur dates (comme Doodle)

### Ce qu'elle n'inclut PAS :
- Gestion de calendriers classiques (c'est dans Core)
- Événements iCal standards (c'est dans Core)
- Partage de calendriers (c'est dans Core)

**Pour avoir un VRAI calendrier**, vous devez analyser les tables du package **`dav`** de Nextcloud Core, pas juste l'app Calendar.
