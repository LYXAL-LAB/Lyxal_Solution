# Analyse de `OCA\DAV\CalDAV\Trashbin\TrashbinHome`

## Description

`TrashbinHome` représente le dossier racine de la corbeille CalDAV pour un utilisateur donné. C'est le point d'entrée de la fonctionnalité de corbeille, généralement accessible via une URL comme `/remote.php/dav/calendars/user-id/trashbin`. Elle agit comme un conteneur statique pour les différentes fonctionnalités liées à la corbeille.

## Rôle et Responsabilités

1.  **Implémentation d'Interfaces Multiples** :
    *   `Sabre\DAVACL\IACL`: Pour la gestion des permissions.
    *   `Sabre\DAV\ICollection`: Pour se comporter comme un dossier/collection DAV.
    *   `Sabre\DAV\IProperties`: Pour exposer des propriétés DAV personnalisées.

2.  **Conteneur Statique et Agrégateur** :
    *   Le rôle principal de `TrashbinHome` est d'agir comme un point de montage pour les sous-composants de la corbeille. Son contenu est fixe et non modifiable.
    *   Les méthodes `getChild()`, `getChildren()`, et `childExists()` sont implémentées pour retourner **toujours les deux mêmes enfants** :
        1.  Une instance de `RestoreTarget` (le dossier virtuel `restore` pour la restauration).
        2.  Une instance de `DeletedCalendarObjectsCollection` (le dossier `objects` qui liste les éléments supprimés).
    *   Elle agrège ces deux fonctionnalités en une structure de dossiers cohérente et prévisible pour les clients DAV.

3.  **Comportement Verrouillé (Lecture Seule)** :
    *   La corbeille elle-même ne peut être ni modifiée ni supprimée.
    *   Toutes les méthodes qui impliquent une modification lèvent une `Sabre\DAV\Exception\Forbidden` :
        *   `createFile()` / `createDirectory()`
        *   `delete()`
        *   `setName()`
        *   `propPatch()`

4.  **Exposition de Propriétés Spécifiques (`getProperties`)** :
    *   Cette méthode est cruciale pour l'auto-découverte par les clients. Elle retourne la propriété `{DAV:}resourcetype`.
    *   La valeur de cette propriété est un tableau contenant deux types :
        1.  `{DAV:}collection` : Indique que c'est un dossier.
        2.  `{http://nextcloud.com/ns}trash-bin` : C'est un **type de ressource personnalisé** spécifique à Nextcloud. Il sert de marqueur pour que les clients (comme l'interface web de Nextcloud) puissent identifier ce dossier comme étant la racine de la corbeille et afficher une interface utilisateur appropriée (par exemple, des boutons "Restaurer" et "Supprimer définitivement").

5.  **Gestion de la Propriété (`getOwner`)** :
    *   La classe identifie clairement son propriétaire en se basant sur les informations du principal (`$this->principalInfo`) passées à son constructeur. Ceci est essentiel pour que le système de permissions ACL puisse fonctionner correctement sur ce nœud et ses enfants.

## Dépendances

-   `OCA\DAV\CalDAV\CalDavBackend`: Cette dépendance est passée aux enfants qu'elle instancie (spécifiquement à `DeletedCalendarObjectsCollection`).
-   `array $principalInfo`: Contient les informations sur l'utilisateur propriétaire de la corbeille.

En résumé, `TrashbinHome` est la façade DAV de la corbeille. C'est un dossier statique et verrouillé qui assemble les composants fonctionnels (`objects` et `restore`) en une seule unité cohérente. Son rôle le plus important est de s'identifier comme une `{nc:trash-bin}` via son `resourcetype`, permettant une intégration transparente avec les clients qui supportent cette extension Nextcloud.
