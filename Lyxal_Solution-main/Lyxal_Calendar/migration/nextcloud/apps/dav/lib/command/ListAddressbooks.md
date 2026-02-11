# Analyse de `OCA\DAV\Command\ListAddressbooks`

## Description

`ListAddressbooks` est une commande console `occ` de consultation qui permet aux administrateurs de lister tous les carnets d'adresses associés à un utilisateur spécifique.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:list-addressbooks`
-   **Description** : "List all addressbooks of a user" (Lister tous les carnets d'adresses d'un utilisateur).

### Fonctionnement

1.  **Argument Requis** : La commande prend un argument unique et obligatoire :
    *   `uid` : L'identifiant de l'utilisateur pour lequel les carnets d'adresses doivent être listés.

2.  **Validation** : La commande vérifie d'abord que l'utilisateur spécifié existe.

3.  **Récupération des Données** :
    *   Elle appelle la méthode `getAddressBooksForUser()` du `CardDavBackend` pour obtenir la liste complète des carnets d'adresses. Cette liste inclut à la fois les carnets d'adresses appartenant à l'utilisateur et ceux qui ont été partagés avec lui par d'autres utilisateurs.

4.  **Traitement et Formatage** :
    *   La commande itère sur la liste des carnets d'adresses récupérés.
    *   **Filtrage** : Elle exclut explicitement de la liste le carnet d'adresses système (`SystemAddressbook::URI_SHARED`), car il ne s'agit pas d'un carnet d'adresses utilisateur standard.
    *   **Extraction des Données** : Pour chaque carnet d'adresses, elle extrait les informations les plus pertinentes :
        *   L'URI (le "nom" unique utilisé par d'autres commandes).
        *   Le nom d'affichage (`displayname`).
        *   Le "principal" du propriétaire (qui a partagé le carnet).
        *   Le nom d'affichage du propriétaire.
        *   Un indicateur pour savoir si le carnet est inscriptible (`Writable`) ou en lecture seule.

5.  **Affichage** :
    *   Si un ou plusieurs carnets d'adresses sont trouvés, les informations sont présentées à l'administrateur sous la forme d'un **tableau bien formaté** dans la console, ce qui facilite la lecture.
    *   Si l'utilisateur n'a aucun carnet d'adresses, un message informatif est affiché.

### Cas d'Usage

Cette commande est un outil d'administration essentiel pour :
-   Obtenir une vue d'ensemble rapide de tous les carnets d'adresses d'un utilisateur.
-   Trouver l'URI exact d'un carnet d'adresses, qui est souvent nécessaire comme argument pour d'autres commandes `occ` (comme `dav:delete-addressbook` si elle existait).
-   Vérifier les permissions (lecture/écriture) sur les carnets d'adresses partagés.

## Dépendances Clés

-   `OCP\IUserManager`: Pour valider l'existence de l'utilisateur.
-   `OCA\DAV\CardDAV\CardDavBackend`: Le service qui fournit la liste des carnets d'adresses.
-   `Symfony\Component\Console`: Le framework utilisé pour la structure de la commande et l'affichage du tableau.
