# Analyse du Répertoire `Events` de Nextcloud DAV

Ce répertoire contient les événements Symfony/Nextcloud émis par le module DAV (25 fichiers).

---

## Événements Calendrier (CalDAV)

| Événement | Déclencheur |
|-----------|-------------|
| `CalendarCreatedEvent` | Création d'un calendrier |
| `CalendarUpdatedEvent` | Modification d'un calendrier |
| `CalendarDeletedEvent` | Suppression d'un calendrier |
| `CalendarMovedToTrashEvent` | Calendrier mis en corbeille |
| `CalendarRestoredEvent` | Calendrier restauré |
| `CalendarPublishedEvent` | Calendrier rendu public |
| `CalendarUnpublishedEvent` | Calendrier rendu privé |
| `CalendarShareUpdatedEvent` | Partage de calendrier modifié |

---

## Événements Objets Calendrier

| Événement | Déclencheur |
|-----------|-------------|
| `CachedCalendarObjectCreatedEvent` | Objet créé dans un abonnement caché |
| `CachedCalendarObjectUpdatedEvent` | Objet mis à jour dans un abonnement |
| `CachedCalendarObjectDeletedEvent` | Objet supprimé d'un abonnement |

---

## Événements Abonnements

| Événement | Déclencheur |
|-----------|-------------|
| `SubscriptionCreatedEvent` | Nouvel abonnement WebCal |
| `SubscriptionUpdatedEvent` | Abonnement modifié |
| `SubscriptionDeletedEvent` | Abonnement supprimé |

---

## Événements Carnet d'Adresses (CardDAV)

| Événement | Déclencheur |
|-----------|-------------|
| `AddressBookCreatedEvent` | Création d'un carnet |
| `AddressBookUpdatedEvent` | Modification d'un carnet |
| `AddressBookDeletedEvent` | Suppression d'un carnet |
| `AddressBookShareUpdatedEvent` | Partage modifié |

---

## Événements Contacts

| Événement | Déclencheur |
|-----------|-------------|
| `CardCreatedEvent` | Contact créé |
| `CardUpdatedEvent` | Contact modifié |
| `CardDeletedEvent` | Contact supprimé |
| `CardMovedEvent` | Contact déplacé |

---

## Événements Système

| Événement | Déclencheur |
|-----------|-------------|
| `SabrePluginAddEvent` | Plugin Sabre ajouté au serveur |
| `SabrePluginAuthInitEvent` | Initialisation authentification Sabre |
| `BeforeFileDirectDownloadedEvent` | Avant téléchargement direct |
