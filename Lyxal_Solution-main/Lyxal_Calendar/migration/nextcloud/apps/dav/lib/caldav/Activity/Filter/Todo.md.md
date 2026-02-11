# Analyse du Fichier `Activity/Filter/Todo.php`

Ce document décompose le contenu de la classe `Activity\Filter\Todo.php`. Il s'agit d'une classe de configuration qui déclare un filtre pour les tâches (VTODO) dans l'application "Activity".

---

## 1. Rôle et Responsabilités

La classe `Todo` implémente l'interface `OCP\Activity\IFilter`. Sa seule responsabilité est de **définir et d'enregistrer un filtre "Tâches"** dans l'interface utilisateur de l'application Activity.

Elle est structurellement identique à `Activity\Filter\Calendar`, mais est configurée pour isoler les activités relatives aux tâches (VTODO) plutôt qu'aux événements (VEVENT) ou aux calendriers.

---

## 2. Méthodes de l'Interface

- **`getIdentifier()`**:
  - Retourne l'identifiant machine du filtre : `calendar_todo`.

- **`getName()`**:
  - Retourne le nom traduit et lisible : "Tâches".

- **`getPriority()`**:
  - Retourne un entier (`40`) pour définir sa position dans la liste des filtres.

- **`getIcon()`**:
  - Retourne l'URL de l'icône "coche" à afficher.

- **`filterTypes(array $types)`**:
  - **C'est la méthode fonctionnelle clé.**
  - **Action**: Elle retourne l'intersection de la liste d'entrée avec `['calendar_todo']`. Lorsque ce filtre est activé, l'application Activity n'affichera que les notifications générées par le `Activity\Backend` qui concernent spécifiquement des tâches.

---

## Conclusion

`Activity\Filter\Todo` est une classe de configuration symétrique à `Activity\Filter\Calendar`. Elle complète la configuration de l'intégration avec l'application Activity en fournissant un filtre dédié aux tâches, permettant aux utilisateurs de séparer facilement les notifications concernant leurs tâches de celles concernant leurs événements.
