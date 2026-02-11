# Analyse du Fichier `appinfo/routes.php` de l'Application DAV

Ce document décompose le contenu du fichier `routes.php`. Ce fichier définit les routes HTTP personnalisées de l'application DAV, c'est-à-dire les points d'entrée (endpoints) de son API REST, qui complètent l'API WebDAV principale.

---

## 1. Rôle et Responsabilités

Le fichier `routes.php` est le **registre des routes de l'API REST** de l'application. Le framework Nextcloud lit ce fichier pour savoir quelles URLs doivent être mappées à quelles méthodes de quels contrôleurs.

Il expose des fonctionnalités qui ne sont pas (ou sont difficilement) modélisables avec le protocole WebDAV. Ces routes sont généralement utilisées par l'interface web de Nextcloud ou par des clients spécifiques qui connaissent l'API OCS.

---

## 2. Définitions des Routes

Le fichier définit deux types de routes.

### Routes Web Classiques (`'routes'`)
Ce sont des endpoints standards utilisés pour des interactions spécifiques, souvent initiées depuis l'interface web ou des liens externes.

- **`/enableBirthdayCalendar` et `/disableBirthdayCalendar`**:
  - **Rôle**: Endpoints pour que l'utilisateur puisse activer ou désactiver son calendrier d'anniversaires depuis les paramètres, sans avoir à faire une requête DAV complexe.
  - **Mappage**: `birthday_calendar#enable` et `birthday_calendar#disable` pointent vers les méthodes `enable` et `disable` du contrôleur `BirthdayCalendarController`.

- **`/invitation/{accept|decline|moreOptions}/{token}`**:
  - **Rôle**: Gérer les réponses rapides aux invitations via des liens contenus dans les emails. Un utilisateur peut accepter ou refuser une invitation en cliquant sur un lien, sans avoir à ouvrir son client de calendrier. Le `{token}` assure la sécurité de l'action.
  - **Mappage**: Pointent vers les méthodes du contrôleur `InvitationResponseController`.

### Routes de l'API OCS (`'ocs'`)
Ce sont des routes qui respectent la spécification OCS (Open Collaboration Services), l'API REST standardisée de Nextcloud. Elles sont préfixées par `/ocs/v.../apps/dav`.

- **`/api/v1/direct`**:
  - **Rôle**: Probablement un endpoint pour générer des liens de téléchargement directs pour des objets, sans passer par une navigation WebDAV complète.
  - **Mappage**: Pointe vers la méthode `getUrl` du `DirectController`.

- **`/api/v1/events/upcoming`**:
  - **Rôle**: C'est l'endpoint que nous avions anticipé. Il expose le `UpcomingEventsService` pour fournir une liste d'événements à venir, typiquement pour un widget de tableau de bord.
  - **Mappage**: Pointe vers `upcoming_events#getEvents`.

- **`/api/v1/outOfOffice/{userId}`**:
  - **Rôle**: Une série de endpoints CRUD (Create, Read, Update, Delete) pour gérer les messages et périodes d'absence ("Out of Office") d'un utilisateur. C'est une fonctionnalité métier complète exposée via une API REST.
  - **Mappage**: Pointe vers les méthodes du `OutOfOfficeController`.

---

## Conclusion

Le fichier `routes.php` est essentiel pour comprendre la **surface d'API complète** de l'application DAV. Il révèle que, en plus de fournir une implémentation robuste des protocoles CalDAV et CardDAV, l'application expose également une API REST moderne pour des fonctionnalités spécifiques et des intégrations plus poussées avec l'écosystème Nextcloud (comme le tableau de bord ou la gestion des absences). Cela montre une architecture à double facette : une API standardisée (WebDAV) pour l'interopérabilité et une API REST (OCS) pour les fonctionnalités spécifiques à l'application.
