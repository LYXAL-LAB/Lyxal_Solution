# Analyse du Fichier `EventReader.php` de Nextcloud

Ce document décompose le contenu de la classe `EventReader.php`. Cette classe est un composant de bas niveau, purement algorithmique, dont le rôle est de lire et d'interpréter des événements iCalendar complexes, en particulier ceux qui sont récurrents.

---

## 1. Rôle et Responsabilités

La classe `EventReader` agit comme un **itérateur d'occurrences d'événements**. Sa responsabilité principale est de prendre un ou plusieurs composants `VEVENT` liés (un événement de base et ses exceptions) et de fournir une interface simple pour "parcourir" toutes les dates où cet événement a lieu, en tenant compte de toutes les règles de récurrence et d'exception.

Elle décode la logique complexe définie par la norme iCalendar (RFC 5545) concernant `RRULE`, `RDATE`, `EXRULE`, `EXDATE`, et `RECURRENCE-ID`.

---

## 2. Logique Principale

### Initialisation (`__construct`)
Le constructeur prépare l'itérateur en analysant l'événement de base.
1.  **Normalisation de l'entrée**: Transforme l'entrée (VCalendar, VEvent, etc.) en une liste de composants `VEvent`.
2.  **Identification de l'événement de base**: Trouve l'événement principal (sans `RECURRENCE-ID`) et sépare les exceptions.
3.  **Gestion des fuseaux horaires**: Détermine le fuseau horaire de l'événement.
4.  **Calcul de la durée**: Calcule la durée de l'événement.
5.  **Initialisation des itérateurs internes**: Crée des instances de `EventReaderRRule` et `EventReaderRDate` pour gérer les `RRULE`, `RDATE`, `EXRULE`, et `EXDATE`.

### Méthodes d'Itération
- **`recurrenceAdvance()`**: Cœur de l'itérateur, calcule la **prochaine date d'occurrence valide**. Elle interroge les itérateurs internes pour trouver la prochaine date possible, trouve la prochaine date d'exception, et s'assure que la date d'occurrence n'est pas une date d'exception.
- **`recurrenceRewind()`**: Réinitialise l'itérateur à la date de début.
- **`recurrenceAdvanceTo(...)`**: Avance rapidement l'itérateur jusqu'à une date spécifique.

### Accesseurs d'Informations
La classe expose de nombreuses méthodes pour obtenir des informations sur la règle de récurrence.
- **`recurs()`**: L'événement est-il récurrent ?
- **`recurringPattern()`, `recurringPrecision()`, `recurringInterval()`**: Détails de la règle (`FREQ`, `INTERVAL`).
- **`recurringConcludes()`**: La récurrence a-t-elle une fin ?
- **`recurringConcludesOn()`, `recurringConcludesAfter()`**: Date de fin ou nombre d'occurrences.
- **`recurringDaysOfWeek()`, `recurringDaysOfMonth()`, etc.**: Listes de jours, mois, etc., spécifiées dans la `RRULE`.

---

## Conclusion

`EventReader` est une classe d'utilitaire algorithmique de bas niveau. C'est une machine à états complexe qui encapsule la logique de la RFC 5545 pour l'itération des événements récurrents. Elle abstrait la complexité du calcul des récurrences, permettant à des services de plus haut niveau de travailler avec ces événements de manière simple et efficace.
