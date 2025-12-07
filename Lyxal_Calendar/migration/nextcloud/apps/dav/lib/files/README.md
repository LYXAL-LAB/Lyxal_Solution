# Analyse du Répertoire `Files` de Nextcloud DAV

Ce répertoire gère l'accès WebDAV aux fichiers utilisateur.

---

## Fichiers Principaux

### `FilesHome.php`
-   **Interface** : `Sabre\DAV\ICollection`
-   **Fonction** : Répertoire racine des fichiers d'un utilisateur (`/files/admin/`)

### `RootCollection.php`
-   **Fonction** : Collection racine `/files/` contenant les `FilesHome` par utilisateur

### `FileSearchBackend.php`
-   **Fonction** : Backend de recherche WebDAV (SEARCH, REPORT)
-   **Capacités** : Recherche par nom, type MIME, taille, dates, tags

### `LazySearchBackend.php`
-   **Fonction** : Wrapper lazy-loading pour `FileSearchBackend`

### `BrowserErrorPagePlugin.php`
-   **Fonction** : Affiche une page d'erreur HTML pour les navigateurs

---

## Sous-répertoire `Sharing/`

### `FilesDropPlugin.php`
-   **Fonction** : Gère les uploads sur les dossiers partagés en "File Drop"
-   Renomme automatiquement les fichiers pour éviter les conflits

### `PublicLinkCheckPlugin.php`
-   **Fonction** : Vérifie la validité des liens publics

### `RootCollection.php`
-   **Fonction** : Collection racine pour les partages publics de fichiers
