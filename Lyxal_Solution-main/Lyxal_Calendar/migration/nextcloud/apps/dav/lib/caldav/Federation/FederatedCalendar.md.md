# Analyse du Fichier `Federation/FederatedCalendar.php`

Ce document décompose le contenu de la classe `Federation\FederatedCalendar.php`. Il s'agit d'une spécialisation de la classe `Calendar` pour représenter un calendrier fédéré.

---

## 1. Rôle et Responsabilités

La classe `FederatedCalendar` **hérite de la classe `Calendar`**, qui représente un calendrier CalDAV standard. C'est un point d'architecture clé qui signifie qu'elle **réutilise la quasi-totalité du comportement d'un calendrier normal**. Une fois qu'un calendrier fédéré est synchronisé, ses événements sont stockés localement et peuvent être lus et gérés de la même manière que ceux d'un calendrier natif.

Le rôle de cette classe est de **spécialiser deux comportements spécifiques** qui diffèrent entre un calendrier standard et un calendrier fédéré.

---

## 2. Logique de Spécialisation

La classe ne contient que deux méthodes qui surchargent (`override`) celles de sa classe parente.

- **`delete()`**:
  - **Rôle**: Gérer la suppression d'un calendrier fédéré.
  - **Action**: Au lieu d'implémenter une logique complexe de suppression d'événements, cette méthode délègue l'opération au `FederatedCalendarMapper`. Elle supprime l'enregistrement de l'abonnement au calendrier fédéré dans la base de données. Cela a pour effet de "couper" le lien de synchronisation. La suppression des événements locaux associés est probablement gérée séparément, par exemple par une tâche de nettoyage en arrière-plan.

- **`getCalendarType()`**:
  - **Rôle**: Identifier le type de ce calendrier.
  - **Action**: Retourne la constante `CalDavBackend::CALENDAR_TYPE_FEDERATED`. Cette information est utilisée par d'autres parties du système (comme l'interface utilisateur) pour savoir qu'il s'agit d'un calendrier en lecture seule synchronisé depuis une source externe, et non d'un calendrier local standard.

---

## Conclusion

`FederatedCalendar` est un excellent exemple de **spécialisation par héritage**. En s'appuyant sur la classe `Calendar` existante, elle évite une duplication massive de code. Elle ne redéfinit que le strict minimum nécessaire pour adapter le comportement de suppression et d'identification, illustrant une conception logicielle efficace et maintenable. Elle agit comme une "étiquette" sur un calendrier standard, indiquant son origine fédérée et modifiant sa procédure de suppression.
