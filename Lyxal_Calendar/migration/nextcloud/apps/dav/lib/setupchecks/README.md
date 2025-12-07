# Analyse du Répertoire `SetupChecks` de Nextcloud DAV

Ce répertoire contient les vérifications de configuration (3 fichiers).

---

## `WebdavEndpoint.php`
-   **Fonction** : Vérifie que l'endpoint WebDAV est accessible
-   **Test** : Requête PROPFIND sur `/remote.php/webdav`
-   **Erreur** : Problème de configuration Apache/Nginx

## `NeedsSystemAddressBookSync.php`
-   **Fonction** : Vérifie si le carnet d'adresses système nécessite une synchronisation
-   **Avertissement** : Sync incomplète après mise à jour

## `SystemAddressBookSize.php`
-   **Fonction** : Vérifie la taille du carnet d'adresses système
-   **Avertissement** : Performance si trop gros
