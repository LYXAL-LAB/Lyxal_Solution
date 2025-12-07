# Analyse du Répertoire `BackgroundJob` de Nextcloud DAV

Ce répertoire contient 17 jobs d'arrière-plan pour la maintenance et l'automatisation du module DAV.

---

## Jobs de Rappels et Notifications

### `EventReminderJob.php`
-   **Type** : `TimedJob` (toutes les 5 min)
-   **Fonction** : Traite les rappels d'événements calendrier via `ReminderService`
-   **Config** : `sendEventReminders`, `sendEventRemindersMode`

### `BuildReminderIndexBackgroundJob.php`
-   **Type** : `QueuedJob`
-   **Fonction** : Construit l'index des rappels pour les objets calendrier existants
-   **Limite** : 15 secondes par exécution, puis replanifie

---

## Jobs de Nettoyage

### `CalendarRetentionJob.php`
-   **Type** : `TimedJob` (toutes les 6h)
-   **Fonction** : Supprime définitivement les calendriers de la corbeille après rétention

### `CleanupDirectLinksJob.php`
-   **Type** : `TimedJob` (quotidien)
-   **Fonction** : Supprime les liens directs WebDAV expirés depuis 24h

### `CleanupInvitationTokenJob.php`
-   **Type** : `TimedJob` (quotidien)
-   **Fonction** : Supprime les tokens d'invitation expirés (`calendar_invitations`)

### `CleanupOrphanedChildrenJob.php`
-   **Type** : `QueuedJob`
-   **Fonction** : Supprime les objets orphelins (calendars/subscriptions sans parent)
-   **Batch** : 1000 éléments par exécution

### `DeleteOutdatedSchedulingObjects.php`
-   **Type** : `TimedJob` (toutes les 23h)
-   **Fonction** : Supprime les objets de planification obsolètes (> 1h)

### `UploadCleanup.php`
-   **Fonction** : Nettoie les uploads incomplets

### `PruneOutdatedSyncTokensJob.php`
-   **Fonction** : Supprime les anciens tokens de synchronisation

---

## Jobs de Synchronisation

### `RefreshWebcalJob.php`
-   **Type** : `Job` (intervalle dynamique)
-   **Fonction** : Rafraîchit les abonnements WebCal
-   **Config** : `calendarSubscriptionRefreshRate` (défaut: P1D)

### `FederatedCalendarSyncJob.php`
-   **Fonction** : Synchronise les calendriers partagés entre instances

### `FederatedCalendarPeriodicSyncJob.php`
-   **Fonction** : Synchronisation périodique des calendriers fédérés

---

## Jobs de Génération

### `GenerateBirthdayCalendarBackgroundJob.php`
-   **Fonction** : Génère le calendrier d'anniversaires depuis CardDAV

### `RegisterRegenerateBirthdayCalendars.php`
-   **Fonction** : Enregistre la régénération des calendriers d'anniversaires

### `UpdateCalendarResourcesRoomsBackgroundJob.php`
-   **Fonction** : Met à jour les ressources et salles de calendrier

---

## Jobs de Statut Utilisateur

### `UserStatusAutomation.php`
-   **Type** : `TimedJob` (intervalle dynamique basé sur VAVAILABILITY)
-   **Fonction** : Automatise le statut utilisateur (DND) selon :
    -   **Disponibilité** : Règles VAVAILABILITY du calendrier
    -   **Absence** : Données Out-of-Office
-   **Comportement** : Réserve au prochain changement de statut

### `OutOfOfficeEventDispatcherJob.php`
-   **Fonction** : Dispatch des événements d'absence
