# Analyse de `OCA\DAV\CalDAV\Validation\CalDavValidatePlugin`

## Description

`CalDavValidatePlugin` est un plugin SabreDAV simple et ciblé dont l'unique responsabilité est d'appliquer une politique de validation sur les objets calendrier avant leur création ou mise à jour.

## Rôle et Responsabilités

1.  **Interception des Mises à Jour** :
    *   Le plugin s'enregistre pour écouter l'événement `beforeMethod:PUT`. Cet événement est déclenché par le serveur SabreDAV juste avant de traiter une requête `PUT`, qui est la méthode HTTP utilisée pour créer un nouvel objet calendrier ou pour remplacer un objet existant.

2.  **Validation de la Taille des Objets (`beforePut`)** :
    *   C'est la seule logique implémentée par le plugin.
    *   Il lit une valeur de configuration de l'application `dav` nommée `event_size_limit`. La valeur par défaut est de 10 Mo (10485760 octets).
    *   Il compare cette limite à la taille du corps de la requête entrante, qu'il obtient à partir de l'en-tête `CONTENT_LENGTH` de la requête HTTP.
    *   Si la taille de l'objet iCalendar envoyé par le client dépasse la limite configurée, le plugin lève une `Sabre\DAV\Exception\Forbidden`.
    *   Cette exception interrompt immédiatement le traitement de la requête et renvoie une réponse d'erreur au client (généralement un code de statut HTTP `403 Forbidden`), empêchant ainsi l'objet volumineux d'être sauvegardé.

## Objectif

Ce plugin agit comme un mécanisme de protection simple mais efficace. Il empêche les utilisateurs de téléverser des événements ou des tâches contenant des données excessivement volumineuses (par exemple, des pièces jointes encodées en base64 de très grande taille ou des données iCalendar malformées), ce qui pourrait consommer une quantité déraisonnable de stockage en base de données et de bande passante.

## Dépendances

-   `OCP\IAppConfig`: Pour lire la limite de taille depuis la configuration de l'application.
-   `Sabre\DAV\Server`: Pour s'abonner aux événements du cycle de vie des requêtes.
