# Analyse du Fichier `Application.php` de Nextcloud

## Description

`Application` est le point d'entrée principal de l'app DAV dans Nextcloud. Elle enregistre tous les services, event listeners, et providers du module DAV.

## Rôle et Responsabilités

### 1. Enregistrement des Composants (`register`)
-   **Event Listeners** : CardDAV, CalDAV, Calendar reminders, Out-of-office, User events
-   **Search Providers** : Contacts, Events, Tasks
-   **User Migration** : CalendarMigrator, ContactsMigrator
-   **Setup Checks** : WebdavEndpoint, SystemAddressBookSize

### 2. Initialisation (`boot`)
-   Configure le contexte de l'app au démarrage

### 3. Providers de Contacts et Calendriers
-   `registerContactsManager()` : Enregistre le CardDAV comme provider de contacts
-   `registerCalendarManager()` : Enregistre le CalDAV comme provider de calendriers
-   `setupContactsProvider()`, `setupCalendarProvider()` : Configuration par utilisateur

### 4. Rappels de Calendrier
-   `registerCalendarReminders()` : Enregistre les providers de notifications (Email, Push)

### 5. Fédération Cloud
-   `registerCloudFederationProvider()` : Support des partages inter-instances

## Dépendances Clés
-   `IRegistrationContext` : Enregistrement des composants Nextcloud
-   Event classes : `CalendarCreatedEvent`, `CardCreatedEvent`, etc.
-   `NotificationProviderManager` : Providers de rappels
