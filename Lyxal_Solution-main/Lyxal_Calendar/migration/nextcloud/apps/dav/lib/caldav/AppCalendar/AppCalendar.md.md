# Analyse du Fichier `AppCalendar/AppCalendar.php`

Ce document décompose le contenu de la classe `AppCalendar\AppCalendar.php`. Il s'agit d'une classe d'adaptation ("wrapper" ou "adapter") qui permet d'exposer n'importe quel calendrier applicatif via le protocole CalDAV.

---

## 1. Rôle et Responsabilités

La classe `AppCalendar` est une **couche de compatibilité**. Son rôle principal est de prendre un objet qui implémente l'interface générique `OCP\Calendar\ICalendar` (fourni par n'importe quelle application de Nextcloud) et de l'**adapter pour qu'il se comporte comme un calendrier standard aux yeux du serveur SabreDAV**.

Elle hérite de `ExternalCalendar` et agit comme un pont, traduisant les requêtes du protocole CalDAV en appels aux méthodes de l'interface `ICalendar`. Cela permet à des "calendriers virtuels" (qui n'existent pas directement dans les tables de la base de données CalDAV) d'être consultables et modifiables via des clients CalDAV standards.

---

## 2. Logique d'Adaptation

La classe implémente les méthodes requises par les interfaces de SabreDAV en les mappant aux méthodes de l'objet `ICalendar` qu'elle encapsule.

- **Permissions (`getPermissions`, `getACL`)**:
  - La logique des permissions est dynamique. Par exemple, le droit d'écriture (`{DAV:}write`) n'est accordé que si le calendrier applicatif sous-jacent implémente l'interface `ICreateFromString`, indiquant qu'il sait comment créer un événement à partir de données brutes.

- **Création d'objet (`createFile`)**:
  - Traduit une requête de création CalDAV en un appel à `$this->calendar->createFromString(...)`. Si le calendrier sous-jacent ne supporte pas cette interface, une exception `Forbidden` est levée.

- **Lecture d'objets (`getChild`, `getChildren`)**:
  - Traduit les requêtes de lecture en appels à `$this->calendar->search(...)`. Elle contient une logique pour regrouper les différents composants d'un même événement (base + exceptions) avant de les retourner.

- **Propriétés (`getProperties`)**:
  - Lit les propriétés de base (nom, couleur) depuis l'objet `ICalendar` et les expose comme des propriétés DAV standards.

- **Opérations bloquées (`delete`, `setACL`, `propPatch`)**:
  - Pour les opérations qui n'ont pas d'équivalent direct dans l'interface `ICalendar` (comme la suppression du calendrier lui-même ou la modification de ses permissions), la classe lève une exception `Forbidden` ou ne fait rien, protégeant ainsi le calendrier applicatif.

- **Requêtes filtrées (`calendarQuery`)**:
  - Implémente une version de base du `calendar-query` en récupérant d'abord tous les enfants (`getChildren`) puis en appliquant les filtres en mémoire, car l'interface `ICalendar` ne fournit pas de méthode de recherche filtrée avancée.

---

## Conclusion

`AppCalendar` est une brique d'intégration architecturale très importante. Elle rend le serveur CalDAV extensible en lui permettant de servir non seulement les calendriers stockés dans sa propre base de données, mais aussi n'importe quel type de source de données calendaires provenant de l'écosystème d'applications Nextcloud, à condition que cette source respecte le contrat de l'interface `ICalendar`. C'est la "colle" qui permet à des applications tierces de s'intégrer nativement au protocole CalDAV de Nextcloud.
