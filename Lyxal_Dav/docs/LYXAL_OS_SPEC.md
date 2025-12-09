# Spécification LYXAL OS – DEFINE DAV

## 0. Rappel conceptuel

DEFINE DAV déclare un service DAV natif (CalDAV, bientôt CardDAV, WebDAV…) géré par le moteur.

Il expose des endpoints du type :
`/dav/<ns>/<db>/<dav_name>/...`

Il ne passe jamais par DEFINE API.

Il s’appuie sur des tables Surreal (dont `calendar_object`) pour stocker les données, et le moteur se charge :
- de parler WebDAV / CalDAV aux clients,
- de parler SurrealQL et KVS en interne.

## 1. Syntaxe générale

```sql
DEFINE DAV <name> ON TABLE <table>
    TYPE <protocol>
    BASE <string>
    CALENDAR_FIELD <field>
    TIME_FIELDS <start_field>, <end_field>
    TIMEZONE_FIELD <tz_field>
    RRULE_FIELD <rrule_field>
    [PROPS_RAW_FIELD <props_raw_field>]
    [PROPS_NORMALIZED_FIELD <props_norm_field>]
    [PERMISSIONS <expression>];
```

### 1.1. Paramètres

- **name** : Nom logique du service DAV (ex. work, personal, team).
- **ON TABLE <table>** : Table Surreal utilisée pour persister les objets DAV. Pour CalDAV, ce sera typiquement `calendar_object`.
- **TYPE <protocol>** : Type de protocole DAV. Valeurs supportées (v1) : `caldav`.
- **BASE <string>** : Base de l’URL DAV exposée par le moteur, relative à `/dav/<ns>/<db>/`. Ex : BASE "/calendars" → endpoint global : `/dav/<ns>/<db>/calendars/<name>/...`
- **CALENDAR_FIELD <field>** : Champ de la table qui référence le calendrier parent (ex : `calendar_id`).
- **TIME_FIELDS <start_field>, <end_field>** : Champs datetime utilisés pour les filtres REPORT time-range. Ex : `TIME_FIELDS dtstart, dtend`.
- **TIMEZONE_FIELD <tz_field>** : Champ contenant le TZID (ex : "Europe/Paris", "America/New_York").
- **RRULE_FIELD <rrule_field>** : Champ qui contient la règle de récurrence brute (ex : `rrule`).
- **PROPS_RAW_FIELD <props_raw_field>** (optionnel, recommandé) : Champ object JSON conservant toutes les propriétés brutes non normalisées (incl. X-PROPERTIES Apple/Google).
- **PROPS_NORMALIZED_FIELD <props_norm_field>** (optionnel) : Champ object JSON contenant les propriétés extraites pour la recherche (summary, location, status, etc.).
- **PERMISSIONS <expression>** (optionnel, mais fortement recommandé) : Expression de permission Surreal définissant qui peut voir / modifier quoi. Exemple : `PERMISSIONS account_id = $auth.account`.

## 2. Schéma recommandé – calendar_object

Pour CalDAV v1, le schéma officiel recommandé est :

```sql
DEFINE TABLE calendar_object SCHEMAFULL;

DEFINE FIELD type            ON TABLE calendar_object TYPE string;
DEFINE FIELD calendar_id     ON TABLE calendar_object TYPE record<calendar>;
DEFINE FIELD props_raw       ON TABLE calendar_object TYPE object;
DEFINE FIELD props_normalized ON TABLE calendar_object TYPE object;

DEFINE FIELD dtstart         ON TABLE calendar_object TYPE datetime;
DEFINE FIELD dtend           ON TABLE calendar_object TYPE datetime;
DEFINE FIELD rrule           ON TABLE calendar_object TYPE string;
DEFINE FIELD tzid            ON TABLE calendar_object TYPE string;

DEFINE FIELD updated_at      ON TABLE calendar_object TYPE datetime
    VALUE time::now();
```

Les valeurs `type` sont au minimum : `VEVENT`, `VTODO`, `VJOURNAL`, `VFREEBUSY`.

## 3. Exemple complet : service CalDAV "work"

### 3.1. Définition des tables

```sql
-- Table des calendriers
DEFINE TABLE calendar SCHEMAFULL;

DEFINE FIELD name       ON TABLE calendar TYPE string;
DEFINE FIELD color      ON TABLE calendar TYPE string;
DEFINE FIELD owner_id   ON TABLE calendar TYPE record<user>;
DEFINE FIELD ctag       ON TABLE calendar TYPE string; -- pour synchro DAV

-- Table des objets CalDAV
DEFINE TABLE calendar_object SCHEMAFULL;

DEFINE FIELD type            ON TABLE calendar_object TYPE string;
DEFINE FIELD calendar_id     ON TABLE calendar_object TYPE record<calendar>;
DEFINE FIELD props_raw       ON TABLE calendar_object TYPE object;
DEFINE FIELD props_normalized ON TABLE calendar_object TYPE object;

DEFINE FIELD dtstart         ON TABLE calendar_object TYPE datetime;
DEFINE FIELD dtend           ON TABLE calendar_object TYPE datetime;
DEFINE FIELD rrule           ON TABLE calendar_object TYPE string;
DEFINE FIELD tzid            ON TABLE calendar_object TYPE string;

DEFINE FIELD updated_at      ON TABLE calendar_object TYPE datetime
    VALUE time::now();
```

### 3.2. Déclaration DEFINE DAV

```sql
DEFINE DAV work ON TABLE calendar_object
    TYPE caldav
    BASE "/calendars"
    CALENDAR_FIELD calendar_id
    TIME_FIELDS dtstart, dtend
    TIMEZONE_FIELD tzid
    RRULE_FIELD rrule
    PROPS_RAW_FIELD props_raw
    PROPS_NORMALIZED_FIELD props_normalized
    PERMISSIONS calendar.owner_id = $auth.id;
```

Ce qui donne comme endpoints DAV (exemples) :
- Liste des calendriers : `/dav/<ns>/<db>/calendars/work/`
- Un calendrier donné : `/dav/<ns>/<db>/calendars/work/<calendar-id>/`
- Un objet dans un calendrier : `/dav/<ns>/<db>/calendars/work/<calendar-id>/<uid>.ics`

Toute requête CalDAV (PROPFIND, REPORT, PUT, GET, DELETE) sur ces URLs est traduite par le moteur en opérations sur `calendar` et `calendar_object`.

## 4. Comportement interne (moteur)

### 4.1. PUT d’un .ics

Le client (Apple, Thunderbird…) envoie un PUT sur : `/dav/…/calendars/work/<calendar-id>/<uid>.ics`

Le moteur :
1. lit le body ICS,
2. appelle `fn::ical::parse(content)` → object Surreal,
3. extrait : type, dtstart, dtend, tzid, rrule, props_raw, props_normalized,
4. écrit/merge un record dans `calendar_object`.

Aucun blob n’est stocké.

### 4.2. GET d’un .ics

Le client fait GET sur la même URL.

Le moteur :
1. lit le record dans `calendar_object`,
2. construit un object avec toutes les propriétés (incluant celles dans props_raw),
3. appelle `fn::ical::stringify(obj)`,
4. renvoie un .ics conforme CalDAV.

Toute modification SQL sur `calendar_object` est automatiquement reflétée.

### 4.3. REPORT time-range

Le client envoie une requête CalDAV REPORT avec un filtre time-range.

Le moteur :
1. filtre par `dtstart` / `dtend` en base,
2. applique `fn::ical::occurrences(rrule, dtstart, tzid, range)` pour projeter les séries récurrentes,
3. renvoie les résultats sous forme d’instances (recur expand) dans la réponse XML.

## 5. VTIMEZONE & TZID (comportement moteur)

Lors de l’utilisation de DEFINE DAV TYPE caldav, le moteur applique la stratégie suivante :

1. Si un bloc **VTIMEZONE** est fourni dans l’ICS :
   - il est parsé et stocké/caché au niveau du calendrier,
   - il est utilisé prioritairement pour les calculs.

2. Si aucun VTIMEZONE mais **TZID standard (IANA)** :
   - usage de `chrono-tz` (ou équivalent) pour la résolution.

3. Si pas de TZID (**floating time**) :
   - les dates sont stockées telles quelles,
   - aucun shift UTC n’est forcé,
   - les clients interprètent selon leur locale.

## 6. Permissions et multi-tenant

Le PERMISSIONS de DEFINE DAV est appliqué pour chaque opération DAV : PROPFIND, REPORT, PUT, DELETE, GET.

Exemple multi-tenant simple :

```sql
DEFINE DAV tenant_calendar ON TABLE calendar_object
    TYPE caldav
    BASE "/cal"
    CALENDAR_FIELD calendar_id
    TIME_FIELDS dtstart, dtend
    TIMEZONE_FIELD tzid
    RRULE_FIELD rrule
    PROPS_RAW_FIELD props_raw
    PERMISSIONS calendar.tenant_id = $auth.tenant;
```

Cela te laisse aligné avec ton modèle namespace/db par client + éventuellement niveau tenant en champ.

## 7. Ce qu’il reste à figer plus tard (mais la spec le permet déjà)

- Ajout futur : TYPE carddav, TYPE webdav_docs, etc. en réutilisant DEFINE DAV.
- Support de ressources supplémentaires : address_object, task_object, etc., avec la même signature DEFINE DAV.
