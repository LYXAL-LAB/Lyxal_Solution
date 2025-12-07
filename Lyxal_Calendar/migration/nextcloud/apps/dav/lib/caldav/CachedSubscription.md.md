# Analyse du Fichier `CachedSubscription.php` de Nextcloud

Ce document décompose le contenu de la classe `CachedSubscription.php`. Cette classe représente, dans le framework SabreDAV, un calendrier de type "abonnement" dont le contenu est mis en cache localement.

---

## 1. Rôle et Responsabilités

La classe `CachedSubscription` agit comme une **façade** ou un **adaptateur**. Son rôle principal est de présenter un abonnement à un calendrier externe (ex: un calendrier Google) comme s'il s'agissait d'un calendrier normal et local.

Elle hérite de `\\Sabre\\CalDAV\\Calendar`, ce qui lui permet de s'intégrer nativement dans l'arborescence du serveur CalDAV. Quand un client CalDAV demande les objets de ce "calendrier", c'est cette classe qui répond.

Cependant, elle ne contient presque aucune logique métier elle-même. Elle **délègue** la quasi-totalité des opérations au service principal `CalDavBackend`.

---

## 2. Fonctions Publiques (Interface DAV)

Les fonctions de cette classe sont principalement des implémentations des méthodes requises par l'interface d'un "nœud" de calendrier dans SabreDAV.

- **`getChildren()`, `getMultipleChildren(...)`, `getChild($name)`**:
  - **Rôle**: Récupérer les événements (les "enfants") de ce calendrier d'abonnement.
  - **Action**: Appelle directement les fonctions correspondantes du `CalDavBackend` (`getCalendarObjects`, etc.) en spécifiant que l'on travaille sur un `CALENDAR_TYPE_SUBSCRIPTION`. Elle encapsule ensuite chaque résultat dans un objet `CachedSubscriptionObject`.

- **`delete()`**:
  - **Rôle**: Supprimer l'abonnement lui-même.
  - **Action**: Appelle `caldavBackend->deleteSubscription(...)`.

- **`propPatch(PropPatch $propPatch)`**:
  - **Rôle**: Mettre à jour les propriétés de l'abonnement (nom, couleur, etc.).
  - **Action**: Appelle `caldavBackend->updateSubscription(...)`.

- **`createFile($name, $data = null)`**:
  - **Rôle**: Gérer une tentative de création d'un événement dans l'abonnement.
  - **Action**: **Lève une exception `MethodNotAllowed`**. C'est une logique métier cruciale : on ne peut pas créer d'événements directement dans un calendrier en lecture seule auquel on est abonné.

- **`calendarQuery(array $filters)` et `getChanges(...)`**:
  - **Rôle**: Gérer les requêtes de recherche filtrée et de synchronisation.
  - **Action**: Délègue ces opérations au `CalDavBackend`.

### Gestion des Permissions (ACL)
- **`getACL()`, `getChildACL()`, `getOwner()`**:
  - **Rôle**: Définir les permissions d'accès.
  - **Action**: Définit des règles strictes. Essentiellement, seul le propriétaire a le droit de lire le contenu et de modifier les propriétés de l'abonnement. L'écriture d'événements est implicitement interdite.

---

## Conclusion

`CachedSubscription` est une classe "glue" de l'architecture DAV. Ce n'est pas un service métier avec une logique complexe, mais un **point d'entrée** qui représente un abonnement dans l'arborescence des fichiers virtuels du serveur DAV. Son travail consiste à recevoir les requêtes standards du protocole DAV/CalDAV et à les traduire en appels spécifiques au service `CalDavBackend`, tout en appliquant une politique de permissions en lecture seule.
