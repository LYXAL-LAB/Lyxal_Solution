# Analyse du Répertoire `Migration` de Nextcloud DAV

Ce répertoire contient les migrations de base de données et scripts de maintenance (47 fichiers).

---

## Types de Migrations

### Migrations de Schéma (Version*)
Format: `Version{YYMMDD}Date{YYYYMMDD}{HHMMSS}.php`

Exemples notables :
-   `Version1004Date20170825134824` : Création tables CalDAV/CardDAV initiales
-   `Version1025Date20240308063933` : Ajout colonnes fédération
-   `Version1034Date20250605132605` : Migrations récentes

### Migrations de Données

| Migration | Fonction |
|-----------|----------|
| `BuildCalendarSearchIndex` | Construit l'index de recherche calendrier |
| `BuildSocialSearchIndex` | Index de recherche réseaux sociaux |
| `CalDAVRemoveEmptyValue` | Nettoie les valeurs vides |
| `ChunkCleanup` | Supprime les chunks d'upload orphelins |
| `DeleteSchedulingObjects` | Supprime les objets de planification obsolètes |
| `RegenerateBirthdayCalendars` | Régénère les calendriers d'anniversaires |
| `RemoveClassifiedEventActivity` | Supprime les activités des événements confidentiels |
| `RemoveDeletedUsersCalendarSubscriptions` | Nettoie les abonnements des utilisateurs supprimés |
| `RemoveOrphanEventsAndContacts` | Supprime les orphelins |

### Jobs de Migration en Arrière-plan

| Job | Fonction |
|-----|----------|
| `BuildCalendarSearchIndexBackgroundJob` | Index recherche en background |
| `BuildSocialSearchIndexBackgroundJob` | Index social en background |
| `RefreshWebcalJobRegistrar` | Enregistre les jobs de refresh WebCal |
| `RegisterBuildReminderIndexBackgroundJob` | Enregistre la construction d'index des rappels |

### Migrations Système

| Migration | Fonction |
|-----------|----------|
| `CreateSystemAddressBookStep` | Crée le carnet d'adresses système |
| `DisableSystemAddressBook` | Désactive le carnet système |
| `FixBirthdayCalendarComponent` | Corrige les composants d'anniversaires |
