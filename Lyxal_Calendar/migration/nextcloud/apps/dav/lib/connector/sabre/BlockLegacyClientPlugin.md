# Analyse du Fichier `BlockLegacyClientPlugin.php` de Nextcloud

## Description

`BlockLegacyClientPlugin` est un plugin de sécurité qui interdit l'accès aux clients de synchronisation Desktop jugés trop anciens ou trop récents (non supportés).

## Rôle et Responsabilités

### 1. Vérification de Version (`beforeHandler`)
-   Intercepte toutes les requêtes (`beforeMethod:*`).
-   Analyse le User-Agent pour extraire la version du client Desktop (`IRequest::USER_AGENT_CLIENT_DESKTOP`).
-   Compare cette version avec les bornes configurées :
    -   `minimum.supported.desktop.version` (défaut: 3.1.0).
    -   `maximum.supported.desktop.version` (défaut: 99.99.99).

### 2. Blocage
-   Si la version est hors des clous, lance une exception `Sabre\DAV\Exception\Forbidden` (403).
-   Le message d'erreur contient un lien HTML vers la page de téléchargement du client (`themingDefaults->getSyncClientUrl()`), incitant l'utilisateur à mettre à jour (ou downgrader).

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\IConfig` : Pour lire les versions supportées.
