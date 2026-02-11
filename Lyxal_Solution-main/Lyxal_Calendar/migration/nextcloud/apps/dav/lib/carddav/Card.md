# Analyse du Fichier `Card.php` de Nextcloud

## Description

`Card` est une extension de la classe standard `\Sabre\CardDAV\Card`. Elle représente une fiche contact individuelle (un fichier VCF) au sein d'un carnet d'adresses.

## Rôle et Responsabilités

### 1. Accès aux Métadonnées
-   Fournit des accesseurs typés pour les propriétés internes du contact stockées en base :
    -   `getId()` : L'ID numérique interne.
    -   `getUri()` : Le nom de fichier (ex: `uuid.vcf`).
    -   `getAddressbookId()` : L'ID du carnet parent.
    -   `getPrincipalUri()` : L'URI du propriétaire.

### 2. Gestion du Propriétaire (`getOwner`)
-   Surcharge la méthode standard pour gérer les carnets partagés.
-   Si la propriété `{http://owncloud.org/ns}owner-principal` est définie (cas d'un partage), elle retourne le véritable propriétaire, sinon elle retourne le propriétaire par défaut (parent).

### 3. Détection de Partage (`isShared`)
-   Détermine si cette carte fait partie d'un carnet partagé en comparant l'URI du principal courant avec le propriétaire réel de la carte.

## Dépendances Clés
-   `Sabre\CardDAV\Card` : Classe parente.
