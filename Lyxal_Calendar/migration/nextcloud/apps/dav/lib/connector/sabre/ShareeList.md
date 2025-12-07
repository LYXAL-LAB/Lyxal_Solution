# Analyse du Fichier `ShareeList.php` de Nextcloud

## Description

`ShareeList` est une classe de propriété WebDAV qui liste les bénéficiaires (sharees) d'un partage. Elle est utilisée pour fournir des détails riches sur les personnes avec qui un fichier est partagé.

## Rôle et Responsabilités

### 1. Transport de Données
-   Contient une liste d'objets `IShare`.

### 2. Sérialisation XML (`xmlSerialize`)
-   Génère une structure XML complexe pour la propriété `{http://nextcloud.org/ns}sharees`.
-   Pour chaque partage, crée un élément `<nc:sharee>` contenant :
    -   `<nc:id>` : ID de l'utilisateur/groupe bénéficiaire.
    -   `<nc:display-name>` : Nom d'affichage.
    -   `<nc:type>` : Type de partage.

## Dépendances Clés
-   `Sabre\Xml\XmlSerializable` : Interface SabreDAV.
-   `OCP\Share\IShare` : Interface de partage Nextcloud.
