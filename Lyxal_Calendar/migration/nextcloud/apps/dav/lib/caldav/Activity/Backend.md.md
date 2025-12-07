# Analyse du Fichier `Activity/Backend.php`

Ce document décompose le contenu de la classe `Activity\Backend.php`. Cette classe est un service qui fait le pont entre les opérations du module CalDAV et l'application "Activity" de Nextcloud.

---

## 1. Rôle et Responsabilités

La classe `Activity\Backend` est un **auditeur d'événements et un générateur de flux d'activité**. Elle n'est pas directement exposée via une API, mais ses méthodes sont appelées par d'autres services (comme `CalDavBackend`) lorsque des actions importantes se produisent.

Sa seule responsabilité est de **créer des entrées dans le flux d'activité** de Nextcloud, en traduisant les actions techniques (ex: `UPDATE calendars SET ...`) en phrases lisibles par un humain (ex: "Vous avez modifié le calendrier 'Projets'").

---

## 2. Logique Principale

La classe est structurée avec des méthodes `on...` qui correspondent à des événements spécifiques du cycle de vie des calendriers et des objets.

- **`onCalendarAdd`, `onCalendarUpdate`, `onCalendarDelete`, etc.**:
  - **Rôle**: Gérer les activités liées au cycle de vie d'un **calendrier**.
  - **Action**: Appellent une méthode centrale `triggerCalendarActivity`.

- **`onCalendarUpdateShares`**:
  - **Rôle**: Gérer spécifiquement les activités de partage/départage d'un calendrier.
  - **Action**: Contient une logique complexe pour générer des messages différents pour le propriétaire, la personne qui partage, et la personne qui reçoit le partage.

- **`onTouchCalendarObject`, `onMovedCalendarObject`**:
  - **Rôle**: Gérer les activités liées au cycle de vie d'un **événement ou d'une tâche**.
  - **Action**: Appellent une méthode centrale `trigger...`.

### Logique de Déclenchement (`trigger...` methods)
C'est le cœur du service.
1.  **Génération de l'événement**: Crée un objet `IEvent` via l'`activityManager`.
2.  **Détermination des utilisateurs concernés**: La logique la plus complexe est ici. Le service détermine qui doit voir l'activité :
    -   Pour une simple modification de nom, seul le propriétaire est notifié.
    -   Pour un partage, le propriétaire et les destinataires sont notifiés.
    -   Pour une modification d'événement, tous les participants au calendrier (propriétaire et partagés) sont notifiés.
3.  **Gestion de la confidentialité**: Avant de notifier, il vérifie la classification de l'événement. Si un événement est `PRIVATE` ou `CONFIDENTIAL`, il ne sera pas montré (ou sera montré de manière anonymisée, "Occupé") dans le flux d'activité des personnes avec qui le calendrier est partagé.
4.  **Construction du message**: Il construit le "sujet" de l'activité (la phrase) en utilisant des clés de traduction et en injectant des paramètres (le nom de l'acteur, le nom du calendrier, etc.). Il génère des phrases différentes selon le contexte (ex: `..._self` si l'acteur et l'utilisateur affecté sont les mêmes).
5.  **Publication**: Appelle `$activityManager->publish($event)` pour enregistrer l'activité dans la base de données.

---

## Conclusion

`Activity\Backend` est un composant crucial pour l'intégration de la fonctionnalité calendrier dans l'expérience utilisateur globale de Nextcloud. En écoutant les événements de bas niveau et en les traduisant en notifications d'activité claires, contextualisées et respectueuses de la confidentialité, il rend les changements dans les calendriers visibles et compréhensibles pour les utilisateurs finaux via le flux d'activité. C'est un exemple parfait de la couche "connective" qui lie un backend technique à une interface utilisateur de haut niveau.
