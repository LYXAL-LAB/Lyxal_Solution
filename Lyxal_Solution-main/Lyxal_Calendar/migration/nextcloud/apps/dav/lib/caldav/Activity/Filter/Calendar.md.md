# Analyse du Fichier `Activity/Filter/Calendar.php`

Ce document décompose le contenu de la classe `Activity\Filter\Calendar.php`. Il s'agit d'une classe de configuration qui déclare un filtre pour l'application "Activity" de Nextcloud.

---

## 1. Rôle et Responsabilités

La classe `Calendar` implémente l'interface `OCP\Activity\IFilter`. Son unique responsabilité est de **définir et d'enregistrer un filtre "Calendrier"** dans l'interface utilisateur de l'application Activity.

Elle ne contient pas de logique de traitement, mais fournit toutes les métadonnées nécessaires à l'application Activity pour afficher une option de filtrage permettant à l'utilisateur de n'isoler que les notifications relatives aux calendriers.

---

## 2. Méthodes de l'Interface

Chaque méthode correspond à une information requise par le gestionnaire d'activités pour construire l'interface de filtrage.

- **`getIdentifier()`**:
  - Retourne l'identifiant machine du filtre : `calendar`.

- **`getName()`**:
  - Retourne le nom traduit et lisible par un humain : "Calendrier".

- **`getPriority()`**:
  - Retourne un entier (`40`) qui définit l'ordre d'affichage du filtre dans la liste.

- **`getIcon()`**:
  - Retourne l'URL de l'icône à afficher à côté du nom du filtre.

- **`filterTypes(array $types)`**:
  - **C'est la méthode fonctionnelle clé.** Elle reçoit une liste de types d'activités et doit retourner uniquement ceux qui correspondent à ce filtre.
  - **Action**: Elle retourne l'intersection de la liste d'entrée avec `['calendar', 'calendar_event']`. Concrètement, si un utilisateur clique sur ce filtre, l'application Activity n'affichera que les notifications dont le type est soit `calendar` (pour les actions sur les calendriers eux-mêmes) soit `calendar_event` (pour les actions sur les événements).

---

## Conclusion

`Activity\Filter\Calendar` est une classe de "plomberie" ou de configuration. Elle agit comme une simple déclaration qui permet au `Activity\Backend` (qui génère les activités) et à l'application Activity (qui les affiche) de se coordonner. En définissant ce filtre, elle offre aux utilisateurs un moyen pratique de consulter spécifiquement l'historique des modifications apportées à leurs calendriers.
