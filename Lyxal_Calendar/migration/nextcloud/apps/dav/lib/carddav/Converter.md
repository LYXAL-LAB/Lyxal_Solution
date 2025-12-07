# Analyse du Fichier `Converter.php` de Nextcloud

## Description

`Converter` est une classe utilitaire spécialisée dans la transformation d'un **Utilisateur Nextcloud** (`IUser`) en une **VCard CardDAV**. Elle est essentielle pour générer le "Carnet d'adresses système".

## Rôle et Responsabilités

### 1. Conversion User -> VCard (`createCardFromUser`)
-   Elle prend un objet `IUser` et crée un objet `VCard` (SabreDAV) correspondant.
-   **Propriétés Mappées** :
    -   `FN` (Full Name) et `N` (Name) : À partir du nom d'affichage.
    -   `PHOTO` : À partir de l'avatar de l'utilisateur.
    -   `EMAIL` : Adresse email.
    -   `TEL` : Numéro de téléphone.
    -   `ADR` : Adresse postale.
    -   `ORG`, `TITLE`, `NOTE` : Organisation, Rôle, Biographie.
    -   `URL` : Site web.
    -   `BDAY` : Date de naissance.
    -   `X-SOCIALPROFILE` : Comptes Twitter/X et lien vers le profil Nextcloud.
    -   `CLOUD` : L'identifiant fédéré (Cloud ID).

### 2. Gestion de la Confidentialité (Scope)
-   Pour chaque propriété, elle vérifie le **Scope** (visibilité) défini par l'utilisateur dans ses paramètres de profil (Public, Contacts uniquement, Privé).
-   **Filtrage** : Les données privées (`SCOPE_PRIVATE`) sont purement et simplement exclues de la VCard générée.
-   **Métadonnées** : Elle ajoute un paramètre `X-NC-SCOPE` aux propriétés VCard pour conserver cette information de visibilité.

### 3. Utilitaires
-   **`splitFullName`** : Une heuristique simple pour découper un nom complet ("Jean Dupont") en Prénom/Nom/Intermédiaire pour le champ `N` de la VCard.

## Dépendances Clés
-   `IAccountManager` : Pour récupérer toutes les propriétés du profil utilisateur et leurs scopes.
-   `IUser` : L'utilisateur source.
-   `Sabre\VObject\Component\VCard` : La structure de données cible.
