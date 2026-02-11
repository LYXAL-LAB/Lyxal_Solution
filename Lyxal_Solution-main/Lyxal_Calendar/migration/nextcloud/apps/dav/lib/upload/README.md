# Analyse du Répertoire `Upload` de Nextcloud DAV

Ce répertoire gère l'upload chunké (par morceaux) via WebDAV (11 fichiers).

---

## Plugins

### `ChunkingPlugin.php`
-   **Fonction** : Plugin pour l'upload chunké v1 (legacy)
-   **Méthode** : PUT avec header `OC-Chunked`

### `ChunkingV2Plugin.php`
-   **Fonction** : Plugin pour l'upload chunké v2 (moderne)
-   **Méthode** : MKCOL + PUT des chunks + MOVE pour assembler
-   **Avantages** : Retry, parallélisation, vérification d'intégrité

### `UploadAutoMkcolPlugin.php`
-   **Fonction** : Crée automatiquement les répertoires parents lors d'un upload

---

## Collections

| Classe | Fonction |
|--------|----------|
| `RootCollection` | Racine `/uploads/` |
| `UploadHome` | Répertoire d'upload d'un utilisateur |
| `UploadFolder` | Dossier temporaire pour un upload en cours |

---

## Fichiers

| Classe | Fonction |
|--------|----------|
| `UploadFile` | Fichier final après assemblage |
| `FutureFile` | Placeholder pour le fichier en cours d'upload |
| `PartFile` | Chunk individuel |

---

## Utilitaires

### `AssemblyStream.php`
-   **Fonction** : Stream qui assemble les chunks à la lecture
-   **Usage** : Fusion des morceaux sans copie en mémoire

### `CleanupService.php`
-   **Fonction** : Nettoie les uploads incomplets
