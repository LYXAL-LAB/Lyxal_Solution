# Analyse de `OCA\DAV\Command\CreateCalendar`

## Description

`CreateCalendar` est une commande console `occ` permettant aux administrateurs de créer un nouveau calendrier pour un utilisateur spécifique. C'est l'équivalent CalDAV de la commande `dav:create-addressbook`.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:create-calendar`
-   **Description** : "Create a dav calendar" (Créer un calendrier DAV).

### Fonctionnement

1.  **Arguments Requis** : La commande prend deux arguments obligatoires :
    1.  `user`: L'identifiant (`uid`) de l'utilisateur pour qui le calendrier doit être créé.
    2.  `name`: Le nom qui sera utilisé pour le nouveau calendrier (ce nom servira aussi à générer l'URI).

2.  **Validation** : La première étape consiste à vérifier, via le `IUserManager`, que l'utilisateur spécifié existe bien.

3.  **Construction Manuelle des Dépendances** :
    *   Contrairement à de nombreuses commandes plus modernes dans Nextcloud, cette classe n'utilise pas pleinement l'injection de dépendances via son constructeur pour tous ses besoins.
    *   Dans la méthode `execute`, elle **instancie manuellement** les services dont elle a besoin, notamment `OCA\DAV\Connector\Sabre\Principal` et `OCA\DAV\CalDAV\CalDavBackend`.
    *   Pour ce faire, elle récupère les dépendances nécessaires (comme le gestionnaire de base de données, le logger, etc.) depuis le conteneur de services global de Nextcloud via `\OCP\Server::get()`. Cette approche est moins courante et moins maintenable que l'injection de dépendances, mais elle reste fonctionnelle.

4.  **Action de Création** :
    *   Une fois qu'une instance de `CalDavBackend` est créée, la commande appelle sa méthode `createCalendar()`.
    *   Elle lui fournit le "principal URI" de l'utilisateur (formaté en `principals/users/user-id`), le nom du calendrier, et un tableau vide pour les propriétés initiales.
    *   Le `CalDavBackend` gère ensuite toute la logique de bas niveau pour créer le calendrier dans la base de données.

### Cas d'Usage

Cette commande est un outil d'administration pour :
-   Provisionner des calendriers pour les utilisateurs via des scripts.
-   Créer des calendriers par défaut ou spécifiques lors de l'intégration de nouveaux utilisateurs.
-   Gérer l'infrastructure CalDAV sans avoir à passer par une interface graphique ou une API.

## Dépendances Clés

-   `OCP\IUserManager`: Injecté via le constructeur pour la validation de l'utilisateur.
-   `OCA\DAV\CalDAV\CalDavBackend`: Instancié manuellement, c'est le service qui contient la logique métier pour la création du calendrier.
-   `OCP\Server`: Utilisé comme localisateur de services pour récupérer les dépendances nécessaires à l'instanciation manuelle.
-   `Symfony\Component\Console`: Le framework sur lequel la commande est basée.
