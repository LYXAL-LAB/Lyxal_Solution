# Analyse de `OCA\DAV\CalDAV\Trashbin\RestoreTarget`

## Description

`RestoreTarget` est une classe astucieuse qui implémente un "nœud cible" virtuel pour les opérations de restauration. Elle se matérialise dans l'arborescence DAV sous la forme d'une collection (un dossier), généralement nommée `restore`, qui agit comme une "zone de dépôt" (drop zone) pour déclencher une action de restauration via une opération `MOVE` standard.

## Rôle et Responsabilités

1.  **Implémentation d'Interfaces Stratégiques** :
    *   `Sabre\DAV\ICollection`: Permet au nœud de se comporter comme un dossier, même s'il est virtuel et toujours vide.
    *   `Sabre\DAV\IMoveTarget`: C'est l'interface la plus importante ici. Elle signale au serveur SabreDAV que ce nœud peut servir de destination pour une requête `MOVE`, ce qui déclenche l'appel à la méthode `moveInto()`.

2.  **Déclenchement de la Restauration (`moveInto`)** :
    *   C'est la seule méthode active et le cœur de la classe. Elle est appelée lorsque le serveur traite une requête `MOVE` ayant ce nœud comme destination.
    *   La logique est simple mais puissante :
        1.  Elle vérifie si l'objet qui est déplacé (`$sourceNode`) est une instance de `IRestorable`. L'interface `IRestorable` est un marqueur personnalisé de Nextcloud pour les objets qui peuvent être restaurés (comme `DeletedCalendarObject`).
        2.  Si l'objet est bien "restaurable", la méthode appelle simplement `$sourceNode->restore()`.
        3.  Elle délègue ainsi toute la logique de restauration à l'objet lui-même. C'est `DeletedCalendarObject` qui sait comment interagir avec le backend pour se restaurer.
    *   Cette approche transforme une opération de protocole standard (`MOVE`) en un appel à une action métier spécifique (`restore`).

3.  **Comportement de Collection Vide et Verrouillée** :
    *   Pour toutes les autres opérations, ce nœud se comporte comme un dossier vide et protégé en écriture.
    *   **Accès** : `getChild()`, `getChildren()`, et `childExists()` retournent toujours des résultats indiquant que le dossier est vide.
    *   **Écriture** : `createFile()`, `createDirectory()`, `delete()`, et `setName()` lèvent systématiquement une `Sabre\DAV\Exception\Forbidden`, empêchant toute modification de ce nœud virtuel.

En résumé, `RestoreTarget` est un design pattern élégant qui expose une action métier complexe (la restauration) via une sémantique de protocole simple et standard (`MOVE`). Il agit comme un point de terminaison qui intercepte une action de déplacement et la traduit en un appel de méthode `restore()` sur l'objet source, sans jamais avoir besoin de stocker de données lui-même.
