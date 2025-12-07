# Analyse de `OCA\DAV\Command\ListCalendars`

## Description

`ListCalendars` est une commande console `occ`, équivalente à `dav:list-addressbooks`, qui permet aux administrategurs de lister tous les calendriers associés à un utilisateur donné.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:list-calendars`
-   **Description** : "List all calendars of a user" (Lister tous les calendriers d'un utilisateur).

### Fonctionnement

1.  **Argument Requis** : La commande prend un unique argument obligatoire :
    *   `uid` : L'identifiant de l'utilisateur pour lequel les calendriers doivent être listés.

2.  **Validation** : Elle vérifie que l'utilisateur spécifié existe.

3.  **Récupération des Données** :
    *   Elle appelle la méthode `getCalendarsForUser()` du `CalDavBackend` pour obtenir la liste complète des calendriers. Cette liste inclut à la fois les calendriers propres à l'utilisateur et ceux qui lui ont été partagés.

4.  **Traitement et Formatage** :
    *   La commande itère sur la liste des calendriers récupérés.
    *   **Filtrage** : Elle exclut de la liste le calendrier spécial des anniversaires (`BirthdayService::BIRTHDAY_CALENDAR_URI`), car il est généré automatiquement et géré différemment des calendriers standards.
    *   **Extraction des Données** : Pour chaque calendrier, elle extrait et formate les informations clés :
        *   L'URI (le "nom" unique du calendrier).
        *   Le nom d'affichage (`displayname`).
        *   Le "principal" du propriétaire (utile pour les calendriers partagés).
        *   Le nom d'affichage du propriétaire.
        *   Un indicateur `Writable` (✓ ou x) pour savoir si l'utilisateur a les droits d'écriture sur le calendrier.

5.  **Affichage** :
    *   Les informations collectées sont présentées à l'administrateur sous la forme d'un **tableau clair et lisible** dans la console.
    *   Si aucun calendrier (autre que celui des anniversaires) n'est trouvé, un message l'indique.

### Cas d'Usage

C'est un outil d'administration fondamental pour :
-   Obtenir rapidement un inventaire des calendriers d'un utilisateur.
-   Trouver l'URI précis d'un calendrier, nécessaire pour d'autres commandes comme `dav:delete-calendar` ou `calendar:export`.
-   Vérifier les permissions d'un utilisateur sur ses calendriers et sur ceux partagés avec lui.

## Dépendances Clés

-   `OCP\IUserManager`: Pour valider l'existence de l'utilisateur.
-   `OCA\DAV\CalDAV\CalDavBackend`: Le service qui fournit la liste des calendriers.
-   `Symfony\Component\Console`: Le framework utilisé pour la structure de la commande et l'affichage du tableau.
