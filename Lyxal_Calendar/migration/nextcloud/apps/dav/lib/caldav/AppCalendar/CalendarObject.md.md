# Analyse du Fichier `AppCalendar/CalendarObject.php`

Ce document décompose le contenu de la classe `AppCalendar\CalendarObject.php`. Cette classe représente un unique événement (ou tâche) au sein d'un calendrier applicatif exposé via CalDAV.

---

## 1. Rôle et Responsabilités

La classe `CalendarObject` est la **représentation DAV d'un objet iCalendar** qui provient d'un calendrier applicatif (un objet `ICalendar`). Elle est instanciée et gérée par la classe `AppCalendar`.

Son rôle est de servir de **couche d'adaptation au niveau de l'objet**. Elle implémente les interfaces `ICalendarObject` et `IACL` de SabreDAV, traduisant les opérations du protocole WebDAV (comme `GET`, `PUT`, `DELETE`) en actions logiques sur le backend `ICalendar` sous-jacent.

---

## 2. Logique d'Adaptation

- **Lecture (`get`, `getName`, `getLastModified`, etc.)**:
  - Ces méthodes lisent les informations directement depuis l'objet `VCalendar` qui lui est fourni lors de son instanciation. Le nom de l'objet (`getName`) est intelligemment déduit de la propriété `X-FILENAME` si elle existe, ou de l'`UID` de l'événement.

- **Mise à jour (`put`)**:
  - Traduit une requête `PUT` en un appel à la méthode `createFromString` du backend `ICalendar`. Elle passe simplement les nouvelles données brutes pour que le calendrier applicatif gère la mise à jour. L'opération n'est autorisée que si le backend `ICalendar` a les permissions `PERMISSION_UPDATE`.

- **Suppression (`delete`)**:
  - **Logique de suppression "logique"**: C'est un point d'implémentation important. Comme l'interface `ICalendar` ne spécifie pas de méthode de suppression, cette classe simule une suppression en respectant le protocole de scheduling (iTip) :
    1.  Elle modifie l'objet `VCalendar` en mémoire.
    2.  Elle change le statut (`STATUS`) à `CANCELLED`.
    3.  Elle incrémente le numéro de séquence (`SEQUENCE`).
    4.  Elle **met à jour** l'objet via `createFromString` avec cette nouvelle version "annulée".
  - L'objet n'est pas physiquement supprimé, mais il est marqué comme annulé, ce qui est la bonne pratique pour notifier les participants.

- **Permissions (`getACL`)**:
  - Construit dynamiquement la liste des permissions en fonction des permissions retournées par le backend `ICalendar` sous-jacent. Par exemple, le droit d'écriture (`write-content`) n'est accordé que si le backend a la permission `PERMISSION_UPDATE`.

- **Opérations Bloquées (`setACL`, `setName`)**:
  - Lève une exception `Forbidden` pour les opérations qui ne sont pas supportées, comme le renommage ou la modification des permissions.

---

## Conclusion

`CalendarObject` finalise l'intégration des calendriers applicatifs en gérant le cycle de vie de chaque événement individuel. Elle complète le travail d'`AppCalendar` en fournissant une adaptation fine des opérations au niveau de l'objet. Sa gestion de la suppression (en la transformant en une mise à jour d'annulation) est un exemple particulièrement intelligent de la manière de rester compatible avec les protocoles standards même lorsque l'interface du backend sous-jacent a des capacités limitées.
