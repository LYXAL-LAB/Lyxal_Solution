# Analyse de `OCA\DAV\Command\ListCalendarShares`

## Description

`ListCalendarShares` est une commande console `occ` qui fournit une vue détaillée de tous les partages de calendrier auxquels un utilisateur a accès, que ce soit directement ou via son appartenance à des groupes ou des cercles.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:list-calendar-shares`
-   **Description** : "List all calendar shares for a user" (Lister tous les partages de calendrier pour un utilisateur).

### Fonctionnement

1.  **Arguments** :
    *   `uid` (obligatoire) : L'identifiant de l'utilisateur dont on veut inspecter les accès.
    *   `--calendar-id` (optionnel) : Permet de restreindre la liste aux partages d'un calendrier spécifique en fournissant son ID numérique.

2.  **Logique de Récupération Complète** :
    *   La commande va au-delà d'une simple recherche de partages directs. Pour obtenir une vue exhaustive, elle détermine d'abord l'ensemble des identités ("principals") de l'utilisateur :
        1.  Son principal d'utilisateur individuel (`principals/users/...`).
        2.  Tous les principaux des groupes auxquels il appartient (`principals/groups/...`).
        3.  Tous les principaux des cercles (Teams) auxquels il appartient (`principals/circles/...`).
    *   Elle utilise ensuite cette liste complète de principals pour interroger le `SharingMapper` et trouver tous les partages de type `'calendar'` qui ont été accordés à l'une de ces identités.

3.  **Filtrage et Formatage Détaillé (`formatCalendarShare`)** :
    *   Si l'option `--calendar-id` est fournie, la liste est filtrée en conséquence.
    *   Pour chaque partage trouvé, la commande rassemble un ensemble riche d'informations :
        *   **ID du Partage** : L'identifiant unique de la règle de partage.
        *   **ID du Calendrier** : L'identifiant du calendrier partagé.
        *   **URI et Nom du Calendrier** : Pour une identification facile.
        *   **Propriétaire du Calendrier** : Qui est le propriétaire original du calendrier.
        *   **Accès Via ("Access By")** : Indique **comment** l'utilisateur a obtenu l'accès (partage "Individuel", via un "Groupe", ou via une "Équipe/Cercle"). Le nom du groupe/cercle est précisé.
        *   **Permissions** : Le niveau d'accès accordé ("Read", "Read/Write", "Unshare").

4.  **Affichage** :
    *   Toutes ces informations sont présentées à l'administrateur dans un **tableau très détaillé**, offrant une vue claire et complète des droits d'accès.

### Cas d'Usage

Cette commande est un outil de **diagnostic et d'audit** très puissant pour les administrateurs :
-   Comprendre pourquoi un utilisateur a (ou n'a pas) accès à un calendrier spécifique.
-   Identifier rapidement tous les calendriers accessibles par un utilisateur via son appartenance à divers groupes et cercles.
-   Auditer les permissions sur un calendrier sensible en listant tous ses partages.
-   Trouver l'ID d'une règle de partage pour des opérations de bas niveau en base de données.

## Dépendances Clés

-   `OCP\IUserManager`: Pour valider l'existence de l'utilisateur.
-   `OCA\DAV\Connector\Sabre\Principal`: Pour résoudre l'appartenance de l'utilisateur aux groupes et cercles.
-   `OCA\DAV\DAV\Sharing\SharingMapper`: La classe d'accès aux données pour la table des partages (`oc_share`).
-   `OCA\DAV\CalDAV\CalDavBackend`: Pour enrichir les informations avec les détails du calendrier (nom, propriétaire, etc.).
-   `Symfony\Component\Console`: Pour la structure de la commande et l'affichage du tableau.
