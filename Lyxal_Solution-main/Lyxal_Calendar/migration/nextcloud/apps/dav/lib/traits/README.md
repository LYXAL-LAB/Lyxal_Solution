# Analyse du Répertoire `Traits` de Nextcloud DAV

Ce répertoire contient les traits PHP réutilisables (1 fichier).

---

## `PrincipalProxyTrait.php`
-   **Fonction** : Trait pour la gestion des proxies de principaux
-   **Usage** : Permet à un utilisateur d'accéder aux calendriers d'un autre (délégation)
-   **Méthodes** :
    -   `getProxies()` : Liste les utilisateurs qui peuvent agir pour ce principal
    -   `getReadProxies()` : Proxies en lecture seule
    -   `getWriteProxies()` : Proxies en lecture/écriture
