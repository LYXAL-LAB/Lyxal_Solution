# Analyse du Répertoire `Db` de Nextcloud DAV

Ce répertoire contient les entités et mappers de base de données pour le module DAV.

---

## Entités

### `Absence.php`
-   **Table** : `dav_absence`
-   **Champs** : `userId`, `firstDay`, `lastDay`, `status`, `message`, `replacementUserId`, `replacementUserDisplayName`
-   **Fonction** : Stocke les périodes d'absence (Out-of-Office) des utilisateurs
-   **Méthode clé** : `toOutOfOfficeData()` - Convertit en `IOutOfOfficeData`

### `Direct.php`
-   **Table** : `directlink`
-   **Champs** : `userId`, `fileId`, `token`, `expiration`
-   **Fonction** : Liens directs temporaires pour téléchargement de fichiers

### `Property.php`
-   **Table** : `properties`
-   **Fonction** : Propriétés WebDAV personnalisées (utilisée par `CustomPropertiesBackend`)

---

## Mappers

### `AbsenceMapper.php`
-   CRUD pour les entités `Absence`
-   `findByUserId()` : Récupère l'absence d'un utilisateur

### `DirectMapper.php`
-   CRUD pour les entités `Direct`
-   `deleteExpired()` : Nettoie les liens expirés

### `PropertyMapper.php`
-   CRUD pour les propriétés WebDAV
-   `findPropertiesByPathsAndUsers()` : Recherche en masse pour optimisation
