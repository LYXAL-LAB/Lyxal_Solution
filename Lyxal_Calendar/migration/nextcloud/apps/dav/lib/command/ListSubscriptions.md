# Analyse de `OCA\DAV\Command\ListSubscriptions`

## Description

`ListSubscriptions` est une commande console `occ` qui permet aux administrateurs de lister tous les abonnements de calendrier (fichiers `.ics` distants) associés à un utilisateur donné.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:list-subscriptions`
-   **Description** : "List all calendar subscriptions for a user" (Lister tous les abonnements de calendrier d'un utilisateur).

### Fonctionnement

1.  **Argument Requis** : La commande prend un unique argument obligatoire :
    *   `uid` : L'identifiant de l'utilisateur pour lequel les abonnements doivent être listés.

2.  **Validation** : Elle vérifie que l'utilisateur spécifié existe via `IUserManager`.

3.  **Récupération des Données** :
    *   Elle récupère la configuration globale du taux de rafraîchissement par défaut (`calendarSubscriptionRefreshRate`).
    *   Elle appelle la méthode `getSubscriptionsForUser()` du `CalDavBackend` pour obtenir la liste des abonnements.

4.  **Traitement et Formatage** :
    *   La commande itère sur la liste des abonnements.
    *   **Extraction des Données** : Pour chaque abonnement, elle extrait :
        *   L'URI (identifiant unique de l'abonnement).
        *   Le nom d'affichage (`displayname`).
        *   Le taux de rafraîchissement (`refreshrate`). Si non défini, elle affiche la valeur par défaut.
        *   La **Source** : L'URL distante du calendrier abonné.
    *   **Tri** : Les résultats sont triés par ordre alphabétique des URI.

5.  **Affichage** :
    *   Les informations sont présentées sous forme de tableau dans la console avec les colonnes : `URI`, `Displayname`, `Refresh rate`, `Source`.
    *   Si aucun abonnement n'est trouvé, un message l'indique.

### Cas d'Usage

C'est un outil utile pour :
-   Auditer les calendriers externes auxquels un utilisateur est abonné (ex: jours fériés, plannings externes).
-   Vérifier les URL sources des abonnements pour le débogage.
-   Contrôler les fréquences de rafraîchissement.

## Dépendances Clés

-   `OCP\IUserManager`: Pour valider l'existence de l'utilisateur.
-   `OCP\IAppConfig`: Pour lire la configuration du taux de rafraîchissement par défaut.
-   `OCA\DAV\CalDAV\CalDavBackend`: Le service qui fournit la liste des abonnements.
