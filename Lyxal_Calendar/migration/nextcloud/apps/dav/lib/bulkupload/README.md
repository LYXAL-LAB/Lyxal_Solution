# Analyse du Répertoire `BulkUpload` de Nextcloud DAV

Ce répertoire implémente l'upload en masse de fichiers via une requête multipart unique.

---

## `BulkUploadPlugin.php`

### Description
Plugin Sabre qui gère l'endpoint `/dav/bulk` pour uploader plusieurs fichiers en une seule requête HTTP POST.

### Fonctionnement
1. Écoute les requêtes `POST` sur `/dav/bulk`
2. Parse le corps multipart via `MultipartRequestParser`
3. Crée chaque fichier via `userFolder->newFile()`
4. Retourne un JSON avec ETag, FileID, permissions pour chaque fichier

### Headers Supportés par Fichier
-   `X-File-Path` : Chemin du fichier
-   `X-File-Mtime` / `X-OC-Mtime` : Date de modification
-   `Content-Length` : Taille du contenu

### Réponse
```json
{
  "/path/to/file1.txt": {"error": false, "etag": "...", "fileid": "...", "permissions": "..."},
  "/path/to/file2.txt": {"error": true, "message": "..."}
}
```

---

## `MultipartRequestParser.php`

### Description
Parseur de requêtes `multipart/related` pour l'upload en masse.

### Fonctionnement
1. Parse le boundary depuis `Content-Type`
2. Lit chaque partie délimitée par le boundary
3. Valide le hash (MD5 ou OC-Checksum) avant écriture
4. Retourne les headers et le contenu de chaque partie

### Validation
-   `Content-Length` obligatoire
-   Hash obligatoire (`X-File-MD5` ou `OC-Checksum`)
-   Vérifie l'intégrité du contenu avant de le transmettre

### Format de Requête
```
--boundary_xyz
Content-Length: 123
X-File-Path: /path/to/file.txt
OC-Checksum: sha256:abc123...

[Contenu du fichier]
--boundary_xyz
...
--boundary_xyz--
```
