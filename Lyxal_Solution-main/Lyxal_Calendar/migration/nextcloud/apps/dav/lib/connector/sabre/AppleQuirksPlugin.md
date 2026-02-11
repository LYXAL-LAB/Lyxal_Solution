# Analyse du Fichier `AppleQuirksPlugin.php` de Nextcloud

## Description

`AppleQuirksPlugin` est un plugin SabreDAV destiné à contourner des bugs ou des comportements spécifiques ("quirks") des clients DAV de macOS (Calendar, Contacts, etc.).

## Rôle et Responsabilités

### 1. Détection des Clients macOS
-   Analyse le User-Agent pour détecter s'il s'agit d'un agent macOS (`macOS/...`).
-   Décode la version de l'agent (ex: `CalendarAgent`, `dataaccessd`).

### 2. Correction des Requêtes REPORT (`report`)
-   **Problème** : Le client calendrier de macOS envoie parfois une requête `REPORT` de type `{DAV:}principal-property-search` sur une collection principale aléatoire, mais s'attend à trouver *tous* les principaux.
-   **Solution** : Si le plugin détecte ce cas, il force la propriété `applyToPrincipalCollectionSet` à `true` dans l'objet de rapport. Cela instruit SabreDAV de chercher dans l'ensemble des collections de principaux, et non juste celle ciblée.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `Sabre\DAVACL\Xml\Request\PrincipalPropertySearchReport` : L'objet de requête modifié.
