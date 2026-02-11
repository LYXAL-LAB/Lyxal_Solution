# Analyse du Fichier `Server.php` de Nextcloud

## Description

`Server` étend la classe `Sabre\DAV\Server` standard. C'est le point d'entrée principal pour le traitement des requêtes WebDAV dans Nextcloud. Il surcharge certaines méthodes pour ajouter des fonctionnalités de débogage et de compatibilité.

## Rôle et Responsabilités

### 1. Surveillance des Performances (`monitorPropfindQueries`)
-   Si le mode debug est activé, il "wrappe" les callbacks des événements `propFind` pour mesurer le nombre de requêtes SQL exécutées par chaque plugin.
-   Stocke ces statistiques (`pluginQueries`) pour qu'elles puissent être analysées par `PropFindMonitorPlugin`.

### 2. Gestion des Erreurs (`start`)
-   Surcharge la méthode `start` pour capturer les exceptions fatales (`Throwable`).
-   Génère une réponse XML d'erreur standardisée (`d:error`) compatible avec WebDAV, incluant (si debug activé) la stack trace.
-   Gère spécifiquement les `TypeError` pour masquer les chemins de fichiers sensibles en production.

### 3. Compatibilité Proxy
-   Force la version HTTP de la réponse à correspondre à celle de la requête (utile pour Nginx en mode proxy).
-   Définit explicitement l'URL de base (`setBaseUrl`) pour gérer les configurations de reverse-proxy complexes.

## Dépendances Clés
-   `Sabre\DAV\Server` : Classe parente.
-   `OC\DB\Connection` : Pour compter les requêtes SQL.
