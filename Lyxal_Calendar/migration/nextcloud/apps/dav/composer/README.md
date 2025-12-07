# Analyse du Répertoire `composer` de Nextcloud DAV

Ce répertoire contient la configuration Composer pour les dépendances de l'app.

---

## Fichiers

### `composer.json`
-   **Fonction** : Définit les dépendances PHP de l'app DAV
-   **Usage** : `composer install` pour installer les dépendances

### `composer.lock`
-   **Fonction** : Verrouille les versions exactes des dépendances

### `autoload.php`
-   **Fonction** : Point d'entrée pour l'autoloading Composer
-   **Usage** : Inclus par l'app pour charger les dépendances

### `composer/`
-   **Contenu** : Fichiers générés par Composer (ClassLoader, autoload_*.php)
