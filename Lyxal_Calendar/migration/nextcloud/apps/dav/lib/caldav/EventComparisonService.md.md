# Analyse du Fichier `EventComparisonService.php` de Nextcloud

Ce document décompose le contenu de la classe `EventComparisonService.php`. Il s'agit d'un service utilitaire spécialisé dans la comparaison de deux versions d'un objet `VCalendar` pour en extraire les différences.

---

## 1. Rôle et Responsabilités

La classe `EventComparisonService` est un **service algorithmique**. Sa seule responsabilité est de comparer une "nouvelle" version d'un `VCalendar` avec une "ancienne" version et d'identifier les composants `VEvent` qui ont été modifiés, ajoutés ou qui sont restés inchangés.

Ce service est essentiel pour des mises à jour granulaires, en particulier dans le contexte de la planification (scheduling) et des invitations.

---

## 2. Logique de Comparaison

- **`EVENT_DIFF` (Constante)**:
  - C'est une liste de propriétés iCalendar considérées comme critiques pour définir l'identité et l'état d'un événement :
    -   `RECURRENCE-ID`, `RRULE`, `SEQUENCE`, `LAST-MODIFIED`.

---

## 3. Fonctions Publiques et Privées

- **`findModified(VCalendar $new, ?VCalendar $old)` (Publique)**:
  - **Rôle**: C'est la méthode principale du service.
  - **Logique d'exécution**:
    1.  Extrait tous les `VEvent` de la nouvelle et de l'ancienne version.
    2.  Parcourt chaque événement de l'**ancienne** version.
    3.  Appelle `removeIfUnchanged` pour chercher un événement **identique** dans la liste des nouveaux événements.
    4.  Si un événement identique est trouvé, il est retiré des deux listes.
    5.  À la fin, il ne reste que les événements modifiés/supprimés dans la liste des "anciens", et les événements modifiés/ajoutés dans la liste des "nouveaux".
    6.  Retourne un tableau contenant ces deux listes.

- **`removeIfUnchanged(VEvent $filterEvent, array &$eventsToFilter)` (Privée)**:
  - **Rôle**: Chercher un événement spécifique dans une liste et le supprimer s'il est identique.
  - **Action**:
    1.  Construit une "signature" de l'événement en extrayant les valeurs des propriétés de `EVENT_DIFF`.
    2.  Parcourt la liste cible et construit la même "signature" pour chaque événement.
    3.  Si les signatures sont identiques, elle supprime l'événement de la liste et retourne `true`.

---

## Conclusion

`EventComparisonService` est un service utilitaire de bas niveau qui encapsule une logique de "diff" (comparaison) spécifique au format iCalendar. En se concentrant sur les propriétés structurelles clés, il offre un moyen fiable de détecter les changements significatifs entre deux versions d'un calendrier, ce qui est une brique fondamentale pour la gestion intelligente des mises à jour d'événements.
