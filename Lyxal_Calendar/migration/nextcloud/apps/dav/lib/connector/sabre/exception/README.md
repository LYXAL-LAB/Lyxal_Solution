# Analyse du Répertoire `Exception` de Nextcloud DAV

Ce répertoire contient les exceptions WebDAV personnalisées pour Nextcloud.

---

## Exceptions HTTP

| Classe | Code HTTP | Description |
|--------|-----------|-------------|
| `BadGateway` | 502 | Réponse invalide d'un serveur upstream (proxy) |
| `EntityTooLarge` | 413 | Fichier trop volumineux |
| `FileLocked` | 423 | Fichier verrouillé par un autre processus |
| `TooManyRequests` | 429 | Rate limiting atteint |
| `UnsupportedMediaType` | 415 | Type de contenu non autorisé |

---

## Exceptions avec Sérialisation XML

Ces exceptions incluent des informations supplémentaires dans la réponse WebDAV :

### `Forbidden` (403)
-   Étend `Sabre\DAV\Exception\Forbidden`
-   Ajoute `{oc}retry` (booléen) et `{oc}reason` (message)

### `InvalidPath` (400)
-   Chemin de fichier invalide
-   Ajoute `{oc}retry` et `{oc}reason`

### `PasswordLoginForbidden` (401)
-   Étend `NotAuthenticated`
-   Indique que le login par mot de passe est interdit (utiliser app password)
-   Ajoute `{oc}hint: "password login forbidden"`

### `TooManyRequests` (429)
-   Étend `NotAuthenticated`
-   Ajoute `{oc}hint: "too many requests"`

---

## Namespace XML
Toutes les exceptions utilisent le namespace ownCloud : `http://owncloud.org/ns`
