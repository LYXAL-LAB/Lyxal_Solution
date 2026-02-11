# Analyse du Répertoire `Comments` de Nextcloud DAV

Ce répertoire expose les commentaires des fichiers via WebDAV.

---

## `CommentsPlugin.php`

### Description
Plugin Sabre pour gérer les commentaires via WebDAV.

### Fonctionnalités
-   **POST** : Création de commentaires sur `/comments/{type}/{id}`
-   **REPORT** `{oc}filter-comments` : Recherche de commentaires avec pagination
    -   Params : `{oc}limit`, `{oc}offset`, `{oc}datetime`

### Création de Commentaire
Requête JSON avec `actorType`, `message`, `verb`.

---

## `CommentNode.php`

### Description
Représente un commentaire individuel dans l'arborescence WebDAV.

### Propriétés Exposées
-   `{oc}id`, `{oc}parentId`, `{oc}message`
-   `{oc}actorType`, `{oc}actorId`, `{oc}actorDisplayName`
-   `{oc}creationDateTime`, `{oc}mentions`
-   `{oc}isUnread` : Basé sur le readMarker de l'utilisateur

### Opérations
-   **DELETE** : Suppression (auteur uniquement)
-   **PROPPATCH** : Modification du message (auteur uniquement)

---

## `EntityCollection.php`

### Description
Collection de commentaires pour une entité spécifique (type + id).

### Fonctionnalités
-   `getChild($name)` : Retourne un `CommentNode` par ID
-   `findChildren()` : Liste les commentaires avec pagination
-   `setReadMarker()` : Marque les commentaires comme lus

---

## `EntityTypeCollection.php`

### Description
Collection regroupant les types d'entités (ex: `files`).

---

## `RootCollection.php`

### Description
Racine de l'arborescence des commentaires (`/comments/`).

### Structure
```
/comments/
  └── files/           (EntityTypeCollection)
       └── 12345/      (EntityCollection - fileid)
            └── 1/     (CommentNode - commentid)
```
