# Analyse de `OCA\DAV\CalDAV\UpcomingEvent`

## Description

`UpcomingEvent` est une classe de type DTO (Data Transfer Object) simple et pure. Son unique rôle est de servir de conteneur de données structuré pour représenter les informations essentielles d'un événement de calendrier à venir.

## Rôle et Responsabilités

1.  **Conteneur de Données** :
    *   La classe utilise un constructeur avec promotion des propriétés pour définir de manière concise un ensemble de propriétés privées en lecture seule.
    *   Elle encapsule les informations clés d'une occurrence d'événement :
        *   `uri`: L'identifiant de l'objet événement dans le backend CalDAV.
        *   `recurrenceId`: L'identifiant de l'occurrence spécifique pour les événements récurrents.
        *   `calendarUri`: L'identifiant du calendrier parent.
        *   `start`: Le timestamp UNIX du début de l'occurrence.
        *   `summary`: Le titre ou résumé de l'événement.
        *   `location`: Le lieu de l'événement.
        *   `calendarAppUrl`: Un lien direct pour visualiser l'événement dans l'interface de l'application Calendrier.
    *   Elle fournit des méthodes `get` publiques pour chaque propriété, respectant ainsi le principe d'encapsulation.

2.  **Sérialisation JSON** :
    *   Elle implémente l'interface native `JsonSerializable`.
    *   La méthode `jsonSerialize()` est implémentée pour permettre une conversion directe et contrôlée de l'objet en un tableau associatif.
    *   Cela rend la classe directement utilisable avec `json_encode()`, ce qui est idéal pour la construction de réponses d'API REST. La structure de la sortie JSON est ainsi clairement définie et couplée à la définition de la classe.

En résumé, `UpcomingEvent` est une classe "modèle" ou "entité" sans logique métier. C'est une structure de données qui facilite le passage d'informations sur un événement entre différentes couches de l'application (par exemple, d'un service de recherche vers un contrôleur d'API) de manière propre, typée et facilement sérialisable en JSON.
