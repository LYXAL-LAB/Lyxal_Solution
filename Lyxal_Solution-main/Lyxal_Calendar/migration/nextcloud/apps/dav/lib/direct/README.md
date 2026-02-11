# Analyse du Répertoire `Direct` de Nextcloud DAV

Ce répertoire implémente les liens de téléchargement direct via WebDAV.

---

## `DirectFile.php`
-   **Interface** : `Sabre\DAV\IFile`
-   **Fonction** : Représente un fichier accessible via lien direct
-   **Opérations** :
    -   `get()` : Retourne le contenu du fichier (stream)
    -   `put()`, `delete()`, `setName()` : Interdits (`Forbidden`)
-   **Événement** : Dispatch `BeforeFileDirectDownloadedEvent`

---

## `DirectHome.php`
-   **Interface** : `Sabre\DAV\ICollection`
-   **Fonction** : Collection racine pour les liens directs (`/dav/direct/`)
-   **Authentification** : Valide le token et l'expiration
-   **Opérations** :
    -   `getChild($token)` : Retourne un `DirectFile` si le token est valide
    -   Création/suppression interdites

---

## `Server.php`
-   Wrapper Sabre Server simplifié

---

## `ServerFactory.php`
-   **Fonction** : Fabrique le serveur WebDAV pour `/dav/direct/`
-   Enregistre les plugins nécessaires (Auth, etc.)
