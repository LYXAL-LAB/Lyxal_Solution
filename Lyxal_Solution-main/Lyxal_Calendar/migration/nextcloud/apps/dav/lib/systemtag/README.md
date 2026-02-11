# Analyse du Répertoire `SystemTag` de Nextcloud DAV

Ce répertoire expose les tags système via WebDAV (11 fichiers).

---

## Plugin Principal

### `SystemTagPlugin.php`
-   **Type** : Plugin Sabre
-   **Fonction** : Gère les opérations CRUD sur les tags système via WebDAV
-   **Propriétés** : `{oc}id`, `{oc}display-name`, `{oc}user-visible`, `{oc}user-assignable`
-   **REPORT** : Recherche de tags, tags par fichier

---

## Collections

| Classe | Chemin | Fonction |
|--------|--------|----------|
| `SystemTagsByIdCollection` | `/systemtags/` | Liste tous les tags par ID |
| `SystemTagsRelationsCollection` | `/systemtags-relations/` | Relations tags-objets |
| `SystemTagsObjectTypeCollection` | `/systemtags-relations/{type}/` | Tags par type d'objet |
| `SystemTagsObjectMappingCollection` | `/systemtags-relations/{type}/{id}/` | Tags d'un objet spécifique |
| `SystemTagsObjectList` | Liste d'objets | Tags affectés à plusieurs objets |
| `SystemTagsInUseCollection` | Tags en usage | Tags effectivement utilisés |

---

## Nœuds

### `SystemTagNode.php`
-   **Interface** : `Sabre\DAV\INode`
-   **Fonction** : Représente un tag individuel
-   **Opérations** : PROPPATCH (modifier), DELETE (supprimer)

### `SystemTagMappingNode.php`
-   **Fonction** : Représente l'association tag-objet
-   **Opérations** : DELETE (dissocier)

---

## Utilitaires

### `SystemTagList.php`
-   **Fonction** : Liste de tags pour serialisation XML

### `SystemTagObjectType.php`
-   **Fonction** : Type d'objet pour les relations (ex: `files`)
