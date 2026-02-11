# Analyse du Fichier `Directory.php` de Nextcloud

## Description

`Directory` représente un dossier dans l'arborescence WebDAV de Nextcloud. Elle étend `Node` et implémente plusieurs interfaces SabreDAV pour gérer les collections, les quotas, les déplacements et les copies.

## Rôle et Responsabilités

### 1. Gestion des Enfants (`getChildren`, `getChild`)
-   Liste le contenu du dossier (`getDirectoryListing`).
-   Instancie les objets enfants (`File` ou `Directory`) en fonction de leur type MIME.
-   Gère les permissions : vérifie si le dossier est lisible (`isReadable`), sinon lance une `Forbidden`.

### 2. Opérations d'Écriture (`createFile`, `createDirectory`, `delete`)
-   **Création de Fichier** :
    -   Vérifie les permissions (`isCreatable`).
    -   Gère le verrouillage (`acquireLock`) pour éviter les écritures concurrentes.
    -   Supporte l'upload partiel (`.part`) pour les gros fichiers.
    -   Utilise `Node::put` pour écrire les données.
-   **Création de Dossier** : Crée un sous-dossier via `fileView->mkdir`.
-   **Suppression** : Supprime le dossier et son contenu via `fileView->rmdir`.

### 3. Gestion des Quotas (`getQuotaInfo`)
-   Retourne l'espace utilisé et l'espace libre disponible pour ce dossier.
-   Utilise `OC_Helper::getStorageInfo`.

### 4. Déplacement et Copie (`moveInto`, `copyInto`)
-   Gère le déplacement/copie d'un nœud *vers* ce dossier.
-   Vérifie les permissions (création dans la destination, suppression dans la source pour un move).
-   Gère les cas spécifiques comme les points de montage (`MoveableMount`).
-   Utilise `fileView->rename` ou `fileView->copy`.

## Dépendances Clés
-   `OCA\DAV\Connector\Sabre\Node` : Classe parente.
-   `OC\Files\View` : Vue sur le système de fichiers Nextcloud.
-   `Sabre\DAV\ICollection` : Interface pour les dossiers.
