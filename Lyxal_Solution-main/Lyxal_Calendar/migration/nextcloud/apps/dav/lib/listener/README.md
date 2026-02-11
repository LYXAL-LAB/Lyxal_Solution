# Analyse du Répertoire `Listener` de Nextcloud DAV

Ce répertoire contient les event listeners qui réagissent aux événements Nextcloud (19 fichiers).

---

## Listeners CalDAV

| Listener | Événements | Fonction |
|----------|------------|----------|
| `CalendarObjectReminderUpdaterListener` | CalendarObject* | Met à jour les rappels lors de modifications d'événements |
| `CalendarPublicationListener` | CalendarPublished/Unpublished | Gère la publication de calendriers |
| `CalendarShareUpdateListener` | CalendarShareUpdated | Réagit aux changements de partage |
| `CalendarDeletionDefaultUpdaterListener` | CalendarDeleted | Met à jour le calendrier par défaut si supprimé |
| `CalendarFederationNotificationListener` | Federation events | Notifications pour calendriers fédérés |
| `CalendarContactInteractionListener` | CalendarObject* | Détecte les interactions avec contacts |

---

## Listeners CardDAV

| Listener | Événements | Fonction |
|----------|------------|----------|
| `AddressbookListener` | AddressBook* | Réagit aux événements de carnets d'adresses |
| `CardListener` | Card* | Réagit aux modifications de contacts |
| `BirthdayListener` | Card* | Régénère les anniversaires |
| `ClearPhotoCacheListener` | Card* | Vide le cache des photos de contacts |

---

## Listeners Utilisateur

| Listener | Événements | Fonction |
|----------|------------|----------|
| `UserEventsListener` | User* | Gère création/suppression utilisateurs |
| `UserPreferenceListener` | UserPreference* | Réagit aux changements de préférences |
| `OutOfOfficeListener` | OutOfOffice* | Gère les événements d'absence |

---

## Autres Listeners

| Listener | Fonction |
|----------|----------|
| `ActivityUpdaterListener` | Publie les activités (fil d'activité) |
| `SubscriptionListener` | Gère les abonnements WebCal |
| `SabrePluginAuthInitListener` | Initialise l'authentification Sabre |
| `TrustedServerRemovedListener` | Nettoie lors de suppression de serveur de confiance |
| `DavAdminSettingsListener` | Paramètres admin DAV |
| `AddMissingIndicesListener` | Ajoute les indices DB manquants |
