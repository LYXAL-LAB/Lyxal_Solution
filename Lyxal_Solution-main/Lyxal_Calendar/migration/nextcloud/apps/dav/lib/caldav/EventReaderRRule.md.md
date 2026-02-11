# Analyse du Fichier `EventReaderRRule.php` de Nextcloud

Ce document décompose le contenu de la classe `EventReaderRRule.php`. C'est une classe d'aide de bas niveau qui encapsule la logique de parcours d'une règle de récurrence iCalendar (`RRULE`).

---

## 1. Rôle et Responsabilités

La classe `EventReaderRRule` est un **itérateur de règle de récurrence**. Elle hérite de `\Sabre\VObject\Recur\RRuleIterator` et sa responsabilité principale est de gérer les propriétés iCalendar `RRULE` (Recurrence Rule) et `EXRULE` (Exception Rule).

Elle prend en entrée les composantes d'une règle (fréquence, intervalle, etc.) et agit comme un "générateur de dates". À chaque appel de sa méthode `next()` (héritée), elle calcule la prochaine date qui correspond à la règle.

Elle est utilisée par la classe `EventReader` pour gérer la génération des dates issues des règles de récurrence et d'exception.

---

## 2. Fonctions Publiques (Accesseurs)

La classe étend la classe de base de Sabre/VObject en y ajoutant une série de méthodes "accesseurs" pratiques pour interroger facilement les différentes parties de la règle de récurrence.

### Informations sur la règle
- **`precision()`**: Retourne la fréquence (`YEARLY`, `MONTHLY`, etc.).
- **`interval()`**: Retourne l'intervalle (ex: `2`).

### Informations sur la fin de la récurrence
- **`concludes()`**: Retourne la date de la dernière occurrence, qu'elle soit définie par `UNTIL` ou calculée via `COUNT`.
- **`concludesAfter()`**: Retourne le `COUNT`.
- **`concludesOn()`**: Retourne la date `UNTIL`.

### Informations sur les filtres "BY..."
- **`daysOfWeek()`**: Retourne les jours de `BYDAY`.
- **`daysOfMonth()`**: Retourne les jours de `BYMONTHDAY`.
- **`daysOfYear()`**, **`weeksOfYear()`**, **`monthsOfYear()`**.

### Informations sur la position relative
- **`isRelative()`**: Indique si la règle utilise `BYSETPOS`.
- **`relativePosition()`**: Retourne les positions de `BYSETPOS`.

---

## Conclusion

`EventReaderRRule` est une classe utilitaire de très bas niveau qui sert de "moteur de calcul" pour les règles de récurrence. En enrichissant l'itérateur de Sabre/VObject avec de nombreux accesseurs clairs, elle fournit une API simple et puissante à la classe `EventReader`, lui permettant de s'abstraire de la complexité du calcul des occurrences.
