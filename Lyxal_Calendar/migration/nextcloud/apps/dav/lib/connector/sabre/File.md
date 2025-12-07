# Analyse du Fichier `File.php` de Nextcloud

## Description

`File` représente un fichier individuel dans l'arborescence WebDAV. Elle gère la lecture, l'écriture (upload), la suppression et les métadonnées associées.

## Rôle et Responsabilités

### 1. Lecture (`get`, `getDirectDownload`)
-   **`get`** : Ouvre un flux de lecture (`fopen`) vers le fichier physique. Gère le chiffrement et vérifie la taille du fichier.
-   **`getDirectDownload`** : Si possible (et si le chiffrement est désactivé), retourne une URL de téléchargement direct pour décharger le serveur PHP.

### 2. Écriture / Upload (`put`)
-   Gère l'upload de fichier, y compris les uploads partiels (`.part`).
-   **Verrouillage** : Acquiert un verrou exclusif pendant l'écriture.
-   **Hashing** : Calcule les checksums (MD5, SHA1, SHA256) à la volée si demandé par le client (`X-HASH`).
-   **Hooks** : Déclenche les hooks Nextcloud (`create`, `write`, `update`) avant et après l'écriture.
-   **Vérification** : Compare la taille reçue avec `Content-Length` pour détecter les uploads corrompus.

### 3. Métadonnées
-   Gère les ETag (`getETag`), la taille (`getSize`), le type MIME (`getContentType`).
-   Supporte les dates de création/modification personnalisées envoyées par les clients de synchro (`X-OC-MTime`, `X-OC-CTime`).

## Dépendances Clés
-   `OCA\DAV\Connector\Sabre\Node` : Classe parente.
-   `OC\Files\View` : Accès au stockage.
-   `Sabre\DAV\IFile` : Interface SabreDAV.
