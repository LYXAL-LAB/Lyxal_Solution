# Analyse du Fichier `MultiGetExportPlugin.php` de Nextcloud

## Description

`MultiGetExportPlugin` est un plugin SabreDAV conçu pour optimiser l'exportation massive de contacts. Il intercepte certaines requêtes `REPORT` (utilisées pour le `multiget` CardDAV) et permet de retourner un fichier VCF unique concaténé au lieu d'une réponse XML verbeuse.

## Rôle et Responsabilités

### 1. Interception REPORT
-   S'abonne à l'événement `afterMethod:REPORT`.
-   Vérifie si la requête contient le paramètre `?export`.
-   Vérifie si le `Content-Type` de la réponse est XML (ce qui est le cas pour une réponse CardDAV standard).

### 2. Transformation en VCF Unique
-   Si les conditions sont réunies, il parse la réponse XML générée par SabreDAV.
-   Il extrait le contenu VCard (`address-data`) de chaque élément de la réponse.
-   Il concatène toutes ces VCards en une seule longue chaîne de caractères.

### 3. Réponse Téléchargeable
-   Remplace le corps de la réponse par cette chaîne concaténée.
-   Définit les en-têtes pour forcer le téléchargement d'un fichier `.vcf` (`Content-Disposition: attachment`).
-   Change le type MIME en `text/vcard`.

## Cas d'Usage
-   Utilisé par l'interface web Nextcloud lorsqu'un utilisateur sélectionne plusieurs contacts (ou tous) et clique sur "Télécharger" / "Exporter". Cela évite au frontend de devoir faire N requêtes ou de parser du XML complexe.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `Sabre\DAV\Xml\Service` : Pour parser la réponse XML intermédiaire.
