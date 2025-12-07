# Analyse du Répertoire `Paginate` de Nextcloud DAV

Ce répertoire implémente la pagination pour les collections WebDAV (3 fichiers).

---

## `PaginatePlugin.php`
-   **Type** : Plugin Sabre
-   **Fonction** : Ajoute le support de pagination aux collections
-   **Headers** : `X-NC-Paginate`, `X-NC-Paginate-Total`
-   **Usage** : Permet de récupérer les enfants d'une collection par lots

## `PaginateCache.php`
-   **Fonction** : Cache les résultats de pagination
-   **Optimisation** : Évite de re-lister les collections pour chaque page

## `LimitedCopyIterator.php`
-   **Fonction** : Itérateur qui limite le nombre d'éléments copiés
-   **Usage** : Utilisé pour extraire une page d'une collection complète
