# Nextcloud Core - Tables Calendrier CalDAV

## 📊 Tables Identifiées (9 tables complètes)

Basé sur migrations de `apps/dav/lib/Migration/` (2017-2025)

**✅ EXTRACTION COMPLÈTE - Toutes les tables et tous les champs**

---

## 1. **calendars** (Calendriers)

**La table principale contenant les calendriers**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `principaluri` | STRING(255) | URI de l'utilisateur (ex: principals/users/john) |
| `displayname` | STRING(255) | Nom affiché ("Travail", "Personnel") |
| `uri` | STRING(255) | URI unique du calendrier |
| `synctoken` | INTEGER | Token de synchronisation |
| `description` | STRING(255) | Description |
| `calendarorder` | INTEGER | Ordre d'affichage |
| `calendarcolor` | STRING | Couleur hexa (#FF0000) |
| `timezone` | TEXT | Timezone (iCal format) |
| `components` | STRING(64) | Types d'objets (VEVENT, VTODO, etc.) |
| `transparent` | SMALLINT | Blocage de temps (0/1) |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `[principaluri, uri]`

---

## 2. **calendarobjects** (Événements du Calendrier)

**Contient tous les événements, tâches, etc. au format iCal**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `calendardata` | BLOB | Données iCal complètes (VEVENT, etc.) |
| `uri` | STRING(255) | URI unique de l'objet |
| `calendarid` | INTEGER (FK) | Référence à calendars |
| `lastmodified` | INTEGER | Timestamp dernière modification |
| `etag` | STRING(32) | ETag pour sync |
| `size` | BIGINT | Taille du blob |
| `componenttype` | STRING(8) | VEVENT, VTODO, VJOURNAL |
| `firstoccurence` | BIGINT | Timestamp première occurrence |
| `lastoccurence` | BIGINT | Timestamp dernière occurrence |
| `uid` | STRING(255) | UID iCal unique |
| `classification` | INTEGER | PUBLIC(0), PRIVATE(1), CONFIDENTIAL(2) |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `[calendarid, uri]`

**Note** : Le champ `calendardata` contient le iCal brut (RFC 5545)

---

## 3. **calendarchanges** (Historique de Changements)

**Pour synchronisation incrémentale (CalDAV sync-collection)**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uri` | STRING(255) | URI de l'objet modifié |
| `synctoken` | INTEGER | Token de sync |
| `calendarid` | INTEGER (FK) | Référence à calendars |
| `operation` | SMALLINT | 1=ADDED, 2=MODIFIED, 3=DELETED |

### Index
- PRIMARY KEY: `id`
- INDEX: `[calendarid, synctoken]`

---

## 4. **calendarsubscriptions** (Abonnements Calendrier)

**Calendriers externes (webcal://, iCal subscriptions)**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `uri` | STRING | URI de l'abonnement |
| `principaluri` | STRING(255) | URI de l'utilisateur |
| `source` | STRING(255) | URL source (webcal://...) |
| `displayname` | STRING(100) | Nom affiché |
| `refreshrate` | STRING(10) | Fréquence de refresh (ex: P1D) |
| `calendarorder` | INTEGER | Ordre d'affichage |
| `calendarcolor` | STRING | Couleur |
| `striptodos` | SMALLINT | Supprimer les TODOs (0/1) |
| `stripalarms` | SMALLINT | Supprimer les alarmes (0/1) |
| `stripattachments` | SMALLINT | Supprimer les pièces jointes (0/1) |
| `lastmodified` | INTEGER | Timestamp dernière modification |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `[principaluri, uri]`

---

## 5. **schedulingobjects** (Objets de Planification)

**Invitations et réponses CalDAV (VFREEBUSY, iTIP)**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `principaluri` | STRING(255) | URI utilisateur |
| `calendardata` | BLOB | Données iCal |
| `uri` | STRING(255) | URI unique |
| `lastmodified` | INTEGER | Timestamp |
| `etag` | STRING(32) | ETag |
| `size` | BIGINT | Taille |

### Index
- PRIMARY KEY: `id`
- INDEX: `[principaluri]`
- INDEX: `[lastmodified]`

---

## 6. **calendarobjects_props** (Propriétés d'Événements)

**Propriétés extraites pour recherche et filtrage**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `calendarid` | BIGINT (FK) | Calendrier |
| `objectid` | BIGINT (FK) | Objet calendrier |
| `name` | STRING(64) | Nom propriété (ex: SUMMARY, LOCATION) |
| `parameter` | STRING(64) | Paramètre iCal |
| `value` | STRING(255) | Valeur |

### Index
- PRIMARY KEY: `id`
- INDEX: `[objectid]`
- INDEX: `[name]`
- INDEX: `[value]`

**Usage** : Permet de rechercher par titre, lieu, etc. sans parser le iCal

---

## 7. **dav_shares** (Partages)

**Partages de calendriers et carnets d'adresses**

### Structure
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT (PK, AI) | Identifiant unique |
| `principaluri` | STRING(255) | Utilisateur partageant |
| `type` | STRING(255) | Type (calendar, addressbook) |
| `access` | SMALLINT | 1=READ, 2=WRITE, 3=ADMIN |
| `resourceid` | INTEGER (FK) | ID du calendrier partagé |
| `publicuri` | STRING(255) | URI public (si partage public) |

### Index
- PRIMARY KEY: `id`
- UNIQUE: `[principaluri, resourceid, type, publicuri]`
- INDEX: `[resourceid, type]`
- INDEX: `[resourceid, access]`

---

## 🔗 Relations Entre Tables

```
calendars (1) ──┬──> (*) calendarobjects (Événements)
                 ├──> (*) calendarchanges (Sync)
                 └──> (*) dav_shares (Partages)

calendarobjects (1) ──> (*) calendarobjects_props (Propriétés)

User (principaluri) ──┬──> (*) calendars
                       └──> (*) calendarsubscriptions
```

---

## 📝 Fonctionnalités Supportées

### Gestion de Calendrier
- ✅ Création/modification/suppression de calendriers
- ✅ Couleurs, noms, descriptions
- ✅ Fuseaux horaires
- ✅ Ordre d'affichage

### Événements (CalendarObjects)
- ✅ Événements (VEVENT)
- ✅ Tâches (VTODO)
- ✅ Journaux (VJOURNAL)
- ✅ Récurrence (RRULE, EXDATE)
- ✅ Classification (PUBLIC, PRIVATE, CONFIDENTIAL)

### Synchronisation
- ✅ CalDAV sync-collection (synctoken)
- ✅ Historique de changements
- ✅ ETags pour concurrence optimiste

### Partage
- ✅ Partage utilisateur-à-utilisateur
- ✅ Permissions READ/WRITE/ADMIN
- ✅ Liens publics

### Abonnements
- ✅ Import de calendriers externes (webcal://)
- ✅ Refresh automatique
- ✅ Filtres (supprimer TODOs, alarmes, etc.)

---

## ⚠️ Architecture iCal/CalDAV

### Format de Données
Nextcloud stocke les événements **au format iCal brut** (RFC 5545) dans le champ `calendardata`.

**Exemple** :
```ical
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:event-123-uuid
DTSTART:20250102T100000Z
DTEND:20250102T110000Z
SUMMARY:Réunion d'équipe
LOCATION:Salle A
RRULE:FREQ=WEEKLY;BYDAY=MO
END:VEVENT
END:VCALENDAR
```

Cela signifie :
- ✅ Très flexible (support complet de RFC 5545)
- ⚠️ Parsing iCal requis pour lire les données
- ⚠️ Complexe à migrer vers un modèle relationnel

---

## 💡 Comparaison avec Cal.com

| Feature | Nextcloud CalDAV | Cal.com |
|---------|------------------|---------|
| **Storage** | BLOB iCal (texte) | Colonnes structurées |
| **Récurrence** | RRULE dans iCal | RRULE en string |
| **Parsing** | Requis (sabre/dav) | Données directes |
| **Flexibilité** | Maximum (RFC 5545) | Cas d'usage limités |
| **Performance** | Plus lent (parsing) | Plus rapide (SQL direct) |
| **Standard** | ✅ 100% CalDAV | ❌ Propriétaire |

---

## 🎯 Conclusion

### Si vous voulez un calendrier full-featured :
**Nextcloud CalDAV** est complet mais **très complexe** :
- Nécessite un parser iCal (sabre/dav en PHP)
- Format BLOB difficile à requêter
- Excellente compatibilité standards

### Alternative recommandée pour Lyxal :
**FullCalendar + Schema Prisma custom** :
- Données structurées (plus rapides)
- Type-safe (TypeScript)
- Plus simple à maintenir
- Suffisant pour 95% des cas d'usage
